module kernal_buffer #(
  parameter SAMPLE_WIDTH            = 8, 
  parameter WINDOW                  = 3, 
  parameter ADDRESS_WIDTH           = $clog2(WINDOW)
) 
(                                   
   input                                  i_clk, 
   input                                  i_en, 
   input                                  i_wen, 
   input          [ADDRESS_WIDTH - 1:0]   i_addr,
   input   signed [SAMPLE_WIDTH    - 1:0] i_data[WINDOW-1:0],
   output  signed [SAMPLE_WIDTH    - 1:0] o_data[WINDOW-1:0] 
);

 reg [SAMPLE_WIDTH-1:0] mem [WINDOW-1:0][WINDOW-1:0];

 integer i;

  
  integer pixel_i;
  genvar  pixel_idx;
  always_ff @(posedge i_clk) begin
    if(i_en) begin
        if(i_wen) begin
           for(pixel_i =0; pixel_i < WINDOW; pixel_i = pixel_i + 1) begin
             mem[i_addr][pixel_i]     <= i_data[pixel_i];
           end
             $write("%d\n",i_addr);
        end
    end
  end

  generate 
    for(pixel_idx = 0; pixel_idx < WINDOW; pixel_idx = pixel_idx+1) begin
      assign    o_data[pixel_idx]     = mem[i_addr][pixel_idx];
    end
  endgenerate

endmodule
