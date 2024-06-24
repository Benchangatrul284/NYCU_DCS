// use merge sort
module Sort(
    // Input signals
	in_num0,
	in_num1,
	in_num2,
	in_num3,
	in_num4,
    // Output signals
	out_num
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input  [5:0] in_num0, in_num1, in_num2, in_num3, in_num4;
output logic [5:0] out_num;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

logic [5:0] temp0, temp1, temp2, temp3, temp4, temp;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always @(*) begin
	temp0 = in_num0;
	temp1 = in_num1;
	temp2 = in_num2;
	temp3 = in_num3;
	temp4 = in_num4;
	// compare the temp0, temp1 if temp0 > temp1 then swap
	if(temp0 > temp1) begin
		temp = temp0;
		temp0 = temp1;
		temp1 = temp;
	end
	else begin
		temp0 = temp0;
		temp1 = temp1;
	end
	// compare the temp2, temp3 if temp2 > temp3 then swap
	if(temp2 > temp3) begin
		temp = temp2;
		temp2 = temp3;
		temp3 = temp;
	end
	else begin
		temp2 = temp2;
		temp3 = temp3;
	end
	// compare the temp1 and temp2 if temp1 > temp2 then swap
	if(temp1 > temp2) begin
		temp = temp1;
		temp1 = temp2;
		temp2 = temp;
	end
	else begin
		temp1 = temp1;
		temp2 = temp2;
	end
	// compare the temp3 and temp4 if temp3 > temp4 then swap
	if(temp3 > temp4) begin
		temp = temp3;
		temp3 = temp4;
		temp4 = temp;
	end
	else begin
		temp3 = temp3;
		temp4 = temp4;
	end
	/////////
	// compare the temp0, temp1 if temp0 > temp1 then swap
	if(temp0 > temp1) begin
		temp = temp0;
		temp0 = temp1;
		temp1 = temp;
	end
	else begin
		temp0 = temp0;
		temp1 = temp1;
	end
	// compare the temp2, temp3 if temp2 > temp3 then swap
	if(temp2 > temp3) begin
		temp = temp2;
		temp2 = temp3;
		temp3 = temp;
	end
	else begin
		temp2 = temp2;
		temp3 = temp3;
	end
	// compare the temp1 and temp2 if temp1 > temp2 then swap
	if(temp1 > temp2) begin
		temp = temp1;
		temp1 = temp2;
		temp2 = temp;
	end
	else begin
		temp1 = temp1;
		temp2 = temp2;
	end
	// compare the temp3 and temp4 if temp3 > temp4 then swap
	if(temp3 > temp4) begin
		temp = temp3;
		temp3 = temp4;
		temp4 = temp;
	end
	else begin
		temp3 = temp3;
		temp4 = temp4;
	end
	/////////
	if(temp0 > temp1) begin
		temp = temp0;
		temp0 = temp1;
		temp1 = temp;
	end
	else begin
		temp0 = temp0;
		temp1 = temp1;
	end
	// compare the temp2, temp3 if temp2 > temp3 then swap
	if(temp2 > temp3) begin
		temp = temp2;
		temp2 = temp3;
		temp3 = temp;
	end
	else begin
		temp2 = temp2;
		temp3 = temp3;
	end


end


assign out_num = temp2;

endmodule