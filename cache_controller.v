`timescale 1ns / 1ps
module cache_controller(
input wire clk,
input wire reset,
input wire cpu_valid,
input wire cpu_write_en,
input wire [31:0] cpu_write_data,
input wire [31:0] physical_address,
input wire page_hit,
input wire page_fault,
output reg hit,
output reg busy,
output reg ready,
output reg [31:0] rdata,
output reg mem_read,
output reg mem_write,
output wire [4:0] mem_address,
output reg [127:0] mem_write_data,
input wire [127:0] mem_read_data
);

reg valid_array[0:7];
reg [1:0] tag_array[0:7];
reg [127:0] data_array[0:7];
wire [1:0] tag=physical_address[8:7];
wire [2:0] index=physical_address[6:4];
wire [1:0] word_offset=physical_address[3:2];
assign mem_address=physical_address[8:4];
wire cache_hit_comb=valid_array[index]&&(tag_array[index]==tag);

localparam IDLE=4'd0;
localparam PAGE_TABLE_LOOKUP=4'd1;
localparam PAGE_CHECK=4'd2;
localparam CACHE_LOOKUP=4'd3;
localparam CACHE_HIT_RESPONSE=4'd4;
localparam CACHE_MISS_REFILL=4'd5;
localparam CACHE_MISS_WAIT=4'd6;
localparam PAGE_FAULT_RESPONSE=4'd7;
localparam READY=4'd8;

reg [3:0] state,next_state;
reg miss_flag;
integer i;

always @(posedge clk or posedge reset) begin
if(reset) begin
state<=IDLE;
miss_flag<=1'b0;
hit<=1'b0;
rdata<=32'd0;
for(i=0;i<8;i=i+1)
valid_array[i]<=1'b0;
end
else begin
state<=next_state;
case(state)
IDLE: begin
miss_flag<=1'b0;
end
CACHE_LOOKUP: begin
if(!cache_hit_comb)
miss_flag<=1'b1;
end
CACHE_MISS_WAIT: begin
data_array[index]<=mem_read_data;
tag_array[index]<=tag;
valid_array[index]<=1'b1;
end
CACHE_HIT_RESPONSE: begin
hit<=!miss_flag;
if(!cpu_write_en) begin
case(word_offset)
2'b00:rdata<=data_array[index][31:0];
2'b01:rdata<=data_array[index][63:32];
2'b10:rdata<=data_array[index][95:64];
2'b11:rdata<=data_array[index][127:96];
endcase
end
else begin
case(word_offset)
2'b00:data_array[index][31:0]<=cpu_write_data;
2'b01:data_array[index][63:32]<=cpu_write_data;
2'b10:data_array[index][95:64]<=cpu_write_data;
2'b11:data_array[index][127:96]<=cpu_write_data;
endcase
end
end
endcase
end
end

always @(*) begin
next_state=state;
busy=1'b1;
ready=1'b0;
mem_read=1'b0;
mem_write=1'b0;
mem_write_data=128'd0;

case(state)
IDLE: begin
busy=1'b0;
if(cpu_valid)
next_state=PAGE_TABLE_LOOKUP;
end

PAGE_TABLE_LOOKUP: begin
next_state=PAGE_CHECK;
end

PAGE_CHECK: begin
if(page_fault)
next_state=PAGE_FAULT_RESPONSE;
else if(page_hit)
next_state=CACHE_LOOKUP;
end

CACHE_LOOKUP: begin
if(cache_hit_comb)
next_state=CACHE_HIT_RESPONSE;
else
next_state=CACHE_MISS_REFILL;
end

CACHE_MISS_REFILL: begin
mem_read=1'b1;
next_state=CACHE_MISS_WAIT;
end

CACHE_MISS_WAIT: begin
next_state=CACHE_LOOKUP;
end

CACHE_HIT_RESPONSE: begin
if(cpu_write_en) begin
mem_write=1'b1;
mem_write_data=data_array[index];
case(word_offset)
2'b00:mem_write_data[31:0]=cpu_write_data;
2'b01:mem_write_data[63:32]=cpu_write_data;
2'b10:mem_write_data[95:64]=cpu_write_data;
2'b11:mem_write_data[127:96]=cpu_write_data;
endcase
end
next_state=READY;
end

PAGE_FAULT_RESPONSE: begin
next_state=READY;
end

READY: begin
busy=1'b0;
ready=1'b1;
next_state=IDLE;
end

default: next_state=IDLE;
endcase
end

endmodule