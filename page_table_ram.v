`timescale 1ns / 1ps
module page_table_ram(
    input clk,
    input [2:0] address,
    output reg [4:0] pte_data
    );
    reg [4:0] ram [7:0];
    initial begin
        ram[0] = {1'b1, 4'd11};
        ram[1] = {1'b1, 4'd8};
        ram[2] = {1'b1, 4'd9};
        ram[3] = {1'b1, 4'd5};
        
        ram[4] = {1'b1, 4'd10};
        ram[5] = {1'b1, 4'd6};
        ram[6] = {1'b0, 4'd0};
        ram[7] = {1'b1, 4'd7};
    end
    
    always @(posedge clk)begin
        pte_data <= ram[address];
    end
endmodule