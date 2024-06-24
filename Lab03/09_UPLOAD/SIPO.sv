module SIPO(
	// input signals
	clk,
	rst_n,
	in_valid,
	s_in,
	
	// output signals
	out_valid,
	p_out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n;
input in_valid;
input s_in;
output logic out_valid;
output logic [3:0] p_out;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [2:0] cnt,cnt_next;
logic [3:0] shift_r;

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		shift_r <= 4'b0;
		cnt <= 0;
	end
	else if(in_valid) begin
		// notice why {shift_r[2:0] here !!!
		shift_r <= {shift_r[2:0],s_in};
		cnt <= cnt_next;
	end
	else begin
		shift_r <= 0;
		cnt <= 0;
	end
end

always_comb begin
	if (in_valid && cnt < 4) begin
		cnt_next = cnt + 1;
	end
	else
		cnt_next = 0;
end

assign out_valid = (cnt==4)? 1 : 0;
assign p_out = shift_r;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------


endmodule