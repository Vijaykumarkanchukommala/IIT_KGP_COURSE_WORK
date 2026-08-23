module tb ();

  parameter DATA_WIDTH = 8;
  parameter DEPTH      = 8;
  parameter ADDRESS_WIDTH = $clog2(DEPTH);

  reg                        i_clk,i_reset;
  reg   [DATA_WIDTH - 1:0]   i_data;
  reg                        i_wen,i_ren;
  wire  [DATA_WIDTH-1:0]     o_output;
  reg   [ADDRESS_WIDTH-1:0]  i_addr;
  wire  [DATA_WIDTH - 1:0]   o_data;
  wire  o_valid;

  integer i;

  initial begin
    i_reset  = 0;
    i_clk    = 0;
    i_wen    = 0;
    i_ren    = 0;
    i_data   = 0;
    i_addr= 0;
    #11;
    i_reset = 1;
    #100 $finish();
  end


  always #1 i_clk = ~i_clk;


  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      i_data   <= {DATA_WIDTH{1'b0}};
    end else begin
      i_data   <= $random;
    end
  end

  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      i_addr   <= {ADDRESS_WIDTH{1'b0}};
      i_wen       <= 1'b0;
    end else begin
      i_addr   <= i_addr + 1;
      i_wen       <= 1'b1;
    end
  end


  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      i_ren       <= 1'b0;
    end else begin
      i_ren       <= i_wen;
    end
  end



  sync_dp_ram #(.DATA_WIDTH(DATA_WIDTH),.DEPTH(DEPTH),.ADDRESS_WIDTH(ADDRESS_WIDTH)) u_sync_dp_ram 
  (
    .i_clk           (i_clk       ),
    .i_reset         (i_reset     ),
    .i_wen           (i_wen       ), 
    .i_ren           (i_ren       ),
    .i_addr          (i_addr      ),
    .i_data          (i_data      ),
    .o_data          (o_data      )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
