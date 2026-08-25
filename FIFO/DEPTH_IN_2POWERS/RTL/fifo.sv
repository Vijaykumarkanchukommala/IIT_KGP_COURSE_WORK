///////////////////////////////////////
//  coder: vijay kumar kanchukommala
///////////////////////////////////////
module fifo #(parameter DATA_WIDTH = 32,  ADDRESS_WIDTH = 4 ,DEPTH = 2**ADDRESS_WIDTH)(i_clk,i_reset,i_push,i_pop,i_data,o_data,o_empty,o_full);
  input i_push,i_pop,i_clk,i_reset;
  input  [DATA_WIDTH - 1:0] i_data;
  output [DATA_WIDTH - 1:0] o_data;
  output o_empty,o_full;
  reg [ADDRESS_WIDTH :0] r_waddr,r_raddr;

  assign o_empty = (r_waddr == r_raddr); 
  assign o_full  = (r_waddr[ADDRESS_WIDTH -1 :0] == r_raddr[ADDRESS_WIDTH -1 :0]) & (r_waddr[ADDRESS_WIDTH] != r_raddr[ADDRESS_WIDTH]);

 
  // r_waddr 
  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      r_waddr <= 0;
    end else if(o_full) begin
      r_waddr <= r_waddr;
    end else if(i_push) begin
      r_waddr <= r_waddr + {{ADDRESS_WIDTH{1'b0}},1'b1};
    end 
  end

  // r_raddr
  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      r_raddr <= 0;
    end else if(i_pop) begin
      r_raddr <= r_raddr + {{ADDRESS_WIDTH{1'b0}},1'b1};
    end 
  end

  sync_dp_ram #(.DATA_WIDTH(DATA_WIDTH),.DEPTH(DEPTH),.ADDRESS_WIDTH(ADDRESS_WIDTH)) U_ram(
        .i_clk    (i_clk                     ),
        .i_reset  (i_reset                   ),
        .i_wen    (i_push                    ),
        .i_ren    (i_pop                     ),   
        .i_waddr  (r_waddr[ADDRESS_WIDTH-1:0]),
        .i_raddr  (r_raddr[ADDRESS_WIDTH-1:0]),
        .i_data   (i_data                    ),
        .o_data   (o_data                    ) 
  );
 

endmodule
