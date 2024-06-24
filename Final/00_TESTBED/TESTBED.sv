
`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
`include "DCSformer.sv"
`elsif GATE
`include "DCSformer_SYN.v"
`endif

module TESTBED();

logic clk, rst_n, i_valid, w_valid;
logic [7:0] i_data, w_data;
logic w_ready, o_valid;
logic [31:0] o_data;


initial begin
  `ifdef RTL
    $fsdbDumpfile("DCSformer.fsdb");
	  $fsdbDumpvars();
	  $fsdbDumpvars("+mda");
  `elsif GATE
    $fsdbDumpfile("DCSformer_SYN.fsdb");
	  $sdf_annotate("DCSformer_SYN.sdf",I_design);
	  $fsdbDumpvars();
  `endif 
end

	
DCSformer I_design
(
	.clk(clk),
	.rst_n(rst_n),
	.i_valid(i_valid),
	.w_valid(w_valid),	
	.i_data(i_data),
	.w_data(w_data),
	.w_ready(w_ready),
	.o_valid(o_valid),
	.o_data(o_data)
);


PATTERN I_PATTERN
(
	.clk(clk),
	.rst_n(rst_n),
	.i_valid(i_valid),
	.w_valid(w_valid),	
	.i_data(i_data),
	.w_data(w_data),
	.w_ready(w_ready),
	.o_valid(o_valid),
	.o_data(o_data)
);

endmodule

