module sync_dp_ram_depth_non_pow2 #(parameter DATA_WIDTH = 8, DEPTH = 7, ADDRESS_WIDTH = 3 ) 
(
   input                                i_clk, 
   input                                i_reset,
   input                                i_wen, 
   input                                i_ren,
   input        [ADDRESS_WIDTH - 1:0]   i_waddr,
   input        [ADDRESS_WIDTH - 1:0]   i_raddr,
   input        [DATA_WIDTH    - 1:0]   i_data,
   output   reg [DATA_WIDTH    - 1:0]   o_data 
);

 reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];

 integer i;

  always_ff @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      for(i=0; i< DEPTH; i = i+1) begin
        mem[i]     <= {DATA_WIDTH{1'b0}};
      end
    end else if(i_wen) begin
        mem[i_waddr]     <= i_data;
    end
  end


  always_ff @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      o_data     <= {DATA_WIDTH{1'b0}};
    end else if(i_ren) begin
      o_data     <= mem[i_raddr];
    end
  end

endmodule
