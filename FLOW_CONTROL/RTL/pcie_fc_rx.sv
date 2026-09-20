`timescale 1ns/1ps

// ============================================================================
// pcie_fc_rx : receive side of the credit-based flow control
//
//   * tracks how many bytes (and how many headers) are in use, per VC
//   * tlp_ready = 1 only if the TLP still fits in that VC's buffer
//   * the application frees space with rx_consume_*
//   * every time space is freed, an FC update (free PH / free PD) is sent
//     to the remote TX
//
// There is no real RAM/FIFO: only the occupancy counters are modelled.
//
// Two simple modelling rules:
//   1. The buffer is made of 16-byte slots, so every TLP (and every consume)
//      is rounded up to a multiple of 16 bytes. That keeps RX's free space
//      exactly equal to the PD credits the TX has counted.
//   2. One rx_consume request = one whole TLP leaves the buffer, so it frees
//      its bytes AND one header (PH) slot.
// ============================================================================
module pcie_fc_rx #(
    parameter int NUM_VC            = 2,
    parameter int VC_W              = 1,
    parameter int BYTES_W           = 10,
    parameter int PH_W              = 4,
    parameter int PD_W              = 5,
    parameter int DATA_CREDIT_BYTES = 16,
    parameter int BUFFER_BYTES      = 256,  // per VC -> 256/16 = 16 PD credits
    parameter int MAX_PH            = 4     // header slots per VC
) (
    input  logic               clk,
    input  logic               rst_n,

    // ---- TLP link side (comes from the remote TX) ----
    input  logic               tlp_valid,
    output logic               tlp_ready,
    input  logic [VC_W-1:0]    tlp_vc,
    input  logic [BYTES_W-1:0] tlp_bytes,

    // ---- application consumes (frees) data ----
    input  logic               rx_consume_valid,
    input  logic [VC_W-1:0]    rx_consume_vc,
    input  logic [BYTES_W-1:0] rx_consume_bytes,

    // ---- FC update going back to the remote TX ----
    output logic               fc_update_valid,
    output logic [VC_W-1:0]    fc_update_vc,
    output logic [PH_W-1:0]    fc_update_ph,
    output logic [PD_W-1:0]    fc_update_pd,

    // ---- occupancy (output so the testbench can look at it) ----
    output logic [BYTES_W-1:0] used_bytes [NUM_VC]
);

    logic [PH_W-1:0]    hdr_used   [NUM_VC];   // header slots in use
    logic [BYTES_W-1:0] free_bytes [NUM_VC];   // BUFFER_BYTES - used_bytes

    // ------------------------------------------------------------------
    // 1. Free space per VC
    // ------------------------------------------------------------------
    always_comb begin
        for (int i = 0; i < NUM_VC; i++) begin
            free_bytes[i] = BYTES_W'(BUFFER_BYTES) - used_bytes[i];
        end
    end

    // ------------------------------------------------------------------
    // 2. Round sizes up to whole 16B slots  (15B -> 16, 17B -> 32, ...)
    //    (sizes are assumed to be <= BUFFER_BYTES)
    // ------------------------------------------------------------------
    logic [BYTES_W-1:0] tlp_alloc, consume_alloc;
    assign tlp_alloc     = BYTES_W'(((32'(tlp_bytes)        + DATA_CREDIT_BYTES - 1) / DATA_CREDIT_BYTES) * DATA_CREDIT_BYTES);
    assign consume_alloc = BYTES_W'(((32'(rx_consume_bytes) + DATA_CREDIT_BYTES - 1) / DATA_CREDIT_BYTES) * DATA_CREDIT_BYTES);

    // ------------------------------------------------------------------
    // 3. Ready: accept only if the data fits AND a header slot is free
    // ------------------------------------------------------------------
    assign tlp_ready = (tlp_alloc <= free_bytes[tlp_vc]) &&
                       (hdr_used[tlp_vc] < PH_W'(MAX_PH));

    logic tlp_fire;                              // TLP accepted this cycle
    assign tlp_fire = tlp_valid && tlp_ready;

    // ------------------------------------------------------------------
    // 4. Next occupancy: + accepted TLP, - consumed TLP
    // ------------------------------------------------------------------
    logic [BYTES_W-1:0] used_next [NUM_VC];
    logic [PH_W-1:0]    hdr_next  [NUM_VC];

    always_comb begin
        for (int i = 0; i < NUM_VC; i++) begin
            used_next[i] = used_bytes[i];
            hdr_next[i]  = hdr_used[i];
        end

        if (tlp_fire) begin
            used_next[tlp_vc] = used_next[tlp_vc] + tlp_alloc;
            hdr_next[tlp_vc]  = hdr_next[tlp_vc]  + PH_W'(1);
        end

        if (rx_consume_valid) begin
            used_next[rx_consume_vc] = used_next[rx_consume_vc] - consume_alloc;
            hdr_next[rx_consume_vc]  = hdr_next[rx_consume_vc]  - PH_W'(1);
        end
    end

    // ------------------------------------------------------------------
    // 5. Registers.
    //    fc_update_* is a one-cycle pulse that follows every consume.
    //    It carries the FREE credits of that VC *after* the consume:
    //        PH = MAX_PH - headers in use
    //        PD = free bytes / 16
    // ------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < NUM_VC; i++) begin
                used_bytes[i] <= '0;
                hdr_used[i]   <= '0;
            end
            fc_update_valid <= 1'b0;
            fc_update_vc    <= '0;
            fc_update_ph    <= '0;
            fc_update_pd    <= '0;
        end else begin
            for (int i = 0; i < NUM_VC; i++) begin
                used_bytes[i] <= used_next[i];
                hdr_used[i]   <= hdr_next[i];
            end
            fc_update_valid <= rx_consume_valid;
            fc_update_vc    <= rx_consume_vc;
            fc_update_ph    <= PH_W'(MAX_PH) - hdr_next[rx_consume_vc];
            fc_update_pd    <= PD_W'((BUFFER_BYTES - 32'(used_next[rx_consume_vc])) / DATA_CREDIT_BYTES);
        end
    end

    // ------------------------------------------------------------------
    // 6. Assertions (simulation only)
    // ------------------------------------------------------------------
`ifndef SYNTHESIS
    always @(posedge clk) begin
        if (rst_n) begin
            if (tlp_fire)
                assert (tlp_alloc <= free_bytes[tlp_vc])
                    else $error("ASSERT: RX accepted a TLP bigger than the free space (vc=%0d)", tlp_vc);

            if (rx_consume_valid) begin
                assert (consume_alloc <= used_bytes[rx_consume_vc])
                    else $error("ASSERT: consumed more bytes than are in the buffer (vc=%0d)", rx_consume_vc);
                assert (hdr_used[rx_consume_vc] >= PH_W'(1))
                    else $error("ASSERT: consume with no TLP in the buffer (vc=%0d)", rx_consume_vc);
            end

            for (int i = 0; i < NUM_VC; i++) begin
                assert (used_bytes[i] <= BYTES_W'(BUFFER_BYTES))
                    else $error("ASSERT: buffer overflow on vc=%0d", i);
            end
        end
    end
`endif

endmodule
