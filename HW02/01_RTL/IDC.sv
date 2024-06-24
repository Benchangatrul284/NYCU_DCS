module IDC(
    // Input signals
	clk,
	rst_n,
	in_valid,
    in_id,
    // Output signals
    out_valid,
    out_legal_id
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [5:0] in_id;

output logic out_valid;
output logic out_legal_id;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [5:0] cnt, cnt_next;
logic [5:0] in_id_buf;
logic [4:0] remainder, remainder_next, remainder_temp; //online computation
logic [4:0] adds [9:0][35:0];
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cnt <= 0;
        remainder <= 0;
        in_id_buf <= 0;
    end
    else begin
        cnt <= cnt_next;
        remainder <= remainder_temp;
        in_id_buf <= in_id;
    end
end

always_comb begin
    cnt_next = 0;
    if (cnt < 12 && in_valid == 1)
        cnt_next = cnt + 1;
end

assign adds[0] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
assign adds[1] = {8,9,0,1,2,3,3,4,5,6,7,8,9,0,1,2,2,3,4,5,6,7,8,9,0,1,0,0,0,0,0,0,0,0,0,0};
assign adds[2] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,4,6,8,0,2,4,6,8,0};
assign adds[3] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,6,9,2,5,8,1,4,7,0};
assign adds[4] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,8,2,6,0,4,8,2,6,0};
assign adds[5] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,5,0,5,0,5,0,5,0};
assign adds[6] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,2,8,4,0,6,2,8,4,0};
assign adds[7] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,4,1,8,5,2,9,6,3,0};
assign adds[8] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,6,4,2,0,8,6,4,2,0};
assign adds[9] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,8,7,6,5,4,3,2,1,0};

always_comb begin
    remainder_next = 0;
    out_valid= 0;
    out_legal_id = 0;
    remainder_temp = 0;
    
    if (cnt == 1) begin
        remainder_temp = adds[cnt][in_id_buf];
    end

    else if (cnt <= 9) begin
        remainder_next = (cnt == 1) ? adds[cnt][in_id_buf] : remainder + adds[cnt][in_id_buf];
        remainder_temp = remainder_next >= 10 ? remainder_next - 10 : remainder_next;
    end

    else begin
        out_valid = 1;
        remainder_temp = (remainder == 0)? 0 : 10 - remainder;
        out_legal_id= (remainder_temp == in_id_buf)? 1 : 0;
    end
end

endmodule