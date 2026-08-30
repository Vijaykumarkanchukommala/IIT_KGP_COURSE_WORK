module kernal_buffer #(
  parameter DATA_WIDTH    = 8, 
  parameter NUM_SAMPLES   = 4, 
  parameter ADDRESS_WIDTH = $clog2(NUM_SAMPLES)
) 
(                                   
   input                                  i_clk, 
   input                                  i_en, 
   input                                  i_wen, 
   input          [ADDRESS_WIDTH - 1:0]   i_addr,
   input   signed [DATA_WIDTH    - 1:0]   i_data,
   output  signed [DATA_WIDTH    - 1:0]   o_data  
);

 reg [DATA_WIDTH-1:0] mem [NUM_SAMPLES-1:0];

 integer i;

  always_ff @(posedge i_clk) begin
    if(i_en) begin
        if(i_wen) begin
           mem[i_addr]     <= i_data;
        end
    end
  end


  assign    o_data     = mem[i_addr];

endmodule
