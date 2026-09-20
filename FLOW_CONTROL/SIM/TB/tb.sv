
`timescale 1ns/1ps

// ============================================================================
// tb_pcie_fc : self-checking testbench
//
//        Endpoint A                         Endpoint B
//     TX  ------------- TLP ------------->  RX
//     RX  <------------ TLP -------------   TX
//     TX  <---------- FC update ----------  RX      (A->B traffic)
//     RX  ----------- FC update --------->  TX      (B->A traffic)
//
// Timing style (keeps things race-free):
//   * inputs are driven on the FALLING clock edge
//   * DUT registers sample them on the next RISING edge
//   * results are looked at on the following falling edge
// ============================================================================
module tb;

    // ------------------------------------------------------------------
    // Clock / reset : 10 ns period, active-low reset
    // ------------------------------------------------------------------
    logic clk;
    logic rst_n;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ------------------------------------------------------------------
    // Signals of endpoint A
    // ------------------------------------------------------------------
    logic       a_app_valid, a_app_ready, a_app_vc;
    logic [9:0] a_app_bytes;
    logic       a_cons_valid, a_cons_vc;
    logic [9:0] a_cons_bytes;
    logic       a_init_valid, a_init_vc;
    logic [3:0] a_init_ph;
    logic [4:0] a_init_pd;

    logic       a_tx_valid, a_tx_ready, a_tx_vc;      // link TX
    logic [9:0] a_tx_bytes;
    logic       a_rx_valid, a_rx_ready, a_rx_vc;      // link RX
    logic [9:0] a_rx_bytes;

    logic       a_upd_out_valid, a_upd_out_vc;        // A's RX -> B's TX
    logic [3:0] a_upd_out_ph;
    logic [4:0] a_upd_out_pd;
    logic       a_upd_in_valid, a_upd_in_vc;          // B's RX -> A's TX
    logic [3:0] a_upd_in_ph;
    logic [4:0] a_upd_in_pd;

    logic [3:0] a_ph   [2];                           // A's TX credits
    logic [4:0] a_pd   [2];
    logic [9:0] a_used [2];                           // A's RX occupancy

    // ------------------------------------------------------------------
    // Signals of endpoint B
    // ------------------------------------------------------------------
    logic       b_app_valid, b_app_ready, b_app_vc;
    logic [9:0] b_app_bytes;
    logic       b_cons_valid, b_cons_vc;
    logic [9:0] b_cons_bytes;
    logic       b_init_valid, b_init_vc;
    logic [3:0] b_init_ph;
    logic [4:0] b_init_pd;

    logic       b_tx_valid, b_tx_ready, b_tx_vc;
    logic [9:0] b_tx_bytes;
    logic       b_rx_valid, b_rx_ready, b_rx_vc;
    logic [9:0] b_rx_bytes;

    logic       b_upd_out_valid, b_upd_out_vc;
    logic [3:0] b_upd_out_ph;
    logic [4:0] b_upd_out_pd;
    logic       b_upd_in_valid, b_upd_in_vc;
    logic [3:0] b_upd_in_ph;
    logic [4:0] b_upd_in_pd;

    logic [3:0] b_ph   [2];
    logic [4:0] b_pd   [2];
    logic [9:0] b_used [2];

    logic [31:0] test_cnt;

    // ------------------------------------------------------------------
    // Test-only probe on B's RX input. When inj_en = 1 the testbench (not
    // A's TX) drives B's RX link, so we can offer a TLP that A's TX would
    // never send (it has no credit) and check that RX says "not ready".
    // ------------------------------------------------------------------
    logic       inj_en, inj_valid, inj_vc;
    logic [9:0] inj_bytes;

    // ------------------------------------------------------------------
    // Wiring between the endpoints
    // ------------------------------------------------------------------
    // A TX -> B RX
    assign b_rx_valid = inj_en ? inj_valid : a_tx_valid;
    assign b_rx_vc    = inj_en ? inj_vc    : a_tx_vc;
    assign b_rx_bytes = inj_en ? inj_bytes : a_tx_bytes;
    assign a_tx_ready = b_rx_ready;

    // B TX -> A RX
    assign a_rx_valid = b_tx_valid;
    assign a_rx_vc    = b_tx_vc;
    assign a_rx_bytes = b_tx_bytes;
    assign b_tx_ready = a_rx_ready;

    // FC updates travel in the reverse direction of the TLPs
    assign a_upd_in_valid = b_upd_out_valid;   // B's RX  -> A's TX
    assign a_upd_in_vc    = b_upd_out_vc;
    assign a_upd_in_ph    = b_upd_out_ph;
    assign a_upd_in_pd    = b_upd_out_pd;

    assign b_upd_in_valid = a_upd_out_valid;   // A's RX  -> B's TX
    assign b_upd_in_vc    = a_upd_out_vc;
    assign b_upd_in_ph    = a_upd_out_ph;
    assign b_upd_in_pd    = a_upd_out_pd;

    // ------------------------------------------------------------------
    // Device under test: two endpoints
    // ------------------------------------------------------------------
    pcie_fc_endpoint u_ep_a (
        .clk(clk), .rst_n(rst_n),
        .app_tx_valid(a_app_valid), .app_tx_ready(a_app_ready),
        .app_tx_vc(a_app_vc),       .app_tx_bytes(a_app_bytes),
        .rx_consume_valid(a_cons_valid), .rx_consume_vc(a_cons_vc),
        .rx_consume_bytes(a_cons_bytes),
        .tx_tlp_valid(a_tx_valid), .tx_tlp_ready(a_tx_ready),
        .tx_tlp_vc(a_tx_vc),       .tx_tlp_bytes(a_tx_bytes),
        .rx_tlp_valid(a_rx_valid), .rx_tlp_ready(a_rx_ready),
        .rx_tlp_vc(a_rx_vc),       .rx_tlp_bytes(a_rx_bytes),
        .fc_update_out_valid(a_upd_out_valid), .fc_update_out_vc(a_upd_out_vc),
        .fc_update_out_ph(a_upd_out_ph),       .fc_update_out_pd(a_upd_out_pd),
        .fc_update_in_valid(a_upd_in_valid),   .fc_update_in_vc(a_upd_in_vc),
        .fc_update_in_ph(a_upd_in_ph),         .fc_update_in_pd(a_upd_in_pd),
        .fc_init_valid(a_init_valid), .fc_init_vc(a_init_vc),
        .fc_init_ph(a_init_ph),       .fc_init_pd(a_init_pd),
        .tx_ph_credit(a_ph), .tx_pd_credit(a_pd), .rx_used_bytes(a_used)
    );

    pcie_fc_endpoint u_ep_b (
        .clk(clk), .rst_n(rst_n),
        .app_tx_valid(b_app_valid), .app_tx_ready(b_app_ready),
        .app_tx_vc(b_app_vc),       .app_tx_bytes(b_app_bytes),
        .rx_consume_valid(b_cons_valid), .rx_consume_vc(b_cons_vc),
        .rx_consume_bytes(b_cons_bytes),
        .tx_tlp_valid(b_tx_valid), .tx_tlp_ready(b_tx_ready),
        .tx_tlp_vc(b_tx_vc),       .tx_tlp_bytes(b_tx_bytes),
        .rx_tlp_valid(b_rx_valid), .rx_tlp_ready(b_rx_ready),
        .rx_tlp_vc(b_rx_vc),       .rx_tlp_bytes(b_rx_bytes),
        .fc_update_out_valid(b_upd_out_valid), .fc_update_out_vc(b_upd_out_vc),
        .fc_update_out_ph(b_upd_out_ph),       .fc_update_out_pd(b_upd_out_pd),
        .fc_update_in_valid(b_upd_in_valid),   .fc_update_in_vc(b_upd_in_vc),
        .fc_update_in_ph(b_upd_in_ph),         .fc_update_in_pd(b_upd_in_pd),
        .fc_init_valid(b_init_valid), .fc_init_vc(b_init_vc),
        .fc_init_ph(b_init_ph),       .fc_init_pd(b_init_pd),
        .tx_ph_credit(b_ph), .tx_pd_credit(b_pd), .rx_used_bytes(b_used)
    );

    // ------------------------------------------------------------------
    // Small helpers.  ep: 0 = endpoint A, 1 = endpoint B
    // ------------------------------------------------------------------
    int errors;
    int last_errors;

    function automatic int tx_ph(input int ep, input int vc);      // TX PH credits
        if (ep == 0) return int'(a_ph[vc]);
        else         return int'(b_ph[vc]);
    endfunction

    function automatic int tx_pd(input int ep, input int vc);      // TX PD credits
        if (ep == 0) return int'(a_pd[vc]);
        else         return int'(b_pd[vc]);
    endfunction

    function automatic int rx_used(input int ep, input int vc);    // RX bytes in use
        if (ep == 0) return int'(a_used[vc]);
        else         return int'(b_used[vc]);
    endfunction

    task automatic check(input logic cond, input string msg);
        if (!cond) begin
            errors = errors + 1;
            $error("TEST FAILED: %s", msg);
        end
    endtask

    task automatic end_test(input int n);
        if (errors == last_errors) $display("TEST %0d PASS", n);
        else                       $display("TEST %0d FAIL", n);
        last_errors = errors;
        test_cnt++;
    endtask

    // ------------------------------------------------------------------
    // Drive one clock cycle of traffic on A and/or B at the same time.
    // Returns, for each side, whether the TLP really transferred (fire)
    // and whether TX offered a TLP on the link (tlpv).
    // ------------------------------------------------------------------
    task automatic try_send2(
        input  logic a_v, input int a_vc_i, input int a_n,
        input  logic b_v, input int b_vc_i, input int b_n,
        output logic a_fire, output logic a_tlpv,
        output logic b_fire, output logic b_tlpv);

        @(negedge clk);
        a_app_valid = a_v;  a_app_vc = 1'(a_vc_i);  a_app_bytes = 10'(a_n);
        b_app_valid = b_v;  b_app_vc = 1'(b_vc_i);  b_app_bytes = 10'(b_n);
        #1;                                    // let combinational logic settle
        a_tlpv = a_tx_valid;
        b_tlpv = b_tx_valid;
        a_fire = a_app_valid && a_app_ready;   // valid && ready = transfer
        b_fire = b_app_valid && b_app_ready;
        @(negedge clk);                        // the rising edge in between did the transfer
        a_app_valid = 1'b0;
        b_app_valid = 1'b0;
    endtask

    // Send from one endpoint only
    task automatic try_send(input int ep, input int vc, input int n,
                            output logic fire, output logic tlpv);
        logic a_f, a_t, b_f, b_t;
        if (ep == 0) begin
            try_send2(1'b1, vc, n, 1'b0, 0, 0, a_f, a_t, b_f, b_t);
            fire = a_f;  tlpv = a_t;
        end else begin
            try_send2(1'b0, 0, 0, 1'b1, vc, n, a_f, a_t, b_f, b_t);
            fire = b_f;  tlpv = b_t;
        end
    endtask

    // Application of endpoint 'ep' consumes n bytes (one TLP) from its RX.
    // Also returns the FC update that RX sent out.
    task automatic consume(input int ep, input int vc, input int n,
                           output logic uv, output logic uvc,
                           output logic [3:0] uph, output logic [4:0] upd);
        @(negedge clk);
        if (ep == 0) begin
            a_cons_valid = 1'b1;  a_cons_vc = 1'(vc);  a_cons_bytes = 10'(n);
        end else begin
            b_cons_valid = 1'b1;  b_cons_vc = 1'(vc);  b_cons_bytes = 10'(n);
        end
        @(negedge clk);                        // RX registered the FC update at the edge
        if (ep == 0) begin
            uv = a_upd_out_valid;  uvc = a_upd_out_vc;
            uph = a_upd_out_ph;    upd = a_upd_out_pd;
        end else begin
            uv = b_upd_out_valid;  uvc = b_upd_out_vc;
            uph = b_upd_out_ph;    upd = b_upd_out_pd;
        end
        a_cons_valid = 1'b0;
        b_cons_valid = 1'b0;
        @(negedge clk);                        // remote TX applied the update at the edge
    endtask

    // Offer a TLP straight to B's RX (bypassing A's TX) and read rx_ready.
    // v = 0 : just look at ready.   v = 1 : really present the TLP.
    task automatic probe_b_rx(input int vc, input int n, input logic v,
                              output logic ready);
        @(negedge clk);
        inj_en = 1'b1;  inj_valid = v;  inj_vc = 1'(vc);  inj_bytes = 10'(n);
        #1;
        ready = b_rx_ready;
        @(negedge clk);
        inj_en = 1'b0;  inj_valid = 1'b0;
    endtask

    // Load start-up credits into both endpoints (one VC per cycle)
    task automatic init_credits();
        @(negedge clk);
        a_init_valid = 1'b1;  a_init_vc = 1'b0;  a_init_ph = 4'd4;  a_init_pd = 5'd16;
        b_init_valid = 1'b1;  b_init_vc = 1'b0;  b_init_ph = 4'd4;  b_init_pd = 5'd16;
        @(negedge clk);
        a_init_vc = 1'b1;
        b_init_vc = 1'b1;
        @(negedge clk);
        a_init_valid = 1'b0;
        b_init_valid = 1'b0;
    endtask

    // Fresh start: reset both endpoints, then initialise credits
    task automatic reset_and_init();
        @(negedge clk);
        rst_n = 1'b0;
        @(negedge clk);
        @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        init_credits();
    endtask

    // ------------------------------------------------------------------
    // The tests
    // ------------------------------------------------------------------
    logic       fire, tlpv, ready;
    logic       uv, uvc;
    logic [3:0] uph;
    logic [4:0] upd;
    logic       a_fire, a_tlpv, b_fire, b_tlpv;
    int         sizes  [6];
    int         exp_pd [6];
    int         k;

    initial begin
        test_cnt = 0;
        // quiet defaults
        errors      = 0;
        last_errors = 0;
        rst_n       = 1'b0;
        a_app_valid = 1'b0;  a_app_vc = 1'b0;  a_app_bytes = '0;
        b_app_valid = 1'b0;  b_app_vc = 1'b0;  b_app_bytes = '0;
        a_cons_valid = 1'b0; a_cons_vc = 1'b0; a_cons_bytes = '0;
        b_cons_valid = 1'b0; b_cons_vc = 1'b0; b_cons_bytes = '0;
        a_init_valid = 1'b0; a_init_vc = 1'b0; a_init_ph = '0; a_init_pd = '0;
        b_init_valid = 1'b0; b_init_vc = 1'b0; b_init_ph = '0; b_init_pd = '0;
        inj_en = 1'b0;  inj_valid = 1'b0;  inj_vc = 1'b0;  inj_bytes = '0;

        repeat (3) @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        init_credits();
        @(negedge clk);

        // ---------------- TEST 1 : initial credits ----------------
        check(tx_ph(0,0) == 4  && tx_pd(0,0) == 16, "A VC0 initial credits");
        check(tx_ph(0,1) == 4  && tx_pd(0,1) == 16, "A VC1 initial credits");
        check(tx_ph(1,0) == 4  && tx_pd(1,0) == 16, "B VC0 initial credits");
        check(tx_ph(1,1) == 4  && tx_pd(1,1) == 16, "B VC1 initial credits");
        end_test(1);

        // ---------------- TEST 2 : send 128B on VC0 ----------------
        try_send(0, 0, 128, fire, tlpv);
        check(fire,               "T2: 128B TLP should transfer");
        check(tx_ph(0,0) == 3,    "T2: PH should go 4 -> 3");
        check(tx_pd(0,0) == 8,    "T2: PD should go 16 -> 8");
        check(rx_used(1,0) == 128,"T2: B RX VC0 should hold 128B");
        end_test(2);

        // ---------------- TEST 3 : another 128B on VC0 ----------------
        try_send(0, 0, 128, fire, tlpv);
        check(fire,               "T3: second 128B TLP should transfer");
        check(tx_pd(0,0) == 0,    "T3: PD should go 8 -> 0");
        check(tx_ph(0,0) == 2,    "T3: PH should go 3 -> 2");
        check(rx_used(1,0) == 256,"T3: B RX VC0 should be full (256B)");
        end_test(3);

        // ---------------- TEST 4 : 64B needs 4 PD, has 0 -> block ----------------
        try_send(0, 0, 64, fire, tlpv);
        check(!tlpv,              "T4: tlp_valid must stay 0 (blocked)");
        check(!fire,              "T4: TLP must not transfer");
        check(tx_pd(0,0) == 0,    "T4: PD must be unchanged");
        check(tx_ph(0,0) == 2,    "T4: PH must be unchanged");
        check(rx_used(1,0) == 256,"T4: RX must be unchanged");
        end_test(4);

        // ---------------- TEST 5 : consume 128B -> FC update ----------------
        consume(1, 0, 128, uv, uvc, uph, upd);
        check(uv,                 "T5: FC update must be sent");
        check(uvc == 1'b0,        "T5: FC update must be for VC0");
        check(upd == 5'd8,        "T5: FC update PD must be 8");
        check(uph == 4'd3,        "T5: FC update PH must be 3");
        check(rx_used(1,0) == 128,"T5: RX should now hold 128B");
        check(tx_pd(0,0) == 8,    "T5: A's TX PD credit must be 8 after update");
        check(tx_ph(0,0) == 3,    "T5: A's TX PH credit must be 3 after update");
        end_test(5);

        // ---------------- TEST 6 : send 64B after the update ----------------
        try_send(0, 0, 64, fire, tlpv);
        check(tlpv && fire,       "T6: TX should resume and send 64B");
        check(tx_pd(0,0) == 4,    "T6: PD should go 8 -> 4");
        check(tx_ph(0,0) == 2,    "T6: PH should go 3 -> 2");
        end_test(6);

        // ---------------- TEST 7 : VC isolation ----------------
        try_send(0, 0, 64, fire, tlpv);                 // VC0: PD 4 -> 0
        check(fire && tx_pd(0,0) == 0, "T7: VC0 credits should be exhausted");
        try_send(0, 0, 16, fire, tlpv);                 // VC0 is dry
        check(!tlpv && !fire,     "T7: VC0 must be blocked");
        try_send(0, 1, 128, fire, tlpv);                // VC1 still has credits
        check(tlpv && fire,       "T7: VC1 must still transmit");
        check(tx_pd(0,1) == 8,    "T7: VC1 PD should go 16 -> 8");
        check(tx_ph(0,1) == 3,    "T7: VC1 PH should go 4 -> 3");
        check(tx_pd(0,0) == 0,    "T7: VC0 PD must be untouched by VC1 traffic");
        end_test(7);

        // ---------------- TEST 8 : RX buffer full ----------------
        reset_and_init();
        try_send(0, 0, 128, fire, tlpv);
        try_send(0, 0, 128, fire, tlpv);                // VC0 RX now 256B
        try_send(0, 1, 128, fire, tlpv);                // VC1 RX now 128B
        check(rx_used(1,0) == 256, "T8: VC0 RX should be full");
        check(rx_used(1,1) == 128, "T8: VC1 RX should hold 128B");

        probe_b_rx(0, 16, 1'b1, ready);                 // full buffer, even 16B is refused
        check(!ready,              "T8: RX ready must be 0 when VC0 buffer is full");
        check(rx_used(1,0) == 256, "T8: refused TLP must not change occupancy");

        probe_b_rx(1, 128, 1'b0, ready);                // 128B fits in the 128B left on VC1
        check(ready,               "T8: VC1 RX must be ready for 128B");
        probe_b_rx(1, 129, 1'b0, ready);                // 129B needs 144B of slots -> no room
        check(!ready,              "T8: VC1 RX must refuse 129B");
        end_test(8);

        // ---------------- TEST 9 : different packet sizes ----------------
        sizes[0] = 16;  sizes[1] = 32;  sizes[2] = 64;  sizes[3] = 128;  sizes[4] = 256;
        for (k = 0; k < 5; k = k + 1) begin
            reset_and_init();
            try_send(0, 0, sizes[k], fire, tlpv);
            check(fire,                            "T9: TLP should transfer");
            check(tx_pd(0,0) == 16 - sizes[k]/16,  "T9: wrong PD consumption");
            check(tx_ph(0,0) == 3,                 "T9: exactly 1 PH must be used");
            check(rx_used(1,0) == sizes[k],        "T9: RX occupancy must equal TLP size");
            check(tx_pd(0,1) == 16,                "T9: VC1 must be untouched");
        end
        end_test(9);

        // ---------------- TEST 10 : boundary sizes ----------------
        sizes[0] = 15;  sizes[1] = 16;  sizes[2] = 17;
        sizes[3] = 31;  sizes[4] = 32;  sizes[5] = 33;
        exp_pd[0] = 1;  exp_pd[1] = 1;  exp_pd[2] = 2;
        exp_pd[3] = 2;  exp_pd[4] = 2;  exp_pd[5] = 3;
        for (k = 0; k < 6; k = k + 1) begin
            reset_and_init();
            try_send(0, 0, sizes[k], fire, tlpv);
            check(fire,                          "T10: TLP should transfer");
            check(tx_pd(0,0) == 16 - exp_pd[k],  "T10: required_pd != ceil(bytes/16)");
            check(rx_used(1,0) == exp_pd[k]*16,  "T10: RX must reserve whole 16B slots");
        end
        end_test(10);

        // ---------------- TEST 11 : bidirectional traffic ----------------
        reset_and_init();
        // A->B 128B on VC0 and B->A 64B on VC1 in the SAME cycle
        try_send2(1'b1, 0, 128, 1'b1, 1, 64, a_fire, a_tlpv, b_fire, b_tlpv);
        check(a_fire && b_fire,   "T11: both directions must transfer");
        check(tx_pd(0,0) == 8  && tx_ph(0,0) == 3, "T11: A VC0 credits");
        check(tx_pd(1,1) == 12 && tx_ph(1,1) == 3, "T11: B VC1 credits");
        check(tx_pd(0,1) == 16 && tx_pd(1,0) == 16, "T11: other VCs untouched");
        check(rx_used(1,0) == 128 && rx_used(0,1) == 64, "T11: RX occupancy of both sides");

        // second round: A drains VC0, B keeps going on VC1
        try_send2(1'b1, 0, 128, 1'b1, 1, 128, a_fire, a_tlpv, b_fire, b_tlpv);
        check(a_fire && b_fire,   "T11: second round must transfer");
        check(tx_pd(0,0) == 0 && tx_pd(1,1) == 4, "T11: credits after second round");

        // A is out of VC0 credits (blocked), B still has VC1 credits (sends)
        try_send2(1'b1, 0, 64, 1'b1, 1, 64, a_fire, a_tlpv, b_fire, b_tlpv);
        check(!a_tlpv && !a_fire, "T11: A must block");
        check(b_tlpv  &&  b_fire, "T11: B must not be affected by A's block");
        check(tx_pd(0,0) == 0 && tx_pd(1,1) == 0, "T11: credits after block test");

        // B's application frees VC0 data -> only A's TX gets credits back
        consume(1, 0, 128, uv, uvc, uph, upd);
        check(tx_pd(0,0) == 8,    "T11: A TX must receive the credits");
        check(tx_pd(1,1) == 0,    "T11: B TX must not change");
        end_test(11);

        // ---------------- summary ----------------
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d CHECK(S) FAILED", errors);
        $finish;
    end

  initial begin
     $dumpfile("flow_ctrl.vcd");
     $dumpvars();
  end


endmodule
