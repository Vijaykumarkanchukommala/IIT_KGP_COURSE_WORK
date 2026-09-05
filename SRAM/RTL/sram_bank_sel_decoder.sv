module sram_bank_sel_decoder #(
   parameter   BANK_SEL_ADDRESS_WIDTH = 2,
   parameter   NUM_BANKS              = 4 
)
(
   input                                 i_clk,
   input                                 i_cen,
   input    [BANK_SEL_ADDRESS_WIDTH-1:0] i_addr,
   output   [NUM_BANKS             -1:0] o_bank_sel, 
   output   [NUM_BANKS             -1:0] o_bank_sel_dly 
);

  reg   [NUM_BANKS-1:0] r_bank_sel;
  reg   [NUM_BANKS-1:0] r_bank_sel_dly;
   

  assign o_bank_sel     = r_bank_sel;
  assign o_bank_sel_dly = r_bank_sel_dly;

  always @(*) begin
    r_bank_sel = {NUM_BANKS{1'b1}};
    if((i_addr<NUM_BANKS) & !i_cen) begin
      r_bank_sel[i_addr] = 1'b0;
    end
  end

  always @(posedge i_clk) begin
     r_bank_sel_dly  <= r_bank_sel; 
  end

endmodule
