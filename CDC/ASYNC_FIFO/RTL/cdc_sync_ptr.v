// Simple FIFO pointer gray-code CDC cell (write → read domain)
module cdc_sync_ptr #(parameter PTR_W = 4) (
    input  wire             clk_dst,
    input  wire             rst_n_dst,
    input  wire [PTR_W-1:0] ptr_src_gray,
    output wire [PTR_W-1:0] ptr_dst_gray
);
    sync_ff #(PTR_W) u_sync (
        .clk  (clk_dst),
        .rst_n(rst_n_dst),
        .d    (ptr_src_gray),
        .q    (ptr_dst_gray)
    );
endmodule
