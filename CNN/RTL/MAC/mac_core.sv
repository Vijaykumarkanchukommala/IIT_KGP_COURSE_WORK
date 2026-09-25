module mac_core #(
   parameter SAMPLE_WIDTH        = 8, 
   parameter WINDOW              = 3, 
   parameter OUTPUT_WIDTH        = 2*SAMPLE_WIDTH+$clog2(WINDOW*WINDOW),
   parameter SIGN_TYPE           = 1 //0- unsigned; 1- signed
) 
(
   input                                   i_clk, 
   input                                   i_reset_n,
   input   signed [SAMPLE_WIDTH   - 1:0]   i_A[WINDOW-1:0], 
   input   signed [SAMPLE_WIDTH   - 1:0]   i_B[WINDOW-1:0],
   input                                   i_load,
   input                                   i_load_final,
   output  signed [OUTPUT_WIDTH - 1:0]     o_output,
   output                                  o_output_valid 
);

  localparam DERIVED_MAC_OUTWIDTH = 2*SAMPLE_WIDTH  +$clog2(WINDOW);

  reg   signed    [SAMPLE_WIDTH  -1:0]            r_A[WINDOW-1:0];
  reg   signed    [SAMPLE_WIDTH  -1:0]            r_B[WINDOW-1:0];
  reg                                             r_load;
  reg             [1:0]                           r_addr_max;
  wire  signed    [2*SAMPLE_WIDTH-1:0]            w_mult_res;
  reg   signed    [OUTPUT_WIDTH - 1:0]            r_sum_res;
  wire  signed    [DERIVED_MAC_OUTWIDTH - 1:0]    w_sum_res;
  reg   signed    [OUTPUT_WIDTH - 1:0]            r_output;

  assign o_output        = r_output;
  assign o_output_valid  = r_addr_max[1];

  mac
  #(
     .SAMPLE_WIDTH   (SAMPLE_WIDTH        ), 
     .NUM_SAMPLES    (WINDOW              ), 
     .OUTPUT_WIDTH   (DERIVED_MAC_OUTWIDTH), 
     .SIGN_TYPE      (SIGN_TYPE           ) 
   ) u_mac
   (
       .i_A              (r_A           ),   
       .i_B              (r_B           ),
       .o_output         (w_sum_res     ) 
   );

  integer pixel_i;

  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(!i_reset_n) begin
      for(pixel_i =0; pixel_i < WINDOW; pixel_i = pixel_i + 1) begin
        r_A [pixel_i]    <= {SAMPLE_WIDTH  {1'b0}};
        r_B [pixel_i]    <= {SAMPLE_WIDTH  {1'b0}};
      end
    end else if(i_load) begin
      for(pixel_i =0; pixel_i < WINDOW; pixel_i = pixel_i + 1) begin
        r_A [pixel_i]    <= i_A[pixel_i];
        r_B [pixel_i]    <= i_B[pixel_i];
      end
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
      r_sum_res      <= r_sum_res + {{(OUTPUT_WIDTH-DERIVED_MAC_OUTWIDTH){w_sum_res[DERIVED_MAC_OUTWIDTH-1]}},w_sum_res};
    end
  end

  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(!i_reset_n) begin
      r_output      <= {OUTPUT_WIDTH{1'b0}};
    end else if(r_addr_max[0]) begin
      r_output      <= r_sum_res + {{(OUTPUT_WIDTH-DERIVED_MAC_OUTWIDTH){w_sum_res[DERIVED_MAC_OUTWIDTH-1]}},w_sum_res};
    end
  end

endmodule
