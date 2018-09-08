interface apb_if
#(
   APB_ADDR_WIDTH = 0,
   APB_DATA_WIDTH = 0
)
(
   input  wire                PCLK,
   input  wire                PRESETn
);
   logic [APB_ADDR_WIDTH - 1:0]  PADDR;
   logic                         PWRITE;
   logic                         PREADY;
   logic [APB_DATA_WIDTH - 1:0]  PWDATA;
   logic [APB_DATA_WIDTH - 1:0]  PRDATA;
   logic                         PSEL;
   logic                         PENABLE;
   logic                         PSLVERR;

   modport slave_mp (
      input                   PCLK,
                              PRESETn,
                              PADDR,
                              PWRITE,
                              PWDATA,
                              PSEL,
                              PENABLE,
      output                  PREADY,
                              PRDATA,
                              PSLVERR
   );

      modport master_mp (
      output                  PADDR,
                              PWRITE,
                              PWDATA,
                              PSEL,
                              PENABLE,
      input                   PCLK,
                              PRESETn,                              
                              PREADY,
                              PRDATA,
                              PSLVERR
   );

   task clearAll();
      PADDR = 0;
      PWRITE = 0;
      PWDATA = 0;
      PSEL = 0;
      PENABLE = 0;
      PREADY = 0;
      PRDATA = 0;
      PSLVERR = 0;     
   endtask : clearAll

   task masterClear();
      // #1ns PSEL = 0;
      PSEL = 0;
      PENABLE = 0;
   endtask : masterClear


   task masterWriteWord( input bit [APB_ADDR_WIDTH - 1:0] addr,
                        input bit [APB_DATA_WIDTH - 1:0] data);
      // #1ns PSEL = 1;
      PSEL = 1;
      PWRITE = 1;
      PADDR = addr;
      PWDATA = data;
      @(posedge PCLK);

      // #1ns PENABLE = 1;
      PENABLE = 1; 
      @(posedge PCLK);

      while(~PREADY) begin
         @(posedge PCLK);
      end
      // $display("WRITE: addr -> %04x, data -> %x", addr, data);
      masterClear();
      if ($urandom_range(1,0)) begin
         @(posedge PCLK);
      end
   endtask : masterWriteWord


   task slaveReceiveTransation(  output bit RNW,                           // read_not_write
                                 output bit [APB_ADDR_WIDTH - 1:0] addr,
                                 output bit [APB_DATA_WIDTH - 1:0] data);
      while(1) begin
         if (PSEL) begin
            if (PWRITE) begin
               // #1ns PREADY = 1;
               RNW = 0;
               PREADY = 1;
               @(posedge PCLK);
               addr = PADDR;
               data = PWDATA; 
               // #1ns PREADY = 0;
               PREADY = 0;
               @(posedge PCLK);
               return; 
            end else begin
               RNW = 1;
               addr = PADDR;
               return;
            end
         end else begin
            @(posedge PCLK);
         end
      end


   endtask : slaveReceiveTransation

   task masterReadWord( input  bit [APB_ADDR_WIDTH - 1:0] addr,
                        output bit [APB_DATA_WIDTH - 1:0] data);

      PSEL = 1;
      PWRITE = 0;
      PADDR = addr;
      @(posedge PCLK);
      PENABLE = 1; 
      @(posedge PCLK);

      while(~PREADY) begin
         @(posedge PCLK);
      end
      data = PRDATA; 
      // $display(" READ: addr -> %04x, data -> %x", addr, data);
      masterClear();
      if ($urandom_range(1,0)) begin
         @(posedge PCLK);
      end

   endtask : masterReadWord



   task slaveSendAnswer(input bit [APB_DATA_WIDTH - 1:0] data); 
      PREADY = 1;
      PRDATA = data;
      @(posedge PCLK);
      PREADY = 0;
      @(posedge PCLK);
      return; 
   endtask : slaveSendAnswer




endinterface : apb_if