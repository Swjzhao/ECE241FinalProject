`timescale 1ns / 1ns
module top(
			SW, 
			KEY,
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
			VGA_CLK);			
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
	PS2_Controller pc0 (
		.CLOCK_50(CLOCK_50),
		.reset(reset),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.received_data(PS2_byte),
		.received_data_en(data_received));

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

module control(
	input clk,
	input go, black, reset,
	input cleared, done, draw,
	
	output reg  ld_plot, ld_coord,ld_BG
);

    reg [4:0] current_state;
	 reg [4:0] next_state;
	 

	 localparam 		S_Reset  = 5'd0,
							S_ClearScreen = 5'd1,
							S_DrawBG = 5'd2,
							S_GenerateLocation = 5'd3,
							S_StartAnimation = 5'd4,
							S_Done = 5'd5;
	 


	always @(*)
	begin: state_table
		case(current_state)
			S_Reset: next_state = reset? S_Reset: S_DrawBG	;
			//S_Reset: next_state = S_GenerateLocation;
			S_DrawBG: next_state = draw? S_GenerateLocation: S_DrawBG;
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
			S_Done: next_state = S_DrawBG;
			//S_Done: next_state = S_GenerateLocation;
			endcase
	end
	 
	 always @(*)
	 begin: enable
		ld_plot = 1'b0;
		ld_coord = 1'b0;
		ld_BG = 1'b0;
		case(current_state)
		
			S_DrawBG: 
				begin
					ld_BG = 1'b1;
				end
			S_GenerateLocation: 
				begin
					ld_coord = 1'b1;
				end
			S_StartAnimation: 
				begin 
					ld_coord = 1'b0;
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
	input [1:0] id2,
	input black, ld_coord, ld_plot, ld_BG, 
	
	output reg [8:0] X, 
	output reg [7:0] Y,
	output reg cleared,
	output reg done,
	output reg draw,
	output reg [14:0] Colour,
	output reg [9:0] counter
);
		
	 reg [17:0] blackcounter;
	 reg [8:0] xx;
	 reg [7:0] yy;
	 reg [4:0] i;
	 reg [6:0] j;
	 
	 reg [5:0] bgi;
	 reg [5:0] bgj;
	 reg [4:0] bgjid;
	 reg [3:0] bgiid;
	 reg [2:0] id;
	 
	// reg [8:0] Data_Out;
	// reg [13:0] Score_Img_Counter;
	 wire [2:0] colour;
	 wire [14:0] bgcolour;
	 wire [25:0] freq;
	 wire clock;
	 RateDivider r1(clk, reset, 26'b0100111110101111000001111, freq);
	 assign clock = (freq  == 26'b00000000000000000000000000)? 1'b1 : 1'b0;
	 always@(posedge clock)
	 begin 
			if(!reset)
				begin
					id <= 3'd0;
					done <= 1'b0;
				end
			else if (ld_coord)
				begin 
					id <= 3'd0;
					done <= 1'b0;
				end
			else if(id == 3'd3 )
				begin
			
					id <= 3'd0;
					done <= 1'b1;
				end
			else
				begin
					id <= id + 1'b1;
					done <= 1'b0;
				end
	 end
	 // RateDivider r4(clock, reset, 26'b10111110101111000001111111, w5);	
	 loadImage la (clk, reset, id,2'd1, i , j ,colour);
	 loadBG bg (clk, reset, bgi, bgj, bgcolour);
	 
//	 always @(posedge clk) begin
//		if (!reset) begin
//		Data_Out <= 0;
//		Score_Img_Counter <= 0;	
//		
//		end
//		if (ld_plot) begin
//			X<= 0;
//			Y<= 0;
//			if (Score_Img_Counter < 14'b11001000001010) Score_Img_Counter <= Score_Img_Counter + 1;
//			else if (Score_Img_Counter == 14'b11001000001010) Score_Img_Counter <= 0;
//		end
//	end 
//	loadImage_Score scoreIMG(clk, reset, Score_Img_Counter , Data_Out);
 
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
							bgi <= 6'b0; 
							bgj <= 6'b0;	
							bgjid <= 6'd0;
							bgjid <= 6'd0;
							blackcounter <= 17'b0;
							cleared <= 1'b0;
							draw <= 1'b0;
							Colour <= 15'b0;
				end
			else if(black)
				begin
					Colour <= 15'b0;
					if(blackcounter <= 17'b11111111111111111)
						begin
							cleared <= 1'b1;
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
			else if(ld_BG)
				begin
					X <= bgi + (bgiid * 6'd32);
					blackcounter <= 17'b0;
					Y <= bgj + (bgjid * 6'd32);
					Colour <= bgcolour;
					if(bgj < (6'd32))
					begin
					
						if(bgi < (6'd32))
							begin
							draw <= 1'b0;
								bgi <= bgi + 1'b1;
							end
						else
							begin
								draw <= 1'b0;
								bgi <= 6'd0;
								bgj <= bgj + 1'b1;
								
							end
						end
					else
						begin

							bgiid <= bgiid + 1'b1;
							bgjid <= bgjid + 1'b0;
							bgj <= 6'd0;
							bgi <= 6'd0;
							
						end
						
					if(bgiid > 6'd9)
						begin
						bgiid <= 6'd0;
						bgjid <= bgjid + 1'b1;
						draw <= 1'b0;
						end
						
					if(bgjid > 6'd7)
						begin
							bgjid <= 6'd0;
							bgiid <= 6'd0;
							draw <= 1'b1;
						end
				end
			else if(ld_plot)
			begin
				draw <= 1'b0;
				if(colour == 3'b111)
					Colour<=15'b111111111111111;
				else
					Colour<=15'b0;
				
				X <= xx + i;
				blackcounter <= 17'b0;
				Y <= yy + j;
				if(j < (7'd15))
					begin
					
						if(i < (5'd15))
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
  
module loadImage(

	input clock, reset, 
	input [2:0] id,
	input [1:0] id2,
	input [3:0] i,
	input [5:0] j,
	output [2:0] colour
);	
	wire [2:0] qa;
	wire [2:0] qs;
	wire [2:0] qd;
	wire [2:0] qf;
	reg [2:0] q; 
	
	wire [5:0] tempj;
	assign tempj[5:0] = j[5:0] + (id * 5'd16);

	loadA a(.address({tempj,i}), .clock(clock),.wren(1'b0), .q(qa));
	loadS s(.address({tempj,i}), .clock(clock),.wren(1'b0), .q(qs));
	loadD d(.address({tempj,i}), .clock(clock),.wren(1'b0), .q(qd));
	loadF f(.address({tempj,i}), .clock(clock),.wren(1'b0), .q(qf));
	always @(*)
	begin
		if(id2 == 2'd1)
			q = qs;
		else if(id2 == 2'd2)
			q = qd;
		else if(id2 == 2'd3)
			q = qf;
		else
			q = qa;
		
	end
	assign colour = q;
	

endmodule

module loadBG(
	input clk, reset, 
	input [5:0] bgi, 
	input [5:0] bgj,
	output [14:0] bgcolour);
	wire [14:0] q;
	BGRam bgram(.address({bgj[5:0],bgi[5:0]}), .clock(clk), .wren(1'b0), .q(q));
	assign bgcolour = q;
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
module genloc(
	input clock,
	input reset,
	input ld_coord,
	output reg [7:0] locx,
	output reg [7:0] locy,
	output reg [1:0] id2

);
	reg [4:0] i;
	wire[7:0] outx;
	wire[7:0] outy;
	wire[1:0] outid;
	reg bool;
	
	loadLocation la (clock,reset,i[4:0], outx, outy);
	keyRam kr (.address({1'b0,i[4:0]}), .clock(clock),.wren(1'b0), .q(outid)); 
	always @(posedge clock)
	begin: iter
	   locx <= outx;
		locy <= outy;
		id2 <= outid;
		if(!reset)
			begin
			i <= 5'b0;
			bool <= 1'b1;
			end
		else if(i >= 5'b01111)
			begin
				i <= 5'b0;
				bool <= 1'b0;
			end
		else if(ld_coord)
			begin
			if(bool == 1'b1)
				begin
					bool <= 1'b0;
					i <= i + 1'b1;
				end
			else
				begin
				bool <= 1'b0;
				i <= i + 1'b0;
				end
			end
		else
			begin
			bool <= 1'b1; 
			i <= i + 1'b0;
			end

		
	end
	
	
endmodule
module loadLocation(
	input clock, reset, 
	input [3:0] i,
	output [7:0] locx,
	output [7:0] locy
);
	wire [7:0] xx;
	wire [7:0] yy;
	ramMapX rax(.address({1'b0,i}), .clock(clock),.wren(1'b0), .q(xx));
	ramMapY ray(.address({1'b0,i}), .clock(clock),.wren(1'b0), .q(yy));
	assign locx = xx;
	assign locy = yy;
	

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
	reg [8:0] xhold;
	reg [7:0] yhold;
	reg gotCoord;

	wire [25:0] freq;
	wire clock;
	RateDivider r1(clk, reset, 26'b0000111110101111000001111, freq);
	assign clock = (freq  == 26'b00000000000000000000000000)? 1'b1 : 1'b0;
				
	always@(posedge clk)
	begin: a
		if(!reset)
			begin
				xcounter <= 9'b0;
				ycounter <= 8'b0;
				X <= 9'b0;
				Y <= 8'b0;
				gotCoord = 1'b0;
			end
		else if(coord == 1'b1)
			begin
				if(gotCoord == 1'b0)
					begin
						gotCoord <= 1'b1;
						
						X <= xcounter;
						Y <= ycounter;
					
					end
				
			end
		else
			begin
				if(clock)
					begin
					xcounter <= xcounter + 1'b1;
					if(xcounter >= 8'd304)
						begin
						ycounter <= ycounter+ 1'b1;
						xcounter <= 8'b0;
						end
					end
					if(ycounter >= 7'd214)
					begin
						ycounter <= 7'b0;
					end
					
				gotCoord <= 1'b0;
			
				
			end
	end

endmodule


