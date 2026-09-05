module sram_data_mux #(
  parameter  DATA_WIDTH                  = 32,
  parameter  NUM_BLOCKS                  = 8,
  parameter  BLOCK_SEL_ADDRESS_WIDTH     = 4 
)
(
  input   [DATA_WIDTH-1:0]                 i_data [NUM_BLOCKS-1:0],
  input   [BLOCK_SEL_ADDRESS_WIDTH-1:0]    i_addr,
  output  [DATA_WIDTH-1:0]                 o_data
);

 reg   [DATA_WIDTH-1:0]  r_out_data;    

 assign o_data = r_out_data;

 always @(*) begin
   r_out_data = {DATA_WIDTH{1'b0}};
     if(i_addr < NUM_BLOCKS) begin
        r_out_data = i_data[i_addr];
     end
 end

endmodule
