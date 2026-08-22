module unsigned_adder #(parameter DATA_WIDTH = 8, parameter RIPPLE_CARRY_ADDER = 1'b1) 
( 
  input  [DATA_WIDTH-1:0] i_A, i_B,
  input                   i_cin,
  output [DATA_WIDTH-1:0] o_sum,
  output                  o_carry 
);

 genvar bit_i;
 generate 
 if(RIPPLE_CARRY_ADDER == 1) begin :Ripple_carry_adder
   assign {o_carry,o_sum} = (i_A+i_B+{{(DATA_WIDTH-1){1'b0}},i_cin});
 end else begin :Carry_look_head_adder
   wire [DATA_WIDTH-1:0] w_carry_in;
   wire [DATA_WIDTH-1:0] w_carry_out;
   wire [DATA_WIDTH-1:0] w_p,w_g;
   for(bit_i =0 ; bit_i < DATA_WIDTH; bit_i = bit_i+ 1) begin :gen_Bit_idx 
      if(bit_i == 0) begin :Bit_0
         assign w_carry_in[bit_i] = i_cin; 
      end else begin :Bit_grater_than_0
         assign w_carry_in[bit_i] = w_carry_out[bit_i-1]; 
      end
      assign w_p[bit_i]         = (i_A[bit_i]^i_B[bit_i]);
      assign w_g[bit_i]         = (i_A[bit_i]&i_B[bit_i]);
      assign o_sum[bit_i]       = (w_p[bit_i]^w_carry_in[bit_i]);
      assign w_carry_out[bit_i] = (w_g[bit_i] | (w_carry_in[bit_i]&w_p[bit_i]));
   end
   assign o_carry = w_carry_out[DATA_WIDTH-1];
 end
 endgenerate
 

endmodule  
