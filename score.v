
module loadscore(clock, reset, id, i, j, outcolour);
	input clock;
	input reset;
	input [4:0] id;
	input [3:0] i;
	input [7:0] j;
	output [14:0]outcolour;
	wire [2:0] colour;
	wire [7:0] tempj;
	assign tempj[7:0] = j[7:0] + (id * 6'd32);
	wire [11:0] ii;
	assign ii = {tempj,i} + 1'b1;
	
	scoreCounterRam scoreCount (.address({ii}), .clock(clock), .wren(1'b0), .q(colour));
	assign outcolour = colour;
//	
//	reg [5:0] tempj;
//	reg [2:0] id;
//	assign tempj[5:0] = j[5:0] + (id * 5'd16);
//	

	//drawing the actual scores on:
	

endmodule
