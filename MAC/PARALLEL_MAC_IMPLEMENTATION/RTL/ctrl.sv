module ctrl 
#(
  parameter NUM_SAMPLES   = 8, 
  parameter ADDRESS_WIDTH = $clog2(NUM_SAMPLES)
)
(
  input                                  i_clk              ,          
  input                                  i_reset_n          , 
  input                                  i_load_weight      , 
  input    [ADDRESS_WIDTH-1:0]           i_load_weight_addr ,
  input                                  i_data_valid       , 
  output                                 o_sram_en          ,
  output                                 o_sram_wen         ,
  output                                 o_mac_load         ,
  output   [ADDRESS_WIDTH-1:0]           o_ram_addr           

);

  reg   [ADDRESS_WIDTH -1:0]    r_raddr;

  assign o_mac_load       = !i_load_weight & i_data_valid;
  assign o_ram_addr       = i_load_weight_addr;
  assign o_sram_wen       = i_load_weight & i_data_valid;
  assign o_sram_en        = i_data_valid;

endmodule
