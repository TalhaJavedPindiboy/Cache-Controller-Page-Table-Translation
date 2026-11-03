`timescale 1ns / 1ps
module system_tb;

reg clk;
reg reset;
reg processor_id;
reg cpu_valid;
reg cpu_write_en;
reg [31:0] virtual_address;
reg [31:0] cpu_write_data;

wire hit;
wire busy;
wire ready;
wire [31:0] rdata;
wire page_hit;
wire page_fault;

system_top uut(
.clk(clk),
.reset(reset),
.processor_id(processor_id),
.cpu_valid(cpu_valid),
.cpu_write_en(cpu_write_en),
.virtual_address(virtual_address),
.cpu_write_data(cpu_write_data),
.hit(hit),
.busy(busy),
.ready(ready),
.rdata(rdata),
.page_hit(page_hit),
.page_fault(page_fault)
);

initial begin
clk=0;
forever #5 clk=~clk;
end

task cpu_read(input reg id_val,input reg [31:0] v_addr);
begin
@(negedge clk);
processor_id=id_val;
virtual_address=v_addr;
cpu_write_en=0;
cpu_valid=1;
wait(ready==1);
if(page_fault) begin
$display("Page fault - fetch page from hard disk");
end
else begin
if(hit)
$display("CACHE HIT  | ID: %b | VA: %08x | Data: %08x",processor_id,virtual_address,rdata);
else
$display("CACHE MISS | ID: %b | VA: %08x | Data: %08x (Refilled)",processor_id,virtual_address,rdata);
end
@(negedge clk);
cpu_valid=0;
#10;
end
endtask

initial begin
reset=1;
processor_id=0;
cpu_valid=0;
cpu_write_en=0;
virtual_address=0;
cpu_write_data=0;

#20;
reset=0;
#20;

$display("--- Starting Cache Controller Verification ---");

$display("\nTEST 1: processor_id=0, VPN=0");
cpu_read(0,32'h00);

$display("\nTEST 2: processor_id=0, VPN=2, line=0");
cpu_read(0,32'h40);

$display("\nTEST 3: processor_id=0, VPN=2, line=1");
cpu_read(0,32'h50);

$display("\nTEST 4: processor_id=1, VPN=0");
cpu_read(1,32'h00);

$display("\nTEST 5: processor_id=1, VPN=2 (Expected Fault)");
cpu_read(1,32'h40);

$display("\nTEST 6: Repeat access to processor_id=0, VPN=2, line=0");
cpu_read(0,32'h40);

$display("\nTEST 7: Conflict Miss on same cache index");
cpu_read(0,32'h60);

$display("Verifying conflict eviction...");
cpu_read(0,32'h40);

$display("\n--- Verification Complete ---");
$finish;
end

endmodule