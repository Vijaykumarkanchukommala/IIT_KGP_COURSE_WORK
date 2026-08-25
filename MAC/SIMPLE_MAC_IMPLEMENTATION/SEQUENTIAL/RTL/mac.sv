module mac #(parameter SAMPLE_WIDTH = 8, parameter NUM_ROWS_VS_COLUMNS = 8, parameter OUTPUT_WIDTH = 2*SAMPLE_WIDTH+$clog2(NUM_ROWS_VS_COLUMNS)) 
(
   input                         i_clk, i_reset,
   input    [SAMPLE_WIDTH - 1:0] i_A, i_B,
   input                         i_valid,
   output   [OUTPUT_WIDTH - 1:0] o_output,
   output                        o_valid 
);

  localparam MAX_COUNTER_WIDTH = $clog2(NUM_ROWS_VS_COLUMNS);

  reg       [MAX_COUNTER_WIDTH-1:0] r_counter;
  reg       [SAMPLE_WIDTH-1:0]      r_A, r_B;
  wire                              w_load;
  reg                               r_load_dly;
  wire                              w_counter_max;
  reg                               r_counter_max;
  wire      [2*SAMPLE_WIDTH-1:0]    w_mult_res;
  reg       [OUTPUT_WIDTH - 1:0]    r_sum_res;
  wire      [OUTPUT_WIDTH - 1:0]    w_sum_res;

  assign w_load   = i_valid;
  assign o_output = r_sum_res;
  assign o_valid  = r_counter_max;


  assign w_counter_max = (r_counter ==  NUM_ROWS_VS_COLUMNS - 1) & r_load_dly;

  multiplier  #(.DATA_WIDTH(SAMPLE_WIDTH)) u_multiplier 
  (
     .i_A                   (r_A        ),
     .i_B                   (r_B        ),
     .o_result              (w_mult_res )
  );

  unsigned_adder  #(.DATA_WIDTH(OUTPUT_WIDTH)) u_adder 
  (
     .i_A                   (r_sum_res  ),
     .i_B                   (w_mult_res ),
     .o_result              (w_sum_res  )
  ); 

  always_ff @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      r_A     <= {SAMPLE_WIDTH{1'b0}};
      r_B     <= {SAMPLE_WIDTH{1'b0}};
    end else if(w_load) begin
      r_A     <= i_A;
      r_B     <= i_B;
    end
  end

  always_ff @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      r_load_dly      <= 1'b0;
    end else if(w_load) begin
      r_load_dly      <= 1'b1;
    end
  end

  always_ff @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      r_counter      <= {MAX_COUNTER_WIDTH{1'b0}};
    end else if(w_counter_max) begin
      r_counter      <= {MAX_COUNTER_WIDTH{1'b0}};
    end else if(r_load_dly) begin
      r_counter      <= r_counter + 1'b1;
    end
  end

  always_ff @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      r_counter_max      <= 1'b0;
    end else begin
      r_counter_max      <= w_counter_max;
    end
  end

  always_ff @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      r_sum_res      <= {OUTPUT_WIDTH{1'b0}};
    end else if(r_load_dly) begin
      r_sum_res      <= w_sum_res;
    end
  end


endmodule
