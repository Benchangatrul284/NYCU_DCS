`timescale 1ns/1ps
`include "PATTERN.sv"
`ifdef RTL
	`include "DCSTCO.sv"
	`include "food_store.sv"
`elsif GATE
	`include "DCSTCO_SYN.v"
	`include "food_store.sv"
`endif

module TESTBED();

logic clk, rst_n ;
logic in_valid ;
logic [11:0] target_product ;
logic ready_refri ;
logic ready_kitch ;
logic out_valid ;
logic [3:0] ten ;
logic five ;
logic [2:0] one ;
logic run_out_ing ;
logic valid_refri ;
logic valid_kitch ;
logic product_out ;
logic [5:0] number_out ;


initial begin
  `ifdef RTL
		$fsdbDumpfile("DCSTCO.fsdb");
		$fsdbDumpvars;
  `elsif GATE
		$fsdbDumpfile("DCSTCO.fsdb");
		$sdf_annotate("DCSTCO_SYN.sdf",DCS);
		$fsdbDumpvars();
  `endif 
end

DCSTCO DCS
(
	.clk(clk),
	.rst_n(rst_n),
    .in_valid(in_valid),
	.target_product(target_product),
    .out_valid(out_valid),
	.ten(ten),
	.five(five),
	.one(one),
	.run_out_ing(run_out_ing),
	.ready_refri(ready_refri),
	.ready_kitch(ready_kitch),
	.valid_refri(valid_refri),
	.valid_kitch(valid_kitch),
	.product_out(product_out),
	.number_out(number_out)
);

PATTERN I_PATTERN
(
	.clk(clk),
	.rst_n(rst_n),
    .in_valid(in_valid),
	.target_product(target_product),
    .out_valid(out_valid),
	.ten(ten),
	.five(five),
	.one(one),
	.run_out_ing(run_out_ing),
	.ready_refri(ready_refri),
	.ready_kitch(ready_kitch),
	.valid_refri(valid_refri),
	.valid_kitch(valid_kitch),
	.product_out(product_out),
	.number_out(number_out)
);

endmodule