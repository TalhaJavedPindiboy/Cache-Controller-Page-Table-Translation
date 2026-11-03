`timescale 1ns / 1ps
module system_top(
input wire clk,
input wire reset,
input wire processor_id,
input wire cpu_valid,
input wire cpu_write_en,
input wire [31:0] virtual_address,
input wire [31:0] cpu_write_data,
output wire hit,
output wire busy,
output wire ready,
output wire [31:0] rdata,
output wire page_hit,
output wire page_fault
);

wire [2:0] page_table_address;
wire [4:0] pte_data;
wire [31:0] physical_address;
wire mem_read;
wire mem_write;
wire [4:0] mem_address;
wire [127:0] mem_write_data;
wire [127:0] mem_read_data;

address_translation u_translation(
.processor_id(processor_id),
.virtual_address(virtual_address),
.page_table_address(page_table_address),
.pte_data(pte_data),
.physical_address(physical_address),
.page_hit(page_hit),
.page_fault(page_fault)
);

page_table_ram u_pt_ram(
.clk(clk),
.address(page_table_address),
.pte_data(pte_data)
);

cache_controller u_cache(
.clk(clk),
.reset(reset),
.cpu_valid(cpu_valid),
.cpu_write_en(cpu_write_en),
.cpu_write_data(cpu_write_data),
.physical_address(physical_address),
.page_hit(page_hit),
.page_fault(page_fault),
.hit(hit),
.busy(busy),
.ready(ready),
.rdata(rdata),
.mem_read(mem_read),
.mem_write(mem_write),
.mem_address(mem_address),
.mem_write_data(mem_write_data),
.mem_read_data(mem_read_data)
);

main_memory u_memory(
.clk(clk),
.mem_read(mem_read),
.mem_write(mem_write),
.line_address(mem_address),
.write_data(mem_write_data),
.read_data(mem_read_data)
);

endmodule