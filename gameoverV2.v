module loadgameover(clock, reset, outx, outy, outcolour);
	input clock;
	input reset;
	output reg [8:0] outx;
	output reg [7:0] outy;
	output reg [14:0]outcolour;
	wire [2:0] colour;
	reg [6:0] i;
	reg [4:0] j;  
	
	gameoversign go (.address({j,i[3:0]}), .clock(clock), .data(3'b0), .wren(1'b0), .q(colour));
	
//	
//	reg [5:0] tempj;
//	reg [2:0] id;
//	assign tempj[5:0] = j[5:0] + (id * 5'd16);
//	
	wire [8:0] xx;
	assign xx	= 9'd25;
	
	wire [7:0] yy;
	assign yy	= 8'd25;
	
	//drawing the actual scores on:
	always @(posedge clock) 
	begin
		outx <= xx + i;
		outy <= yy + j;
		
		if(colour == 3'b0)
			outcolour <= 15'b0;
		else
			outcolour <= 15'b111111111111111;
			
		if(!reset)
			begin
				i <= 5'd0;
				j <= 7'd0;
				//outcolour <= 15'd0;
			end
		
		else if(j < (5'd16))
			begin
				if(i < (7'd32))
					begin
						i <= i + 1'b1;
						j <= j + 1'b0;
						
					end
				else
					begin
						i <= 5'd0;
						j <= j + 1'b1;
					end
			end
		else
			begin
				j <= 7'd0;
				i <= 5'd0;
			end
		end

endmodule 