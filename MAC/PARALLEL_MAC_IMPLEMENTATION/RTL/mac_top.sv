module mac_top #(
  parameter SAMPLE_WIDTH            = 8, //Pixel width 
  parameter NUM_SAMPLES             = 8, //Number of samples 
  parameter OUTPUT_WIDTH            = 2*SAMPLE_WIDTH+$clog2(NUM_SAMPLES), 
  parameter DATA_WIDTH              = 8, 
  parameter ADDRESS_WIDTH           = $clog2(NUM_SAMPLES),
  parameter ADDER_TYPE              = 0  //0- unsigned; 1- signed
) 
(
   input                                i_clk             , 
   input                                i_reset_n         ,
   input                                i_load_weight     , 
   input        [ADDRESS_WIDTH- 1:0]    i_load_weight_addr,
   input        [DATA_WIDTH   - 1:0]    i_weight_data     ,
   input        [DATA_WIDTH   - 1:0]    i_data            [NUM_SAMPLES-1:0],
   input                                i_data_valid      ,
   output       [OUTPUT_WIDTH - 1:0]    o_output          , 
   output                               o_output_valid     
);


  wire                                  w_sram_en       ;
  wire                                  w_mac_load      ;
  wire                                  w_sram_wen      ;
  wire          [ADDRESS_WIDTH -1:0]    w_ram_addr      ;
  wire          [ADDRESS_WIDTH -1:0]    w_mac_addr      ;
  wire          [DATA_WIDTH    -1:0]    w_data          [NUM_SAMPLES-1:0];


  ctrl #( 
    .NUM_SAMPLES          (NUM_SAMPLES        ),
    .ADDRESS_WIDTH        (ADDRESS_WIDTH      )
  )u_ctrl
  (
  //.i_clk                (i_clk              ),
  //.i_reset_n            (i_reset_n          ),
    .i_load_weight        (i_load_weight      ),
    .i_load_weight_addr   (i_load_weight_addr ),
    .i_data_valid         (i_data_valid       ),
    .o_sram_en            (w_sram_en          ),
    .o_sram_wen           (w_sram_wen         ),
    .o_mac_load           (w_mac_load         ),
    .o_ram_addr           (w_ram_addr         ) 
  );

  sram_single_port #(
    .DATA_WIDTH           (DATA_WIDTH         ),
    .NUM_SAMPLES          (NUM_SAMPLES        ),
    .ADDRESS_WIDTH        (ADDRESS_WIDTH      )
  )u_sram_single_port
  (
    .i_clk                (i_clk              ), 
    .i_en                 (w_sram_en          ), 
    .i_wen                (w_sram_wen         ), 
    .i_addr               (w_ram_addr         ),
    .i_data               (i_weight_data      ),
    .o_data               (w_data             )
  );

  mac_core #(
    .SAMPLE_WIDTH         (SAMPLE_WIDTH       ),
    .NUM_SAMPLES          (NUM_SAMPLES        ),
    .OUTPUT_WIDTH         (OUTPUT_WIDTH       ),
    .ADDER_TYPE           (ADDER_TYPE         )
  ) u_mac_core 
  (
  //.i_clk                (i_clk              ),
  //.i_reset_n            (i_reset_n          ),
    .i_A                  (i_data             ),
    .i_B                  (w_data             ),
    .i_load               (w_mac_load         ),
    .o_output             (o_output           ),
    .o_output_valid       (o_output_valid     ) 
  );

endmodule
