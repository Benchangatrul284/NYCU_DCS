module inter(
  // Input signals
  clk,
  rst_n,
  in_valid_1,
  in_valid_2,
  data_in_1,
  data_in_2,
  ready_slave1,
  ready_slave2,
  // Output signals
  valid_slave1,
  valid_slave2,
  addr_out,
  value_out,
  handshake_slave1,
  handshake_slave2
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid_1, in_valid_2;
input [6:0] data_in_1, data_in_2; 
input ready_slave1, ready_slave2;

output logic valid_slave1, valid_slave2;
output logic [2:0] addr_out, value_out;
output logic handshake_slave1, handshake_slave2;

parameter S_idle = 2'b00;
parameter S_master1 = 2'b01;
parameter S_master2 = 2'b10;
parameter S_handshake = 2'b11;
logic [1:0] cur_state, next_state;
logic in1, in2, in1_buf, in2_buf;
logic [6:0] data_in_1_buf, data_in_2_buf;
logic [6:0] data1, data2;
logic handshake_slave1_next, handshake_slave2_next;
logic [2:0] addr_out_next, value_out_next;
logic valid_slave1_next, valid_slave2_next;

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cur_state <= S_idle;
    end
    else begin
        cur_state <= next_state;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        in1_buf <= 0;
        in2_buf <= 0;
        data_in_1_buf <= 0;
        data_in_2_buf <= 0;
        handshake_slave1 <= 0;
        handshake_slave2 <= 0;
        valid_slave1 <= 0;
        valid_slave2 <= 0;
        value_out <= 0;
        addr_out <= 0;
    end
    else begin
        in1_buf <= in1;
        in2_buf <= in2;
        data_in_1_buf <= data1;
        data_in_2_buf <= data2;
        handshake_slave1 <= handshake_slave1_next;
        handshake_slave2 <= handshake_slave2_next;
        valid_slave1 <= valid_slave1_next;
        valid_slave2 <= valid_slave2_next;
        value_out <= value_out_next;
        addr_out <= addr_out_next;
    end
end

always_comb begin

    in1 = in1_buf;
    in2 = in2_buf;
    data1 = data_in_1_buf;
    data2 = data_in_2_buf;
    next_state = cur_state;
    addr_out_next = addr_out;
    value_out_next = value_out;
    handshake_slave1_next = 0;
    handshake_slave2_next = 0;
    addr_out_next = 0;
    value_out_next = 0;
    valid_slave1_next = 0;
    valid_slave2_next = 0;
    
    if (in_valid_1) begin
        in1 = 1;
        data1 = data_in_1;
    end
    if (in_valid_2) begin
        in2 = 1;
        data2 = data_in_2;
    end

    case (cur_state)
    S_idle: begin
        if (in2) begin
            next_state = S_master2;
            in2 = 0;
        end
        else if (in1) begin
            next_state = S_master1;
            in1 = 0;
        end
    end

    S_master1: begin
        handshake_slave1_next = 0;
        handshake_slave2_next = 0;
        addr_out_next = data_in_1_buf[5:3];
        value_out_next = data_in_1_buf[2:0];
        // to slave 1
        if (data_in_1_buf[6] == 0) begin
            valid_slave1_next = 1;
            if (valid_slave1 && ready_slave1) begin
                handshake_slave1_next = 1;
                next_state = S_handshake;
                in1 = 0;
            end
        end
        // to slave 2
        else if (data_in_1_buf[6] == 1) begin
            valid_slave2_next = 1;
            if (valid_slave2 && ready_slave2) begin
                handshake_slave2_next = 1;
                next_state = S_handshake;
                in1 = 0;
            end
        end
    end

    S_master2: begin
        handshake_slave1_next = 0;
        handshake_slave2_next = 0;
        addr_out_next = data_in_2_buf[5:3];
        value_out_next = data_in_2_buf[2:0];
        // to slave 1
        if (data_in_2_buf[6] == 0) begin
            valid_slave1_next = 1;
            if (valid_slave1 && ready_slave1) begin
                handshake_slave1_next = 1;
                next_state = S_handshake;
                in2 = 0;
            end
        end
        // to slave 2
        else if  (data_in_2_buf[6] == 1) begin
            valid_slave2_next = 1;
            if (valid_slave2 && ready_slave2) begin
                handshake_slave2_next = 1;
                next_state = S_handshake;
                in2 = 0;
            end
        end
    end

    S_handshake: begin
        if (in2 == 1) begin
            next_state = S_master2;
        end
        else if (in1 == 1 && in2 == 0) begin
            next_state = S_master1;
        end
        else
            next_state = S_idle; 
        if (handshake_slave1 || handshake_slave2) begin
            handshake_slave1_next = 0;
            handshake_slave2_next = 0;
            valid_slave1_next = 0;
            valid_slave2_next = 0;
        end
    end
    endcase

end
endmodule
