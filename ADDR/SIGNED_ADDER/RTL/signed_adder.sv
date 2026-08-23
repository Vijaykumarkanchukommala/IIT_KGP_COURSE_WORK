module signed_adder #(parameter DATA_WIDTH = 8) 
( 
  input  signed [DATA_WIDTH-1:0] i_A, i_B,
  output signed [DATA_WIDTH  :0] o_result 
);


assign o_result = i_A + i_B;
endmodule  
