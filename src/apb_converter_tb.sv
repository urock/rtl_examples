
module apb_converter_tb;


logic PCLK;
logic PRESETn;


event reset_done_trigger;

parameter APB_ADDR_WIDTH_     =     13;
parameter APB_DATA_WIDTH_     =     32;
parameter APB_DATA_NBYTES_    =     (APB_DATA_WIDTH_/8);  

parameter NUM_BYTES           =     256; 

typedef logic [APB_DATA_WIDTH_ - 1:0] m_data_t;
typedef logic [APB_ADDR_WIDTH_ - 1:0] m_addr_t;


// declare interfaces
apb_if  #(
      .APB_ADDR_WIDTH (APB_ADDR_WIDTH_),
      .APB_DATA_WIDTH (APB_DATA_WIDTH_)
   ) apb_in (
      PCLK, PRESETn
   );

apb_if  #(
      .APB_ADDR_WIDTH (APB_ADDR_WIDTH_),
      .APB_DATA_WIDTH (APB_DATA_WIDTH_)
   ) apb_out (
      PCLK, PRESETn
   );


default clocking cb_counter @(posedge PCLK); // clocking block for testbench 
   default input #1step output #2; 
endclocking


initial begin
   PCLK = 0;
   PRESETn = 0; 
   ##3 PRESETn = 1;
   -> reset_done_trigger; 
end

always begin
   #5  PCLK = ! PCLK;     
end


// dut
apb_converter # (
      .ADDRM_WIDTH (APB_ADDR_WIDTH_),
      .DATAM_WIDTH (APB_DATA_WIDTH_),
      .ADDRS_WIDTH (APB_ADDR_WIDTH_),
      .DATAS_WIDTH (APB_DATA_WIDTH_)    
   ) converter (
      apb_in,
      apb_out
   );



function automatic m_data_t get_data_with_apb_width(input int byte_addr, const ref logic [7:0] data_array[NUM_BYTES]);
   m_data_t data_word;

   for (int i = 0; i < APB_DATA_NBYTES_; i++) begin
      data_word[APB_DATA_WIDTH_ - 8*i -: 8] = data_array[byte_addr + i];
   end

   return data_word;
endfunction : get_data_with_apb_width


// master device 
initial begin

   logic error;
   int p; 
   m_data_t  data_wr;
   m_data_t  data_rd;
   m_addr_t  addr;
   logic [7:0] test_data [NUM_BYTES]; 

   apb_in.clearAll();
   apb_out.clearAll();

   //create randow test data array
   for (p = 0; p < NUM_BYTES; p++)
      test_data[p] = $urandom_range(255,0);

   
   @(reset_done_trigger);
   $display("Reset Done");
   error = 0;

   @(posedge PCLK);

   for (addr = 0; addr < NUM_BYTES; addr += APB_DATA_NBYTES_) begin

      data_wr = get_data_with_apb_width(addr, test_data);

      apb_in.masterWriteWord(addr, data_wr);

      apb_in.masterReadWord(addr, data_rd);

      if (data_rd != data_wr) begin
         $error("addr -> %04x ERROR: data_wr -> %x, data_rd -> %x", addr, data_wr, data_rd);
         error = 1; 
      end else begin
         $display("addr -> %04x OK", addr);
      end
   end

   $display("====================================");
   if (error) begin
      $display("Test FAILED");
   end else begin
      $display("Test OK");
   end 
   $display("====================================");

   for (p=0; p<5; p++)
      @(negedge PCLK);

   $finish;

end


// slave memory model
initial begin
   m_addr_t  addr;
   m_data_t  data;
   logic RNW; 

   logic [7:0] mem [NUM_BYTES]; 
   int i;
   
   @(reset_done_trigger);

   while(1) begin

      apb_out.slaveReceiveTransation(RNW, addr, data);
      if (~RNW) begin
         // $display("Monitor recieved WRITE: addr -> %d, data -> %d", addr, data);

         for (i = 0; i < APB_DATA_NBYTES_; i++) begin
            mem[addr + i] =  data[APB_DATA_WIDTH_ - 8*i -: 8];  
         end 

      end else begin
         data = get_data_with_apb_width(addr, mem);       
         apb_out.slaveSendAnswer(data);
      end

   
   end

end


// checker





endmodule // apb_converter_tb