module mac #(parameter SAMPLE_WIDTH = 8, parameter NUM_ROWS_VS_COLUMNS = 8, parameter OUTPUT_WIDTH = 2*SAMPLE_WIDTH+$clog2(NUM_ROWS_VS_COLUMNS)) 
(
   input    [NUM_ROWS_VS_COLUMNS * SAMPLE_WIDTH - 1:0] i_A, i_B,
   output   [OUTPUT_WIDTH - 1:0] o_output 
);

  localparam NUM_ADDER_STAGES = $clog2(NUM_ROWS_VS_COLUMNS);
  localparam NUM_MULTIPLIERS  = NUM_ROWS_VS_COLUMNS;
  localparam MULT_RESULT_SAMPLE_WIDTH = 2*SAMPLE_WIDTH;

  genvar mult_i,stg_i,addr_i;

  wire  [MULT_RESULT_SAMPLE_WIDTH-1:0] w_multiplier_result[NUM_ROWS_VS_COLUMNS-1:0];

  generate for(mult_i = 0; mult_i < NUM_MULTIPLIERS; mult_i = mult_i + 1) begin :gen_multiplier
    assign w_multiplier_result[mult_i] = i_A[mult_i*SAMPLE_WIDTH+SAMPLE_WIDTH-1:mult_i*SAMPLE_WIDTH] * i_B[mult_i*SAMPLE_WIDTH+SAMPLE_WIDTH-1:mult_i*SAMPLE_WIDTH];
  end
  endgenerate

  generate for(stg_i = 0; stg_i < NUM_ADDER_STAGES; stg_i = stg_i + 1) begin :gen_stg
    wire [(MULT_RESULT_SAMPLE_WIDTH+stg_i)-1:0]     w_input_a  [(NUM_ROWS_VS_COLUMNS/(2**(stg_i+1)))-1:0];
    wire [(MULT_RESULT_SAMPLE_WIDTH+stg_i)-1:0]     w_input_b  [(NUM_ROWS_VS_COLUMNS/(2**(stg_i+1)))-1:0];
    wire [(MULT_RESULT_SAMPLE_WIDTH+stg_i+1)-1:0]   w_result   [(NUM_ROWS_VS_COLUMNS/(2**(stg_i+1)))-1:0];
    for(addr_i = 0 ; addr_i < NUM_ROWS_VS_COLUMNS/(2**(stg_i+1)); addr_i = addr_i + 1) begin :adder_block 
      if(stg_i == 0) begin
        assign  w_input_a [addr_i] = w_multiplier_result[2*addr_i  ];
        assign  w_input_b [addr_i] = w_multiplier_result[2*addr_i+1];
      end else begin
        assign  w_input_a [addr_i] = gen_stg[stg_i-1].w_result[2*addr_i  ];
        assign  w_input_b [addr_i] = gen_stg[stg_i-1].w_result[2*addr_i+1];
      end
       unsigned_adder  #(.DATA_WIDTH((MULT_RESULT_SAMPLE_WIDTH+stg_i))) u_adder (.i_A(w_input_a[addr_i]),.i_B(w_input_b[addr_i]),.o_result(w_result[addr_i])); 
    end
  end
  endgenerate

  assign o_output = gen_stg[NUM_ADDER_STAGES-1].w_result[0];

endmodule
