module round_robin_arbiter #(
    parameter int WIDTH = 8
) (
    input  logic             i_clk,
    input  logic             i_reset_n,
    input  logic [WIDTH-1:0] i_req,
    output logic [WIDTH-1:0] o_grant
);

    localparam POINTER_INC_WIDTH = $clog2(WIDTH);

    logic [2*WIDTH-1:0]             w_req_frame;
    logic [2*WIDTH-1:0]             w_req_fram_shift;
    logic [2*WIDTH-1:0]             w_req_fram_shift_prior;
    logic [WIDTH  -1:0]             w_grant_shift;
    logic [2*WIDTH-1:0]             w_grant_frame;
    logic [POINTER_INC_WIDTH-1:0]   r_pointer;        
    logic [POINTER_INC_WIDTH-1:0]   r_pointer_inc;


    integer grant_i;

    assign w_req_frame = {i_req,i_req};
    assign w_req_fram_shift = w_req_frame>>r_pointer;
    assign w_req_fram_shift_prior = w_req_fram_shift & ~(w_req_fram_shift-1);
    assign w_grant_shift = w_req_fram_shift_prior[WIDTH-1:0]; 
    assign w_grant_frame = {w_grant_shift,w_grant_shift}<<r_pointer;


    // 5. Select masked grant if valid; otherwise select wrap-around grant
    assign o_grant = w_grant_frame[WIDTH+:WIDTH];


    always @(*) begin
      r_pointer_inc = {POINTER_INC_WIDTH{1'b0}};
      for(grant_i = 0; grant_i < WIDTH; grant_i = grant_i + 1) begin
        if(w_grant_shift[grant_i]) begin
          r_pointer_inc = grant_i[POINTER_INC_WIDTH-1:0];
        end
      end
    end

    // 6. Update round-robin pointer to next index (rotates left)
    always_ff @(posedge i_clk or negedge i_reset_n) begin
        if (!i_reset_n) begin
            r_pointer <= {POINTER_INC_WIDTH{1'b0}}; // Default priority starts at bit 0
        end else if (|o_grant) begin
            // Shift left by 1 bit with wrap-around
            r_pointer <= r_pointer + r_pointer_inc + 1'd1;
        end
    end

endmodule
