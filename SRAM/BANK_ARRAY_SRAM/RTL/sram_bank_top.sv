module sram_bank_top #(
  parameter DATA_WIDTH      = 32, 
  parameter ADDRESS_WIDTH   = 15,  
  parameter NUM_BANKS       = 4,
  parameter NUM_ROWS        = 1024,
  parameter NUM_COLS        = 32 
)
(                                   
   input                                    i_clk, 
   input                                    i_cen, 
   input                                    i_wen, 
   input            [ADDRESS_WIDTH - 1:0]   i_addr,
   input            [DATA_WIDTH    - 1:0]   i_din,
   output           [DATA_WIDTH    - 1:0]   o_dout
);

 localparam BANK_ADDRESS_WIDTH     = ADDRESS_WIDTH-$clog2(NUM_BANKS); 
 localparam BANK_SEL_ADDRESS_WIDTH = $clog2(NUM_BANKS); 
 localparam ROWS_ADDRESS_WIDTH     = $clog2(NUM_ROWS );
 localparam COLS_ADDRESS_WIDTH     = $clog2(NUM_COLS );


 wire   [DATA_WIDTH    - 1:0] w_dout [NUM_BANKS-1:0];
 wire   [NUM_BANKS-1:0]       w_bank_sel;
 wire   [NUM_BANKS-1:0]       w_bank_sel_dly;

 genvar bank_i;
 generate
   for(bank_i = 0 ; bank_i < NUM_BANKS; bank_i = bank_i + 1) begin :banks
     sram_matrix_array 
     #(
        .DATA_WIDTH         (DATA_WIDTH            ),    
        .NUM_ROWS           (NUM_ROWS              ),  
        .NUM_COLS           (NUM_COLS              )  
     ) u_sram_matrix_array
     (
          .i_clk              (i_clk                                              ),
          .i_cen              (w_bank_sel[bank_i]                                 ),
          .i_wen              (i_wen                                              ),
          .i_row_addr         (i_addr[0+:ROWS_ADDRESS_WIDTH]                      ),
          .i_col_addr         (i_addr[ROWS_ADDRESS_WIDTH+:COLS_ADDRESS_WIDTH]     ),
          .i_din              (i_din                                              ),
          .o_dout             (w_dout[bank_i]                                     ) 
     );
   end
 endgenerate


 sram_addr_decoder
 #(
     .SEL_WIDTH              (NUM_BANKS             ),
     .SEL_ADDRESS_WIDTH      (BANK_SEL_ADDRESS_WIDTH) 
  ) 
 u_sram_addr_decoder
 (
      .i_clk                 (i_clk                                             ),
      .i_cen                 (i_cen                                             ),
      .i_addr                (i_addr[BANK_ADDRESS_WIDTH+:BANK_SEL_ADDRESS_WIDTH]),
      .o_sel                 (w_bank_sel                                        ),
      .o_sel_dly             (w_bank_sel_dly                                    )
 );

 sram_tristate_bus
 #(
     .NUM_BANKS              (NUM_BANKS             ),
     .DATA_WIDTH             (DATA_WIDTH            )     
  ) 
 u_sram_tristate_bus
 (
     .i_data                 (w_dout                ),
     .i_enable               (w_bank_sel_dly        ),
     .o_bus_output           (o_dout                )
 );
endmodule
