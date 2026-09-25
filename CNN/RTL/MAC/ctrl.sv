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
  input                                  i_busy             , 
  output                                 o_ram_en           ,
  output                                 o_ram_wen          ,
  output                                 o_mac_load         ,
  output                                 o_mac_load_final   ,
  output   [ADDRESS_WIDTH-1:0]           o_ram_addr           

);

  reg   [ADDRESS_WIDTH -1:0]    r_raddr;

  assign o_mac_load       = i_busy & i_data_valid;
  assign o_ram_addr       = o_ram_wen ? i_load_weight_addr : r_raddr ;
  assign o_ram_wen        = !i_busy & i_load_weight;
  assign o_ram_en         =  (!i_busy & i_load_weight) | i_data_valid;
  assign o_mac_load_final = (r_raddr ==  NUM_SAMPLES - 1) & o_mac_load;

  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(!i_reset_n) begin
      r_raddr      <= {ADDRESS_WIDTH{1'b0}};
    end else if(o_mac_load_final) begin
      r_raddr      <= {ADDRESS_WIDTH{1'b0}};
    end else if(o_mac_load) begin
      r_raddr      <= r_raddr + 1'b1;
    end
  end

endmodule
