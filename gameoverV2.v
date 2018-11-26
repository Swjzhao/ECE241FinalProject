// Part 2 skeleton

module gameoverV2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;					
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [14:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	wire writeEn;


	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	
	//ram output for the scoring: 
	lower lw(.clock(CLOCK_50), .reset(resetn), .outx(x),.outy(y), .outcolour(colour));
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 5;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
//	reg [15:0] address; 
//	reg [15:0] mif_lines = 16'd6641; 
//   reg [26:0] limit = 27'd25000000;
//	reg [26:0] frequency_counter;
//	wire [2:0] ram_output;
//	wire reset = KEY[0];
	
endmodule

module lower(clock, reset, outx, outy, outcolour);
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