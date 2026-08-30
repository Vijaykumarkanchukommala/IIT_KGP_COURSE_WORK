integer i;
initial 
begin
     i_clk               = 0;
     i_reset_n           = 0;
     r_load_weight       = 0;   
     r_load_weight_addr  = 0;  
     r_data_valid        = 0;   
     r_weight_data       = 0;   
     for(i=0; i<NUM_SAMPLES; i = i+ 1) begin
       r_data[i]              = 0;   
     end

    #11;
    i_reset_n = 1;
    cnn_operation;
    #100 $finish();
end



task cnn_operation;
begin
   loading_kernal;
   loading_data;
   loading_data;
end
endtask


task loading_kernal;
 begin
   r_load_weight      = 1;
   r_data_valid       = 1; 
   r_load_weight_addr = 0;

   repeat(NUM_SAMPLES) begin
     @(posedge i_clk)
     r_load_weight_addr = i_load_weight_addr + 1;
     r_weight_data      = $random;
   end
   r_load_weight      = 0;
   r_data_valid       = 0; 
   r_load_weight_addr = 0;
 end
endtask

task loading_data;
 begin
   r_load_weight      = 0;
   r_data_valid       = 1; 
   r_load_weight_addr = 0;
   for(i=0; i<NUM_SAMPLES; i = i+ 1) begin
     r_data[i]              = 1;   
   end
   #1;
   r_load_weight      = 0;
   r_data_valid       = 0; 
   r_load_weight_addr = 0;
 end
endtask


always @(posedge i_clk or negedge i_reset_n) begin
  if(!i_reset_n) begin
     i_load_weight     <= 0;   
     i_load_weight_addr<= 0;  
     i_weight_data     <= 0;  
     for(i=0; i<NUM_SAMPLES; i = i+ 1) begin
       i_data[i]            <= 0;  
     end
     i_data_valid      <= 0;   
  end else begin
     i_load_weight     <= r_load_weight     ;   
     i_load_weight_addr<= r_load_weight_addr;  
     i_weight_data     <= r_weight_data     ;  
     for(i=0; i<NUM_SAMPLES; i = i+ 1) begin
       i_data[i]            <= r_data[i];  
     end
     i_data_valid      <= r_data_valid      ;   
  end

end

