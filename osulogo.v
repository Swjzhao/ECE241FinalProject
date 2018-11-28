module loadosu (clock, reset, osucd, outcolour);
	input clock;
	input reset;
	input [9:0] osucd;
	output [14:0]outcolour;
	wire [14:0] colour;
	wire [9:0] nadd;
	assign nadd = osucd + 1'b1;
	
	osulogoRAM oss (.address(nadd), .clock(clock),  .wren(1'b0), .q(colour));
	assign outcolour = colour;

endmodule
