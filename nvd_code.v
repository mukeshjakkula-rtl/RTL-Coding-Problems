/*
Problem :-
^^^^^^^
Design a state machine which receives two inputs RQ1 and RQ2 and has
two outputs GR1 and GR2 following the adjoining timing diagram. When a
RQ pulse comes; the corresponding GR becomes high and stays there until
4T-states from it. When a GR is high, the other RQ is not served if it comes
during that duration. If both RQ are asserted simultaneously, that RQ is
served which has most recently been served.

rq1 ______|---|________________________|---|______________

rq2 ___________ |---|__________________|---|______________

gr1 ___________|---------|_________________|---------|____

gr2 ______________________________________________________


*/


module nvd_code (
  input clk,
  input rst,
  input rq1, rq2,
  output reg gr1,gr2);


 reg l_g;
 reg [1:0]count;

 typedef enum logic [1:0]{IDLE,RQ1,RQ2}nvd_states;
 nvd_states state;

 always@(posedge clk, posedge rst) begin
   if(rst) begin
     state <= IDLE;
     count <= 2'b00;
     l_g <= 1'b0;
   end else begin
     case(state) 
      IDLE : begin
        case({rq1,rq2,l_g})
          3'b100 : state <= RQ1;
          3'b010 : state <= RQ2;
          3'b110 : state <= RQ1;
          3'b111 : state <= RQ2;
        endcase
      end 

      RQ1 : begin
        l_g <= 1'b0;
        if(count == 2'd3) begin
          count <= 2'd0;
          state <= IDLE;
        end else begin
          count <= count + 1'b1;
          state <= RQ1;
        end    
      end 

      RQ2 : begin
        l_g <= 1'b1;
        if(count == 2'd3) begin
          count <= 2'd0;
          state <= IDLE;
        end else begin
          count <= count + 1'b1;
          state <= RQ2;
        end   
      end 

     endcase
   end 
 end 

 always@(*) begin
  gr1 = state == RQ1 ;
  gr2 = state == RQ2 ;
 end 

endmodule 


