module tb ();

  parameter DATA_WIDTH      = 8;
  parameter ADDRESS_WIDTH   = 15;
  parameter NUM_BANKS       = 4;
  parameter NUM_BLOCKS      = 8;

  reg                        i_clk,i_reset;
  reg   [DATA_WIDTH - 1:0]   i_din;
  reg                        i_wen,i_cen;
  wire  [DATA_WIDTH-1:0]     o_output;
  reg   [ADDRESS_WIDTH-1:0]  i_addr;
  wire  [DATA_WIDTH - 1:0]   o_dout;
  wire  o_valid;

  integer i;

  initial begin
    i_reset  = 0;
    i_clk    = 0;
    i_wen    = 1;
    i_cen    = 1;
    i_din   = 0;
    i_addr= 0;
    #11;
    i_reset = 1;
    #100 $finish();
  end


  always #1 i_clk = ~i_clk;


  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      i_din   <= {DATA_WIDTH{1'b0}};
    end else begin
      i_din   <= $random;
    end
  end

  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      i_addr   <= {ADDRESS_WIDTH{1'b0}};
      i_cen       <= 1'b1;
    end else begin
      i_addr   <= i_wen ? i_addr + 1 : i_addr;
      i_cen       <= 1'b0;
    end
  end


  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      i_wen       <= 1'b1;
    end else begin
      i_wen       <= i_wen ? i_cen: 1'b1;
    end
  end



  sram_banked_top #(.DATA_WIDTH(DATA_WIDTH),.ADDRESS_WIDTH(ADDRESS_WIDTH),.NUM_BANKS(NUM_BANKS),.NUM_BLOCKS(NUM_BLOCKS)) u_sram_banked_top 
  (
    .i_clk           (i_clk       ),
    .i_wen           (i_wen       ), 
    .i_cen           (i_cen        ),
    .i_addr          (i_addr      ),
    .i_din           (i_din      ),
    .o_dout          (o_dout      )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
