module apb_converter
   #(parameter
      ADDRM_WIDTH=13,
      ADDRS_WIDTH=13,
      DATAM_WIDTH=8,
      DATAS_WIDTH=32
   )
(
   apb_if.slave_mp                  apbs,
   apb_if.master_mp                 apbm
);

function int addr_lsb_n(int data_width);
   return $clog2(data_width/8);
endfunction 


enum {ST_IDLE,  ST_SETUP, ST_ACCESS, ST_FINISH} state, next_state;

always_ff @(posedge apbs.PCLK) begin
   if (~apbs.PRESETn) begin
      state    <= ST_IDLE;
   end else begin
      state <= next_state;      
   end
end




generate 
   if (DATAS_WIDTH <= DATAM_WIDTH) begin 

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
      end // always_comb


   logic addr_not_alligned; 
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

         addr_not_alligned <= 1'b0;
      end else begin

         apbs.PSLVERR   <= 1'b0; 

         case (state)
            ST_IDLE: begin

               if (apbs.PSEL) begin
                  apbm.PSEL   <= 1'b1;
                  apbm.PWRITE <= apbs.PWRITE;
               end
                 
            end // ST_IDLE

            ST_SETUP: begin
               apbm.PENABLE <= 1'b1; 
               for (int i = 0; i < addr_lsb_n(DATAM_WIDTH); i++) 
                  if (apbs.PADDR[i])
                     addr_not_alligned <= 1'b1;
            end 

            ST_ACCESS: begin
               if (apbm.PREADY) begin
                  apbm.PSEL      <= 1'b0;
                  apbm.PENABLE   <= 1'b0;
                  apbs.PSLVERR   <= apbm.PSLVERR | addr_not_alligned; 
                  addr_not_alligned <= 1'b0; 
               end
            end 

         endcase // state      

         apbm.PADDR     <= apbs.PADDR;
         apbm.PWDATA    <= apbs.PWDATA;
         apbs.PREADY    <= apbm.PREADY;
         apbs.PRDATA    <= apbm.PRDATA;

      end
   end  // always_ff

end // if DATAS_WIDTH <= DATAM_WIDTH

else begin // DATAS_WIDTH > DATAM_WIDTH

   parameter N_TRANSACTIONS   = (DATAS_WIDTH / DATAM_WIDTH);
   parameter ADDR_INC         = (DATAM_WIDTH / 8);

   logic [$clog2(N_TRANSACTIONS) : 0] t_cnt; // transactions cnt
   logic m_ready; 

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
            // if (m_ready) begin
            if (apbm.PREADY) begin
               if (t_cnt[$clog2(N_TRANSACTIONS)]) begin
                  next_state <= ST_FINISH; 
               end else begin
                  next_state <= ST_SETUP; 
               end 
            end 
         end 

         ST_FINISH: begin
            next_state <= ST_IDLE;
         end

      endcase // state
   end // always_comb


   logic addr_not_alligned; 

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

         addr_not_alligned <= 1'b0;
         t_cnt             <= '0; 
         m_ready           <= 1'b0;
      end else begin

         apbs.PSLVERR   <= 1'b0; 
         apbs.PREADY    <= 1'b0;

         case (state)
            ST_IDLE: begin

               if (apbs.PSEL) begin
                  apbm.PSEL   <= 1'b1;
                  apbm.PWRITE <= apbs.PWRITE;
                  apbm.PADDR     <= apbs.PADDR;
                  // little endian 
                  apbm.PWDATA    <= apbs.PWDATA[DATAS_WIDTH -1 -: DATAM_WIDTH];
                  t_cnt          <= 1; 
               end
                 
            end // ST_IDLE

            ST_SETUP: begin
               apbm.PENABLE <= 1'b1; 
               for (int i = 0; i < addr_lsb_n(DATAM_WIDTH); i++) 
                  if (apbs.PADDR[i])
                     addr_not_alligned <= 1'b1;
            end 

            ST_ACCESS: begin

               if (apbm.PREADY) begin
                  apbm.PENABLE   <= 1'b0;

                  apbs.PRDATA[DATAS_WIDTH - 1 - DATAM_WIDTH*(t_cnt-1) -: DATAM_WIDTH]    <= apbm.PRDATA;

                  if (t_cnt[$clog2(N_TRANSACTIONS)]) begin
                     apbm.PSEL         <= 1'b0;
                     apbs.PSLVERR      <= apbm.PSLVERR | addr_not_alligned; 
                     addr_not_alligned <= 1'b0; 
                     apbs.PREADY       <= 1'b1; 
                  end else begin
                     apbm.PADDR     <= apbm.PADDR + ADDR_INC;
                     apbm.PWDATA    <= apbs.PWDATA[DATAS_WIDTH - 1 - DATAM_WIDTH*t_cnt -: DATAM_WIDTH];

                     t_cnt          <= t_cnt + 1;

                  end
               end
            end 

         endcase // state      

         m_ready <= apbm.PREADY; 

      end
   end //always_ff

end // if else generate

endgenerate

endmodule
