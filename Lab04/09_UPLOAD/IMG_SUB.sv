module IMG_SUB(
  // Input signals
	clk,
	rst_n,
    in_valid,
    in_image,
  // Output signals
    out_valid,
	out_diff
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n ;
input in_valid ;
input [3:0] in_image;
output logic out_valid ;
output logic [3:0] out_diff;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

logic [5:0] cnt,cnt_nxt;
logic [3:0] out_diff_nxt;
logic out_valid_nxt;
logic [3:0] images [17:0];


//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------



always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
        out_diff <= 0;
        out_valid <= 0;
    end
    else begin
        cnt <= cnt_nxt;
        out_diff <= out_diff_nxt;
        out_valid <= out_valid_nxt;

        if (cnt < 18) begin
            images[cnt] <= in_image;
        end

        else begin
        end
    end
end


always_comb begin
    if ((in_valid == 0 && cnt == 0) || cnt > 26 ) begin
        cnt_nxt = 0; //stop the counter if the initial state and the counter is bigger than 26
    end 
    else begin
        cnt_nxt = cnt + 1; 
    end
end

always_comb begin
    if (cnt > 17 && cnt < 27) begin
        // output the value
        out_valid_nxt = 1;
        out_diff_nxt = images[cnt-18]-images[cnt-9];
    end
    else begin
        out_valid_nxt = 0;
        out_diff_nxt = 0;
    end
end
endmodule