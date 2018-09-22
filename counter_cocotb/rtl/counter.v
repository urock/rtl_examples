module counter
   #(parameter
      WIDTH = 4
   )
(
   input  logic               clk,
   input  logic               reset,
   output logic [WIDTH-1:0]   count_val
);

`ifdef COCOTB_SIM
initial begin
  $dumpfile ("counter.vcd");
  $dumpvars (0, counter);
  #1;
end
`endif


always @(posedge clk) begin
   if (reset) begin
      count_val <= 0;
   end else begin
      count_val <= count_val + 1;
   end
end

endmodule