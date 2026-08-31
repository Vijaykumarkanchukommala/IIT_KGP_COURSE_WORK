module sram_bank #(
  parameter DATA_WIDTH      = 32, 
  parameter ADDRESS_WIDTH   = 13,  
  parameter NUM_BLOCKS      = 8 , 
) 
(                                   
   input                                    i_clk, 
   input                                    i_cen, 
   input                                    i_wen, 
   input            [ADDRESS_WIDTH - 1:0]   i_addr,
   input            [DATA_WIDTH    - 1:0]   i_din,
   output           [DATA_WIDTH    - 1:0]   o_dout
);

 local ADDRESS_WIDTH_OF_BLOCK = ADDRESS_WIDTH >> $clog2(NUM_BLOCKS); 

 genvar block_i;
 generate
   for(block_i = 0 ; block_i < NUM_BLOCKS; block_i = block_i + 1) begin :Blocks
     sram_block 
     (
        .DATA_WIDTH         (DATA_WIDTH            ),    
        .ADDRESS_WIDTH      (ADDRESS_WIDTH_OF_BLOCK), 
     ) u_sram_block
          .i_clk              (i_clk                             ),
          .i_cen              (i_cen                             ),
          .i_wen              (i_wen                             ),
          .i_addr             (i_addr[ADDRESS_WIDTH_OF_BLOCK-1:0]),
          .i_din              (i_din                             ),
          .o_dout             (o_dout                            ),
     );
   end
 endgenerate

endmodule
