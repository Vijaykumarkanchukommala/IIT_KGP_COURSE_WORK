module tb ();

  parameter NUM_REQ      = 8;
  parameter OUT_WIDTH    = $clog2(NUM_REQ  );

  reg      [NUM_REQ-1:0] i_req;
  wire     [OUT_WIDTH-1:0] o_grant;

  integer i;

  initial begin
    i_req  = 0;
    #11;
    repeat(256) begin
      i_req = i_req + 1;
      #1;
    end
    #100 $finish();
  end


  priority_encoder #(
    .NUM_REQ         (NUM_REQ  ),
    .OUT_WIDTH       (OUT_WIDTH)
  ) u_priority_encoder 
  (
    .i_req           (i_req      ),
    .o_grant         (o_grant    )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
