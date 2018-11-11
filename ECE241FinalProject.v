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
	
		defparam v1.RESOLUTION = "160x120";
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
	
	datapath d1(
		.clk(clk),
		.go(go),
		.colour(loadcolour), 
		.reset(reset),
		.data_in(data_in),
		.ld_black(black),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.ld_plot(ld_plot),
		.X(X),
		.Y(Y),
		.Colour(colour)
		);

	


endmodule

module control(
	input clk,
	input go, black, plot, reset,
	output reg  ld_plot, ld_x, ld_y
);

    reg [2:0] current_state;
	 reg [2:0] next_state;
	 
	 localparam 		S_LOAD_X = 5'd0,
							S_LOAD_X_WAIT = 5'd1,
							S_LOAD_Y = 5'd2,
							S_LOAD_Y_WAIT = 5'd3,
							S_PLOT = 5'd4;
	 
	 always @(*)
	 begin: state_table
		case(current_state)
			S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X;
			S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT: S_LOAD_Y;
			S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y;
			S_LOAD_Y_WAIT: next_state = plot ? S_LOAD_Y_WAIT: S_PLOT;
			S_PLOT: next_state = S_LOAD_X;
		endcase
	 end
	 
	 always @(*)
	 begin: enable
		ld_plot = 1'b0;
		ld_x = 1'b0;
		ld_y = 1'b0;
		case(current_state)
		
			S_LOAD_X: ld_x = 1'b1;
			S_LOAD_Y: ld_y = 1'b1;
			S_PLOT: ld_plot = 1'b1;
			
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
	input [6:0] data_in,
	input ld_black, ld_x, ld_y, ld_plot,
	output reg [7:0] X, 
	output reg [6:0] Y,
	output reg [2:0] Colour
);
		
	 reg [15:0] blackcounter;
	 reg [4:0] counter;
	 reg [7:0] xx;
	 reg [6:0] yy;

	 
	 always@(posedge clk)
    begin: states
		  if(ld_black)
					Colour <= 3'b0;
        else if(!reset)
				begin
					xx <= 8'b0;
					yy <= 7'b0;
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
			
			if(ld_black)
						begin
							if(!reset)
								blackcounter <= 15'b0;
							else if(blackcounter < 15'b111111111111111)
								begin
									X <= blackcounter[7:0];
									Y <= blackcounter[15:8];
									blackcounter <= blackcounter + 1'b1;
								end
							
						end
			else if(ld_plot)
				begin
					if(!reset)
						begin
							counter <= 5'b0000;
							X <= 8'b0;
							Y <= 7'b0;
							blackcounter <= 15'b0;
						end
					else if(counter <= 5'b01111)
						begin
							X<= xx + counter[1:0];
							blackcounter <= 15'b0;
							Y<= yy + counter[3:2];
							counter <= counter + 1'b1;
						end
					else
						begin
							counter <= 5'b00000;
							X <= xx;
							Y <= yy;

						end
				end

			else
				begin
					if(xx>=8'd156)
						X <= 8'd156;
					else	
						X <= xx;
						
					if(yy >= 7'd116)
						Y <= 7'd116;
					else 	
						Y <= yy;
				end
		end
endmodule 