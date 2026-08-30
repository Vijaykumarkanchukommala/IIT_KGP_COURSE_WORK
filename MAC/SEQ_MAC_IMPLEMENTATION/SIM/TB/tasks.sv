
reg [SAMPLE_WIDTH-1:0] r_kernal_input [NUM_SAMPLES-1:0];
reg [ADDRESS_WIDTH-1:0] r_idx;

integer i;
task kernal_gen;
   for (i =0 ; i<NUM_SAMPLES; i = i+ 1) begin
     r_kernal_input[i][SAMPLE_WIDTH-1]   = $random;
     r_kernal_input[i][SAMPLE_WIDTH-2:0] = $random;
   end
endtask

initial 
begin
     i_clk               = 0;
     i_reset_n           = 0;
     i_load_weight       = 0;   
     i_load_weight_addr  = 0;  
     i_data              = 0;   
     i_data_valid        = 0;   
     r_idx               = 0;

    #11;
    i_reset_n = 1;
    cnn_operation;
    #100 $finish();
end

task cnn_operation;
begin
   kernal_gen;
   $display("Loading the kernal data\n");
   loading_kernal;
   $display("Mac operation\n");
   loading_data;
   $display("Mac operation\n");
   loading_data;
end
endtask

task loading_kernal;
 begin
   r_load_weight      = 1;
   r_data_valid       = 1; 
   r_load_weight_addr = 0;
   r_idx              = 0;

   repeat(NUM_SAMPLES) begin
     @(posedge i_clk)
     r_load_weight_addr = i_load_weight_addr + 1;
     //r_data             = $random;
     r_data             = r_kernal_input[r_idx];
     $display("Load weight idx: %d weight data:%d",r_idx, r_data);
     r_idx = r_idx + 1;
   end
   r_load_weight      = 0;
   r_data_valid       = 0; 
   r_load_weight_addr = 0;
 end
endtask

task wait_for_output;
begin
  wait(o_output_valid);
  $display("Output data:%d",o_output);
end
endtask

task loading_data;
 begin
   r_load_weight      = 0;
   r_data_valid       = 1; 
   r_load_weight_addr = 0;
   r_data             = 1;
   r_idx              = 0;

   repeat(NUM_SAMPLES) begin
     @(posedge i_clk)
     //r_data             = $random;
     r_data             =  1;
     $display("Load data idx: %d data:%d",r_idx, r_data);
     r_idx = r_idx + 1;
   end
   #1;
   r_load_weight      = 0;
   r_data_valid       = 0; 
   r_load_weight_addr = 0;
   wait_for_output;
 end
endtask


always @(posedge i_clk or negedge i_reset_n) begin
  if(!i_reset_n) begin
     i_load_weight     <= 0;   
     i_load_weight_addr<= 0;  
     i_data            <= 0;  
     i_data_valid      <= 0;   
  end else begin
     i_load_weight     <= r_load_weight     ;   
     i_load_weight_addr<= r_load_weight_addr;  
     i_data            <= r_data            ;  
     i_data_valid      <= r_data_valid      ;   
  end

end

