module apb_converter
   #(parameter
      ADDRM_WIDTH=13,
      ADDRS_WIDTH=13,
      DATAM_WIDTH=32,
      DATAS_WIDTH=8
   )
(
   apb_if.slave_mp                  apbs,
   apb_if.master_mp                 apbm
);


enum {ST_IDLE,  ST_SETUP, ST_ACCESS} state, next_state;

always_ff @(posedge apbs.PCLK) begin
   if (~apbs.PRESETn) begin
      state    <= ST_IDLE;
   end else begin
      state <= next_state;      
   end
end

// next state logic
always_comb begin

   next_state  <= state;

   case (state)
      ST_IDLE: begin
         if (apbs.PSEL) begin
            next_state <= ST_SETUP;
         end
      end 

      ST_SETUP: begin
         next_state <= ST_ACCESS;
      end 

      ST_ACCESS: begin
         if (apbs.PREADY) begin
            next_state <= ST_IDLE; 
         end 
      end 

   endcase // state
end

// outputs
always_ff @(posedge apbs.PCLK) begin
   if (~apbs.PRESETn) begin
      apbm.PSEL      <= 1'b0;
      apbm.PENABLE   <= 1'b0;

      apbs.PREADY    <= 1'b0;
      apbs.PSLVERR   <= 1'b0;

      apbm.PADDR     <= 'X;
      apbm.PWDATA    <= 'X;
      apbs.PRDATA    <= 'X;
   end else begin

      case (state)
         ST_IDLE: begin

            if (apbs.PSEL) begin
               apbm.PSEL   <= 1'b1;
               apbm.PWRITE <= apbs.PWRITE;
            end
              
         end // ST_IDLE

         ST_SETUP: begin
            apbm.PENABLE <= 1'b1; 
         end 

         ST_ACCESS: begin
            if (apbm.PREADY) begin
               apbm.PSEL      <= 1'b0;
               apbm.PENABLE   <= 1'b0;
            end
         end 

      endcase // state      

      apbm.PADDR     <= apbs.PADDR;
      apbm.PWDATA    <= apbs.PWDATA;
      apbs.PREADY    <= apbm.PREADY;
      apbs.PRDATA    <= apbm.PRDATA;

      apbs.PSLVERR   <= apbm.PSLVERR;

   end
end 



endmodule