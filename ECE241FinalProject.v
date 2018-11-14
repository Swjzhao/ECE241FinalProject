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
	wire [8:0] x;
	wire [7:0] y;
	
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
		defparam v1.BITS_PER_COLOUR_CHANNEL = 1;
		defparam v1.BACKGROUND_IMAGE = "black.mif";
	
	
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
	output [2:0] colour
);
	wire[1:0] alu_select;
	wire  ld_plot, ld_coord;
	wire[9:0] counter;
	wire[9:0] address;
	wire[3:0] data;
	wire clock;
	wire q; 
	
	wire [8:0] randX;
	wire [7:0] randY;

	wire[25:0] freq;

	
	wire cleared, done;
	
	control c1 (
		.clk(clk),
		.go(go),
		.black(black),  
		.reset(reset),
		.cleared(cleared),
		.done(done),
		.ld_plot(ld_plot),
		.ld_coord(ld_coord)
		);
		
	
	//

	randNum ra(clk,ld_coord,reset,randX,randY);

		
	datapath d1(
		.clk(clk),
		.go(go),
		.reset(reset),
		.locX(randX),
		.locY(randY),
		.black(black),
		.ld_plot(ld_plot),
		.X(X),
		.Y(Y),
		.cleared(cleared),
		.done(done),
		.Colour(colour),
		.counter(counter)
		);
	

endmodule

module control(
	input clk,
	input go, black, reset,
	input cleared, done,
	
	output reg  ld_plot, ld_coord
);

    reg [2:0] current_state;
	 reg [2:0] next_state;
	 

	 localparam 		S_Reset  = 5'd0,
							S_ClearScreen = 5'd1,
							S_GenerateLocation = 5'd2,
							S_StartAnimation = 5'd3,
							S_Done = 5'd4;
	 


	always @(*)
	begin: state_table
		case(current_state)
			S_Reset: next_state = S_ClearScreen;
			//S_Reset: next_state = S_GenerateLocation;
			S_ClearScreen: next_state = cleared? S_StartAnimation: S_ClearScreen;
			S_GenerateLocation: next_state = S_StartAnimation;
			S_StartAnimation: 
					begin
						if(done) 
							next_state = S_Done;
						else if(black)
							next_state = S_ClearScreen;
						else 
							next_state = S_StartAnimation;
					end
			S_Done: next_state = S_GenerateLocation;
			endcase
	end
	 
	 always @(*)
	 begin: enable
		ld_plot = 1'b0;
		ld_coord = 1'b0;
		case(current_state)
		
			//S_ClearScreen: 
			S_GenerateLocation: 
				begin
					ld_coord = 1'b1;
				end
			S_StartAnimation: 
				begin 
					ld_plot = 1'b1;
				end
			
		endcase
	end

	 always@(posedge clk)
    begin: state_FFs
        if(!reset)
            current_state <= S_Reset;
		  else
            current_state <= next_state;
			
    end 
endmodule

module datapath(
	input clk,
	input go,
	
	input reset,
	input [8:0] locX,
	input [7:0] locY,
	input black, ld_coord, ld_plot,  
	output reg [8:0] X, 
	output reg [7:0] Y,
	output reg cleared,
	output reg done,
	output reg [2:0] Colour,
	output reg [9:0] counter
);
		
	 reg [17:0] blackcounter;
	 reg [8:0] xx;
	 reg [7:0] yy;
	 reg [4:0] i;
	 reg [6:0] j;
	 reg [2:0] id;
	 reg [2:0] id2;
	 wire[2:0] colour;
	 wire [25:0] freq;
	 wire clock;
	 RateDivider r1(clk, reset, 26'b0010111110101111000001111, freq);
	 assign clock = (freq  == 26'b00000000000000000000000000)? 1'b1 : 1'b0;
	
	 always@(posedge clock)
	 begin
			if(!reset)
				begin
					id <= 3'd0;
					id2 <=3'd0;
				end
			else if (ld_coord)
				begin 
					id <= 3'd0;
					
				end
			else if(id == 3'd3)
				begin
			
					id <= 3'd0;
					done <= 1'b1;
				end
			else
				begin
					id <= id + 1'b1;
				end
	 end
	 // RateDivider r4(clock, reset, 26'b10111110101111000001111111, w5);	
	 loadImage la (clk, reset, id, i , j ,colour);
	 always@(posedge clk)
    begin: states
		  if(!reset)
				begin
					xx <= 9'b0;
					yy <= 8'b0;
			

				end
		  else
				begin	
					
					xx <= locX;
					yy <= locY;
				
            end 
	 end 
	always@(posedge clk)
		begin: square
			if(!reset)
				begin
					counter <= 5'b0;
							X <= 8'b0;
							Y <= 7'b0;
							i <= 5'b0;
							j <= 7'b0;
							blackcounter <= 17'b0;
							cleared <= 1'b0;
							Colour <= 3'b0;
				end
			else if(black)
				begin
					Colour <= 3'b0;
					if(blackcounter <= 17'b1)
						begin
							X <= blackcounter[8:0];
							Y <= blackcounter[17:9];
							blackcounter <= blackcounter + 1'b1;
						end
					else
						begin
							cleared <= 1'b1;
							blackcounter <= 17'b0;
						end
					
				end
			else if(ld_plot)
			begin
				Colour <= colour;

				X <= xx + i;
				blackcounter <= 15'b0;
				Y <= yy + j;
				if(j < (7'd15))
					begin
					
						if(i < (5'd15))
							begin
								i <= i + 1'b1;
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
				

		//						end
				end

			else
				begin
					if(xx>=8'd304)
						X <= 8'd304;
					else	
						X <= xx;
						
					if(yy >= 7'd224)
						Y <= 7'd224;
					else 
						Y <= yy;
				end
		end
endmodule 

module randNum(
	input clk,
   input coord,
	input reset,
	output reg [8:0] X,
	output reg [7:0] Y
);
	reg [8:0] xcounter;
	reg [7:0] ycounter;

	
	always@(posedge clk)
	begin: a
		if(!reset)
			begin
				xcounter <= 9'b0;
				ycounter <= 8'b0;
				
			end
		else if(xcounter == 9'b111111111)
			xcounter <= 9'b0;
		else if(ycounter == 8'b11111111)
			ycounter <= 8'b0;
		else if(coord == 1'b1)
			begin
				X <= xcounter;
				Y <= ycounter;
			
			end
		else
			begin
				xcounter <= xcounter + 1'b1;
				ycounter <= ycounter + 1'b1;
		
			end
	end

endmodule

module loadImage(

	input clock, reset, 
	input [2:0] id,
	input [3:0] i,
	input [5:0] j,
	output [2:0] colour
);	
	wire [2:0] q;
	wire [5:0] tempj;
	assign tempj[5:0] = j[5:0] + (id * 5'd16);

	ramGraphics ra(.address({tempj,i}), .clock(clock),.wren(1'b0), .q(q));
	assign colour = q;
	

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

