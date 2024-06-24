// pipeline at WEI, have if
// 6 ns
module DCSformer(
	// Input signals
	clk,
	rst_n,
	i_valid,
	w_valid,
	i_data,
	w_data,
	// Output signals
	w_ready,
	o_valid,
	o_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input               clk, rst_n, i_valid, w_valid;
input         [7:0] i_data, w_data;
output logic        w_ready, o_valid;
output logic [31:0] o_data;
//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
logic [7:0] i_data_matrix [0:7][0:15];
logic [7:0] i_data_matrix_next [0:7][0:15];

logic [20:0] mm_matrix [0:7][0:7];
logic [20:0] mm_matrix_next [0:7][0:7];

logic [28:0] mul [0:7];
logic [28:0] mul_next [0:7];

logic [31:0] vec [0:7];
logic [31:0] vec_next [0:7];

logic [3:0] r_cnt,r_cnt_next;
logic [3:0] c_cnt,c_cnt_next;

logic ave_flag,ave_flag_next;
logic w_ready_next, o_valid_next;

logic [1:0] cur_state,next_state;


parameter IDLE = 2'b00,
		RAT = 2'b01,
		WEI = 2'b10,
		OUT = 2'b11;

logic [7:0] i_data_reg;
logic [7:0] w_data_reg;

logic i_valid_buf;
logic w_valid_buf,w_valid_buf_buf,w_valid_buf_buf_buf;

logic [31:0] o_data_next;
logic [3:0] index;

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		w_ready <= 0; 
		o_valid <= 0;
		o_data <= 0;
		r_cnt <= 0;
		c_cnt <= 0;
		cur_state <= IDLE;
		i_data_reg <= 0;
		w_data_reg <= 0;
		i_valid_buf <= 0;
		w_valid_buf <= 0;
		w_valid_buf_buf <= 0;
		ave_flag <= 0;

		i_data_matrix[0] <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		i_data_matrix[1] <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		i_data_matrix[2] <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		i_data_matrix[3] <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		i_data_matrix[4] <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		i_data_matrix[5] <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		i_data_matrix[6] <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		i_data_matrix[7] <= {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

		mm_matrix[0] <= {0,0,0,0,0,0,0,0};
		mm_matrix[1] <= {0,0,0,0,0,0,0,0};
		mm_matrix[2] <= {0,0,0,0,0,0,0,0};
		mm_matrix[3] <= {0,0,0,0,0,0,0,0};
		mm_matrix[4] <= {0,0,0,0,0,0,0,0};
		mm_matrix[5] <= {0,0,0,0,0,0,0,0};
		mm_matrix[6] <= {0,0,0,0,0,0,0,0};
		mm_matrix[7] <= {0,0,0,0,0,0,0,0};
		vec <= {0,0,0,0,0,0,0,0};
		mul <= {0,0,0,0,0,0,0,0};
	end
	else begin
		w_ready <= w_ready_next; 
		o_valid <= o_valid_next;
		o_data <= o_data_next;
		r_cnt <= r_cnt_next;
		c_cnt <= c_cnt_next;
		ave_flag <= ave_flag_next;
		cur_state <= next_state;
		i_data_reg <= i_data;
		w_data_reg <= w_data;
		i_valid_buf <= i_valid;
		i_data_matrix <= i_data_matrix_next;
		mm_matrix <= mm_matrix_next;
		w_valid_buf <= w_valid;
		w_valid_buf_buf <= w_valid_buf;
		vec <= vec_next;
		mul <= mul_next;
	end

end

always_comb begin
	next_state = cur_state;
	r_cnt_next = r_cnt;
	c_cnt_next = c_cnt;
	mm_matrix_next = mm_matrix;
	i_data_matrix_next = i_data_matrix;
	vec_next = vec;
	mul_next = mul;
	ave_flag_next = ave_flag;
	w_ready_next = 0;
	o_data_next = 0;
	o_valid_next = 0;

	case (cur_state)
	IDLE: begin
		// compute AAT
		if (i_valid_buf) begin
			if (c_cnt == 15) begin
				c_cnt_next = 0;
				r_cnt_next = r_cnt + 1;
			end
			else begin
				c_cnt_next = c_cnt + 1;
				r_cnt_next = r_cnt;
			end
			if (r_cnt == 7 && c_cnt == 15) begin
				next_state = RAT;
				r_cnt_next = 0;
				c_cnt_next = 0;
			end
			i_data_matrix_next[r_cnt][c_cnt] = i_data_reg;

			
			mm_matrix_next[r_cnt][r_cnt] = mm_matrix[r_cnt][r_cnt]+ i_data_matrix_next[r_cnt][c_cnt]*i_data_matrix_next[r_cnt][c_cnt];
			
			if (r_cnt>0) begin
				index = r_cnt-1;
				mm_matrix_next[index][r_cnt] = mm_matrix[index][r_cnt] + i_data_matrix_next[r_cnt][c_cnt]*i_data_matrix_next[index][c_cnt];
				mm_matrix_next[r_cnt][index] = mm_matrix_next[index][r_cnt];
			end
			if (r_cnt>1) begin
				index = r_cnt-2;
				mm_matrix_next[index][r_cnt] = mm_matrix[index][r_cnt] + i_data_matrix_next[r_cnt][c_cnt]*i_data_matrix_next[index][c_cnt];
				mm_matrix_next[r_cnt][index] = mm_matrix_next[index][r_cnt];
			end
			if (r_cnt>2) begin
				index = r_cnt-3;
				mm_matrix_next[index][r_cnt] = mm_matrix[index][r_cnt] + i_data_matrix_next[r_cnt][c_cnt]*i_data_matrix_next[index][c_cnt];
				mm_matrix_next[r_cnt][index] = mm_matrix_next[index][r_cnt];
			end
			if (r_cnt>3) begin
				index = r_cnt-4;
				mm_matrix_next[index][r_cnt] = mm_matrix[index][r_cnt] + i_data_matrix_next[r_cnt][c_cnt]*i_data_matrix_next[index][c_cnt];
				mm_matrix_next[r_cnt][index] = mm_matrix_next[index][r_cnt];
			end
			if (r_cnt>4) begin
				index = r_cnt-5;
				mm_matrix_next[index][r_cnt] = mm_matrix[index][r_cnt] + i_data_matrix_next[r_cnt][c_cnt]*i_data_matrix_next[index][c_cnt];
				mm_matrix_next[r_cnt][index] = mm_matrix_next[index][r_cnt];
			end
			if (r_cnt>5) begin
				index = r_cnt-6;
				mm_matrix_next[index][r_cnt] = mm_matrix[index][r_cnt] + i_data_matrix_next[r_cnt][c_cnt]*i_data_matrix_next[index][c_cnt];
				mm_matrix_next[r_cnt][index] = mm_matrix_next[index][r_cnt];
			end
			if (r_cnt>6) begin
				index = r_cnt-7;
				mm_matrix_next[index][r_cnt] = mm_matrix[index][r_cnt] + i_data_matrix_next[r_cnt][c_cnt]*i_data_matrix_next[index][c_cnt];
				mm_matrix_next[r_cnt][index] = mm_matrix_next[index][r_cnt];
			end
		end
	end
	RAT: begin
		r_cnt_next = r_cnt + 1;
		c_cnt_next = c_cnt + 1;
		if (ave_flag == 0) begin
			if (r_cnt < 8) begin
				vec_next[0] = vec[0] + mm_matrix[r_cnt][0];
				vec_next[1] = vec[1] + mm_matrix[r_cnt][1];
				vec_next[2] = vec[2] + mm_matrix[r_cnt][2];
				vec_next[3] = vec[3] + mm_matrix[r_cnt][3];
				vec_next[4] = vec[4] + mm_matrix[r_cnt][4];
				vec_next[5] = vec[5] + mm_matrix[r_cnt][5];
				vec_next[6] = vec[6] + mm_matrix[r_cnt][6];
				vec_next[7] = vec[7] + mm_matrix[r_cnt][7];
			end
			else if (r_cnt == 8) begin
				vec_next[0] = vec[0] >> 3;
				vec_next[1] = vec[1] >> 3;
				vec_next[2] = vec[2] >> 3;
				vec_next[3] = vec[3] >> 3;
				vec_next[4] = vec[4] >> 3;
				vec_next[5] = vec[5] >> 3;
				vec_next[6] = vec[6] >> 3;
				vec_next[7] = vec[7] >> 3;
				c_cnt_next = 0;
				ave_flag_next = 1;
			end
		end
		// compare
		else begin
			mm_matrix_next[c_cnt][0] = (mm_matrix[c_cnt][0] > vec[c_cnt])? mm_matrix[c_cnt][0]:0;
			mm_matrix_next[c_cnt][1] = (mm_matrix[c_cnt][1] > vec[c_cnt])? mm_matrix[c_cnt][1]:0;
			mm_matrix_next[c_cnt][2] = (mm_matrix[c_cnt][2] > vec[c_cnt])? mm_matrix[c_cnt][2]:0;
			mm_matrix_next[c_cnt][3] = (mm_matrix[c_cnt][3] > vec[c_cnt])? mm_matrix[c_cnt][3]:0;
			mm_matrix_next[c_cnt][4] = (mm_matrix[c_cnt][4] > vec[c_cnt])? mm_matrix[c_cnt][4]:0;
			mm_matrix_next[c_cnt][5] = (mm_matrix[c_cnt][5] > vec[c_cnt])? mm_matrix[c_cnt][5]:0;
			mm_matrix_next[c_cnt][6] = (mm_matrix[c_cnt][6] > vec[c_cnt])? mm_matrix[c_cnt][6]:0;
			mm_matrix_next[c_cnt][7] = (mm_matrix[c_cnt][7] > vec[c_cnt])? mm_matrix[c_cnt][7]:0;
			if (c_cnt == 8) begin
				w_ready_next = 1;
				next_state = WEI;
				vec_next = {0,0,0,0,0,0,0,0};
				r_cnt_next = 0;
				c_cnt_next = 0;
			end
		end

	end
	WEI: begin
		if (w_valid_buf) begin
			r_cnt_next = r_cnt + 1;
			// pipeline this multiplier
			// crtical path here (21bit multiplier)
			mul_next[0] = w_data_reg * mm_matrix[0][r_cnt];
			mul_next[1] = w_data_reg * mm_matrix[1][r_cnt];
			mul_next[2] = w_data_reg * mm_matrix[2][r_cnt];
			mul_next[3] = w_data_reg * mm_matrix[3][r_cnt];
			mul_next[4] = w_data_reg * mm_matrix[4][r_cnt];
			mul_next[5] = w_data_reg * mm_matrix[5][r_cnt];
			mul_next[6] = w_data_reg * mm_matrix[6][r_cnt];
			mul_next[7] = w_data_reg * mm_matrix[7][r_cnt];
		end
		if (w_valid_buf_buf) begin
			vec_next[0] = vec[0] + mul[0];
			vec_next[1] = vec[1] + mul[1];
			vec_next[2] = vec[2] + mul[2];
			vec_next[3] = vec[3] + mul[3];
			vec_next[4] = vec[4] + mul[4];
			vec_next[5] = vec[5] + mul[5];
			vec_next[6] = vec[6] + mul[6];
			vec_next[7] = vec[7] + mul[7];
			if (r_cnt == 8) begin
				next_state = OUT;
				r_cnt_next = 0;
				c_cnt_next = 0;
			end
		end
	end
	OUT: begin
		o_valid_next = 1;
		r_cnt_next = r_cnt + 1;
		o_data_next = vec[r_cnt];
		if (r_cnt == 8) begin
			next_state = IDLE;
			r_cnt_next = 0;
			c_cnt_next = 0;
			o_valid_next = 0;
			o_data_next = 0;
			i_data_matrix_next[0] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
			i_data_matrix_next[1] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
			i_data_matrix_next[2] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
			i_data_matrix_next[3] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
			i_data_matrix_next[4] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
			i_data_matrix_next[5] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
			i_data_matrix_next[6] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
			i_data_matrix_next[7] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

			mm_matrix_next[0] = {0,0,0,0,0,0,0,0};
			mm_matrix_next[1] = {0,0,0,0,0,0,0,0};
			mm_matrix_next[2] = {0,0,0,0,0,0,0,0};
			mm_matrix_next[3] = {0,0,0,0,0,0,0,0};
			mm_matrix_next[4] = {0,0,0,0,0,0,0,0};
			mm_matrix_next[5] = {0,0,0,0,0,0,0,0};
			mm_matrix_next[6] = {0,0,0,0,0,0,0,0};
			mm_matrix_next[7] = {0,0,0,0,0,0,0,0};
			vec_next = {0,0,0,0,0,0,0,0};
			mul_next = {0,0,0,0,0,0,0,0};
			ave_flag_next = 0;
		end
	end
	endcase
end
endmodule
