//   PROBLEM_STATEMENT
/*          
Design a Write-Once Read-Many (WORM) register file in SystemVerilog.
Requirements:

8 registers, each 32 bits wide
Once a register is written, it cannot be overwritten — subsequent writes to that address are silently ignored
Ports: wr_en, wr_addr[2:0], wr_data[31:0], rd_addr[2:0], rd_data[31:0]
A locked[7:0] output — each bit indicates that register is permanently locked
Read is asynchronous (combinational)
Write is synchronous, active-low reset clears all registers and lock bits
Reading an unlocked register returns 32'hDEAD_BEEF

Constraints:

No latches
Lock mechanism must be a separate always_ff block from write logic
Use always_ff and always_comb throughout

  */

  module worm#(parameter DATA_WIDTH = 32,
                       REG_DEPTH = 8,
                       ADDR_WIDTH = $clog2(REG_DEPTH))(
 input logic clk,rst,wr_en,
 input logic [DATA_WIDTH-1:0]wr_data,
 input logic [ADDR_WIDTH-1:0]rd_addr,wr_addr,
 output logic [DATA_WIDTH-1:0]rd_data,
 output logic [REG_DEPTH-1:0]locked);

reg [DATA_WIDTH-1:0]mem[REG_DEPTH-1:0];

 always_ff@(posedge clk, negedge rst) begin
   if(!rst) begin
     locked <= '0;
   end else begin
      if(wr_en) begin
        if(!locked[wr_addr]) begin
          mem[wr_addr] <= wr_data;
          locked[wr_addr] <= 1'b1;
        end 
      end 
   end 
 end 

 always_comb begin
   rd_data = locked[rd_addr] ? mem[rd_addr] : 32'hDEADBEEF;
 end 

 // assign rd_data = locked[rd_addr] ? mem[rd_addr] : 32'hDEADBEEF;

endmodule 
