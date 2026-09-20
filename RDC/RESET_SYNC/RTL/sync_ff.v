module sync_ff #(parameter WIDTH = 1, RESET_POLARITY = 1'b1) (
    input  wire             clk,
    input  wire             rst_n,
    output reg  [WIDTH-1:0] q
);
    reg [WIDTH-1:0] d_meta;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin 
          d_meta <= {WIDTH{RESET_POLARITY}}; 
          q      <= {WIDTH{RESET_POLARITY}}; 
        end else begin 
          d_meta <= {WIDTH{~RESET_POLARITY}};              
          q <= d_meta;        
        end
    end
endmodule
