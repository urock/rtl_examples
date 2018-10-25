
module counter_tb;

parameter  WIDTH = 4;
parameter  DIV = 5;

logic                clk;
logic                reset;
logic                enable;
logic                dir;
logic [WIDTH-1:0]    leds;

task wait_cycles(int c);
   int i;
   for (i = 0; i < c; i++)
      @(posedge clk);
endtask : wait_cycles

//instantiate design under test (dut) rtl module
counter_top #(
   .WIDTH      (WIDTH),
   .DIV        (DIV)   
) counter_dut (
   .clk        (clk), 
   .reset      (reset), 
   .enable     (enable),
   .dir        (dir), 
   .leds       (leds)
);

event reset_done_trigger;

default clocking cb_counter @(posedge clk); // clocking block for testbench 
   default input #1step output #2; 
endclocking

initial begin
   clk = 0;
   reset = 1; 
   ##10 reset = 0;
   -> reset_done_trigger; 
end

always begin
   #5  clk = ! clk;     
end

// generate inputs
initial begin
   int i; 
   dir      <= 1; 
   enable   <= 0;
   @(reset_done_trigger);

   wait_cycles(10);
   enable   <= 1; 

   wait_cycles(20);
   dir      <= 0; 
   
   wait_cycles(50);
   enable   <= 0;
end

endmodule // counter_tb