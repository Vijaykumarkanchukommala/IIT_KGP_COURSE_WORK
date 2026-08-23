///////////////////////////////////////
//  coder: vijay kumar kanchukommala
///////////////////////////////////////
module tb();

 localparam DEPTH = 256, DWIDTH = 32,PTR_WIDTH = 8;
 reg clk,rst;
 reg push,pop;   
 reg [4:0] cnt;
 reg  [DWIDTH - 1:0] wdata;
 wire [DWIDTH - 1:0] rdata;

 fifo #(.DATA_WIDTH(DWIDTH),.DEPTH(DEPTH),.ADDRESS_WIDTH(PTR_WIDTH))U_fifo
    ( 
        .i_clk  (clk  ),
        .i_reset  (rst  ),
        .i_push   (push   ),
        .i_pop   (pop   ),   
        .o_empty (empty),
        .o_full  (full ),
        .i_data(wdata),
        .o_data(rdata) 
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
  //      push  <= 0;
  //      pop   <= 0;
  //      wdata <= 0;
  //    end else if(cnt == 3) begin
  //      push  <= 1;
  //      pop   <= 0;
  //      wdata <= 20;
  //    end else if(cnt == 5) begin
  //      push  <= 0;
  //      pop   <= 1;
  //      wdata <= 0;
  //    end else begin
  //      push  <= 0;
  //      pop   <= 0;
  //      wdata <= 0;
  //    end
  // end


  always @(posedge clk or negedge rst) begin
      if(!rst) begin
        push  <= 0;
        pop   <= 0;
        wdata <= 0;
      end else begin
        push  <= 1;
        pop   <= 0;
        wdata <= 20;
      end
   end



  always #1 clk = ~clk;

endmodule
