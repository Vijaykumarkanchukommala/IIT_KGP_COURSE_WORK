module unsigned_adder #(parameter DATA_WIDTH = 8) 
( 
  input  [DATA_WIDTH-1:0] i_A, i_B,
  output [DATA_WIDTH:0]   o_result 
);

 wire   [DATA_WIDTH-1:0] w_sum;
 wire                    w_carry;
 assign {w_carry,w_sum} = {i_A + i_B};
 assign o_result        = {w_carry,w_sum};
endmodule  
