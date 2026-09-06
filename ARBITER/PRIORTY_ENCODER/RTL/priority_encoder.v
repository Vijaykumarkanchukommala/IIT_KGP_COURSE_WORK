module priority_encoder #(
  parameter  NUM_REQ   = 4,
  parameter  OUT_WIDTH = $clog2(NUM_REQ)
)
(
   input    [NUM_REQ  -1:0]  i_req,
   output   [OUT_WIDTH-1:0]  o_grant
);


   wire  [NUM_REQ  -1:0] w_req_sel;
   reg   [OUT_WIDTH-1:0] r_grant  ;

   integer bit_i;
   
   assign w_req_sel = i_req & ~(i_req-1);
   assign o_grant   = r_grant;


   always @(*) begin
     r_grant = {OUT_WIDTH{1'b0}};
     for(bit_i = 0; bit_i < NUM_REQ; bit_i = bit_i + 1) begin
        if(w_req_sel[bit_i]) begin
          r_grant = bit_i[OUT_WIDTH-1:0];
        end
     end  
   end

endmodule
