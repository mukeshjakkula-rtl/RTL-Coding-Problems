/*
 Requirements:

Receiver has a buffer of depth CREDIT_MAX (parameter, default 8)
On reset, receiver sends CREDIT_MAX credits to sender
Sender maintains a credit counter  decrements on each data transfer, increments when it receives a credit return from receiver
Sender may only transmit when credit count > 0
Receiver returns a credit each time it consumes (reads) an entry from its buffer

Ports on sender: clk, rst_n, send_valid, send_data, credit_in, tx_valid, tx_data
Ports on receiver: clk, rst_n, rx_valid, rx_data, rd_en, credit_out, buf_data, buf_valid

Both sender and receiver on same clock

Constraints:

Sender and receiver must be separate modules
Credit counter must never go below 0 or above CREDIT_MAX  add saturating logic
No latches
Use always_ff and always_comb
 */


module sender#(parameter CREDIT_MAX = 8,
                         DATA_WIDTH = 8)(
  input logic clk,rstn,
  input logic send_valid,
  input logic credit_in,
  input logic [DATA_WIDTH-1:0]send_data,
  output logic [DATA_WIDTH-1:0]tx_data,
  output logic tx_valid
  
);

localparam CREDIT_COUNT = $clog2(CREDIT_MAX);
logic [CREDIT_COUNT:0]credit_count;

always@(posedge clk, negedge rstn) begin
 if(!rstn) begin
    credit_count <= CREDIT_MAX;
    tx_data <= '0;
    tx_valid <= 1'b0;
 end else begin
    tx_valid <= 1'b0;
    case({send_valid,credit_in})
     2'b10 : begin
      if(credit_count > 0) begin
        tx_data <= send_data;
        tx_valid <= 1'b1;
        credit_count <= credit_count-1;
      end  
     end 
     2'b01 : begin
      tx_valid <= 1'b0;
      if(credit_count < CREDIT_MAX) begin
       credit_count <= credit_count +1;
      end 
     end   
     2'b11 : begin 
       tx_data <= send_data;   
       tx_valid <= 1'b1;
     end 
     default : tx_valid <= 1'b0;
    endcase
 end 
end 
endmodule 




module receiver#(parameter CREDIT_MAX = 8,
                           DATA_WIDTH = 8,
                           CREDIT_COUNT = $clog2(CREDIT_MAX))(
 input logic clk,rstn,
 input logic rx_valid,
 input logic rd_en,
 input logic [DATA_WIDTH-1:0]rx_data,
 output logic credit_out,
 output logic [DATA_WIDTH-1:0]buff_data,
 output logic buff_valid
);
 logic [DATA_WIDTH-1:0]buff[CREDIT_MAX-1:0];
 logic [CREDIT_COUNT:0]wr_ptr,rd_ptr;
 logic full, empty,read,write;

always@(posedge clk, negedge rstn) begin
  if(!rstn) begin
    credit_out <= '0;
    buff_data <= '0;
    wr_ptr <= '0;
    rd_ptr <= '0;
  end else begin
    case({read,write})
    2'b01: begin
      buff[wr_ptr[CREDIT_COUNT-1:0]] <= rx_data;
      wr_ptr <= wr_ptr + 1;
      credit_out <= 1'b0;
    end 

    2'b10 : begin
      buff_data <= buff[rd_ptr[CREDIT_COUNT-1:0]];
      rd_ptr <= rd_ptr + 1;
      credit_out <= 1'b1;
    end 
     
    2'b11 : begin
      buff[wr_ptr[CREDIT_COUNT-1:0]] <= rx_data;
      wr_ptr <= wr_ptr + 1;
      buff_data <= buff[rd_ptr[CREDIT_COUNT-1:0]];
      rd_ptr <= rd_ptr + 1;
      credit_out <= 1'b1;
    end   
      default : credit_out <= 1'b0;
  endcase
 end 
end



assign buff_valid = !empty;
assign write = rx_valid && !full;
assign read = rd_en && !empty;
assign full = ((wr_ptr[CREDIT_COUNT] != rd_ptr[CREDIT_COUNT])&&(wr_ptr[CREDIT_COUNT-1:0] == rd_ptr[CREDIT_COUNT-1:0]));
assign empty = rd_ptr == wr_ptr; 

endmodule 
