  reg [SAMPLE_WIDTH-1:0]  r_kernal_input [WINDOW*WINDOW-1:0];
  integer       r_idx;

  integer i;
  task kernal_gen;
     for (i =0 ; i<WINDOW*WINDOW; i = i+ 1) begin
       r_kernal_input[i][SAMPLE_WIDTH-1]   = $random;
       r_kernal_input[i][SAMPLE_WIDTH-2:0] = $random;
     end
  endtask


  reg   [DATA_WIDTH - 1:0]   r_din;
  reg   [DATA_WIDTH - 1:0]   r_dout;
  reg                        r_wen;
  reg                        r_cen;
  reg   [ADDRESS_WIDTH-1:0]  r_addr;

  reg                        r_start;

  initial begin
    i_reset_n  = 0;
    i_clk    = 0;
    r_wen    = 1;
    r_cen    = 1;
    r_din    = 0;
    r_addr   = 0;

    r_start  = 0;
    #11;
    i_reset_n = 1;
    preload_image;
    cnn_operation;
    //SRAM_TEST;
    #100 $finish();
  end

assign i_start = r_start;
task START;
begin
    r_start  = 1;
    wait(o_done);
end
endtask


task cnn_operation;
begin
   kernal_gen;
   $display("Loading the kernal data\n");
   loading_kernal;
    START;
   //$display("\nMac operation\n");
   //loading_data;
   //$display("\nMac operation\n");
   //loading_data;
end
endtask


task loading_kernal;
 begin
   r_load_weight      = 0;
   r_load_weight_addr = 0;
   r_idx  = 0;

   repeat(WINDOW) begin
     @(posedge i_clk)
     r_load_weight      = 1;
     r_load_weight_addr = (r_idx == 0) ? 0 : r_load_weight_addr + 1;
     for(i=0; i<WINDOW; i = i+ 1) begin
       r_load_weight_data[i] = r_kernal_input[r_idx+i];
       $display("Load weight idx: %d weight data:%d",r_idx+i, r_load_weight_data[i]);
     end
     r_idx  = r_idx + WINDOW;
   end
  @(posedge i_clk)
  @(posedge i_clk)
   r_load_weight      = 0;
   r_load_weight_addr = 0;
 end
endtask


always @(posedge i_clk or negedge i_reset_n) begin
  if(!i_reset_n) begin
     i_load_weight                      <= 0;   
     i_load_weight_addr                 <= 0;  
     for(i=0; i<WINDOW; i = i+ 1) begin
       i_load_weight_data[i]            <= 0;  
     end
  end else begin
     i_load_weight             <= r_load_weight ;   
     i_load_weight_addr        <= r_load_weight_addr;  
     for(i=0; i<WINDOW; i = i+ 1) begin
       i_load_weight_data[i]   <= r_load_weight_data[i];  
     end
  end

end



 task SRAM_TEST;
    begin
       SRAM_BANK_WRITE;
       SRAM_BANK_READ;
    end
