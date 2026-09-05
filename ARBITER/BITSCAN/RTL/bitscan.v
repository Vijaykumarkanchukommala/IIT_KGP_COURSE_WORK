module bitscan #(
  parameter   WIDTH = 4
)
(
   input    [WIDTH-1:0]  i_req,
   output   [WIDTH-1:0]  o_grant
);


  assign o_grant = i_req & ~(i_req-1);

endmodule 
