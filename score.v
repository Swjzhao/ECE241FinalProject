
module loadscore(clock, reset, id, i, j, outcolour);
	input clock;
	input reset;
	input [2:0] id;
	input [4:0] i;
	input [6:0] j;
	output [14:0]outcolour;
	wire [2:0] colour;
	wire [5:0] tempj;
	assign tempj[5:0] = j[6:0] + (id * 6'd32);
	wire [9:0] ii;
	assign ii = {tempj,i} + 1'b1;
	
	scoreCounterRam scoreCount (.address({j,i[3:0]}), .clock(clock), .wren(1'b0), .q(colour));
	assign outcolour = colour;
//	
//	reg [5:0] tempj;
//	reg [2:0] id;
//	assign tempj[5:0] = j[5:0] + (id * 5'd16);
//	

	//drawing the actual scores on:
	

endmodule
