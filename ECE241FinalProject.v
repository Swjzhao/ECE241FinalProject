`timescale 1ns / 1ns
module top(
			SW, 
			KEY,
			CLOCK_50, 
			VGA_R,
			VGA_G,
			VGA_B,
			VGA_HS,
			VGA_VS,
			VGA_BLANK,
			VGA_SYNC,
			VGA_CLK);			
	
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
	
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	
	wire go, black, reset;

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
	
	vga_adapter v1(
		.resetn(reset),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(plot),
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
		defparam v1.BITS_PER_COLOUR_CHANNEL = 1;
		defparam v1.BACKGROUND_IMAGE = "black.mif";
	
	
	part2 p2(
		.clk(CLOCK_50),
		.go(go),
		.black(black),
		.draw(plot),
		.reset(reset),
		.data_in(SW[6:0]),
		.loadcolour(SW[9:7]),
		.X(x), 
		.Y(y), 
		.colour(colour)
		
	);
	
endmodule

module part2(
	input clk, go, black, draw, reset,
	input[6:0] data_in,
	input[2:0] loadcolour,

	output [7:0] X,
	output [6:0] Y,
	output [2:0] colour
);
	wire[1:0] alu_select;
	wire  ld_plot, ld_x, ld_y;
	wire[9:0] counter;
	wire[9:0] address;
	wire[3:0] data;
	wire clock;
	wire q; 
	
	wire [9:0] randX;
	wire [8:0] randY;

	wire[25:0] freq;
	RateDivider r1(clk, reset, 26'b01011111010111100000111111, freq);
	wire clock;
	
	assign clock = (freq  == 26'b00000000000000000000000000)? 1'b1 : 1'b0;
	
	
	control c1 (
		.clk(clk),
		.go(go),
		.black(black), 
		.plot(plot), 
		.reset(reset),
	
		.ld_plot(ld_plot),
		.ld_x(ld_x),
		.ld_y(ld_y)
		);
		
	
	ram32x4 ra(.address(address), .clock(clock),.wren(1'b0), .q(q));
	

	
	datapath d1(
		.clk(clk),
		.go(go),
		.colour(loadcolour), 
		.reset(reset),
		.locx(randX),
		.locY(randY),
		.ld_black(black),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.ld_plot(ld_plot),
		.X(X),
		.Y(Y),
		.Colour(colour),
		.counter(counter)
		);
	

endmodule

module control(
	input clk,
	input go, black, plot, reset,
	output reg  ld_plot, ld_x, ld_y
);

    reg [2:0] current_state;
	 reg [2:0] next_state;
	 
//	 localparam 		S_LOAD_X = 5'd0,
//							S_LOAD_X_WAIT = 5'd1,
//							S_LOAD_Y = 5'd2,
//							S_LOAD_Y_WAIT = 5'd3,
//							S_PLOT = 5'd4,
//							S_PLOT_WAIT = 5'd5;
	 localparam 		S_RESET  = 5'd0,
							S_ClearScreen = 5'd1,
							S_GenerateLocation = 5'd2,
							S_StartAnimation = 5'd3,
							S_Done = 5'd4;
	 
//	 always @(*)
//	 begin: state_table
//		case(current_state)
//			S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;
//			S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT: S_LOAD_Y;
//			S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y;
//			S_LOAD_Y_WAIT: next_state = plot ? S_LOAD_Y_WAIT: S_PLOT;
//			S_PLOT: next_state = plot? S_PLOT_WAIT: S_PLOT;
//			S_PLOT_WAIT: next_state = plot? S_PLOT_WAIT : S_LOAD_X;
//		endcase
//	 end

	S_Reset: next_state = S_DeleteOld;
	//S_Reset: next_state = S_StartAnimation;	
	S_DeleteOld: next_state =  move ? S_StartAnimation : S_DeleteOld;
	S_StartAnimation: next_state = upFlag? S_ShiftUp : S_ShiftDown;
	S_ShiftUp: next_state = rightFlag? S_ShiftRight : S_ShiftLeft; 
	S_ShiftDown: next_state = rightFlag? S_ShiftRight : S_ShiftLeft; 
	S_ShiftLeft: next_state = S_PrintNew;
	S_ShiftRight: next_state = S_PrintNew;
	S_PrintNew: next_state =  madesquare ? S_Done : S_PrintNew ;
	S_Done: next_state = enable1? S_DeleteOld: S_Done;
	default:
		next_state=S_StartAnimation;
		
	endcase
			
	 always @(*)
	 begin: state_table
		case(current_state)
			S_RES


	S_PrintNew: next_state =  madesquare ? S_Done : S_PrintNew ;
			
			S_Done: next_state = enable1? S_DeleteOld: S_Done;
			
	 always @(*)
	 begin: enable
		ld_plot = 1'b0;
		ld_x = 1'b0;
		ld_y = 1'b0;
		case(current_state)
		
			S_LOAD_X: 
				begin 
					ld_x = 1'b1;
				end
			S_LOAD_Y: 
				begin
					ld_y = 1'b1;
				end
			S_PLOT: 
				begin 
					ld_plot = 1'b1;
				end
			
		endcase
	end
	
	 always@(posedge clk)
    begin: state_FFs
        if(!reset) 
            current_state <= S_LOAD_X;
		  else
            current_state <= next_state;
			
    end 
endmodule

module datapath(
	input clk,
	input go,
	input [2:0] colour, 
	input reset,
	input [8:0] xloc,
	input [7:0] yloc,
	input ld_black, ld_x, ld_y, ld_plot,
	output reg [8:0] X, 
	output reg [7:0] Y,
	output reg [2:0] Colour,
	output reg [9:0] counter
);
		
		 reg [17:0] blackcounter;
		 reg [8:0] xx;
		 reg [7:0] yy;
	 
	 
	 
	 always@(posedge clk)
    begin: states
		  if(ld_black)
					Colour <= 3'b0;
        else if(!reset)
				begin
					xx <= 9'b0;
					yy <= 8'b0;
					Colour <= 3'b0;
					
				end
		  else
				begin	
					if(ld_x) xx <= {1'b0, data_in};
					if(ld_y) yy <= data_in;
					
					Colour <= colour;
            end 
	 end 
	always@(posedge clk)
		begin: square
			if(!reset)
				begin
					counter <= 5'b0;
							X <= 8'b0;
							Y <= 7'b0;
							blackcounter <= 15'b0;
				end
			else if(ld_black)
				begin
					if(blackcounter < 17'b1)
						begin
							X <= blackcounter[8:0];
							Y <= blackcounter[17:9];
							blackcounter <= blackcounter + 1'b1;
						end
				end
		else if(ld_plot)
		begin
				 if(counter < 10'd256)
						begin
							X<= xx + counter[1:0];
							blackcounter <= 15'b0;
							Y<= yy + counter[3:2];
							counter <= counter + 1'b1;
						end
					else
						begin
							counter <= 10'b0;
							X <= xx;
							Y <= yy;

						end
				end

			else
				begin
					if(xx>=8'd316)
						X <= 8'd316;
					else	
						X <= xx;
						
					if(yy >= 7'd236)
						Y <= 7'd236;
					else 
						Y <= yy;
				end
		end
endmodule 

module RateDivider(clock, reset, d, q);
	input clock;
	input reset;
	
	input [25:0] d;
	output reg [25:0] q;
	
	always @(posedge clock)
	begin
		if(!reset)
			q <= 0;
		else if(q == 0)
			q <= d;
		else 
			q <= q - 1'b1;
	end
endmodule
