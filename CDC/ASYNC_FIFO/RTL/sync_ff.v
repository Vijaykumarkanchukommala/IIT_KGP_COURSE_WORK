module sync_ff #(parameter WIDTH = 1) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    reg [WIDTH-1:0] d_meta;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin 
          d_meta <= {WIDTH{1'b0}}; 
          q <= {WIDTH{1'b0}}; end
        else        begin 
          d_meta <= d;              
          q <= d_meta;        
        end
    end
endmodule
