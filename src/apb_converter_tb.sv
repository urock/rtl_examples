
module apb_converter_tb;


logic PCLK;
logic PRESETn;


event reset_done_trigger;

parameter APB_ADDR_WIDTH_     =     13;
parameter APB_DATA_WIDTH_     =     32;
parameter APB_DATA_NBYTES_    =     (APB_DATA_WIDTH_/8);  

parameter NUM_BYTES           =     256; 

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



// driver

initial begin

   int p; 
   logic [APB_DATA_WIDTH_ - 1:0]  data_wr;
   logic [APB_DATA_WIDTH_ - 1:0]  data_rd;
   logic [APB_ADDR_WIDTH_ - 1:0]  addr;

   apb_in.clearAll();
   apb_out.clearAll();
   
   @(reset_done_trigger);
   $display("Reset Done");

   @(posedge PCLK);

   addr = 4; 
   data_wr = 32'h12345678;

   apb_in.masterWriteWord(addr, data_wr);

   @(posedge PCLK);
   @(posedge PCLK);


   apb_in.masterReadWord(addr, data_rd);


   if (data_rd != data_wr) begin
      $error("addr -> %04x, data_wr -> %x, data_rd -> %x", addr, data_wr, data_rd);
   end


   for (p=0; p<25; p++)
      @(negedge PCLK);

   $finish;

end


// slave memory model
initial begin
   logic [APB_ADDR_WIDTH_ - 1:0]  addr;
   logic [APB_DATA_WIDTH_ - 1:0]  data;
   logic RNW; 

   logic [7:0] mem [NUM_BYTES]; 
   int i;
   
   @(reset_done_trigger);

   while(1) begin

      apb_out.slaveReceiveTransation(RNW, addr, data);
      if (~RNW) begin
         // $display("Monitor recieved WRITE: addr -> %d, data -> %d", addr, data);

         for (i = 0; i < APB_DATA_NBYTES_; i++) begin
            mem[addr * APB_DATA_NBYTES_ + i] =  data[APB_DATA_WIDTH_ - 8*i -: 8]; 
            // $display("APB_DATA_WIDTH_ - 8*%d -> ", i, APB_DATA_WIDTH_ - 8*i); 
         end 

      end else begin
         // $display("Monitor recieved READ: addr -> %d", addr);
         for (i = 0; i < APB_DATA_NBYTES_; i++) begin
            data[APB_DATA_WIDTH_ - 8*i -: 8] = mem[addr * APB_DATA_NBYTES_ + i];
            // $display("APB_DATA_WIDTH_ - 8*%d -> ", i, APB_DATA_WIDTH_ - 8*i); 
         end         
         apb_out.slaveSendAnswer(data);
      end

   
   end

end


// checker





endmodule // apb_converter_tb
