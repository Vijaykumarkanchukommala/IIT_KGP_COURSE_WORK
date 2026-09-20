// Async FIFO (write = CPU domain, read = BUS domain)
module async_fifo #(
    parameter DATA_W = 32,
    parameter DEPTH  = 8,
    parameter PTR_W  = 4   // log2(DEPTH)+1
)(
    // Write port (CPU clock)
    input  wire              wclk,
    input  wire              wrst_n,
    input  wire              wen,
    input  wire [DATA_W-1:0] wdata,
    output wire              wfull,
    // Read port (BUS clock)
    input  wire              rclk,
    input  wire              rrst_n,
    input  wire              ren,
    output wire [DATA_W-1:0] rdata,
    output wire              rempty
);
    reg [DATA_W-1:0] mem [0:DEPTH-1];
    reg [PTR_W-1:0]  wptr, rptr;
    wire[PTR_W-1:0]  wptr_gray, rptr_gray;
    wire[PTR_W-1:0]  wptr_gray_sync, rptr_gray_sync;

    // Binary → Gray
    assign wptr_gray = wptr ^ (wptr >> 1);
    assign rptr_gray = rptr ^ (rptr >> 1);

    // Cross pointers
    cdc_sync_ptr #(PTR_W) u_rptr_sync (
        .clk_dst    (wclk),        .rst_n_dst  (wrst_n),
        .ptr_src_gray(rptr_gray),  .ptr_dst_gray(rptr_gray_sync)
    );
    cdc_sync_ptr #(PTR_W) u_wptr_sync (
        .clk_dst    (rclk),        .rst_n_dst  (rrst_n),
        .ptr_src_gray(wptr_gray),  .ptr_dst_gray(wptr_gray_sync)
    );

    assign wfull  = (wptr_gray == {~rptr_gray_sync[PTR_W-1:PTR_W-2], rptr_gray_sync[PTR_W-3:0]});
    assign rempty = (rptr_gray == wptr_gray_sync);
    assign rdata  = mem[rptr[PTR_W-2:0]];

    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) 
            wptr <= 0;
        else if (wen && !wfull) begin
            mem[wptr[PTR_W-2:0]] <= wdata;
            wptr <= wptr + 1;
        end

    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) 
            rptr <= 0;
        else if (ren && !rempty)
            rptr <= rptr + 1;
endmodule

