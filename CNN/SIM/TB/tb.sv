module tb ();

  parameter IMAGE_HEIGHT         = 256;
  parameter IMAGE_WIDTH          = 256;
  parameter DATA_WIDTH           = 8;
  parameter ADDRESS_WIDTH        = 14;
  parameter NUM_BANKS            = 4;
  parameter NUM_ROWS             = 256;
  parameter NUM_COLS             = 64;
  parameter WINDOW               = 3;
  parameter SAMPLE_WIDTH         = 8; 
  parameter OUTPUT_WIDTH         = 2*SAMPLE_WIDTH+$clog2(WINDOW*WINDOW);
  parameter WEIGHT_ADDRESS_WIDTH = $clog2(WINDOW);
  parameter SIGN_TYPE            = 1;//0- unsigned; 1- signed



  reg                          i_clk;
  reg                          i_reset_n;
  wire  [DATA_WIDTH - 1:0]     i_din;
  wire                         i_wen;
  wire                         i_cen;
  wire  [ADDRESS_WIDTH-1:0]    i_addr;
  wire  [DATA_WIDTH-1:0]       o_output;
  wire  [DATA_WIDTH - 1:0]     o_dout;

  wire                         i_start ; 
  wire                         o_valid ; 
  wire                         o_done  ; 
  wire [DATA_WIDTH-1:0]        o_pixel[WINDOW-1:0];

  reg                                         i_load_weight; 
  reg           [WEIGHT_ADDRESS_WIDTH- 1:0]   i_load_weight_addr;
  reg    signed [SAMPLE_WIDTH - 1:0]          i_load_weight_data[WINDOW-1:0];

  reg                                         r_load_weight; 
  reg           [WEIGHT_ADDRESS_WIDTH- 1:0]   r_load_weight_addr;
  reg    signed [SAMPLE_WIDTH - 1:0]          r_load_weight_data[WINDOW-1:0];




  `include "TB/tasks.sv"


  always #1 i_clk = ~i_clk;

  cnn_top #(
     .IMAGE_HEIGHT            (IMAGE_HEIGHT  ), 
     .IMAGE_WIDTH             (IMAGE_WIDTH   ), 
     .PIXEL_WIDTH             (DATA_WIDTH    ),
     .ADDRESS_WIDTH           (ADDRESS_WIDTH ),
     .NUM_BANKS               (NUM_BANKS     ),
     .NUM_ROWS                (NUM_ROWS      ),  
     .NUM_COLS                (NUM_COLS      ), 
     .WINDOW                  (WINDOW        ), 
     .SAMPLE_WIDTH            (SAMPLE_WIDTH          ), 
     .OUTPUT_WIDTH            (OUTPUT_WIDTH          ),    
     .WEIGHT_ADDRESS_WIDTH    (WEIGHT_ADDRESS_WIDTH  ),   
     .SIGN_TYPE               (SIGN_TYPE             )    
  ) u_cnn_top 
  (
    .i_clk             (i_clk             ),
    .i_reset_n         (i_reset_n         ),
    .i_load_weight     (i_load_weight     ), 
    .i_load_weight_addr(i_load_weight_addr),
    .i_load_weight_data(i_load_weight_data),
    .i_start           (i_start           ), 
    .o_valid           (o_valid           ),
    .o_done            (o_done            ),
    .o_pixel           (o_pixel           ) 
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end


`ifdef SHM_DUMP 
   initial begin
       $shm_open("waves.shm");  // Creates the SHM database file
       $shm_probe(tb,"A");        // Probes signals ("AS" means All ports and Static/ports/signals)
   end
`endif
endmodule
