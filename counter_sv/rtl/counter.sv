`timescale 1ns / 10ps

module counter
#(parameter
   WIDTH = 4
)(
   input  logic               clk,
   input  logic               reset,
   input  logic               cnt_en,
   input  logic               dir,      // 0 - count up, 1 - count down
   output logic [WIDTH-1:0]   cnt_val
);

always_ff @(posedge clk) begin
   if (reset) begin
      cnt_val <= 0;
   end else begin
      if (cnt_en) begin
         if (dir) begin
            cnt_val <= cnt_val + 1;
         end else begin
            cnt_val <= cnt_val - 1;
         end
      end
   end
end

endmodule // counter