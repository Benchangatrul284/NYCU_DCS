
`include "Handshake_syn.v"

module CDC(
	// Input signals
	clk_1,
	clk_2,
	rst_n,
	in_valid,
	in_data,
	// Output signals
	out_valid,
	out_data
);

input clk_1; 
input clk_2;			
input rst_n;
input in_valid;
input[7:0]in_data;

output logic out_valid;
output logic [4:0]out_data; 			

// ---------------------------------------------------------------------
// logic declaration                 
// ---------------------------------------------------------------------
parameter S_wait_input = 3'b000;
parameter S_wait_sync_idle = 3'b001;
parameter S_send_data = 3'b010;

parameter S_wait_sync_high = 3'b100;
parameter S_out = 3'b101;
parameter S_wait_sync_low = 3'b110;

logic [2:0] cur_state1, next_state1;
logic [2:0] cur_state2, next_state2;
logic [7:0] in_data_comb, in_data_reg;

logic syn_idle, syn_ready; // design <- sync
logic [7:0] design_out; // design <- sync
logic design_valid; // design <- sync

logic [7:0] in_data_sync_comb, in_data_sync_reg; // store the data from the sync
logic design_busy; // design -> sync

logic out_valid_next;
logic [4:0] out_data_next;
// ---------------------------------------------------------------------
// design              
// ---------------------------------------------------------------------



always_ff @(posedge clk_1, negedge rst_n) begin
	if (~rst_n) begin
		cur_state1 <= 0;
		in_data_reg <= 0;
	end
	else begin
		cur_state1 <= next_state1;
		in_data_reg <= in_data_comb;
	end
end

always_ff @(posedge clk_2, negedge rst_n) begin
	if (~rst_n) begin
		cur_state2 <= 3'b100;
		in_data_sync_reg <= 0;
		out_valid <= 0;
		out_data <= 0;
	end
	else begin
		cur_state2 <= next_state2;
		in_data_sync_reg <= in_data_sync_comb;
		out_valid <= out_valid_next;
		out_data <= out_data_next;
	end
end

// receive the pattern
always_comb begin
	next_state1 = cur_state1;
	in_data_comb = in_data_reg;
	syn_ready = 0;
	case (cur_state1)
	S_wait_input: begin
		if (in_valid) begin
			next_state1 = S_wait_sync_idle;
			in_data_comb = in_data;
		end
	end
	S_wait_sync_idle: begin
		// wait for the sync to be available to send data
		if (syn_idle) begin
			next_state1 = S_send_data;
		end
	end
	S_send_data: begin
		// send the data to the sync
		syn_ready = 1;
		next_state1 = S_wait_input;
	end
	endcase
end

// receive and compute from sync
always_comb begin
	design_busy = 0; // the design is always able to receive the data from sync
	in_data_sync_comb = in_data_sync_reg;
	out_valid_next = 0;
	out_data_next = 0;
	next_state2 = cur_state2;
	case (cur_state2)
	S_wait_sync_high: begin
		if (design_valid) begin
			next_state2 = S_out;
			in_data_sync_comb = design_out;
		end
	end
	S_out: begin
		// compute the result
		out_valid_next = 1;
		out_data_next = in_data_sync_reg[7:4] + in_data_sync_reg[3:0];
		next_state2 = S_wait_sync_low;
	end
	S_wait_sync_low: begin
		if (!design_valid) // to avoid picking the previous data
			next_state2 = S_wait_sync_high;
	end
	endcase
end


Handshake_syn sync(
					.sclk(clk_1), 
					.dclk(clk_2), 
					.rst_n(rst_n),
					.sidle(syn_idle), 
					.sready(syn_ready),  
					.din(in_data_reg), 
					.dbusy(design_busy), 
					.dvalid(design_valid), 
					.dout(design_out)
);

// Handshake_syn sync(
// 					.sclk(clk_1), 
// 					.dclk(clk_2), 
// 					.rst_n(rst_n),
// 					.sidle(syn_idle), // 告訴design現在synchronizer是否可以接受來自design的資料
// 					.sready(syn_ready),  //當design傳送資料(din)給synchronizer時拉起 (類似給in_valid)
// 					.din(in_data_reg), // 要給synchronizer的資料 (PATTERN給的8 bit data)
// 					.dbusy(design_busy), // 告訴synchronizer現在design是否可以接收來自synchronizer的資料
// 					.dvalid(design_valid), // Synchronizer告訴design現在的資料是合法的 (類似給in_valid)
// 					.dout(design_out) // Synchronizer的資料輸出，由design接收後計算
// );


		
endmodule