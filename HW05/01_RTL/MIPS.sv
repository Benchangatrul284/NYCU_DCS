module MIPS(
    //INPUT
    clk,
    rst_n,
    in_valid,
    instruction,

    //OUTPUT
    out_valid,
    instruction_fail,
    out_0,
    out_1,
    out_2,
    out_3,
    out_4,
    out_5
);
// INPUT
input clk;
input rst_n;
input in_valid;
input [31:0] instruction;

// OUTPUT
output logic out_valid, instruction_fail;
output logic [15:0] out_0, out_1, out_2, out_3, out_4, out_5;

//================================================================
// DESIGN 
//================================================================

logic [31:0] instruction_buf;
logic in_valid_buf;
logic out_valid_next, instruction_fail_next;
logic [15:0] out_0_next, out_1_next, out_2_next, out_3_next, out_4_next, out_5_next;

logic [15:0] rs_val, rt_val, rd_val, signal_or;
logic [4:0]  shamt;
logic [15:0] imm;

// retrieve the value given the address
function [15:0] addr_val;
    input [4:0] addr;
    case (addr) 
        5'b10001: addr_val = out_0;
        5'b10010: addr_val = out_1;
        5'b01000: addr_val = out_2; 
        5'b10111: addr_val = out_3; 
        5'b11111: addr_val = out_4; 
        5'b10000: addr_val = out_5; 
        default:  addr_val = 0;
    endcase
endfunction


always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        instruction_buf <= 0;
        in_valid_buf <= 0;
        out_0 <= 0;
        out_1 <= 0;
        out_2 <= 0;
        out_3 <= 0;
        out_4 <= 0;
        out_5 <= 0;
        out_valid <= 0;
        instruction_fail <= 0;
    end
    else begin
        if (in_valid) begin
            instruction_buf <= instruction;
        end
        in_valid_buf <= in_valid;
        out_0 <= out_0_next;
        out_1 <= out_1_next;
        out_2 <= out_2_next;
        out_3 <= out_3_next;
        out_4 <= out_4_next;
        out_5 <= out_5_next;
        out_valid <= out_valid_next;
        instruction_fail <= instruction_fail_next;
    end
end

always_comb begin
    instruction_fail_next = 0;
    out_0_next = 0;
    out_1_next = 0;
    out_2_next = 0;
    out_3_next = 0;
    out_4_next = 0;
    out_5_next = 0;
    out_valid_next = 0;
    rs_val = 0;
    rt_val = 0;
    rd_val = 0;
    shamt = 0;
    imm = 0;

    if (in_valid_buf != 0) begin
        out_0_next = out_0;
        out_1_next = out_1;
        out_2_next = out_2;
        out_3_next = out_3;
        out_4_next = out_4;
        out_5_next = out_5;
        // decode here
        out_valid_next = 1;
        shamt = instruction_buf[10:6];
        case (instruction_buf[31:26])
            6'b000000: begin
                rs_val = addr_val(instruction_buf[25:21]);
                rt_val = addr_val(instruction_buf[20:16]);
                signal_or = rs_val | rt_val;
                // R-type -> WB to rd's address
                case (instruction_buf[5:0])
                    6'b100000: rd_val = rs_val + rt_val;
                    6'b100100: rd_val = rs_val & rt_val;
                    6'b100101: rd_val = signal_or;
                    6'b100111: rd_val = ~signal_or;
                    6'b000000: rd_val = rt_val << shamt;
                    6'b000010: rd_val = rt_val >> shamt;
                default: instruction_fail_next = 0;
                endcase
                // write back
                case (instruction_buf[15:11])
                    5'b10001: out_0_next = rd_val;
                    5'b10010: out_1_next = rd_val;
                    5'b01000: out_2_next = rd_val; 
                    5'b10111: out_3_next = rd_val; 
                    5'b11111: out_4_next = rd_val; 
                    5'b10000: out_5_next = rd_val;
                    default: instruction_fail_next = 0; 
                endcase
            end
            6'b001000: begin
                // I-type
                rs_val = addr_val(instruction_buf[25:21]);
                imm = instruction_buf[15:0];
                rt_val = imm + rs_val;
                // write back
                case (instruction_buf[20:16])
                    5'b10001: out_0_next = rt_val;
                    5'b10010: out_1_next = rt_val;
                    5'b01000: out_2_next = rt_val; 
                    5'b10111: out_3_next = rt_val; 
                    5'b11111: out_4_next = rt_val; 
                    5'b10000: out_5_next = rt_val;
                default: instruction_fail_next = 0; 
                endcase
            end
            default: instruction_fail_next = 1;
        endcase
    end
end
endmodule