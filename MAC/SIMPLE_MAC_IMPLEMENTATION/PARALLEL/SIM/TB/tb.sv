module tb ();

  parameter SAMPLE_WIDTH = 8;
  parameter NUM_ROWS_VS_COLUMNS = 2;
  parameter OUTPUT_WIDTH = 2*SAMPLE_WIDTH+$clog2(NUM_ROWS_VS_COLUMNS);

  reg   [NUM_ROWS_VS_COLUMNS * SAMPLE_WIDTH - 1:0] i_A, i_B;
  wire  [OUTPUT_WIDTH-1:0] o_output;
  reg   [SAMPLE_WIDTH-1:0] r_random0,r_random1;

  initial begin
    i_A    = 0;
    i_B    = 0;
    repeat (256) begin
      r_random0 = $random;
      r_random1 = $random;
      i_A = {NUM_ROWS_VS_COLUMNS{r_random0}};
      i_B = {NUM_ROWS_VS_COLUMNS{r_random1}};
      #2;
    end
    #100 $finish();
  end

  mac #(.SAMPLE_WIDTH(SAMPLE_WIDTH),.NUM_ROWS_VS_COLUMNS(NUM_ROWS_VS_COLUMNS),.OUTPUT_WIDTH(OUTPUT_WIDTH)) u_mac 
  (
    .i_A             (i_A         ),
    .i_B             (i_B         ),
    .o_output        (o_output    ) 
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
