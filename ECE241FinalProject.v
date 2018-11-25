`timescale 1ns / 1ns
module top(
			SW, 
			KEY, HEX0 , HEX1, HEX2, HEX3, HEX4, HEX5,
			CLOCK_50,
			PS2_CLK,
			PS2_DAT,
			VGA_R,
			VGA_G,
			VGA_B,
			VGA_HS,
			VGA_VS,
			VGA_BLANK,
			VGA_SYNC,
			VGA_CLK,
			AUD_ADCDAT,

			// Bidirectionals
			AUD_BCLK,
			AUD_ADCLRCK,
			AUD_DACLRCK,

			FPGA_I2C_SDAT,

			// Outputs
			AUD_XCK,
			AUD_DACDAT,

			FPGA_I2C_SCLK
			);			
	inout PS2_CLK, PS2_DAT;
	//SW[6:0] X,Y
	//SW[9:7] Colour
	//KEY 3 = load, 1 draw, 2 clear (black), 0 reset
	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	
	output [9:0] VGA_R;
	output [9:0] VGA_G;
	output [9:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK;
	output VGA_SYNC;
	output VGA_CLK;
	input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;
	output [6:0] HEX0 , HEX1, HEX2, HEX3, HEX4, HEX5;

	
	wire [14:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	
	
	wire go, black, reset;
	
	wire [7:0] PS2_byte;
	wire data_received;

	assign go = ~KEY[3];
	assign black = ~KEY[2];
	reg plot;
   assign reset = KEY[0];
	
	always@(*)
	begin
		case(black)
			1'b1: plot = 1'b1;
			default: plot = ~KEY[1];
		endcase
	end
//	PS2_Demo pc0 (
//		.CLOCK_50(CLOCK_50),
//		.reset(reset),
//		.PS2_CLK(PS2_CLK),
//		.PS2_DAT(PS2_DAT),
//		.received_data(PS2_byte),
//		.received_data_en(data_received));
	PS2_Demo pc0 (
		.CLOCK_50(CLOCK_50),
		.KEY(KEY[3:0]),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.last_data_received(PS2_byte),
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3),
		.HEX4(HEX4),
		.HEX5(HEX5)
		
	);

	vga_adapter v1(
		.resetn(reset),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(1'b1),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK),
		.VGA_SYNC(VGA_SYNC),
		.VGA_CLK(VGA_CLK)
		
	);
	
		defparam v1.RESOLUTION = "320x240";
		defparam v1.MONOCHROME = "FALSE";
		defparam v1.BITS_PER_COLOUR_CHANNEL = 5;
		defparam v1.BACKGROUND_IMAGE = "Graphics/osuhd.mif";
	
	DE1_SoC_Audio_Example  d1 (
	// Inputs
	.CLOCK_50(CLOCK_50),
	.KEY(KEY[0]),

	.AUD_ADCDAT(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK(AUD_BCLK),
	.AUD_ADCLRCK(AUD_ADCLRCK),
	.AUD_DACLRCK(AUD_DACLRCK),

	.FPGA_I2C_SDAT(FPGA_I2C_SDAT),

	// Outputs
	.AUD_XCK(AUD_XCK),
	.AUD_DACDAT(AUD_DACDAT),

	.FPGA_I2C_SCLK(FPGA_I2C_SCLK),
	.SW(SW[3:0])
	);

	
	part2 p2(
		.clk(CLOCK_50),
		.go(go),
		.black(black),
		.reset(reset),
		.loadcolour(SW[9:7]),
		.X(x), 
		.Y(y), 
		.colour(colour)
		
	);
	
endmodule

module part2(
	input clk, go, black, reset,
	input[2:0] loadcolour,

	output [8:0] X,
	output [7:0] Y,
	output [14:0] colour
);
	wire[1:0] alu_select;
	wire  ld_plot, ld_coord, ld_BG;
	wire[9:0] counter;
	wire[9:0] address;
	wire[3:0] data;
	wire clock;
	wire q; 
	
	wire [8:0] randX;
	wire [7:0] randY;
	wire [1:0] id2;

	wire[25:0] freq;

	
	wire cleared, done, draw;
	
	control c1 (
		.clk(clk),
		.go(go),
		.black(black),  
		.reset(reset),
		.cleared(cleared),
		.done(done),
		.draw(draw),
		.ld_plot(ld_plot),
		.ld_coord(ld_coord),
		.ld_BG(ld_BG)
		);
	wire genclock;
	wire [25:0] genfreq;
	RateDivider r1(clk, reset, 26'b00000000000000000000000001, genfreq);
	assign genclock = (genfreq  == 26'b00000000000000000000000000)? 1'b1 : 1'b0;
	
	genloc gl(genclock, reset, ld_coord,randX,randY,id2);
	
	datapath d1(
		.clk(clk),
		.go(go),
		.reset(reset),
		.locX(randX),
		.locY(randY),
		.id2(id2),
		.black(black),
		.ld_plot(ld_plot),
		.ld_BG(ld_BG),
		.X(X),
		.Y(Y),
		.cleared(cleared),
		.done(done),
		.draw(draw),
		.Colour(colour),
		.counter(counter)
		);
	

endmodule


//
//
//module randNum(
//	input clk,
//   input coord,
//	input reset,
//	output reg [8:0] X,
//	output reg [7:0] Y
//);
//	reg [8:0] xcounter;
//	reg [7:0] ycounter;
//	reg [8:0] xhold;
//	reg [7:0] yhold;
//	reg gotCoord;
//
//	wire [25:0] freq;
//	wire clock;
//	RateDivider r1(clk, reset, 26'b0000111110101111000001111, freq);
//	assign clock = (freq  == 26'b00000000000000000000000000)? 1'b1 : 1'b0;
//				
//	always@(posedge clk)
//	begin: a
//		if(!reset)
//			begin
//				xcounter <= 9'b0;
//				ycounter <= 8'b0;
//				X <= 9'b0;
//				Y <= 8'b0;
//				gotCoord = 1'b0;
//			end
//		else if(coord == 1'b1)
//			begin
//				if(gotCoord == 1'b0)
//					begin
//						gotCoord <= 1'b1;
//						
//						X <= xcounter;
//						Y <= ycounter;
//					
//					end
//				
//			end
//		else
//			begin
//				if(clock)
//					begin
//					xcounter <= xcounter + 1'b1;
//					if(xcounter >= 8'd304)
//						begin
//						ycounter <= ycounter+ 1'b1;
//						xcounter <= 8'b0;
//						end
//					end
//					if(ycounter >= 7'd214)
//					begin
//						ycounter <= 7'b0;
//					end
//					
//				gotCoord <= 1'b0;
//			
//				
//			end
//	end
//
//endmodule
//

