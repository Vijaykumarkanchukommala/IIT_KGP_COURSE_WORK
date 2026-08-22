module tb ();

  parameter DATA_WIDTH = 8;

  reg   [DATA_WIDTH-1:0] i_A, i_B;
  reg                    i_cin; 
  wire  [DATA_WIDTH-1:0] o_sum,o_sum_c;
  wire                   o_carry,o_carry_c;

  initial begin
    i_A    = 0;
    i_B    = 0;
    i_cin  = 0;
    repeat (256) begin
      i_A = i_A + 1;
      #2;
      i_B = i_B + $random;
    end
    #100 $finish();
  end

  unsigned_adder #(.DATA_WIDTH(DATA_WIDTH),.RIPPLE_CARRY_ADDER(1'b1)) u_signed_adder 
  (
    .i_A             (i_A         ),
    .i_B             (i_B         ),
    .i_cin           (i_cin       ),
    .o_sum           (o_sum       ),
    .o_carry         (o_carry     ) 
  );

  unsigned_adder #(.DATA_WIDTH(DATA_WIDTH),.RIPPLE_CARRY_ADDER(1'b1)) u_signed_adder_carry_look_head 
  (
    .i_A             (i_A         ),
    .i_B             (i_B         ),
    .i_cin           (i_cin       ),
    .o_sum           (o_sum_c     ),
    .o_carry         (o_carry_c   ) 
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
