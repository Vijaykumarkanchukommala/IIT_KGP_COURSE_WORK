module sram_bank #(
  parameter DATA_WIDTH              = 32, 
  parameter BANK_ADDRESS_WIDTH      = 13,  
  parameter NUM_BLOCKS              = 8   
) 
(                                   
   input                                            i_clk, 
   input                                            i_cen, 
   input                                            i_wen, 
   input            [BANK_ADDRESS_WIDTH - 1:0]      i_addr,
   input            [DATA_WIDTH    - 1:0]           i_din,
   output           [DATA_WIDTH    - 1:0]           o_dout
);

 localparam BLOCK_ADDRESS_WIDTH = BANK_ADDRESS_WIDTH-$clog2(NUM_BLOCKS); 

 wire   [DATA_WIDTH    - 1:0] w_dout [NUM_BLOCKS-1:0];


 wire   [NUM_BLOCKS-1:0]       w_block_sel;

 sram_addr_decoder #(.INPUT_WIDTH($clog2(NUM_BLOCKS)),.OUTPUT_WIDTH(NUM_BLOCKS))
 u_sram_addr_decoder
 (
    .i_cen             (i_cen                                            ),
    .i_addr            (i_addr[BANK_ADDRESS_WIDTH-1:BLOCK_ADDRESS_WIDTH] ),
    .o_bank_sel        (w_block_sel                                      ) 
 ); 

 genvar block_i;
 generate
   for(block_i = 0 ; block_i < NUM_BLOCKS; block_i = block_i + 1) begin :Blocks
     sram_block 
     #(
        .DATA_WIDTH              (DATA_WIDTH            ),    
        .BLOCK_ADDRESS_WIDTH     (BLOCK_ADDRESS_WIDTH   )  
     ) u_sram_block
     (
          .i_clk              (i_clk                          ),
          .i_cen              (w_block_sel[block_i]           ),
          .i_wen              (i_wen                          ),
          .i_addr             (i_addr[BLOCK_ADDRESS_WIDTH-1:0]),
          .i_din              (i_din                          ),
          .o_dout             (w_dout[block_i]                ) 
     );
   end
 endgenerate

endmodule
