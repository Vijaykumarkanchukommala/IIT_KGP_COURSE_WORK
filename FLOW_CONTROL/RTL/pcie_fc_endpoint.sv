`timescale 1ns/1ps

// ============================================================================
// pcie_fc_endpoint : one TX + one RX
//
//   TX  sends TLPs to the remote endpoint. Its credits describe the REMOTE
//       RX buffer, so it is fed by  fc_update_in_*  (from the remote RX).
//   RX  receives TLPs from the remote endpoint. It reports its free space
//       on  fc_update_out_*  (to the remote TX).
//
//   fc_init_* only initialises the credits of this endpoint's TX.
// ============================================================================
module pcie_fc_endpoint #(
    parameter int NUM_VC            = 2,
    parameter int VC_W              = 1,
    parameter int BYTES_W           = 10,
    parameter int PH_W              = 4,
    parameter int PD_W              = 5,
    parameter int DATA_CREDIT_BYTES = 16,
    parameter int BUFFER_BYTES      = 256,
    parameter int MAX_PH            = 4
) (
    input  logic               clk,
    input  logic               rst_n,

    // ---- application TX interface ----
    input  logic               app_tx_valid,
    output logic               app_tx_ready,
    input  logic [VC_W-1:0]    app_tx_vc,
    input  logic [BYTES_W-1:0] app_tx_bytes,

    // ---- application RX consume interface ----
    input  logic               rx_consume_valid,
    input  logic [VC_W-1:0]    rx_consume_vc,
    input  logic [BYTES_W-1:0] rx_consume_bytes,

    // ---- link TX interface (to remote RX) ----
    output logic               tx_tlp_valid,
    input  logic               tx_tlp_ready,
    output logic [VC_W-1:0]    tx_tlp_vc,
    output logic [BYTES_W-1:0] tx_tlp_bytes,

    // ---- link RX interface (from remote TX) ----
    input  logic               rx_tlp_valid,
    output logic               rx_tlp_ready,
    input  logic [VC_W-1:0]    rx_tlp_vc,
    input  logic [BYTES_W-1:0] rx_tlp_bytes,

    // ---- FC update: my RX -> remote TX ----
    output logic               fc_update_out_valid,
    output logic [VC_W-1:0]    fc_update_out_vc,
    output logic [PH_W-1:0]    fc_update_out_ph,
    output logic [PD_W-1:0]    fc_update_out_pd,

    // ---- FC update: remote RX -> my TX ----
    input  logic               fc_update_in_valid,
    input  logic [VC_W-1:0]    fc_update_in_vc,
    input  logic [PH_W-1:0]    fc_update_in_ph,
    input  logic [PD_W-1:0]    fc_update_in_pd,

    // ---- FC initialisation of my TX credits ----
    input  logic               fc_init_valid,
    input  logic [VC_W-1:0]    fc_init_vc,
    input  logic [PH_W-1:0]    fc_init_ph,
    input  logic [PD_W-1:0]    fc_init_pd,

    // ---- visibility for the testbench ----
    output logic [PH_W-1:0]    tx_ph_credit  [NUM_VC],
    output logic [PD_W-1:0]    tx_pd_credit  [NUM_VC],
    output logic [BYTES_W-1:0] rx_used_bytes [NUM_VC]
);

    pcie_fc_tx #(
        .NUM_VC(NUM_VC), .VC_W(VC_W), .BYTES_W(BYTES_W),
        .PH_W(PH_W), .PD_W(PD_W), .DATA_CREDIT_BYTES(DATA_CREDIT_BYTES)
    ) u_tx (
        .clk            (clk),
        .rst_n          (rst_n),
        .app_tx_valid   (app_tx_valid),
        .app_tx_ready   (app_tx_ready),
        .app_tx_vc      (app_tx_vc),
        .app_tx_bytes   (app_tx_bytes),
        .tlp_valid      (tx_tlp_valid),
        .tlp_ready      (tx_tlp_ready),
        .tlp_vc         (tx_tlp_vc),
        .tlp_bytes      (tx_tlp_bytes),
        .fc_init_valid  (fc_init_valid),
        .fc_init_vc     (fc_init_vc),
        .fc_init_ph     (fc_init_ph),
        .fc_init_pd     (fc_init_pd),
        .fc_update_valid(fc_update_in_valid),
        .fc_update_vc   (fc_update_in_vc),
        .fc_update_ph   (fc_update_in_ph),
        .fc_update_pd   (fc_update_in_pd),
        .ph_credit      (tx_ph_credit),
        .pd_credit      (tx_pd_credit)
    );

    pcie_fc_rx #(
        .NUM_VC(NUM_VC), .VC_W(VC_W), .BYTES_W(BYTES_W),
        .PH_W(PH_W), .PD_W(PD_W), .DATA_CREDIT_BYTES(DATA_CREDIT_BYTES),
        .BUFFER_BYTES(BUFFER_BYTES), .MAX_PH(MAX_PH)
    ) u_rx (
        .clk             (clk),
        .rst_n           (rst_n),
        .tlp_valid       (rx_tlp_valid),
        .tlp_ready       (rx_tlp_ready),
        .tlp_vc          (rx_tlp_vc),
        .tlp_bytes       (rx_tlp_bytes),
        .rx_consume_valid(rx_consume_valid),
        .rx_consume_vc   (rx_consume_vc),
        .rx_consume_bytes(rx_consume_bytes),
        .fc_update_valid (fc_update_out_valid),
        .fc_update_vc    (fc_update_out_vc),
        .fc_update_ph    (fc_update_out_ph),
        .fc_update_pd    (fc_update_out_pd),
        .used_bytes      (rx_used_bytes)
    );

endmodule
