module tb ();

  parameter WIDTH      = 8;

  reg      [WIDTH-1:0] i_req;
  wire     [WIDTH-1:0] o_grant;

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


  bitscan #(.WIDTH(WIDTH)) u_bitscan 
  (
    .i_req           (i_req      ),
    .o_grant         (o_grant    )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
