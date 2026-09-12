module round_robin_arbiter #(
    parameter int NUM_REQ = 8
) (
    input  logic               i_clk,
    input  logic               i_reset_n,
    input  logic [NUM_REQ-1:0] i_req,
    output logic [NUM_REQ-1:0] o_grant
);

    localparam POINTER_INC_REQ = $clog2(NUM_REQ);

    logic [NUM_REQ-1:0]               w_req_shift;
    logic [NUM_REQ-1:0]               w_req_shift_prior;
    logic [NUM_REQ-1:0]               w_grant;
    logic [POINTER_INC_REQ-1:0]       r_pointer;        
    logic [POINTER_INC_REQ-1:0]       r_pointer_inc;


    integer grant_i;

    assign w_req_shift       = (i_req>>r_pointer) | (i_req<<(NUM_REQ-r_pointer));  //Right circular shift by pointer position
    assign w_req_shift_prior = w_req_shift & ~(w_req_shift-1);                     //Fixed priory encoder highest priority for LSB to MSB
    assign w_grant           = (w_req_shift_prior<<r_pointer) | (w_req_shift_prior>>(NUM_REQ-r_pointer)); //Left cirular shift y pointer position

    assign o_grant = w_grant;


    always_comb begin  //How many poisiton to be away from the current pounter
      r_pointer_inc = {POINTER_INC_REQ{1'b0}};
      for(grant_i = 0; grant_i < NUM_REQ; grant_i = grant_i + 1) begin
        if(w_req_shift_prior[grant_i]) begin
          r_pointer_inc = grant_i[POINTER_INC_REQ-1:0];
        end
      end
    end

    always_ff @(posedge i_clk or negedge i_reset_n) begin
        if (!i_reset_n) begin
            r_pointer <= {POINTER_INC_REQ{1'b0}}; // Default priority starts at bit 0
        end else if (|w_grant) begin
            // Shift left by 1 bit with wrap-around
            r_pointer <= (r_pointer + r_pointer_inc + 1'd1) % NUM_REQ;
        end
    end

endmodule
