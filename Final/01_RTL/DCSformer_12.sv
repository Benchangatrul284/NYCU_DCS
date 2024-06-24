// pipeline at WEI, have if
// 5.3 ns (67)
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

logic [19:0] mm_matrix [0:7][0:7];
logic [19:0] mm_matrix_next [0:7][0:7];

logic [27:0] mul [0:7];
logic [27:0] mul_next [0:7];

logic [31:0] vec [0:7];
logic [31:0] vec_next [0:7];

logic [3:0] r_cnt,r_cnt_next,r_cnt_buf,r_cnt_buf_buf,r_cnt_buf_buf_buf;
logic [3:0] c_cnt,c_cnt_next,c_cnt_buf;


logic [1:0] cur_state,next_state;

parameter IDLE = 2'b00,
		AVE = 2'b01,
		RAT = 2'b10,
		OUT = 2'b11;


logic [7:0] data_buf,data_buf_buf,data_buf_buf_buf;

logic i_valid_buf,i_valid_buf_buf,i_valid_buf_buf_buf,i_valid_buf_buf_buf_buf;
logic w_valid_buf,w_valid_buf_buf,w_valid_buf_buf_buf,w_valid_buf_buf_buf_buf;

logic [19:0] mul_temp_next [0:7];
logic [19:0] mul_temp [0:7];


