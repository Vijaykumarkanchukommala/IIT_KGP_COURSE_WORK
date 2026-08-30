module signed_adder #(
   parameter DATA_WIDTH = 8
) 
( 
  input  signed [DATA_WIDTH-1:0] i_A, 
  input  signed [DATA_WIDTH-1:0] i_B,
  output signed [DATA_WIDTH  :0] o_result 
);

 wire  [DATA_WIDTH:0] w_A,w_B; 

 assign w_A  = {i_A[DATA_WIDTH-1],i_A}; 
 assign w_B  = {i_B[DATA_WIDTH-1],i_B}; 

  
  unsigned_adder #(.DATA_WIDTH(DATA_WIDTH+1)) u_unsigned_adder 
  (
    .i_A             (w_A         ),
    .i_B             (w_B         ),
    .o_result        (o_result    ) 
  );


endmodule  
