`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2025 11:07:14
// Design Name: 
// Module Name: alu32_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module alu32_tb();

    reg clk;
    reg rst;
    reg [31:0] A, B;
    reg [3:0] op;
    wire [31:0] result;
    wire [31:0] mul_hi, mul_lo;
    wire N, Z, V, C;

    alu32 uut(
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .op(op),
        .result(result),
        .mul_hi(mul_hi),
        .mul_lo(mul_lo),
        .N(N),
        .Z(Z),
        .V(V),
        .C(C)
    );

    task test;
        input [31:0] inA, inB;
        input [3:0]  operation;
        input [255:0] op_name;
        begin
            A = inA; B = inB; op = operation;
            #10;
            $display("[%s] A=%0d B=%0d Result=%0d | NZVC=%b%b%b%b", op_name, A, B, result, N, Z, V, C);
        end
    endtask

    initial begin
        $display("\n==== ALU Testbench Start ====");
        clk = 0;
        rst = 0;
        A = 0; B = 0; op = 0;

        test(32'd10, 32'd5, 4'b0000, "ADD");
        test(32'd10, 32'd5, 4'b0001, "SUB");
        test(32'd10, 32'd5, 4'b0010, "MUL");
        test(32'd15, 32'd3, 4'b0011, "DIV");
        test(32'shFFFFFFF0, 32'd4, 4'b0100, "ASR");
        test(32'h0F0F0F0F, 32'd4, 4'b0101, "LSL");
        test(32'hF0F0F0F0, 32'd4, 4'b0110, "LSR");
        test(32'hFF00FF00, 32'h00FF00FF, 4'b0111, "AND");
        test(32'hFF00FF00, 32'h00FF00FF, 4'b1000, "OR");
        test(32'hFF00FF00, 32'h00FF00FF, 4'b1001, "XOR");
        test(32'hAAAAAAAA, 32'd0, 4'b1010, "NOT");
        test(32'd5, 32'd7, 4'b1011, "COMP (5 < 7)");
        test(32'd7, 32'd5, 4'b1011, "COMP (7 < 5)");
        test(-32'd5, 32'd2, 4'b1011, "COMP (-5 < 2)");
        test(32'd2, -32'd5, 4'b1011, "COMP (2 < -5)");

        $display("==== ALU Testbench Complete ====");
        $finish;
    end

endmodule



