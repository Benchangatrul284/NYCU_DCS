
`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
    `include "PIPE.sv"
`elsif GATE
    `include "PIPE_SYN.v"
`endif

module TESTBED();

logic clk,rst_n,in_valid;
logic out_valid;

logic [26:0] out_value; 
logic [5:0] in_1, in_2, in_3, in_4;
logic [1:0] mode;

initial begin
  `ifdef RTL
    $fsdbDumpfile("PIPE.fsdb");
	  $fsdbDumpvars(0,"+mda");
  `elsif GATE
    $fsdbDumpfile("PIPE_SYN.fsdb");
	  $sdf_annotate("PIPE_SYN.sdf",I_design);
	  $fsdbDumpvars(0,"+mda");
  `endif
end

	


PIPE I_design
(
  .clk(clk),
  .rst_n(rst_n),
  .in_valid(in_valid),
  .in_1(in_1),
  .in_2(in_2),
  .in_3(in_3),
  .in_4(in_4),
  .mode(mode),

  .out_valid(out_valid),
  .out_value(out_value)
);


PATTERN I_PATTERN
(   
  .clk(clk),
  .rst_n(rst_n),
  .in_valid(in_valid),
  .in_1(in_1),
  .in_2(in_2),
  .in_3(in_3),
  .in_4(in_4),
  .mode(mode),

  .out_valid(out_valid),
  .out_value(out_value)
);
endmodule

