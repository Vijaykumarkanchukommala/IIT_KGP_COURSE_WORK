module tb ();

  parameter DATA_WIDTH = 4;

  reg  signed  [DATA_WIDTH-1:0] i_A, i_B;
  wire signed  [DATA_WIDTH:0] o_result;

  initial begin
    i_A    = 0;
    i_B    = 0;
    #2;
    i_A    = 1;
    i_B    = 5;
    #2
    i_A    = -2;
    i_B    = 5;
    #2
    i_A    = -8;
    i_B    = -5;
    #2
    i_A    =  7;
    i_B    = -5;
    #100 $finish();
  end

  signed_adder #(.DATA_WIDTH(DATA_WIDTH)) u_signed_adder 
  (
    .i_A             (i_A         ),
    .i_B             (i_B         ),
    .o_result        (o_result    ) 
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
