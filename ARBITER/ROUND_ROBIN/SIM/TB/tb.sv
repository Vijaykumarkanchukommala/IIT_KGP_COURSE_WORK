module tb ();

  parameter WIDTH      = 4;


  reg                  i_clk;
  reg                  i_reset_n;
  reg      [WIDTH-1:0] i_req,r_req;
  wire     [WIDTH-1:0] o_grant;

  integer i;

  initial begin
    i_clk   =0;
    r_req  = 0;
    i_reset_n = 0;
    #11;
    i_reset_n = 1;
    r_req   = {WIDTH{1'b1}};
    repeat(256) begin
      r_req = $random;
      #1;
    end
    #100
    r_req   = {WIDTH{1'b0}};
    #100 $finish();
  end


  always @(posedge i_clk or negedge i_reset_n) begin
    if(!i_reset_n) begin
      i_req  <= 0;
    end else begin
      i_req  <= r_req;
    end
  end


  //1111 -> 11111111 -> 11111111 -> 00010001 -> 0001 0-> 00010001 -> 00010001 ->0001 
  //1100 -> 11001100 -> 01100110 -> 00000010 -> 0010 1-> 00100010 -> 01000100 ->0100
  //1100 -> 11001100 -> 00011001 -> 00000001 -> 0001 3-> 00010001 -> 10001000 ->1000
  //1110 -> 11101110 -> 11101110 -> 00000010 -> 0010 0-> 00100010 -> 00100010 ->0010 
  //1110 -> 11101110 -> 00111011 -> 00000001 -> 0001 2-> 00010001 -> 01000100 ->0100 
  //1110 -> 11101110 -> 00011101 -> 00000001 -> 0001 3-> 00010001 -> 10001000 ->1000 
  //1001 -> 10011001 -> 10011001 -> 00000001 -> 0001 0-> 00010001 -> 00010001 ->0001 
  //1001 -> 10011001 -> 01001100 -> 00000100 -> 0100 1-> 01000100 -> 10001000 ->1000 


  always #1 i_clk = ~i_clk;


  round_robin_arbiter #(.WIDTH(WIDTH)) u_round_robin_arbiter 
  (
    .i_clk           (i_clk      ),
    .i_reset_n       (i_reset_n  ),
    .i_req           (i_req      ),
    .o_grant         (o_grant    )
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
