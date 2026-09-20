///////////////////////////////////////
//  coder: vijay kumar kanchukommala
///////////////////////////////////////
module tb();

 parameter RESET_POLARITY = 1'b0;

 reg clk,rst;
 wire sync_rst;

 reset_sync #(.RESET_POLARITY(RESET_POLARITY)) U_reset_sync
    ( 
        .i_clk       (clk  ),
        .i_rst       (rst  ),
        .o_sync_rst  (sync_rst) 
    );

  initial begin
     $dumpfile("reset_sync.vcd");
     $dumpvars();
     clk = 0;
     rst = 0;
     #10 
     rst = 1;
     #10 
     rst = 0;
     #10 
     rst = 1;
     #10 
     rst = 0;
     #2 ;
     #2 ;
     #2 ;
     #1000;
     $finish();
  end


  always #1 clk = ~clk;

endmodule
