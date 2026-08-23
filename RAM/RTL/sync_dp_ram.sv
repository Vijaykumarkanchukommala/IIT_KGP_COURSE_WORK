module sync_dp_ram #(parameter DATA_WIDTH = 8, ADDRESS_WIDTH = 4 ,DEPTH = 2**ADDRESS_WIDTH) 
(
   input                                i_clk, 
   input                                i_reset,
   input                                i_wen, 
   input                                i_ren,
   input        [ADDRESS_WIDTH - 1:0]   i_addr,
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
        mem[i_addr]     <= i_data;
    end
  end


  always_ff @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      o_data     <= {DATA_WIDTH{1'b0}};
    end else if(i_ren) begin
      o_data     <= mem[i_addr];
    end
  end

endmodule
