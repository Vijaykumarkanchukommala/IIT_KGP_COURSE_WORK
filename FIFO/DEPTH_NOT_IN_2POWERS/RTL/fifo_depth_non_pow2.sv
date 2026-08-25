///////////////////////////////////////
//  coder: vijay kumar kanchukommala
///////////////////////////////////////
module fifo_depth_non_pow2 #(parameter DATA_WIDTH = 32, DEPTH = 7)(
  input                        i_clk,
  input                        i_reset,
  input                        i_valid,
  input                        i_ready,
  input   [DATA_WIDTH - 1:0]   i_data,
  output  [DATA_WIDTH - 1:0]   o_data,
  output                       o_valid,
  output                       o_ready
);

  localparam ADDRESS_WIDTH = $clog2(DEPTH);

  reg [ADDRESS_WIDTH-1:0] r_waddr,r_raddr;
  reg [ADDRESS_WIDTH  :0] r_counter; 

  wire                    w_load;
  wire                    w_accept;


  assign w_load   = i_valid & o_ready;
  assign w_accept = i_ready & o_valid;

  assign o_ready  = (r_counter != DEPTH) | w_accept; 
  assign o_valid  = (r_counter != 0)   ;
 
  // r_waddr 
  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      r_waddr <= {ADDRESS_WIDTH{1'b0}};
    end else if(w_load) begin
      if(r_waddr == DEPTH-1)
         r_waddr <= {ADDRESS_WIDTH{1'b0}};
      else
         r_waddr <= r_waddr + {{ADDRESS_WIDTH{1'b0}},1'b1};
    end 
  end

  // r_counter 
  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      r_counter <= {(ADDRESS_WIDTH+1){1'b0}};
    end else begin
      case({w_load,w_accept})
        2'b01: r_counter <= r_counter - 1'd1;
        2'b10: r_counter <= r_counter + 1'd1;
        2'b11: r_counter <= r_counter;
        default: r_counter <= r_counter; 
      endcase
    end 
  end

  // r_raddr
  always @(posedge i_clk or negedge i_reset) begin
    if(!i_reset) begin
      r_raddr <= {ADDRESS_WIDTH{1'b0}};
    end else if(w_accept) begin
      if(r_raddr == DEPTH-1)
        r_raddr <= {ADDRESS_WIDTH{1'b0}};
      else  
        r_raddr <= r_raddr + {{ADDRESS_WIDTH{1'b0}},1'b1};
    end 
  end

  sync_dp_ram_depth_non_pow2 #(.DATA_WIDTH(DATA_WIDTH),.DEPTH(DEPTH),.ADDRESS_WIDTH(ADDRESS_WIDTH)) U_ram(
        .i_clk    (i_clk                     ),
        .i_reset  (i_reset                   ),
        .i_wen    (w_load                    ),
        .i_ren    (w_accept                  ),   
        .i_waddr  (r_waddr[ADDRESS_WIDTH-1:0]),
        .i_raddr  (r_raddr[ADDRESS_WIDTH-1:0]),
        .i_data   (i_data                    ),
        .o_data   (o_data                    ) 
  );
 

endmodule
