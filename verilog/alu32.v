`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2025 10:54:30
// Design Name: 
// Module Name: alu32
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


// 32-bit ALU in Verilog with CLA Adder, Radix-4 Multiplication, Non-Restoring Division
// and NZVC flag support. Logical right shift with signed handling included



// 32-bit ALU in Verilog with CLA Adder, Radix-4 Multiplication, Non-Restoring Division
// NZVC flag support. Includes logical/arithmetic shifts, bitwise ops, and comparison

`timescale 1ns / 1ps

module alu32(
    input clk,
    input rst,
    input [31:0] A,
    input [31:0] B,
    input [3:0] op,   // 0000=ADD, 0001=SUB, 0010=MUL, 0011=DIV, 0100=ASR, 0101=LSL, 0110=LSR, 0111=AND, 1000=OR, 1001=XOR, 1010=NOT, 1011=COMP
    output reg [31:0] result,
    output reg [31:0] mul_hi,
    output reg [31:0] mul_lo,
    output reg N, Z, V, C
);

    // Internal signals
    reg [31:0] sum, diff;
    reg carry_out_add, overflow_add;
    reg carry_out_sub, overflow_sub;
    reg [63:0] mul_result;
    reg [31:0] quotient, remainder;
    reg A_neg, B_neg;
    reg [31:0] A_abs, B_abs;

    // ---------- CLA ADDITION ----------
    function [33:0] cla_add;
        input [31:0] A, B;
        input Cin;
        reg [31:0] P, G, C, S;
        integer i;
        begin
            P = A ^ B;
            G = A & B;
            C[0] = Cin;
            for (i = 0; i < 31; i = i + 1) begin
                C[i+1] = G[i] | (P[i] & C[i]);
            end
            S = P ^ C;
            cla_add[31:0] = S;
            cla_add[32] = C[31];
            cla_add[33] = C[30] ^ C[31]; // Overflow flag
        end
    endfunction

    // ---------- Radix-4 Booth Multiplier ----------
    task radix4_mul;
        input [31:0] A, B;
        output [63:0] result;
        reg [63:0] M, negM, P;
        reg [2:0] group;
        integer i;
        begin
            P = 64'd0;
            M = { {32{A[31]}}, A };
            negM = ~M + 1;
            for (i = 0; i < 16; i = i + 1) begin
                group = {B[2*i+1], B[2*i], (i==0) ? 1'b0 : B[2*i-1]};
                case (group)
                    3'b000, 3'b111: P = P;
                    3'b001, 3'b010: P = P + (M << (2*i));
                    3'b011:         P = P + (M << (2*i+1));
                    3'b100:         P = P + (negM << (2*i+1));
                    3'b101, 3'b110: P = P + (negM << (2*i));
                endcase
            end
            result = P;
        end
    endtask

    // ---------- Non-Restoring Division ----------
    task non_restoring_div;
        input [31:0] dividend, divisor;
        output [31:0] quotient, remainder;
        reg [31:0] A;
        reg [31:0] Q;
        reg [31:0] M;
        reg [4:0] count;
        begin
            A = 32'd0;
            Q = dividend;
            M = divisor;

            for (count = 0; count < 32; count = count + 1) begin
                {A, Q} = {A, Q} << 1;
                if (A[31] == 0) begin
                    A = A - M;
                end else begin
                    A = A + M;
                end

                if (A[31] == 0)
                    Q[0] = 1;
                else
                    Q[0] = 0;
            end

            if (A[31] == 1) begin
                A = A + M;  // Final correction
            end

            quotient = Q;
            remainder = A;
        end
    endtask

    // Perform operations and update outputs
    always @(*) begin
        {carry_out_add, overflow_add, sum} = cla_add(A, B, 1'b0);
        {carry_out_sub, overflow_sub, diff} = cla_add(A, ~B, 1'b1);

        radix4_mul(A, B, mul_result);
        non_restoring_div(A, B, quotient, remainder);

        A_neg = A[31];
        B_neg = B[31];
        A_abs = A_neg ? (~A + 1) : A;
        B_abs = B_neg ? (~B + 1) : B;

        case (op)
            4'b0000: result = sum;
            4'b0001: result = diff;
            4'b0010: result = mul_result[31:0];
            4'b0011: result = quotient;
            4'b0100: result = A >>> B[4:0];
            4'b0101: result = A << B[4:0];
            4'b0110: result = A >> B[4:0];
            4'b0111: result = A & B;
            4'b1000: result = A | B;
            4'b1001: result = A ^ B;
            4'b1010: result = ~A;
            4'b1011: result = (A[31] & ~B[31]) ? 32'd1 :
                               (~A[31] & B[31]) ? 32'd0 :
                               (A_abs < B_abs ? 32'd1 : 32'd0);
            default: result = 32'h00000000;
        endcase

        mul_hi = mul_result[63:32];
        mul_lo = mul_result[31:0];

        N = result[31];
        Z = (result == 0);
        case (op)
            4'b0000: begin V = overflow_add; C = carry_out_add; end
            4'b0001: begin V = overflow_sub; C = carry_out_sub; end
            default: begin V = 1'b0; C = 1'b0; end
        endcase
    end

endmodule
  