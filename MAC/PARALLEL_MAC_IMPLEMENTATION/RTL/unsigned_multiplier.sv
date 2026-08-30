module unsigned_multiplier #(parameter DATA_WIDTH = 8) 
(
  input   unsigned [DATA_WIDTH-1:0  ] i_A,i_B,
  output  unsigned [2*DATA_WIDTH-1:0] o_result
);
  assign o_result = i_A * i_B;
endmodule
