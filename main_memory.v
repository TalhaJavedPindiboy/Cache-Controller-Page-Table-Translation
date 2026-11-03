`timescale 1ns / 1ps
module main_memory(
    input clk, mem_read, mem_write,
    input [4:0] line_address,
    input [127:0] write_data,
    output reg [127:0] read_data
    );
    
    reg [127:0] mem_array [0:31];
    
    integer i;
    initial begin
        for(i=0; i<128; i=i+1)begin
            mem_array[i] = {32'hDDDD_DDDD, 32'hCCCC_CCCC, 32'hBBBB_BBBB, i[31:0]};
        end
    end
    
    always @(posedge clk) begin
        if (mem_write) begin
            mem_array[line_address] <= write_data;
        end
        
        if (mem_read) begin
            read_data <= mem_array[line_address];
        end
    end
endmodule












