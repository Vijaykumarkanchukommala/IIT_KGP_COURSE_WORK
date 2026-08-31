module sram_addr_decoder
#(
  parameter INPUT_WIDTH   = 2,
  parameter OUTPUT_WIDTH  = 2**INPUT_WIDTH
)
(
   input                         i_cen,
   input    [INPUT_WIDTH -1:0]   i_addr,
   output   [OUTPUT_WIDTH-1:0]   o_bank_sel
);

  genvar bit_i;
  generate 
  for(bit_i = 0; bit_i < OUTPUT_WIDTH; bit_i = bit_i + 1) begin :Bank_sel
      assign o_bank_sel[bit_i] = !(!i_cen & (i_addr == bit_i));
  end
  endgenerate
  

endmodule
