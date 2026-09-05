module sram_addr_decoder #(
   parameter   SEL_ADDRESS_WIDTH = 2,
   parameter   SEL_WIDTH              = 4 
)
(
   input                            i_clk,
   input                            i_cen,
   input    [SEL_ADDRESS_WIDTH-1:0] i_addr,
   output   [SEL_WIDTH        -1:0] o_sel, 
   output   [SEL_WIDTH        -1:0] o_sel_dly 
);

  reg   [SEL_WIDTH-1:0] r_bank_sel;
  reg   [SEL_WIDTH-1:0] r_bank_sel_dly;
   

  assign o_sel     = r_bank_sel;
  assign o_sel_dly = r_bank_sel_dly;

  always @(*) begin
    r_bank_sel = {SEL_WIDTH{1'b1}};
    if((i_addr<SEL_WIDTH) & !i_cen) begin
      r_bank_sel[i_addr] = 1'b0;
    end
  end

  always @(posedge i_clk) begin
     r_bank_sel_dly  <= r_bank_sel; 
  end

endmodule
