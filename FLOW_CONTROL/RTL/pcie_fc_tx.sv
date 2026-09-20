`timescale 1ns/1ps

// ============================================================================
// pcie_fc_tx : transmit side of the credit-based flow control
//
//   * keeps PH / PD credit counters for every VC
//   * a TLP may be sent only if  PH >= 1  AND  PD >= ceil(bytes/16)
//   * credits are consumed ONLY when the TLP really transfers (valid && ready)
//   * credits come from:  fc_init_*   (start-up value)
//                         fc_update_* (RX tells us how much space it has now)
// ============================================================================
module pcie_fc_tx #(
    parameter int NUM_VC            = 2,
    parameter int VC_W              = 1,    // bits needed to index a VC
    parameter int BYTES_W           = 10,   // width of a byte count
    parameter int PH_W              = 4,    // PH counter width (max 4 used)
    parameter int PD_W              = 5,    // PD counter width (max 16 used)
    parameter int DATA_CREDIT_BYTES = 16    // 1 PD credit = 16 bytes
) (
    input  logic               clk,
    input  logic               rst_n,

    // ---- application side ----
    input  logic               app_tx_valid,
    output logic               app_tx_ready,
    input  logic [VC_W-1:0]    app_tx_vc,
    input  logic [BYTES_W-1:0] app_tx_bytes,

    // ---- TLP link side (goes to the remote RX) ----
    output logic               tlp_valid,
    input  logic               tlp_ready,
    output logic [VC_W-1:0]    tlp_vc,
    output logic [BYTES_W-1:0] tlp_bytes,

    // ---- credit initialisation (educational replacement for FC_INIT) ----
    input  logic               fc_init_valid,
    input  logic [VC_W-1:0]    fc_init_vc,
    input  logic [PH_W-1:0]    fc_init_ph,
    input  logic [PD_W-1:0]    fc_init_pd,

    // ---- FC update coming back from the remote RX ----
    input  logic               fc_update_valid,
    input  logic [VC_W-1:0]    fc_update_vc,
    input  logic [PH_W-1:0]    fc_update_ph,
    input  logic [PD_W-1:0]    fc_update_pd,

    // ---- credit counters (outputs so the testbench can look at them) ----
    output logic [PH_W-1:0]    ph_credit [NUM_VC],
    output logic [PD_W-1:0]    pd_credit [NUM_VC]
);

    // ------------------------------------------------------------------
    // 1. How many PD credits does this request need?   ceil(bytes / 16)
    //    e.g. 15B -> 1, 16B -> 1, 17B -> 2, 128B -> 8
    // ------------------------------------------------------------------
    logic [PD_W-1:0] required_pd;
    assign required_pd = PD_W'((32'(app_tx_bytes) + DATA_CREDIT_BYTES - 1) / DATA_CREDIT_BYTES);

    // ------------------------------------------------------------------
    // 2. Credit check for the VC the application asked for.
    //    Only the selected VC is looked at -> VCs are independent.
    // ------------------------------------------------------------------
    logic ph_ok, pd_ok, credit_ok;
    assign ph_ok     = (ph_credit[app_tx_vc] >= PH_W'(1));
    assign pd_ok     = (pd_credit[app_tx_vc] >= required_pd);
    assign credit_ok = ph_ok && pd_ok;

    // ------------------------------------------------------------------
    // 3. Handshake.
    //    No credit  -> tlp_valid = 0 and app_tx_ready = 0  (TX blocks)
    //    Credit ok  -> present the TLP; it moves when the RX says ready.
    // ------------------------------------------------------------------
    assign tlp_valid    = app_tx_valid && credit_ok;
    assign tlp_vc       = app_tx_vc;
    assign tlp_bytes    = app_tx_bytes;
    assign app_tx_ready = credit_ok && tlp_ready;

    logic tlp_fire;                              // the TLP really transfers now
    assign tlp_fire = tlp_valid && tlp_ready;

    // ------------------------------------------------------------------
    // 4. Next value of every credit counter.
    //    Order matters (later statements win):
    //      a) FC update : counter = value reported by RX
    //      b) TLP sent  : counter = counter - what this TLP used
    //      c) FC init   : counter = start-up value
    //    (b) after (a) handles "update and send in the same cycle":
    //    the RX's number does not yet include the TLP being sent now,
    //    so we subtract it here.
    // ------------------------------------------------------------------
    logic [PH_W-1:0] ph_next [NUM_VC];
    logic [PD_W-1:0] pd_next [NUM_VC];

    always_comb begin
        for (int i = 0; i < NUM_VC; i++) begin
            ph_next[i] = ph_credit[i];
            pd_next[i] = pd_credit[i];
        end

        if (fc_update_valid) begin
            ph_next[fc_update_vc] = fc_update_ph;
            pd_next[fc_update_vc] = fc_update_pd;
        end

        if (tlp_fire) begin
            ph_next[tlp_vc] = ph_next[tlp_vc] - PH_W'(1);
            pd_next[tlp_vc] = pd_next[tlp_vc] - required_pd;
        end

        if (fc_init_valid) begin
            ph_next[fc_init_vc] = fc_init_ph;
            pd_next[fc_init_vc] = fc_init_pd;
        end
    end

    // ------------------------------------------------------------------
    // 5. Credit registers. After reset they are 0 -> TX cannot send
    //    anything until credits are initialised.
    // ------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < NUM_VC; i++) begin
                ph_credit[i] <= '0;
                pd_credit[i] <= '0;
            end
        end else begin
            for (int i = 0; i < NUM_VC; i++) begin
                ph_credit[i] <= ph_next[i];
                pd_credit[i] <= pd_next[i];
            end
        end
    end

    // ------------------------------------------------------------------
    // 6. Assertions (simulation only)
    //    Because the counters are unsigned, "never negative" means
    //    "never subtract more than we have".
    // ------------------------------------------------------------------
`ifndef SYNTHESIS
    always @(posedge clk) begin
        if (rst_n && tlp_valid) begin
            assert (ph_credit[tlp_vc] >= PH_W'(1))
                else $error("ASSERT: TX offered a TLP with no PH credit (vc=%0d)", tlp_vc);
            assert (pd_credit[tlp_vc] >= required_pd)
                else $error("ASSERT: TX offered a TLP without enough PD credit (vc=%0d)", tlp_vc);
        end
    end
`endif

endmodule
