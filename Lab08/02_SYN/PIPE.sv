module PIPE(
  // Input signals
  clk,
  rst_n,
  in_valid,
  in_1,
  in_2,
  in_3,
  in_4,
  mode,
  // Output signals
  out_valid,
  out_value
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input  logic clk,rst_n,in_valid;
input  logic [5:0] in_1,in_2,in_3,in_4;
input  logic [1:0] mode;

output logic out_valid;

output logic [26:0] out_value;
//---------------------------------------------------------------------
//   Design
//---------------------------------------------------------------------
logic [5:0] in_1_buf,in_2_buf,in_3_buf,in_4_buf;
logic in_valid_buf;

logic [26:0] pipe1_a, pipe1_b, pipe2_a, pipe2_b;
logic out_valid_buf, out_valid1;
logic [1:0] mode_buf, mode1;

// the signal should be reset
always_ff @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    out_valid <= 0;
    out_value <= 0;
  end
  else begin
    out_valid <= out_valid1;
    out_value <= pipe2_a;
  end
end

// valid signal
always_ff @ (posedge clk) begin
  out_valid_buf <= (in_valid_buf)? 1:0;
  out_valid1 <= out_valid_buf;
end

// input buffer
always_ff @ (posedge clk) begin
  in_valid_buf <= in_valid;
  in_1_buf <= in_1;
  in_2_buf <= in_2;
  in_3_buf <= in_3;
  in_4_buf <= in_4;
  mode_buf <= mode;
end

// pipeline signal
always_ff @ (posedge clk) begin
  mode1 <= mode_buf;
  // first stage pipeline
  case (mode_buf)
  2'b00: begin
    pipe1_a <= in_1_buf;
    pipe1_b <= in_2_buf;
  end
  2'b01: begin
    pipe1_a <= in_3_buf;
    pipe1_b <= in_4_buf;
  end
  2'b10: begin
    pipe1_a <= in_1_buf * in_2_buf;
    pipe1_b <= in_3_buf * in_4_buf;
  end
  endcase

  //second stage pipeline
  case (mode1)
  2'b00: begin
    pipe2_a <= pipe1_a * pipe1_b;
    pipe2_b <= pipe2_b;
  end
  2'b01: begin
    pipe2_a <= pipe1_a + pipe1_b;
    pipe2_b <= pipe2_b;
  end
  2'b10: begin
    pipe2_a <= pipe1_a * pipe1_b;
    pipe2_b <= pipe2_b;
  end
  endcase

end
endmodule
