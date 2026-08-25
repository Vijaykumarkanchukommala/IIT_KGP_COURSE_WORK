module tb ();

  parameter SAMPLE_WIDTH = 8;
  parameter NUM_ROWS_VS_COLUMNS = 2;
  parameter OUTPUT_WIDTH = 2*SAMPLE_WIDTH+$clog2(NUM_ROWS_VS_COLUMNS);

  reg   [NUM_ROWS_VS_COLUMNS * SAMPLE_WIDTH - 1:0] r_A, r_B;
  reg                                              i_clk,i_reset;
  reg   [SAMPLE_WIDTH-1:0]                         i_A,i_B;
  reg                                              i_valid;
  wire  [OUTPUT_WIDTH-1:0] o_output;
  reg   [SAMPLE_WIDTH-1:0] r_random0,r_random1;
  wire  o_valid;

  integer i;

  initial begin
    r_A      = 0;
    r_B      = 0;
    i_A      = 0;
    i_B      = 0;
    i_clk    = 0;
    i_reset  = 0;
    r_random0 = $random;
    r_random1 = $random;
    for(i =0; i < NUM_ROWS_VS_COLUMNS; i = i + 1) begin
      r_A[i*SAMPLE_WIDTH+:SAMPLE_WIDTH]  = r_random0 + i;
      r_B[i*SAMPLE_WIDTH+:SAMPLE_WIDTH]  = r_random1 + i;
    end
    #11;
    i_reset = 1;
    #100 $finish();
  end



  always @(posedge i_clk or i_reset) begin
    if(i_reset) begin
       r_A   <= {r_A[SAMPLE_WIDTH-1:0],r_A[NUM_ROWS_VS_COLUMNS*SAMPLE_WIDTH-1:SAMPLE_WIDTH]};
       r_B   <= {r_B[SAMPLE_WIDTH-1:0],r_B[NUM_ROWS_VS_COLUMNS*SAMPLE_WIDTH-1:SAMPLE_WIDTH]};
    end
  end

  always @(posedge i_clk or i_reset) begin
       i_A   <= r_A[SAMPLE_WIDTH-1:0];
       i_B   <= r_B[SAMPLE_WIDTH-1:0];
  end


  always @(posedge i_clk or i_reset) begin
    if(!i_reset) begin
       i_valid   <= 1'b0;
    end else begin
       i_valid   <= 1'b1;
    end
  end


  always #1 i_clk = ~i_clk;

  mac #(.SAMPLE_WIDTH(SAMPLE_WIDTH),.NUM_ROWS_VS_COLUMNS(NUM_ROWS_VS_COLUMNS),.OUTPUT_WIDTH(OUTPUT_WIDTH)) u_mac 
  (
    .i_clk           (i_clk       ),
    .i_reset         (i_reset     ),
    .i_A             (i_A         ),
    .i_B             (i_B         ),
    .i_valid         (i_valid     ),
    .o_output        (o_output    ),
    .o_valid         (o_valid     ) 
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
