module full_adder 
(
   input  i_A, i_B, i_cin,
   output o_sum,o_carry
);

  assign o_sum   = i_A ^ i_B ^ i_cin;
  assign o_carry = (i_A & i_B) | (i_cin & (i_A ^ i_B));
endmodule
