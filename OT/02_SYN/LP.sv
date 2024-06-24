module LP(
    // Input signals
	clk,
	rst_n,
	in_valid,
    in_a1,
	in_a2,
	in_b,
    // Output signals
    out_valid,
    out_max_value
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input signed [5:0] in_a1,in_a2;
input signed [11:0] in_b;

output logic out_valid;
output logic signed [11:0] out_max_value;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic in_valid_buf;
logic signed [5:0] in_a1_buf,in_a2_buf;
logic signed [11:0] in_b_buf;

logic signed [5:0] A[0:5][0:1];
logic signed [11:0] B[0:5];
logic signed [5:0] C[0:1];

logic signed [5:0] A_next[0:5][0:1];
logic signed [11:0] B_next[0:5];
logic signed [5:0] C_next[0:1];
logic [8:0] cnt, cnt_next;
logic [2:0] cur_state, next_state;

logic signed [11:0] out_max_value_next;
logic out_valid_next;

// store the bounds
logic signed [11:0] bound [0:1][0:1];
logic signed [11:0] bound_next [0:1][0:1];

logic [6:0] xrange,xrange_next;
logic [6:0] yrange,yrange_next;

logic signed [11:0] x,x_next;
logic signed [11:0] y,y_next;

logic [8:0] xcnt, xcnt_next;
logic [8:0] ycnt, ycnt_next;

logic is_valid;
logic signed [11:0] value;

parameter IDLE = 3'b000,
		  IN = 3'b001,
		  FIND = 3'b010,
          COMP = 3'b011,
          OUT = 3'b100;

// give the value of c first
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cnt <= 0;
        in_valid_buf <= 0;

        cur_state <= IDLE;
        in_a1_buf <= 0;
        in_a2_buf <= 0;
        in_b_buf <= 0;

        out_max_value <= 0;
        out_valid <= 0;
        C <= {0,0};
        B <= {0,0,0,0,0,0};
        A[0] <= {0,0};
        A[1] <= {0,0};
        A[2] <= {0,0};
        A[3] <= {0,0};
        A[4] <= {0,0};
        A[5] <= {0,0};

        bound[0] <= {0,0};
        bound[1] <= {0,0};

        xrange <= 0;
        yrange <= 0;

        x <= 0;
        y <= 0;

        xcnt <= 0;
        ycnt <= 0;
    end
    else begin
        cnt <= cnt_next;
        in_valid_buf <= in_valid;

        cur_state <= next_state;
        
        in_a1_buf <= in_a1;
        in_a2_buf <= in_a2;
        in_b_buf <= in_b;

        out_max_value <= out_max_value_next;
        out_valid <= out_valid_next;
        C <= C_next;
        B <= B_next;
        A <= A_next;

        bound <= bound_next;
        xrange <= xrange_next;
        yrange <= yrange_next;

        x <= x_next;
        y <= y_next;

        xcnt <= xcnt_next;
        ycnt <= ycnt_next;
    end
end


always_comb begin
    out_valid_next = 0;
    out_max_value_next = out_max_value;
    next_state = cur_state;
    cnt_next = 0;
    C_next = C;
    B_next = B;
    A_next = A;

    bound_next = bound;
    xrange_next = xrange;
    yrange_next = yrange;

    x_next = 0;
    y_next = 0;

    xcnt_next = 0;
    ycnt_next = 0;

    is_valid = 0;
    value = 0;
    case (cur_state)
    IDLE: begin
        if (in_valid_buf) begin
            cnt_next = cnt + 1;
            // read the value of the c 
            if (cnt == 0) begin
                C_next[0] = in_a1_buf;
                C_next[1] = in_a2_buf;
            end
            else if (cnt < 6)begin
                // read the value of A and B
                A_next[cnt-1][0] = in_a1_buf;
                A_next[cnt-1][1] = in_a2_buf;
                B_next[cnt-1] = in_b_buf;
            end
            else if (cnt == 6) begin
                A_next[cnt-1][0] = in_a1_buf;
                A_next[cnt-1][1] = in_a2_buf;
                B_next[cnt-1] = in_b_buf;
                cnt_next = 0;
                next_state = FIND;
            end
        end
    end
    // find the bound given the four constraint
    // find the constraint that have a zero in it
    // check each one in each cycle
    FIND: begin
        cnt_next = cnt + 1;
        if (cnt >=0 && cnt <= 5) begin
            if (A[cnt][0] == 0 || A[cnt][1] == 0) begin
                if (A[cnt][0] == 0) begin
                    // the coefficient of x is zero, than we check y
                    if (A[cnt][1] > 0) begin
                        // upper bound
                        bound_next[1][0] = B[cnt];
                    end
                    else begin
                        // lower bound
                        bound_next[1][1] = -B[cnt];
                    end
                end
                else if (A[cnt][1] == 0) begin
                    // the coefficient of y is zero, than we check x
                    if (A[cnt][0] > 0) begin
                        // right bound
                        bound_next[0][0] = B[cnt];
                    end
                    else begin
                        // left bound
                        bound_next[0][1] = -B[cnt];
                    end
                end
            end
        end
        else begin
            next_state = COMP;
            cnt_next = 0;
        end
    end
    COMP: begin
        // given the constraint, we will start looking for the max value
        // we need a x and y value to remember where we are
        // and we go from left -> right, down -> up
        // we first caclulate the max-min value of the bound
        // we first set minimum value to -2048 in this stage
        cnt_next = cnt + 1;
        if (cnt == 0) begin
            xrange_next = bound[0][0]-bound[0][1];
            yrange_next = bound[1][0]-bound[1][1];
            x_next = bound[0][1];
            y_next = bound[1][1];
            out_max_value_next = -2048;
        end
        else begin
            // check if the coord. satisfy the constraint
            is_valid = (A[0][0]*x +  A[0][1]*y <= B[0]) &&
                       (A[1][0]*x +  A[1][1]*y <= B[1]) &&
                       (A[2][0]*x +  A[2][1]*y <= B[2]) &&
                       (A[3][0]*x +  A[3][1]*y <= B[3]) &&
                       (A[4][0]*x +  A[4][1]*y <= B[4]) &&
                       (A[5][0]*x +  A[5][1]*y <= B[5]);
            if (is_valid) begin
                value = C[0]*x + C[1]*y;
                if (value > out_max_value) begin
                    out_max_value_next = value;
                end
            end
            // find next coord. value
            x_next = bound[0][1] + xcnt;
            y_next = bound[1][1] + ycnt;

            // find the aggr. of the index
            // if the x cnt has 
            if (xcnt == xrange + 1) begin
                xcnt_next = 0;
                ycnt_next = ycnt + 1;
                if (ycnt == yrange + 1) begin
                    next_state = OUT;
                    cnt_next = 0;
                end
            end
            else begin
                xcnt_next = xcnt + 1;
                ycnt_next = ycnt;
            end
            
        end
    end
    OUT: begin
        out_valid_next = 1;
        out_max_value_next = out_max_value;
        next_state = IDLE;
    end
    endcase
end
endmodule