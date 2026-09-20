module reset_sync
#(
   parameter RESET_POLARITY  = 1'b1 
)
(
    input  wire        i_clk,
    input  wire        i_rst,  
    output wire        o_sync_rst 
);
    sync_ff #(.WIDTH(1),.RESET_POLARITY(RESET_POLARITY)) u_rst_ff (i_clk, i_rst, o_sync_rst);
endmodule
