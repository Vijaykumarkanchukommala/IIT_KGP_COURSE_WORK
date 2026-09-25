module sram_bank_top #(
  parameter int DATA_WIDTH      = 8, 
  parameter int NUM_BANKS       = 4,
  parameter int ADDRESS_WIDTH   = 14,  
  parameter int NUM_ROWS        = 256,
  parameter int NUM_COLS        = 64 
)
(                                   
   input                                    i_clk, 
   input                                    i_cen [NUM_BANKS-1:0], 
   input                                    i_wen [NUM_BANKS-1:0], 
   input            [ADDRESS_WIDTH - 1:0]   i_addr[NUM_BANKS-1:0],
   input            [DATA_WIDTH    - 1:0]   i_din [NUM_BANKS-1:0],
   output           [DATA_WIDTH    - 1:0]   o_dout[NUM_BANKS-1:0]
);

 localparam ROWS_ADDRESS_WIDTH     = $clog2(NUM_ROWS );
 localparam COLS_ADDRESS_WIDTH     = $clog2(NUM_COLS );

 wire   [DATA_WIDTH    - 1:0] w_dout [NUM_BANKS-1:0];

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
          .i_clk              (i_clk                                                  ),
          .i_cen              (i_cen [bank_i]                                         ),
          .i_wen              (i_wen [bank_i]                                         ),
          .i_row_addr         (i_addr[bank_i][COLS_ADDRESS_WIDTH+:ROWS_ADDRESS_WIDTH] ),
          .i_col_addr         (i_addr[bank_i][0+:COLS_ADDRESS_WIDTH]                  ),
          .i_din              (i_din [bank_i]                                         ),
          .o_dout             (o_dout[bank_i]                                         ) 
     );
   end
 endgenerate

endmodule
