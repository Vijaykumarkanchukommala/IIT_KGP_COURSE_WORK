module mac_top #(
  parameter SAMPLE_WIDTH            = 8, //Pixel width 
  parameter NUM_SAMPLES             = 8, //Number of samples 
  parameter OUTPUT_WIDTH            = 2*SAMPLE_WIDTH+$clog2(NUM_SAMPLES), 
  parameter DATA_WIDTH              = 8, 
  parameter ADDRESS_WIDTH           = $clog2(NUM_SAMPLES),
  parameter SIGN_TYPE               = 1 //0- unsigned; 1- signed
) 
(
   input                                  i_clk             , 
   input                                  i_reset_n         ,
   input                                  i_load_weight     , 
   input          [ADDRESS_WIDTH- 1:0]    i_load_weight_addr,
   input   signed [DATA_WIDTH   - 1:0]    i_data            ,
   input                                  i_data_valid      ,
   output  signed [OUTPUT_WIDTH - 1:0]    o_output          , 
   output                                 o_output_valid     
);


  wire                                  w_sram_en       ;
  wire                                  w_mac_load      ;
  wire                                  w_sram_wen      ;
  wire                                  w_mac_load_final;
  wire          [ADDRESS_WIDTH -1:0]    w_ram_addr      ;
  wire          [ADDRESS_WIDTH -1:0]    w_mac_addr      ;
  wire   signed [DATA_WIDTH    -1:0]    w_data          ;


  ctrl #( 
    .NUM_SAMPLES          (NUM_SAMPLES        ),
    .ADDRESS_WIDTH        (ADDRESS_WIDTH      )
  )u_ctrl
  (
    .i_clk                (i_clk              ),
    .i_reset_n            (i_reset_n          ),
    .i_load_weight        (i_load_weight      ),
    .i_load_weight_addr   (i_load_weight_addr ),
    .i_data_valid         (i_data_valid       ),
    .o_sram_en            (w_sram_en          ),
    .o_sram_wen           (w_sram_wen         ),
    .o_mac_load           (w_mac_load         ),
    .o_mac_load_final     (w_mac_load_final   ),
    .o_ram_addr           (w_ram_addr         ) 
  );

  kernal_buffer #(
    .DATA_WIDTH           (DATA_WIDTH         ),
    .NUM_SAMPLES          (NUM_SAMPLES        ),
    .ADDRESS_WIDTH        (ADDRESS_WIDTH      )
  )u_kernal_buffer
  (
    .i_clk                (i_clk              ), 
    .i_en                 (w_sram_en          ), 
    .i_wen                (w_sram_wen         ), 
    .i_addr               (w_ram_addr         ),
    .i_data               (i_data             ),
    .o_data               (w_data             )
  );

  mac_core #(
    .SAMPLE_WIDTH         (SAMPLE_WIDTH       ),
    .NUM_SAMPLES          (NUM_SAMPLES        ),
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
