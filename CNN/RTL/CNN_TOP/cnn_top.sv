module cnn_top #(
  parameter int IMAGE_HEIGHT         = 256,
  parameter int IMAGE_WIDTH          = 256,
  parameter int PIXEL_WIDTH          = 8,
  parameter int NUM_BANKS            = 4,
  parameter int ADDRESS_WIDTH        = 14,  
  parameter int NUM_ROWS             = 256,
  parameter int NUM_COLS             = 64, 
  parameter int WINDOW               = 3,
  parameter int SAMPLE_WIDTH         = 8, 
  parameter int OUTPUT_WIDTH         = 2*SAMPLE_WIDTH+$clog2(WINDOW*WINDOW),
  parameter int WEIGHT_ADDRESS_WIDTH = $clog2(WINDOW),
  parameter int SIGN_TYPE            = 1 //0- unsigned; 1- signed
)
(
    input                                        i_clk, 
    input                                        i_reset_n, 
    input                                        i_load_weight, 
    input          [WEIGHT_ADDRESS_WIDTH- 1:0]   i_load_weight_addr,
    input   signed [SAMPLE_WIDTH - 1:0]          i_load_weight_data[WINDOW-1:0],
    input                                        i_start,
    output                                       o_valid,
    output                                       o_done,
    output [PIXEL_WIDTH-1:0]                     o_pixel[WINDOW-1:0] 
);


  wire [ADDRESS_WIDTH-1:0]      w_addr[NUM_BANKS-1:0];
  wire                          w_wen [NUM_BANKS-1:0];
  wire                          w_cen [NUM_BANKS-1:0];
  wire [PIXEL_WIDTH  -1:0]      w_dout[NUM_BANKS-1:0]; 
  wire [PIXEL_WIDTH  -1:0]      w_din [NUM_BANKS-1:0]; 
  wire                          w_busy;

  cnn_addr_read 
  #(
     .IMAGE_HEIGHT (IMAGE_HEIGHT ), 
     .IMAGE_WIDTH  (IMAGE_WIDTH  ), 
     .PIXEL_WIDTH  (PIXEL_WIDTH  ), 
     .NUM_BANKS    (NUM_BANKS    ), 
     .ADDRESS_WIDTH(ADDRESS_WIDTH), 
     .NUM_ROWS     (NUM_ROWS     ), 
     .NUM_COLS     (NUM_COLS     ), 
     .WINDOW       (WINDOW       )  
   ) u_cnn_addr_read
   (
      .i_clk        (i_clk    ), 
      .i_reset_n    (i_reset_n), 
      .i_start      (i_start  ),
      .o_valid      (o_valid  ),
      .o_done       (o_done   ),
      .o_pixel      (o_pixel  ),
      .o_din        (w_din    ), 
      .o_addr       (w_addr   ), 
      .o_wen        (w_wen    ), 
      .o_cen        (w_cen    ), 
      .i_dout       (w_dout   ), 
      .o_busy       (w_busy   )  
   );

   sram_bank_top
   #(
     .DATA_WIDTH    (PIXEL_WIDTH  ),  
     .NUM_BANKS     (NUM_BANKS    ), 
     .ADDRESS_WIDTH (ADDRESS_WIDTH),  
     .NUM_ROWS      (NUM_ROWS     ), 
     .NUM_COLS      (NUM_COLS     )  
   ) u_sram_bank_top
   (
     .i_clk         (i_clk        ),
     .i_cen         (w_cen        ),
     .i_wen         (w_wen        ),
     .i_addr        (w_addr       ), 
     .i_din         (w_din        ), 
     .o_dout        (w_dout       )  
   );

   mac_top
   #(
     .SAMPLE_WIDTH   (SAMPLE_WIDTH         ), 
     .WINDOW         (WINDOW               ), 
     .OUTPUT_WIDTH   (OUTPUT_WIDTH         ), 
     .ADDRESS_WIDTH  (WEIGHT_ADDRESS_WIDTH ), 
     .SIGN_TYPE      (SIGN_TYPE            )  
   ) u_mac_top
   (
      .i_clk              (i_clk              ), 
      .i_reset_n          (i_reset_n          ), 
      .i_load_weight      (i_load_weight      ), 
      .i_load_weight_addr (i_load_weight_addr ), 
      .i_load_weight_data (i_load_weight_data ), 
      .i_data             (o_pixel            ), 
      .i_data_valid       (o_valid            ), 
      .i_busy             (w_busy             ), 
      .o_output           (o_output           ), 
      .o_output_valid     (o_output_valid     )  
   );



endmodule
