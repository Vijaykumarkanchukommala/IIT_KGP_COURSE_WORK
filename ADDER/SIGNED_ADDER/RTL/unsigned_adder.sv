module unsigned_adder #(parameter DATA_WIDTH = 8) 
( 
  input  [DATA_WIDTH-1:0] i_A, i_B,
  output [DATA_WIDTH-1:0]   o_result 
);

 wire   [DATA_WIDTH-1:0] w_sum,w_A,w_B;
 assign o_result        = {w_sum};



 genvar bit_i;
 wire [DATA_WIDTH-1:1] w_carry_in;
 wire [DATA_WIDTH-1:0] w_carry_out;
 wire [DATA_WIDTH-1:0] w_p,w_g;
 generate
 for(bit_i =0 ; bit_i < DATA_WIDTH; bit_i = bit_i+ 1) begin :gen_Bit_idx 
    if(bit_i == 0) begin :Bit_0
       assign w_p[bit_i]         = (i_A[bit_i]^i_B[bit_i]);
       assign w_g[bit_i]         = (i_A[bit_i]&i_B[bit_i]);
       assign w_sum[bit_i]       = (w_p[bit_i]);
       assign w_carry_out[bit_i] = (w_g[bit_i]);
    end else begin :Bit_grater_than_0
       assign w_carry_in[bit_i] = w_carry_out[bit_i-1]; 
       assign w_p[bit_i]         = (i_A[bit_i]^i_B[bit_i]);
       assign w_g[bit_i]         = (i_A[bit_i]&i_B[bit_i]);
       assign w_sum[bit_i]       = (w_p[bit_i]^w_carry_in[bit_i]);
       assign w_carry_out[bit_i] = (w_g[bit_i] | (w_carry_in[bit_i]&w_p[bit_i]));
    end
 end
 endgenerate

endmodule  
