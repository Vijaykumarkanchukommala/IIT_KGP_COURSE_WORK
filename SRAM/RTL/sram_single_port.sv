module sram_single_port #(parameter DATA_WIDTH = 8, ADDRESS_WIDTH = 4 ,DEPTH = 2**ADDRESS_WIDTH) 
(
   input                                i_clk, 
   input                                i_en, 
   input                                i_wen, 
   input        [ADDRESS_WIDTH - 1:0]   i_addr,
   input        [DATA_WIDTH    - 1:0]   i_data,
   output   reg [DATA_WIDTH    - 1:0]   o_data 
);

 reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];

 integer i;

  always_ff @(posedge i_clk) begin
    if(i_en) begin
        if(i_wen) begin
           mem[i_addr]     <= i_data;
        end
    end
  end


  always_ff @(posedge i_clk) begin
    if(i_en) begin
      o_data     <= mem[i_addr];
    end
  end

endmodule
