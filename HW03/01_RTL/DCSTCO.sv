module DCSTCO(
    // Input signals
	clk,
	rst_n,
    in_valid,
	target_product,
    // Output signals
    out_valid,
	ten,
	five,
	one,
	run_out_ing,
	// AHB-interconnect input signals
	ready_refri,
	ready_kitch,
	// AHB-interconnect output signals
	valid_refri,
	valid_kitch,
	product_out,
	number_out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input        clk, rst_n ;
input        in_valid ;
input        [11:0] target_product ;
input        ready_refri ;
input        ready_kitch ;
output logic out_valid ;
output logic [3:0] ten ;
output logic five ;
output logic [2:0] one ;
output logic run_out_ing ;
output logic valid_refri ;
output logic valid_kitch ;
output logic product_out ;
output logic [5:0] number_out ; 

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [6:0] nugget_in_shop_next, fried_rice_in_shop_next;
logic [6:0] apple_in_shop_next , peach_in_shop_next;
logic [1:0] cur_state, next_state;
logic run_out_ing_next;
logic valid_refri_next;
logic valid_kitch_next;
logic product_out_next; // the address
logic [5:0] number_out_next;
logic [3:0] need_store, need_store_next;
logic [10:0] cost;
logic [4:0] changes;
logic [3:0] ten_next ;
logic five_next ;
logic [2:0] one_next ;
logic out_valid_next;
//---------------------------------------------------------------------
//   DON'T MODIFIED THE REGISTER'S NAME (PRODUCT REGISTER)
//---------------------------------------------------------------------
logic [6:0] nugget_in_shop, fried_rice_in_shop ;
logic [6:0] apple_in_shop , peach_in_shop ;
logic [2:0] nugget, fried_rice, apple, peach;
logic [2:0] nugget_buf, fried_rice_buf, apple_buf, peach_buf;
logic ready_kitch_buf, ready_refri_buf;
logic kitch_stored_next, refri_stored_next;
logic kitch_stored, refri_stored;

//---------------------------------------------------------------------

//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------
parameter IDLE = 2'b00,
		  SUPPLY = 2'b01,
		  STORE = 2'b10;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

logic [4:0] fives [9:0];
logic [4:0] ones [9:0];
assign fives = {1,1,1,1,1,0,0,0,0,0};
assign ones =  {4,3,2,1,0,4,3,2,1,0};

always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		cur_state <= IDLE;
		nugget_buf <= 0;
		fried_rice_buf <= 0;
		apple_buf <= 0;
		peach_buf <= 0;
		need_store <= 0;
		ten <= 0;
		five <= 0;
		one <= 0;
		nugget_in_shop <= 0;
		fried_rice_in_shop <= 0;
		apple_in_shop <= 0;
		peach_in_shop <= 0;
		number_out <= 0;
		product_out <= 0;
		run_out_ing <= 0;
		out_valid <= 0;
		valid_kitch <= 0;
		valid_refri <= 0;
		refri_stored <= 0;
		kitch_stored <= 0;
	end
	else begin
		cur_state <= next_state;
		nugget_buf <= nugget;
		fried_rice_buf <= fried_rice;
		apple_buf <= apple;
		peach_buf <= peach;
		need_store <= need_store_next;
		ten <= ten_next;
		five <= five_next;
		one <= one_next;
		nugget_in_shop <= nugget_in_shop_next;
		fried_rice_in_shop <= fried_rice_in_shop_next;
		apple_in_shop <= apple_in_shop_next;
		peach_in_shop <= peach_in_shop_next;
		number_out <= number_out_next;
		product_out <= product_out_next;
		run_out_ing <= run_out_ing_next;
		out_valid <= out_valid_next;
		valid_kitch <= valid_kitch_next;
		valid_refri <= valid_refri_next;
		ready_kitch_buf <= ready_kitch;
		ready_refri_buf <= ready_refri;
		refri_stored <= refri_stored_next;
		kitch_stored <= kitch_stored_next;
	end
end

always_comb begin
	next_state = cur_state;
	out_valid_next = 0;
	nugget = nugget_buf;
	fried_rice = fried_rice_buf;
	apple = apple_buf;
	peach = peach_buf;
	need_store_next = need_store;
	cost = 0;
	ten_next = 0;
	five_next = 0;
	one_next = 0;
	out_valid_next = 0;
	changes = 0;
	product_out_next = 0;
	number_out_next = 0;
	nugget_in_shop_next = nugget_in_shop;
	fried_rice_in_shop_next = fried_rice_in_shop;
	apple_in_shop_next = apple_in_shop;
	peach_in_shop_next = peach_in_shop;
	valid_kitch_next = 0;
	valid_refri_next = 0;
	run_out_ing_next = 0;
	refri_stored_next = 0;
	kitch_stored_next = 0;

	case (cur_state)
	IDLE: begin
		if (in_valid) begin
			nugget = target_product[11:9];
			fried_rice = target_product[8:6];
			apple = target_product[5:3];
			peach = target_product[2:0];

			need_store_next = {nugget > nugget_in_shop, fried_rice > fried_rice_in_shop, apple > apple_in_shop, peach > peach_in_shop};
			// if need store has a single one, go to state STORE
			if (|need_store_next)
				next_state = STORE;
			else
				next_state = SUPPLY;
		end
	end
	// this state supplies the customer
	SUPPLY: begin
		// compute the total cost
		cost = (nugget*3 + fried_rice*5) + (apple*2+peach*4);
		// compute the ten, five, and ones
		ten_next = cost / 10;
		changes = cost % 10;
		five_next = fives[changes];
		one_next = ones[changes];
		out_valid_next = 1;
		next_state = IDLE;

		// remember to subtract
		nugget_in_shop_next = nugget_in_shop - nugget;
		fried_rice_in_shop_next = fried_rice_in_shop - fried_rice;
		apple_in_shop_next = apple_in_shop - apple;
		peach_in_shop_next = peach_in_shop - peach;
	end

	STORE: begin
		// use buf to store the kitch
		// for each products, assign the address, pull high valid, and get the number_out (use_next), record the new in_shop value (ues_next)
		if (need_store[3] && ready_kitch && (!kitch_stored)) begin
			// nugget
			need_store_next[3] = 0;
			nugget_in_shop_next = 50;
			number_out_next = 50 - nugget_in_shop;
			product_out_next = 1;
			valid_kitch_next = 1;
			kitch_stored_next = 1;
		end
		else if (need_store[2] && ready_kitch && (!kitch_stored)) begin
			// fried rice
			need_store_next[2] = 0;
			fried_rice_in_shop_next = 50;
			number_out_next = 50 - fried_rice_in_shop;
			product_out_next = 0;
			valid_kitch_next = 1;
			kitch_stored_next = 1;
		end
		else if (need_store[1] && ready_refri && (!refri_stored)) begin
			// apple 
			need_store_next[1] = 0;
			apple_in_shop_next = 50;
			number_out_next = 50 - apple_in_shop;
			product_out_next = 1;
			valid_refri_next = 1;
			refri_stored_next = 1;
		end
		else if (need_store[0] && ready_refri && (!refri_stored)) begin
			// peach
			need_store_next[0] = 0;
			peach_in_shop_next = 50;
			number_out_next = 50 - peach_in_shop;
			product_out_next = 0;
			valid_refri_next = 1;
			refri_stored_next = 1;
		end
		

		if (!(|need_store)) begin
			run_out_ing_next = 1;
			out_valid_next = 1;
			next_state = IDLE;
		end
	end
	endcase
end

endmodule