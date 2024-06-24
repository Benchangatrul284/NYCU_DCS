`timescale 1ns/1ps
`include "PATTERN.sv"

`ifdef RTL
`include "CDC.sv"
`elsif GATE
`include "CDC_SYN.v"
`endif

module TESTBED();


wire	clk_1,clk_2,rst_n,in_valid;
wire	[7:0] in_data;

wire	out_valid;
wire 	[4:0]out_data;

initial begin
  `ifdef RTL
    $fsdbDumpfile("CDC.fsdb");
	  $fsdbDumpvars(0,"+mda");
  `elsif GATE
    $fsdbDumpfile("CDC_SYN.fsdb");
	//$sdf_annotate("CDC_SYN.sdf",I_CDC);  
	$sdf_annotate("CDC_SYN_pt.sdf",I_CDC,,,"maximum"); 
	  $fsdbDumpvars(0,"+mda");
  `endif
end

CDC I_CDC
(
  // Input signals
	.clk_1(clk_1),
	.clk_2(clk_2),
	.rst_n(rst_n),
	.in_valid(in_valid),
	.in_data(in_data),
  // Output signals
	.out_valid(out_valid),
	.out_data(out_data)
);


PATTERN I_PATTERN
(
 // Input signals
	.clk_1(clk_1),
	.clk_2(clk_2),
	.rst_n(rst_n),
	.in_valid(in_valid),
	.in_data(in_data),
  // Output signals
	.out_valid(out_valid),
	.out_data(out_data)
);

endmodule