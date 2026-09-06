module tb ();

  parameter DATA_WIDTH      = 32;
  parameter ADDRESS_WIDTH   = 15;
  parameter NUM_BANKS       = 4;
  parameter NUM_BLOCKS      = 8;

  reg                        i_clk,i_reset;
  reg   [DATA_WIDTH - 1:0]   i_din;
  reg                        i_wen,i_cen;
  reg   [ADDRESS_WIDTH-1:0]  i_addr;
  wire  [DATA_WIDTH - 1:0]   o_dout;


  `include "TB/tasks.sv"

  always #1 i_clk = ~i_clk;


  sram_bank_top #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDRESS_WIDTH(ADDRESS_WIDTH),
      .NUM_BANKS(NUM_BANKS),
      .NUM_BLOCKS(NUM_BLOCKS)
  ) u_sram_bank_top 
  (
    .i_clk           (i_clk       ),
    .i_wen           (i_wen       ), 
    .i_cen           (i_cen       ),
    .i_addr          (i_addr      ),
    .i_din           (i_din       ),
    .o_dout          (o_dout      )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
