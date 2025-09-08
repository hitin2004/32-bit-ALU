# 32-bit ALU (Verilog) Overview

This project implements a 32-bit Arithmetic Logic Unit (ALU) in Verilog. The ALU is designed to handle arithmetic, logic, shift, and comparison operations while providing proper status flag outputs.

The design uses a carry lookahead adder for efficient addition and subtraction, a radix-4 Booth’s algorithm for signed multiplication, and a non-restoring division algorithm for signed division. It also supports bitwise operations, logical and arithmetic shifts, and signed comparisons.

## Features
- Addition and subtraction using a carry lookahead adder  
- Multiplication using radix-4 Booth’s algorithm  
- Division using the non-restoring division method  
- Arithmetic and logical shifts  
- Bitwise operations: AND, OR, XOR, NOT  
- Signed comparison (less-than check)  
- Status flags: Negative (N), Zero (Z), Overflow (V), and Carry (C)  
- Separate high and low results for multiplication  
