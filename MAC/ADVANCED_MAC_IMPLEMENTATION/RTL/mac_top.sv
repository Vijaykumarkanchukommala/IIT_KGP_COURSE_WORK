module mac_top #(parameter SAMPLE_WIDTH = 8, parameter NUM_ROWS_VS_COLUMNS = 8, parameter OUTPUT_WIDTH = 2*SAMPLE_WIDTH+$clog2(NUM_ROWS_VS_COLUMNS), DATA_WIDTH = 8, DEPTH = 4, ADDRESS_WIDTH = $clog2(DEPTH)) 
(
   input                                i_clk, 
   input                                i_reset,
   input                                i_input_sel, 
   input                                i_en, 
   input        [ADDRESS_WIDTH- 1:0]    i_addr,
   input                                i_valid,
   input        [DATA_WIDTH   - 1:0]    i_data,
   output       [OUTPUT_WIDTH - 1:0]    o_output 
);


  wire                                  w_sram_en ;
  wire                                  w_mac_en  ;
  wire                                  w_wen     ;
  wire          [ADDRESS_WIDTH -1:0]    w_ram_addr;
  wire          [ADDRESS_WIDTH -1:0]    w_mac_addr;
  wire          [DATA_WIDTH    -1:0]    w_data    ;

  assign w_wen      =  i_input_sel & i_valid;
  assign w_mac_en   = !i_input_sel & i_valid;
  assign w_sram_en  =  i_valid;
  assign w_ram_addr =  w_mac_en ? w_mac_addr : i_addr ;

  sram_single_port #(.DATA_WIDTH(DATA_WIDTH),.DEPTH(DEPTH))u_sram_single_port
  (
    .i_clk           (i_clk       ), 
    .i_en            (w_sram_en   ), 
    .i_wen           (w_wen       ), 
    .i_addr          (w_ram_addr  ),
    .i_data          (i_data      ),
    .o_data          (w_data      )
  );

  mac #(.SAMPLE_WIDTH(SAMPLE_WIDTH),.NUM_ROWS_VS_COLUMNS(NUM_ROWS_VS_COLUMNS),.OUTPUT_WIDTH(OUTPUT_WIDTH)) u_mac 
  (
    .i_clk           (i_clk       ),
    .i_reset         (i_reset     ),
    .i_A             (i_data      ),
    .i_B             (w_data      ),
    .i_valid         (w_mac_en    ),
    .o_raddr         (w_mac_addr  ),
    .o_output        (o_output    ),
    .o_valid         (o_valid     ) 
  );

endmodule
