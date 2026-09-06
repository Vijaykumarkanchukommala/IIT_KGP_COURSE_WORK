module tb ();

  parameter DATA_WIDTH      = 8;
  parameter ADDRESS_WIDTH   = 17;
  parameter NUM_BANKS       = 4;
  parameter NUM_ROWS        = 1024;
  parameter NUM_COLS        = 32;

  reg                          i_clk,i_reset;
  wire    [DATA_WIDTH - 1:0]   i_din;
  wire                         i_wen;
  wire                         i_cen;
  wire    [ADDRESS_WIDTH-1:0]  i_addr;
  wire  [DATA_WIDTH-1:0]       o_output;
  wire  [DATA_WIDTH - 1:0]     o_dout;
  wire                         o_valid;

  `include "TB/tasks.sv"


  always #1 i_clk = ~i_clk;

  sram_bank_top #(
     .DATA_WIDTH     (DATA_WIDTH    ),
     .ADDRESS_WIDTH  (ADDRESS_WIDTH ),
     .NUM_BANKS      (NUM_BANKS     ),
     .NUM_ROWS       (NUM_ROWS      ),  
     .NUM_COLS       (NUM_COLS      )  
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
