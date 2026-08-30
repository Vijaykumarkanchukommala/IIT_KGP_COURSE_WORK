module mac_core #(
  parameter SAMPLE_WIDTH = 8, 
  parameter NUM_SAMPLES  = 8, 
  parameter OUTPUT_WIDTH = 2*SAMPLE_WIDTH+$clog2(NUM_SAMPLES),
  parameter SIGN_TYPE    = 1  //0- unsigned; 1- signed
) 
(
   input   signed   [SAMPLE_WIDTH - 1:0]     i_A            [NUM_SAMPLES-1:0], 
   input   signed   [SAMPLE_WIDTH - 1:0]     i_B            [NUM_SAMPLES-1:0],
   input                                     i_load                          ,
   output  signed   [OUTPUT_WIDTH - 1:0]     o_output                        , 
   output                                    o_output_valid            
);

  localparam NUM_MULTIPLIERS  = NUM_SAMPLES;

  localparam NUM_EVEN_SAMPLES = NUM_SAMPLES-((NUM_SAMPLES%2)!=0);
  localparam NUM_ADDER_STAGES = $clog2(NUM_EVEN_SAMPLES);
  localparam MULT_RESULT_SAMPLE_WIDTH = 2*SAMPLE_WIDTH;

  genvar mult_i,stg_i,addr_i;

  wire  signed [MULT_RESULT_SAMPLE_WIDTH-1:0] w_multiplier_result[NUM_SAMPLES-1:0];


  assign o_output_valid = i_load;

  //Multiplier
  generate for(mult_i = 0; mult_i < NUM_MULTIPLIERS; mult_i = mult_i + 1) begin :gen_multiplier
    if(SIGN_TYPE  == 0) begin
       unsigned_multiplier  #(.DATA_WIDTH(SAMPLE_WIDTH)) u_unsigned_multiplier 
       (
          .i_A                   (i_A[mult_i]                  ),
          .i_B                   (i_B[mult_i]                  ),
          .o_result              (w_multiplier_result[mult_i]  )
       ); 
    end else begin
       signed_multiplier  #(.DATA_WIDTH(SAMPLE_WIDTH)) u_signed_multiplier 
       (
          .i_A                   (i_A[mult_i]                  ),
          .i_B                   (i_B[mult_i]                  ),
          .o_result              (w_multiplier_result[mult_i]  )
       ); 
    end
  end
  endgenerate

  //Adder stages
  generate for(stg_i = 0; stg_i < NUM_ADDER_STAGES; stg_i = stg_i + 1) begin :gen_stg
    wire signed [(MULT_RESULT_SAMPLE_WIDTH+stg_i)-1:0]     w_addr_in_a  [(NUM_EVEN_SAMPLES/(2**(stg_i+1)))-1:0];
    wire signed [(MULT_RESULT_SAMPLE_WIDTH+stg_i)-1:0]     w_addr_in_b  [(NUM_EVEN_SAMPLES/(2**(stg_i+1)))-1:0];
    wire signed [(MULT_RESULT_SAMPLE_WIDTH+stg_i+1)-1:0]   w_result   [(NUM_EVEN_SAMPLES/(2**(stg_i+1)))-1:0];
    for(addr_i = 0 ; addr_i < NUM_EVEN_SAMPLES/(2**(stg_i+1)); addr_i = addr_i + 1) begin :adder_block 
      if(stg_i == 0) begin
        assign  w_addr_in_a [addr_i] = w_multiplier_result[2*addr_i  ];
        assign  w_addr_in_b [addr_i] = w_multiplier_result[2*addr_i+1];
      end else begin
        assign  w_addr_in_a [addr_i] = gen_stg[stg_i-1].w_result[2*addr_i  ];
        assign  w_addr_in_b [addr_i] = gen_stg[stg_i-1].w_result[2*addr_i+1];
      end
      if(SIGN_TYPE  == 0) begin
       unsigned_adder  #(.DATA_WIDTH((MULT_RESULT_SAMPLE_WIDTH+stg_i))) u_unsined_adder 
       (
          .i_A                   (w_addr_in_a[addr_i]),
          .i_B                   (w_addr_in_b[addr_i]),
          .o_result              (w_result[addr_i]   )
       ); 
      end else begin
       signed_adder  #(.DATA_WIDTH((MULT_RESULT_SAMPLE_WIDTH+stg_i))) u_signed_adder 
       (
          .i_A                   (w_addr_in_a[addr_i]),
          .i_B                   (w_addr_in_b[addr_i]),
          .o_result              (w_result[addr_i]   )
       );
      end
    end
  end
  endgenerate

  generate 
   if((NUM_SAMPLES%2)!=0) begin  :final_odd_addr_stg
      if(SIGN_TYPE  == 0) begin  
         unsigned_adder  #(.DATA_WIDTH(OUTPUT_WIDTH-1)) u_unsigned_adder 
         (
            .i_A                   ({{NUM_ADDER_STAGES{w_multiplier_result[NUM_SAMPLES-1][MULT_RESULT_SAMPLE_WIDTH-1]}},w_multiplier_result[NUM_SAMPLES-1]}),
            .i_B                   (gen_stg[NUM_ADDER_STAGES-1].w_result[0]                      ),
            .o_result              (o_output                                                     )
         ); 
      end else begin
         signed_adder  #(.DATA_WIDTH(OUTPUT_WIDTH-1)) u_signed_adder 
         (
            .i_A                   ({{NUM_ADDER_STAGES{w_multiplier_result[NUM_SAMPLES-1][MULT_RESULT_SAMPLE_WIDTH-1]}},w_multiplier_result[NUM_SAMPLES-1]}),
            .i_B                   (gen_stg[NUM_ADDER_STAGES-1].w_result[0]                      ),
            .o_result              (o_output                                                     )
         ); 
      end
   end else begin
       assign o_output = gen_stg[NUM_ADDER_STAGES-1].w_result[0];
   end
  endgenerate

endmodule
