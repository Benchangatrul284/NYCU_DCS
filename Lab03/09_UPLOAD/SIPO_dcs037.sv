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
logic [1:0] counter;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff @(negedge rst_n or posedge clk) begin
	if (~rst_n) begin
		out_valid <= 0;
		p_out <= 0; //reset the output
		counter <= 0; //reset the counter
	end


	else begin
		if (in_valid) begin
			p_out <= {p_out[2:0],s_in}; //shift the input to the left
			counter <= counter + 1; //increment the counter
			
			if (counter == 3) begin
				out_valid <= 1; //set the output valid signal
				counter <= 0; //reset the counter
			end
			else if (counter == 0) begin
				out_valid <= 0;
			end

			else begin
				out_valid <= 0; //reset the output valid signal
			end
		end

		else begin
			out_valid <= 0; //reset the output valid signal
			counter <= 0; //reset the counter
			p_out <= 0; //reset the output

		end
	end
end

endmodule