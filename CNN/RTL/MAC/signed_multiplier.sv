module signed_multiplier #(parameter DATA_WIDTH = 8) 
(
  input   signed [DATA_WIDTH-1:0  ] i_A,i_B,
  output  signed [2*DATA_WIDTH-1:0] o_result
);
  assign o_result = i_A * i_B;
endmodule
