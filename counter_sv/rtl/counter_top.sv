`timescale 1ns / 10ps

module counter_top
   #(parameter
      WIDTH = 4, 
      DIV   = 125000000
   )
(
   input  logic               clk,
   input  logic               reset,
   input  logic               enable,
   input  logic               dir,      // 0 - count up, 1 - count down
   output logic [WIDTH-1:0]   leds
);

// input clk frequency = 125 MHz
// that is 125 M ticks per second 
// minimum bit length for 125M is 27 bits  
logic [26:0]   div_cnt; 
logic          div_clr;

always @(posedge clk) begin
   if (reset) begin
      div_cnt <= 0;
   end else begin
      if (enable) begin
         if (div_clr) begin
            div_cnt <= 0;
         end else begin
            div_cnt <= div_cnt + 1;
         end
      end
   end
end

assign div_clr = (div_cnt == DIV) ? 1'b1 : 1'b0; 

counter counter_rtl(
   .clk        (clk), 
   .reset      (reset), 
   .cnt_en     (div_clr & enable), 
   .dir        (dir), 
   .cnt_val    (leds)
);


endmodule // counter_top