always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		r_cnt <= 0;
		c_cnt <= 0;
		r_cnt_buf <= 0;
		r_cnt_buf_buf <= 0;
		c_cnt_buf <= 0;

		cur_state <= IDLE;
		data_buf <= 0;
		data_buf_buf <= 0;
		data_buf_buf_buf <= 0;

		i_valid_buf <= 0;
		i_valid_buf_buf <= 0;
		i_valid_buf_buf_buf <= 0;
		i_valid_buf_buf_buf_buf <= 0;
		
		w_valid_buf <= 0;
		w_valid_buf_buf <= 0;
		w_valid_buf_buf_buf <= 0;
		w_valid_buf_buf_buf_buf <= 0;
		
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
		mul_temp <= {0,0,0,0,0,0,0,0};
		
	end
	else begin
		r_cnt <= r_cnt_next;
		r_cnt_buf <= r_cnt;
		r_cnt_buf_buf <= r_cnt_buf;
		r_cnt_buf_buf_buf <= r_cnt_buf_buf;

		c_cnt <= c_cnt_next;
		c_cnt_buf <= c_cnt;

		cur_state <= next_state;

		if (i_valid) begin
			data_buf <= i_data;
		end 
		else if (w_valid) begin
			data_buf <= w_data;
		end

		data_buf_buf <= data_buf;
		data_buf_buf_buf <= data_buf_buf;

		i_valid_buf <= i_valid;
		i_valid_buf_buf <= i_valid_buf;
		i_valid_buf_buf_buf <= i_valid_buf_buf;
		i_valid_buf_buf_buf_buf <= i_valid_buf_buf_buf;
		

		w_valid_buf <= w_valid;
		w_valid_buf_buf <= w_valid_buf;
		w_valid_buf_buf_buf <= w_valid_buf_buf;
		w_valid_buf_buf_buf_buf <= w_valid_buf_buf_buf;
		
		i_data_matrix <= i_data_matrix_next;
		mm_matrix <= mm_matrix_next;
		vec <= vec_next;
		mul <= mul_next;
		mul_temp <= mul_temp_next;
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
	w_ready = 0;
	o_valid = 0;
	o_data = 0;
	mul_temp_next = mul_temp;

	case (cur_state)
	IDLE: begin
		// compute AAT and I@W
		if (i_valid_buf || w_valid_buf) begin
			// store the input value
			i_data_matrix_next[r_cnt][c_cnt] = data_buf;
			if (c_cnt == 15) begin
				c_cnt_next = 0;
				r_cnt_next = r_cnt + 1;
			end
			else begin
				c_cnt_next = c_cnt + 1;
			end
		end

		
		if (i_valid_buf_buf) begin
			mul_temp_next[0] = i_data_matrix[0][c_cnt_buf];
			mul_temp_next[1] = i_data_matrix[1][c_cnt_buf];
			mul_temp_next[2] = i_data_matrix[2][c_cnt_buf];
			mul_temp_next[3] = i_data_matrix[3][c_cnt_buf];
			mul_temp_next[4] = i_data_matrix[4][c_cnt_buf];
			mul_temp_next[5] = i_data_matrix[5][c_cnt_buf];
			mul_temp_next[6] = i_data_matrix[6][c_cnt_buf];
			mul_temp_next[7] = i_data_matrix[7][c_cnt_buf];
		end
		else if (w_valid_buf_buf) begin
			mul_temp_next[0] = mm_matrix[0][c_cnt_buf];
			mul_temp_next[1] = mm_matrix[1][c_cnt_buf];
			mul_temp_next[2] = mm_matrix[2][c_cnt_buf];
			mul_temp_next[3] = mm_matrix[3][c_cnt_buf];
			mul_temp_next[4] = mm_matrix[4][c_cnt_buf];
			mul_temp_next[5] = mm_matrix[5][c_cnt_buf];
			mul_temp_next[6] = mm_matrix[6][c_cnt_buf];
			mul_temp_next[7] = mm_matrix[7][c_cnt_buf];
		end
		
			
		if  (i_valid_buf_buf_buf || w_valid_buf_buf_buf) begin
			// multiplication
			mul_next[0] = mul_temp[0] * data_buf_buf_buf;
			mul_next[1] = mul_temp[1] * data_buf_buf_buf;
			mul_next[2] = mul_temp[2] * data_buf_buf_buf;
			mul_next[3] = mul_temp[3] * data_buf_buf_buf;
			mul_next[4] = mul_temp[4] * data_buf_buf_buf;
			mul_next[5] = mul_temp[5] * data_buf_buf_buf;
			mul_next[6] = mul_temp[6] * data_buf_buf_buf;
			mul_next[7] = mul_temp[7] * data_buf_buf_buf;
		end
		
		if (i_valid_buf_buf_buf_buf) begin
			mm_matrix_next[0][r_cnt_buf_buf_buf] = mm_matrix[0][r_cnt_buf_buf_buf] + mul[0][15:0];
			mm_matrix_next[1][r_cnt_buf_buf_buf] = mm_matrix[1][r_cnt_buf_buf_buf] + mul[1][15:0];
			mm_matrix_next[2][r_cnt_buf_buf_buf] = mm_matrix[2][r_cnt_buf_buf_buf] + mul[2][15:0];
			mm_matrix_next[3][r_cnt_buf_buf_buf] = mm_matrix[3][r_cnt_buf_buf_buf] + mul[3][15:0];
			mm_matrix_next[4][r_cnt_buf_buf_buf] = mm_matrix[4][r_cnt_buf_buf_buf] + mul[4][15:0];
			mm_matrix_next[5][r_cnt_buf_buf_buf] = mm_matrix[5][r_cnt_buf_buf_buf] + mul[5][15:0];
			mm_matrix_next[6][r_cnt_buf_buf_buf] = mm_matrix[6][r_cnt_buf_buf_buf] + mul[6][15:0];
			mm_matrix_next[7][r_cnt_buf_buf_buf] = mm_matrix[7][r_cnt_buf_buf_buf] + mul[7][15:0];

			mm_matrix_next[r_cnt_buf_buf_buf][0] = mm_matrix_next[0][r_cnt_buf_buf_buf];
			mm_matrix_next[r_cnt_buf_buf_buf][1] = mm_matrix_next[1][r_cnt_buf_buf_buf];
			mm_matrix_next[r_cnt_buf_buf_buf][2] = mm_matrix_next[2][r_cnt_buf_buf_buf];
			mm_matrix_next[r_cnt_buf_buf_buf][3] = mm_matrix_next[3][r_cnt_buf_buf_buf];
			mm_matrix_next[r_cnt_buf_buf_buf][4] = mm_matrix_next[4][r_cnt_buf_buf_buf];
			mm_matrix_next[r_cnt_buf_buf_buf][5] = mm_matrix_next[5][r_cnt_buf_buf_buf];
			mm_matrix_next[r_cnt_buf_buf_buf][6] = mm_matrix_next[6][r_cnt_buf_buf_buf];
			mm_matrix_next[r_cnt_buf_buf_buf][7] = mm_matrix_next[7][r_cnt_buf_buf_buf];
			
			if (!i_valid_buf_buf_buf) begin
				next_state = AVE;
				r_cnt_next = 0;
				c_cnt_next = 0;
			end
		end

		else if (w_valid_buf_buf_buf_buf) begin
			vec_next[0] = vec[0] + mul[0];
			vec_next[1] = vec[1] + mul[1];
			vec_next[2] = vec[2] + mul[2];
			vec_next[3] = vec[3] + mul[3];
			vec_next[4] = vec[4] + mul[4];
			vec_next[5] = vec[5] + mul[5];
			vec_next[6] = vec[6] + mul[6];
			vec_next[7] = vec[7] + mul[7];
			if (!w_valid_buf_buf_buf) begin
				next_state = OUT;
				c_cnt_next = 0;
				r_cnt_next = 0;
			end
		end
	end
	AVE: begin
		c_cnt_next = c_cnt + 1;
		if (c_cnt < 8) begin
			vec_next[0] = vec[0] + mm_matrix[c_cnt][0];
			vec_next[1] = vec[1] + mm_matrix[c_cnt][1];
			vec_next[2] = vec[2] + mm_matrix[c_cnt][2];
			vec_next[3] = vec[3] + mm_matrix[c_cnt][3];
			vec_next[4] = vec[4] + mm_matrix[c_cnt][4];
			vec_next[5] = vec[5] + mm_matrix[c_cnt][5];
			vec_next[6] = vec[6] + mm_matrix[c_cnt][6];
			vec_next[7] = vec[7] + mm_matrix[c_cnt][7];
		end
		else if (c_cnt == 8) begin
			vec_next[0] = vec[0] >> 3;
			vec_next[1] = vec[1] >> 3;
			vec_next[2] = vec[2] >> 3;
			vec_next[3] = vec[3] >> 3;
			vec_next[4] = vec[4] >> 3;
			vec_next[5] = vec[5] >> 3;
			vec_next[6] = vec[6] >> 3;
			vec_next[7] = vec[7] >> 3;
			c_cnt_next = 0;
			r_cnt_next = 0;
			next_state = RAT;
		end
	end
	RAT: begin
		// compare
		c_cnt_next = c_cnt + 1;
		mm_matrix_next[c_cnt][0] = (mm_matrix[c_cnt][0] >= vec[c_cnt])? mm_matrix[c_cnt][0]:0;
		mm_matrix_next[c_cnt][1] = (mm_matrix[c_cnt][1] >= vec[c_cnt])? mm_matrix[c_cnt][1]:0;
		mm_matrix_next[c_cnt][2] = (mm_matrix[c_cnt][2] >= vec[c_cnt])? mm_matrix[c_cnt][2]:0;
		mm_matrix_next[c_cnt][3] = (mm_matrix[c_cnt][3] >= vec[c_cnt])? mm_matrix[c_cnt][3]:0;
		mm_matrix_next[c_cnt][4] = (mm_matrix[c_cnt][4] >= vec[c_cnt])? mm_matrix[c_cnt][4]:0;
		mm_matrix_next[c_cnt][5] = (mm_matrix[c_cnt][5] >= vec[c_cnt])? mm_matrix[c_cnt][5]:0;
		mm_matrix_next[c_cnt][6] = (mm_matrix[c_cnt][6] >= vec[c_cnt])? mm_matrix[c_cnt][6]:0;
		mm_matrix_next[c_cnt][7] = (mm_matrix[c_cnt][7] >= vec[c_cnt])? mm_matrix[c_cnt][7]:0;
		if (c_cnt == 8) begin
			w_ready = 1;
			next_state = IDLE;
			vec_next = {0,0,0,0,0,0,0,0};
			r_cnt_next = 0;
			c_cnt_next = 0;
		end
		
	end
	OUT: begin
		c_cnt_next = c_cnt + 1;
		o_valid = 1;
		o_data = vec[c_cnt];
		if (c_cnt == 8) begin
			next_state = IDLE;
			r_cnt_next = 0;
			c_cnt_next = 0;
			o_valid = 0;
			o_data = 0;
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
		end
	end
	endcase
end
endmodule
