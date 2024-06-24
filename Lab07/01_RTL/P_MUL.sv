module P_MUL(
    // input signals
	in_1,
	in_2,
	in_3,
	in_4,
	in_valid,
	rst_n,
	clk,
	
    // output signals
    out_valid,
	out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [47:0] in_1, in_2;
input [47:0] in_3, in_4;
input in_valid, rst_n, clk;
output logic out_valid;
output logic [95:0] out;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [47:0] max_a, max_a_next;
logic [47:0] max_b, max_b_next;
logic [47:0] a [3:0];
logic [47:0] b [3:0];
logic [23:0] multiplier_next [15:0]; // there will be 16 24bits intermediate value
logic [23:0] multiplier [15:0]; // there will be 16 intermediate value
logic [95:0] out_next;
logic out_valid_next;
logic [10:0] cnt,cnt_next;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		max_a <= 0;
		max_b <= 0;
		multiplier <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		out <= 0;
		out_valid <= 0;
		cnt <= 0;
	end
	else begin
		max_a <= max_a_next;
		max_b <= max_b_next;
		multiplier <= multiplier_next;
		out <= out_next;
		out_valid <= out_valid_next;
		cnt <= cnt_next;
	end
end

always_comb begin
	out_valid_next = 0;
	max_a_next = max_a;
	max_b_next = max_b;

	cnt_next = cnt + 1;
	if (in_valid == 1) begin
		max_a_next = (in_1 > in_2) ? in_1: in_2;
		max_b_next = (in_3 > in_4) ? in_3: in_4;
	end
	
	a[3] = max_a[47:36];
	a[2] = max_a[35:24];
	a[1] = max_a[23:12];
	a[0] = max_a[11:0];

	b[3] = max_b[47:36];
	b[2] = max_b[35:24];
	b[1] = max_b[23:12];
	b[0] = max_b[11:0];

	multiplier_next = {a[3]*b[3],a[3]*b[2],a[3]*b[1],a[3]*b[0], 
					   a[2]*b[3],a[2]*b[2],a[2]*b[1],a[2]*b[0],
					   a[1]*b[3],a[1]*b[2],a[1]*b[1],a[1]*b[0],
					   a[0]*b[3],a[0]*b[2],a[0]*b[1],a[0]*b[0]};
	
	// mul
	out_next =  (  ((multiplier[15] << 72) + (multiplier[14] << 60)) + ((multiplier[13] << 48) + (multiplier[12] << 36))) + 
				(  ((multiplier[11] << 60) + (multiplier[10] << 48)) + ((multiplier[9] << 36)  +  (multiplier[8] << 24))) + 
				(  ((multiplier[7] << 48)  +  (multiplier[6] << 36)) +  ((multiplier[5] << 24)  +  (multiplier[4] << 12))) + 
				(  ((multiplier[3] << 36)  +  (multiplier[2] << 24)) +  ((multiplier[1] << 12) + (multiplier[0])));
	
	if (cnt >= 6)
		out_valid_next = 1;
end

endmodule