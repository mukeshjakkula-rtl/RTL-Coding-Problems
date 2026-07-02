// PROBLEM STATEMENT
/*
Design a digital stopwatch in SystemVerilog.

Counts in seconds and minutes — MM:SS format
Inputs: clk (assume 1Hz for simplicity), rst_n, start_stop, lap
Outputs: seconds [5:0] (0–59), minutes [5:0] (0–59), lap_seconds [5:0], lap_minutes [5:0]
start_stop toggles between running and paused
lap captures current time into lap_seconds and lap_minutes without stopping the main counter
On reset everything clears to zero

This is straightforward, satisfying to see work, and still uses real RTL patterns — counter chaining, enable logic, registered outputs.
*/
module stop_watch(
    input  logic clk,        // 1Hz clock
    input  logic rst,      // active low reset
    input  logic start_stop, // button — toggles running/paused
    input  logic lap,        // button — captures lap time

    output logic [5:0] seconds,      // main counter 0-59
    output logic [5:0] minutes,      // main counter 0-59
    output logic [5:0] lap_seconds,  // frozen lap time
    output logic [5:0] lap_minutes   // frozen lap time
);

logic start_stop_edge;
logic lap_edge;
logic st; 


always@(posedge clk, posedge rst) begin
 if(rst) begin
   st <= 1'b0;
 end else begin
   if(start_stop_edge) st <= ~st;  
 end 
end 


always@(posedge clk, posedge rst) begin
 if(rst) begin
   minutes <= 6'd0;
   seconds <= 6'd0;
 end else begin
 if(st) begin 
   if(seconds == 6'd59) begin
     seconds <= 6'd0;
     if(minutes == 6'd59) minutes <= 6'd0;
     else minutes <= minutes + 6'd1;
   end else seconds <= seconds + 6'd1;
  end 
 end   
end 

always@(posedge clk, posedge rst) begin
 if(rst) begin
  lap_seconds <= 6'd0;
  lap_minutes <= 6'd0;
 end else begin
  if(lap_edge) begin
    lap_minutes <= minutes;
    lap_seconds <= seconds;
  end 
 end 
end 

// edge detectors to catch the dge instaed of duplication of signals 
ed f1(.clk(clk), .rst(rst), .d(start_stop), .o(start_stop_edge));
ed f2(.clk(clk), .rst(rst), .d(lap), .o(lap_edge));

endmodule 

module ed(
 input logic clk,rst,d,
 output logic o
);
reg a;
always@(posedge clk,posedge rst) begin
 if(rst) begin
 a <= 1'b0;
 end else begin
 a <= d;
 end 
end 
assign o = d & ~a;
endmodule 
