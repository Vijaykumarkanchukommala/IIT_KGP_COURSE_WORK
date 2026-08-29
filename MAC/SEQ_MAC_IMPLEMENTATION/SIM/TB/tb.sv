module tb ();

  parameter SAMPLE_WIDTH            = 8;
  parameter NUM_SAMPLES             = 9;
  parameter OUTPUT_WIDTH            = 2*SAMPLE_WIDTH+$clog2(NUM_SAMPLES);
  parameter DATA_WIDTH              = 8; 
  parameter DEPTH                   = NUM_SAMPLES; 
  parameter ADDRESS_WIDTH           = $clog2(DEPTH);




  reg                                              i_clk,i_reset_n;

  reg                                              i_load_weight     ;     
  reg           [ADDRESS_WIDTH-1:0]                i_load_weight_addr;
  reg           [DATA_WIDTH   -1:0]                i_data            ;              
  reg                                              i_data_valid      ;      
  reg                                              r_load_weight     ;     
  reg           [ADDRESS_WIDTH-1:0]                r_load_weight_addr;
  reg           [DATA_WIDTH   -1:0]                r_data            ;              
  reg                                              r_data_valid      ;     
  wire          [OUTPUT_WIDTH -1:0]                o_output          ;          
  wire                                             o_output_valid    ;   


  `include "TB/tasks.sv"


  always #1 i_clk = ~i_clk;


  mac_top #(
    .SAMPLE_WIDTH            (SAMPLE_WIDTH       ),       
    .NUM_SAMPLES             (NUM_SAMPLES        ), 
    .OUTPUT_WIDTH            (OUTPUT_WIDTH       ), 
    .DATA_WIDTH              (DATA_WIDTH         ), 
    .DEPTH                   (DEPTH              ), 
    .ADDRESS_WIDTH           (ADDRESS_WIDTH      )  
  ) u_mac_top
  (
     .i_clk                  (i_clk             ),      
     .i_reset_n              (i_reset_n         ), 
     .i_load_weight          (i_load_weight     ),  
     .i_load_weight_addr     (i_load_weight_addr),  
     .i_data                 (i_data            ),
     .i_data_valid           (i_data_valid      ),
     .o_output               (o_output          ),
     .o_output_valid         (o_output_valid    ) 
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
