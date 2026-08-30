module mac_core #(
   parameter SAMPLE_WIDTH        = 8, 
   parameter NUM_SAMPLES         = 8, 
   parameter OUTPUT_WIDTH        = 2*SAMPLE_WIDTH+$clog2(NUM_SAMPLES),
   parameter SIGN_TYPE           = 1 //0- unsigned; 1- signed
) 
(
   input                                   i_clk, 
   input                                   i_reset_n,
   input   signed [SAMPLE_WIDTH - 1:0]     i_A, 
   input   signed [SAMPLE_WIDTH - 1:0]     i_B,
   input                                   i_load,
   input                                   i_load_final,
   output  signed [OUTPUT_WIDTH - 1:0]     o_output,
   output                                  o_output_valid 
);

  reg   signed    [SAMPLE_WIDTH-1:0]      r_A;
  reg   signed    [SAMPLE_WIDTH-1:0]      r_B;
  reg                                     r_load;
  reg             [1:0]                   r_addr_max;
  wire  signed    [2*SAMPLE_WIDTH-1:0]    w_mult_res;
  reg   signed    [OUTPUT_WIDTH - 1:0]    r_sum_res;
  wire  signed    [OUTPUT_WIDTH - 1:0]    w_sum_res;
  reg   signed    [OUTPUT_WIDTH - 1:0]    r_output;

  assign o_output        = r_output;
  assign o_output_valid  = r_addr_max[1];


 generate
  if(SIGN_TYPE == 0) begin
     unsigned_multiplier  #(
        .DATA_WIDTH    (SAMPLE_WIDTH)
     ) u_unsigned_multiplier 
     (
        .i_A                   (r_A        ),
        .i_B                   (r_B        ),
        .o_result              (w_mult_res )
     );

     unsigned_adder  #(
        .DATA_WIDTH    (OUTPUT_WIDTH)
     ) u_unsigned_adder 
     (
        .i_A                   (r_sum_res  ),
        .i_B                   (w_mult_res ),
        .o_result              (w_sum_res  )
     ); 
  end else begin
     signed_multiplier  #(
        .DATA_WIDTH    (SAMPLE_WIDTH)
     ) u_signed_multiplier 
     (
        .i_A                   (r_A        ),
        .i_B                   (r_B        ),
        .o_result              (w_mult_res )
     );

     signed_adder  #(
        .DATA_WIDTH    (OUTPUT_WIDTH)
     ) u_nsigned_adder 
     (
        .i_A                   (r_sum_res  ),
        .i_B                   (w_mult_res ),
        .o_result              (w_sum_res  )
     ); 
  end
 endgenerate

  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(!i_reset_n) begin
      r_A     <= {SAMPLE_WIDTH{1'b0}};
      r_B     <= {SAMPLE_WIDTH{1'b0}};
    end else if(i_load) begin
      r_A     <= i_A;
      r_B     <= i_B;
    end
  end

  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(!i_reset_n) begin
      r_load      <= 1'b0;
    end else if(i_load) begin
      r_load      <= 1'b1;
    end
  end

  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(!i_reset_n) begin
      r_addr_max      <= 2'b0;
    end else begin
      r_addr_max      <= {r_addr_max[0],i_load_final};
    end
  end

  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(!i_reset_n) begin
      r_sum_res      <= {OUTPUT_WIDTH{1'b0}};
    end else if(r_addr_max[0]) begin
      r_sum_res      <= {OUTPUT_WIDTH{1'b0}};
    end else if(r_load) begin
      r_sum_res      <= w_sum_res;
    end
  end

  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(!i_reset_n) begin
      r_output      <= {OUTPUT_WIDTH{1'b0}};
    end else if(r_addr_max[0]) begin
      r_output      <= w_sum_res;
    end
  end

endmodule