endtask

 task SRAM_BANK_WRITE;
    begin
      for(i = 0; i < NUM_BANKS; i = i + 1) begin
         SRAM_WRITE({i,{$clog2(NUM_COLS){1'b0}},{$clog2(NUM_ROWS){1'b0}}},8'($random));
         SRAM_WRITE({i,{$clog2(NUM_COLS){1'b0}},{$clog2(NUM_ROWS){1'b1}}},8'($random));
         SRAM_WRITE({i,{$clog2(NUM_COLS){1'b1}},{$clog2(NUM_ROWS){1'b0}}},8'($random));
         SRAM_WRITE({i,{$clog2(NUM_COLS){1'b1}},{$clog2(NUM_ROWS){1'b1}}},8'($random));
      end
    end
 endtask

 task SRAM_BANK_READ;
    begin
      for(i = 0; i < NUM_BANKS; i = i + 1) begin
         SRAM_READ({i,{$clog2(NUM_COLS){1'b0}},{$clog2(NUM_ROWS){1'b0}}});
         SRAM_READ({i,{$clog2(NUM_COLS){1'b0}},{$clog2(NUM_ROWS){1'b1}}});
         SRAM_READ({i,{$clog2(NUM_COLS){1'b1}},{$clog2(NUM_ROWS){1'b0}}});
         SRAM_READ({i,{$clog2(NUM_COLS){1'b1}},{$clog2(NUM_ROWS){1'b1}}});
      end
    end
 endtask


 task SRAM_WRITE;
    input   [ADDRESS_WIDTH-1:0] i_addr;
    input   [DATA_WIDTH   -1:0] i_data;
    begin
      r_cen  = 1'b0;
      r_wen  = 1'b0;
      r_din  = i_data;
      r_addr = i_addr;
      @(posedge i_clk);
      $write("SRAM WRITE ADDRESS:%h  DATA:%h\n",r_addr,r_din);
      r_cen = 1'b1;
      r_wen = 1'b1;
      r_din = {DATA_WIDTH{1'b0}};
      r_addr = {ADDRESS_WIDTH{1'b0}};
    end
 endtask


 task SRAM_READ;
    input   [ADDRESS_WIDTH-1:0] i_addr;
    begin
      r_cen  = 1'b0;
      r_wen  = 1'b1;
      r_addr = i_addr;
      @(posedge i_clk);
      $write("SRAM READ ADDRESS:%h  DATA:%h\n",r_addr,o_dout);
      r_cen = 1'b1;
      r_wen = 1'b1;
      r_addr = {ADDRESS_WIDTH{1'b0}};
    end
 endtask

 // assign     i_din   = r_din;
 // assign     i_addr  = r_addr;
 // assign     i_cen   = r_cen;
 // assign     i_wen   = r_wen;

  //always @(posedge i_clk or negedge i_reset_n) begin
  //  if(!i_reset_n) begin
  //    i_din   <= {DATA_WIDTH{1'b0}};
  //    i_addr   <= {ADDRESS_WIDTH{1'b0}};
  //    i_cen       <= 1'b1;
  //    i_wen       <= 1'b1;
  //    r_dout      <= {DATA_WIDTH{1'b0}};
  //  end else begin
  //    i_din   <= r_din;
  //    i_addr  <= r_addr;
  //    i_cen   <= r_cen;
  //    i_wen   <= r_wen;
  //    r_dout  <= o_dout; 
  //  end
  //end


    integer r, c, bank, coladdr, addr;
    integer errors, checks;
    integer cycle_count;


    // ---- expected pixel function (must match preload) ----
    function [7:0] exp_pix(input [7:0] rr, input [7:0] cc);
        exp_pix = (rr + cc) & 8'hFF;
    endfunction


    // ---- preload the 4 banks per the staggered storage scheme ----
    task preload_image;
        begin
            for (r = 0; r < IMAGE_HEIGHT; r = r + 1) begin
                for (c = 0; c < IMAGE_WIDTH; c = c + 1) begin
                    bank    = c % 4;
                    coladdr = c >> 2;
                    addr    = (r * 64) + coladdr;      // {row[7:0],col[5:0]}
                    case (bank)
                        0: u_cnn_top.u_sram_bank_top.banks[0].u_sram_matrix_array.mem_matrix[addr[13:6]][addr[5:0]] = exp_pix(r[7:0], c[7:0]);
                        1: u_cnn_top.u_sram_bank_top.banks[1].u_sram_matrix_array.mem_matrix[addr[13:6]][addr[5:0]] = exp_pix(r[7:0], c[7:0]);
                        2: u_cnn_top.u_sram_bank_top.banks[2].u_sram_matrix_array.mem_matrix[addr[13:6]][addr[5:0]] = exp_pix(r[7:0], c[7:0]);
                        3: u_cnn_top.u_sram_bank_top.banks[3].u_sram_matrix_array.mem_matrix[addr[13:6]][addr[5:0]] = exp_pix(r[7:0], c[7:0]);
                    endcase
                end
            end
            $display("[%0t] Image preload complete (256x256, pixel=(r+c)&0xFF)", $time);
        end
    endtask



