module CT(
    // Input signals
    opcode,
	in_n0,
	in_n1,
	in_n2,
	in_n3,
	in_n4,
	in_n5,
    // Output signals
    out_n
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [3:0] in_n0, in_n1, in_n2, in_n3, in_n4, in_n5;
input [4:0] opcode;
output logic [10:0] out_n;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

logic [4:0] value_0, value_1, value_2, value_3, value_4, value_5;
logic [4:0] temp_0, temp_1, temp_2, temp_3, temp_4, temp_5, temp;
logic [4:0] a0, a1, a2, a3, a4, a5;
logic [4:0] b0, b1, b2, b3, b4, b5;
logic [4:0] c0, c1, c2, c3, c4, c5;
logic [4:0] d0, d1, d2, d3;
logic [4:0] e0, e1;

logic [4:0] sum;
logic [5:0] partial_sum;

register_file reg1(.address(in_n0), .value(value_0));
register_file reg2(.address(in_n1), .value(value_1));
register_file reg3(.address(in_n2), .value(value_2));
register_file reg4(.address(in_n3), .value(value_3));
register_file reg5(.address(in_n4), .value(value_4));
register_file reg6(.address(in_n5), .value(value_5));

always_comb begin

    temp_0 = value_0;
    temp_1 = value_1;
    temp_2 = value_2;
    temp_3 = value_3;
    temp_4 = value_4;
    temp_5 = value_5;
    
    case (opcode[4:3]) 
    2'b11: begin
        a0 = (temp_0 < temp_1) ? temp_0 : temp_1;
        a1 = (temp_0 < temp_1) ? temp_1 : temp_0;
        a2 = (temp_2 < temp_3) ? temp_2 : temp_3;
        a3 = (temp_2 < temp_3) ? temp_3 : temp_2;
        a4 = (temp_4 < temp_5) ? temp_4 : temp_5;
        a5 = (temp_4 < temp_5) ? temp_5 : temp_4;
        b0 = (a0 < a2)? a0 : a2;
        b1 = (a0 < a2)? a2 : a0;
        b2 = (a1 < a4)? a1 : a4;
        b3 = (a1 < a4)? a4 : a1;
        b4 = (a3 < a5)? a3 : a5;
        b5 = (a3 < a5)? a5 : a3;
        c0 = (b0 < b2)? b0 : b2;
        c1 = (b0 < b2)? b2 : b0;
        c2 = (b1 < b4)? b1 : b4;
        c3 = (b1 < b4)? b4 : b1;
        c4 = (b3 < b5)? b3 : b5;
        c5 = (b3 < b5)? b5 : b3;
        d0 = (c1 < c2)? c1 : c2;
        d1 = (c1 < c2)? c2 : c1;
        d2 = (c3 < c4)? c3 : c4;
        d3 = (c3 < c4)? c4 : c3;
        e0 = (d1 < d2)? d1 : d2;
        e1 = (d1 < d2)? d2 : d1;

        temp_0 = c0;
        temp_1 = d0;
        temp_2 = e0;
        temp_3 = e1;
        temp_4 = d3;
        temp_5 = c5;
    end
    2'b10: begin
        a0 = (temp_0 < temp_1) ? temp_0 : temp_1;
        a1 = (temp_0 < temp_1) ? temp_1 : temp_0;
        a2 = (temp_2 < temp_3) ? temp_2 : temp_3;
        a3 = (temp_2 < temp_3) ? temp_3 : temp_2;
        a4 = (temp_4 < temp_5) ? temp_4 : temp_5;
        a5 = (temp_4 < temp_5) ? temp_5 : temp_4;
        b0 = (a0 < a2)? a0 : a2;
        b1 = (a0 < a2)? a2 : a0;
        b2 = (a1 < a4)? a1 : a4;
        b3 = (a1 < a4)? a4 : a1;
        b4 = (a3 < a5)? a3 : a5;
        b5 = (a3 < a5)? a5 : a3;
        c0 = (b0 < b2)? b0 : b2;
        c1 = (b0 < b2)? b2 : b0;
        c2 = (b1 < b4)? b1 : b4;
        c3 = (b1 < b4)? b4 : b1;
        c4 = (b3 < b5)? b3 : b5;
        c5 = (b3 < b5)? b5 : b3;
        d0 = (c1 < c2)? c1 : c2;
        d1 = (c1 < c2)? c2 : c1;
        d2 = (c3 < c4)? c3 : c4;
        d3 = (c3 < c4)? c4 : c3;
        e0 = (d1 < d2)? d1 : d2;
        e1 = (d1 < d2)? d2 : d1;

        temp_0 = c5;
        temp_1 = d3;
        temp_2 = e1;
        temp_3 = e0;
        temp_4 = d0;
        temp_5 = c0;
    end

    2'b01: begin
        temp = temp_0;
        temp_0 = temp_5;
        temp_5 = temp;
        temp = temp_1;
        temp_1 = temp_4;
        temp_4 = temp;
        temp = temp_2;
        temp_2 = temp_3;
        temp_3 = temp;
    end
    default: begin

    end
    endcase
    
    partial_sum = temp_0 + temp_5;
    case (opcode[2:0]) 
    3'b000: begin
        sum = (temp_1 + temp_2 + temp_3 + temp_4 + partial_sum) / 6;
        out_n = (temp_0 >= sum) + (temp_1 >= sum) + (temp_2 >= sum) + (temp_3 >= sum) + (temp_4 >= sum) + (temp_5 >= sum);
    end
    3'b001: begin
        out_n = partial_sum;
    end
    3'b010: begin
        out_n = (temp_3 * temp_4) >> 1;
    end
    3'b011: begin
        out_n = temp_0 + (temp_2 << 1);
    end
    3'b100: begin
        out_n = temp_1 & temp_2;
    end
    3'b101: begin
        out_n = ~temp_0;
    end
    3'b110: begin
        out_n = temp_3 ^ temp_4;
    end
    3'b111: begin
        out_n = temp_1 << 1;
    end
    endcase
end



endmodule



//---------------------------------------------------------------------
//   Register design from TA (Do not modify, or demo fails)
//---------------------------------------------------------------------
module register_file(
    address,
    value
);
input [3:0] address;
output logic [4:0] value;

always_comb begin
    case(address)
    4'b0000:value = 5'd9;
    4'b0001:value = 5'd27;
    4'b0010:value = 5'd30;
    4'b0011:value = 5'd3;
    4'b0100:value = 5'd11;
    4'b0101:value = 5'd8;
    4'b0110:value = 5'd26;
    4'b0111:value = 5'd17;
    4'b1000:value = 5'd3;
    4'b1001:value = 5'd12;
    4'b1010:value = 5'd1;
    4'b1011:value = 5'd10;
    4'b1100:value = 5'd15;
    4'b1101:value = 5'd5;
    4'b1110:value = 5'd23;
    4'b1111:value = 5'd20;
    default: value = 0;
    endcase
end

endmodule