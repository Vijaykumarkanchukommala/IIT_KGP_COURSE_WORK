module multiplier #(parameter DATA_WIDTH = 8) 
(
  input   [DATA_WIDTH-1:0  ] i_A,i_B,
  output  [2*DATA_WIDTH-1:0] o_result
);
  assign o_result = i_A * i_B;
endmodule
