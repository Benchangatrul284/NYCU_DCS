
`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
    `include "MIPS.sv"
`elsif GATE
    `include "MIPS_SYN.v"
`endif

module TESTBED();

logic clk,rst_n,in_valid;
logic out_valid,intruction_fail;

logic [31:0] instruction; 
logic [15:0] out_0, out_1,out_2,out_3,out_4, out_5;

initial begin
  `ifdef RTL
    $fsdbDumpfile("MIPS.fsdb");
	  $fsdbDumpvars(0,"+mda");
  `elsif GATE
    $fsdbDumpfile("MIPS_SYN.fsdb");
	  $sdf_annotate("MIPS_SYN.sdf",I_design);
	  $fsdbDumpvars(0,"+mda");
  `endif
end

	


MIPS I_design
(
  .clk(clk),
  .rst_n(rst_n),
  .in_valid(in_valid),
  .instruction(instruction),


  .out_valid(out_valid),
  .instruction_fail(instruction_fail),
  .out_0(out_0),
  .out_1(out_1),
  .out_2(out_2),
  .out_3(out_3),
  .out_4(out_4),
  .out_5(out_5)
);


PATTERN I_PATTERN
(   
  .clk(clk),
  .rst_n(rst_n),
  .in_valid(in_valid),
  .instruction(instruction),
  
  .out_valid(out_valid),
  .instruction_fail(instruction_fail),
  .out_0(out_0),
  .out_1(out_1),
  .out_2(out_2),
  .out_3(out_3),
  .out_4(out_4),
  .out_5(out_5)
);
endmodule
