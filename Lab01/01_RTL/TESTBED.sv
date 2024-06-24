`timescale 1ns/1ps
`include "PATTERN.sv"
`include "Comb.sv"

module TESTBED();

initial begin
	$fsdbDumpfile("Comb.fsdb");
	$fsdbDumpvars(0,"+mda");
end

logic [3:0] in_num0, in_num1, in_num2, in_num3;
logic [4:0] out_num0, out_num1;

Comb_1 I_Comb
(
	.in_num0 (in_num0 ),
	.in_num1 (in_num1 ),
	.in_num2 (in_num2 ),
	.in_num3 (in_num3 ),
	.out_num0(out_num0),
	.out_num1(out_num1)
);

PATTERN I_PATTERN
(
	.in_num0 (in_num0 ),
	.in_num1 (in_num1 ),
	.in_num2 (in_num2 ),
	.in_num3 (in_num3 ),
	.out_num0(out_num0),
	.out_num1(out_num1)
);

endmodule

