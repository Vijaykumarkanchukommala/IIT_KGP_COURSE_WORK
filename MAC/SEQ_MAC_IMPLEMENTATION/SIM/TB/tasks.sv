initial 
begin
     i_clk               = 0;
     i_reset_n           = 0;
     i_load_weight       = 0;   
     i_load_weight_addr  = 0;  
     i_data              = 0;   
     i_data_valid        = 0;   
     o_output            = 0;  
     o_output_valid      = 0;  

    #11;
    i_reset_n = 1;
    #100 $finish();
end






task loading_kernal;
 begin
   i_load_weight      = 1;
   i_data_valid       = 1; 
   i_load_weight_addr = 0;

   repeat(NUM_SAMPLES) begin
     @(posedge i_clk)
     i_load_weight_addr = i_load_weight_addr + 1;
     i_data             = $random;
   end
 end
endtask
