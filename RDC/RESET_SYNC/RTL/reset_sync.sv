module reset_sync
#(
   parameter RESET_POLARITY  = 1'b1;
)
(
    input  wire        clk,
    input  wire        rst_n,  // async active-low reset (common)
    output wire        sync    // bus interrupt synchronized to cpu domain
);
    sync_ff #(1) u_rst_cpu (clk_cpu, rst_n, RESET_POLARITY, rst_cpu_n);
endmodule
