module loadgameover(clock, reset, gameoveradd, outcolour);
	input clock;
	input reset;
	input[11:0] gameoveradd;
	output [2:0]outcolour;
	gameoversign go (.address(gameoveradd), .clock(clock), .wren(1'b0), .q(colour));
	assign outcolour = colour;

endmodule 