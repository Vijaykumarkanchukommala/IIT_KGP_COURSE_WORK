module sram_bank_sel_decoder #(
   parameter   BANK_SEL_ADDRESS_WIDTH = 2,
   parameter   NUM_BANKS              = 4 
)
(
   input    [BANK_SEL_ADDRESS_WIDTH-1:0] i_addr,
   output   [NUM_BANKS             -1:0] o_bank_output_enable 
);

  reg   [NUM_BANKS-1:0] r_bank_output_enable;
   

  assign o_bank_output_enable = r_bank_output_enable;

  always @(*) begin
    r_bank_output_enable = {NUM_BANKS{1'b0}};
    if(i_addr<NUM_BANKS) begin
      r_bank_output_enable[i_addr] = 1'b1;
    end
  end

endmodule
