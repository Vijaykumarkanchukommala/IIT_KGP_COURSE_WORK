///////////////////////////////////////
//  coder: vijay kumar kanchukommala
///////////////////////////////////////
module tb();

 localparam DEPTH = 7, DWIDTH = 32,PTR_WIDTH = 8;
 reg clk,rst;
 reg i_valid,o_ready;   
 wire i_ready;
 reg [4:0] cnt;
 reg  [DWIDTH - 1:0] wdata;
 wire [DWIDTH - 1:0] rdata;

 fifo_depth_non_pow2 #(.DATA_WIDTH(DWIDTH),.DEPTH(DEPTH))U_fifo
    ( 
        .i_clk   (clk  ),
        .i_reset (rst  ),
        .i_valid (i_valid ),
        .i_ready (o_ready ),   
        .o_valid (o_valid),
        .o_ready (i_ready ),
        .i_data  (wdata),
        .o_data  (rdata) 
    );

  initial begin
     $dumpfile("fifo.vcd");
     $dumpvars();
     clk = 0;
     rst = 0;
     #10 
     rst = 1;
     #2 ;
     #2 ;
     #2 ;
     #1000;
     $finish();
  end


   always @(posedge clk or negedge rst) begin
      if(!rst) begin
        cnt <= 0;
      end else begin
        cnt <= cnt + 1;
      end
   end

  // always @(posedge clk or negedge rst) begin
  //    if(!rst) begin
  //      i_valid  <= 0;
  //      i_ready   <= 0;
  //      wdata <= 0;
  //    end else if(cnt == 3) begin
  //      i_valid  <= 1;
  //      i_ready   <= 0;
  //      wdata <= 20;
  //    end else if(cnt == 5) begin
  //      i_valid  <= 0;
  //      i_ready   <= 1;
  //      wdata <= 0;
  //    end else begin
  //      i_valid  <= 0;
  //      i_ready   <= 0;
  //      wdata <= 0;
  //    end
  // end


  always @(posedge clk or negedge rst) begin
      if(!rst) begin
        i_valid  <= 0;
        o_ready   <= 0;
        wdata <= 0;
      end else begin
        i_valid  <= 1;
        o_ready   <= !o_ready ? !i_ready : 1;
        wdata <= $random;
      end
   end



  always #1 clk = ~clk;

endmodule
