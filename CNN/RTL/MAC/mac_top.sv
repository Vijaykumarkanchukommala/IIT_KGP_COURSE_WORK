module mac_top #(
  parameter SAMPLE_WIDTH            = 8, 
  parameter WINDOW                  = 3, 
  parameter NUM_SAMPLES             = 8, //Number of samples 
  parameter OUTPUT_WIDTH            = 2*SAMPLE_WIDTH+$clog2(WINDOW*WINDOW), 
  parameter ADDRESS_WIDTH           = $clog2(WINDOW),
  parameter SIGN_TYPE               = 1 //0- unsigned; 1- signed
) 
(
   input                                  i_clk                         , 
   input                                  i_reset_n                     ,
   input                                  i_load_weight                 , 
   input          [ADDRESS_WIDTH- 1:0]    i_load_weight_addr            ,
   input   signed [SAMPLE_WIDTH - 1:0]    i_load_weight_data[WINDOW-1:0],
   input   signed [SAMPLE_WIDTH - 1:0]    i_data            [WINDOW-1:0],
   input                                  i_data_valid                  ,
   input                                  i_busy                        ,
   output  signed [OUTPUT_WIDTH - 1:0]    o_output                      , 
   output                                 o_output_valid                 
);

  localparam NUM_SAMPLE_PER_CLK = WINDOW*SAMPLE_WIDTH;

  wire                                  w_ram_en                    ;
  wire                                  w_mac_load                  ;
  wire                                  w_ram_wen                   ;
  wire                                  w_mac_load_final            ;
  wire          [ADDRESS_WIDTH -1:0]    w_ram_addr                  ;
  wire          [ADDRESS_WIDTH -1:0]    w_mac_addr                  ;
  wire   signed [SAMPLE_WIDTH  -1:0]    w_data          [WINDOW-1:0];


  ctrl #( 
    .NUM_SAMPLES          (WINDOW             ),
    .ADDRESS_WIDTH        (ADDRESS_WIDTH      )
  )u_ctrl
  (
    .i_clk                (i_clk              ),
    .i_reset_n            (i_reset_n          ),
    .i_load_weight        (i_load_weight      ),
    .i_load_weight_addr   (i_load_weight_addr ),
    .i_data_valid         (i_data_valid       ),
    .i_busy               (i_busy             ),
    .o_ram_en             (w_ram_en           ),
    .o_ram_wen            (w_ram_wen          ),
    .o_mac_load           (w_mac_load         ),
    .o_mac_load_final     (w_mac_load_final   ),
    .o_ram_addr           (w_ram_addr         ) 
  );

  kernal_buffer #(
    .SAMPLE_WIDTH         (SAMPLE_WIDTH       ),
    .WINDOW               (WINDOW             ),
    .ADDRESS_WIDTH        (ADDRESS_WIDTH      )
  )u_kernal_buffer
  (
    .i_clk                (i_clk              ), 
    .i_en                 (w_ram_en           ), 
    .i_wen                (w_ram_wen          ), 
    .i_addr               (w_ram_addr         ),
    .i_data               (i_load_weight_data ),
    .o_data               (w_data             )
  );

  mac_core #(
    .SAMPLE_WIDTH         (SAMPLE_WIDTH       ),
    .WINDOW               (WINDOW             ),
    .OUTPUT_WIDTH         (OUTPUT_WIDTH       ),
    .SIGN_TYPE            (SIGN_TYPE          )
  ) u_mac_core 
  (
    .i_clk                (i_clk              ),
    .i_reset_n            (i_reset_n          ),
    .i_A                  (i_data             ),
    .i_B                  (w_data             ),
    .i_load               (w_mac_load         ),
    .i_load_final         (w_mac_load_final   ),
    .o_output             (o_output           ),
    .o_output_valid       (o_output_valid     ) 
  );

endmodule
