module sram_block #(
  parameter DATA_WIDTH    = 32, 
  parameter ADDRESS_WIDTH = 10  
) 
(                                   
   input                                    i_clk, 
   input                                    i_cen, 
   input                                    i_wen, 
   input                                    i_wen, 
   input            [ADDRESS_WIDTH - 1:0]   i_addr,
   input            [DATA_WIDTH    - 1:0]   i_din,
   output           [DATA_WIDTH    - 1:0]   o_dout 
);

 localparam NUM_ROWS      = 2**ADDRESS_WIDTH;

 reg [DATA_WIDTH-1:0] mem [NUM_ROWS-1:0];

 integer i;

  always_ff @(posedge i_clk) begin
    if(!i_cen) begin
        if(!i_wen) begin
           mem[i_addr] <= i_din;
        end
    end
  end

  always_ff @(posedge i_clk) begin
    if(!i_cen) begin
        o_dout     <= mem[i_addr];
    end
  end

endmodule
