
module loadscore(clock, reset, id, i, j, outcolour);
	input clock;
	input reset;
	input [4:0] id;
	input [3:0] i;
	input [6:0] j;
	output [14:0] outcolour;
	wire [2:0] colour;
	wire [9:0] tempj;
	assign tempj[9:0] = j[6:0] + (id * 6'd32);
	wire [14:0] ii;
	assign ii = {tempj,i} + 1'b1;

	scoreCounterRam scoreCount (.address({ii}), .clock(clock), .wren(1'b0), .q(colour));
	assign outcolour = colour;



endmodule
