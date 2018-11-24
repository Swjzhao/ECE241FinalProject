module looptest (CLOCK_50, KEY);
	input [3:0] KEY; 
	input CLOCK_50;
	lower l1(.clock(CLOCK_50), .start(KEY[1]));
endmodule 

module lower(clock, start);
input clock;
input start;

reg [15:0] address_count_reg = 0;
reg [11:0] clk_count = 0;
//reg [10:0] pulse_count;
//reg [15:0] output_counter = 0;

always @(posedge clock) begin
//		if (address_count_reg == 16'd3) begin
//			address_count_reg <= 16'b0;
//		end
		
		if (clk_count == 12'd4) begin
			address_count_reg <= address_count_reg + 1'b1;
			clk_count <= 12'b0;
			
			if (address_count_reg == 16'd3) begin
				address_count_reg <= 16'b0;
			end
			
		end
		
		else begin
			address_count_reg <= address_count_reg + 1'b0;
			clk_count <= clk_count + 12'b1;
		end
	end
endmodule

//always @(posedge clock)begin
//	//if (~start)  pulse_count <= 12'b0;
//	
//	if(address_count_reg == 16'd4) begin
//			address_count_reg <= 16'b0;
//			output_counter <= 16'b0;
//	end
//	
//	if(clk_count == 12'd2)  begin
//		address_count_reg <= address_count_reg + 1'b0; //send in the same address
//		output_counter <= address_count_reg;
//	end
//	
//	if (clk_count == 12'd4) begin
//		address_count_reg <= address_count_reg + 1'b1;
//		output_counter <= address_count_reg;
//		clk_count <= 12'b0;
//	end
//	
//	else begin
//		output_counter <= 16'b0;
//		clk_count <= clk_count + 12'b1;
//	end
//end

