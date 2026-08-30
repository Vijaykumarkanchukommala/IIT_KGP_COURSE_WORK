module unsigned_adder #(
  parameter DATA_WIDTH = 8
) 
( 
  input  unsigned [DATA_WIDTH-1:0] i_A, 
  input  unsigned [DATA_WIDTH-1:0] i_B,
  output unsigned [DATA_WIDTH:0]   o_result 
);

 wire   [DATA_WIDTH-1:0] w_sum;
 wire                    w_carry;
 assign {w_carry,w_sum} = {i_A + i_B};
 assign o_result        = {w_carry,w_sum};
endmodule  
