 
module datapath(
	input clk,
	input go,
	
	input reset,
	input [8:0] locX,
	input [7:0] locY,
	input [1:0] id2,
	input ld_black, ld_coord, ld_plot, ld_BG, ld_osu, ld_line, ld_score, ld_gameover,
	input [7:0] datareceived,
	output reg writeEn,
	output reg [8:0] X, 
	output reg [7:0] Y,
	output reg cleared,
	output reg done,
	output reg draw,
	output reg drewOsu,
	output reg drewScore,
	output reg gameover,
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
	 
	 reg [11:0] score;
	 reg [2:0]  scoreid;
	 reg [4:0]  scoreid1;
	 reg [4:0]  scoreid2;
	 reg [4:0]  scoreid3;
	 reg [4:0]  scorei;
	 reg [6:0]  scorej;
	 
	 reg [10:0] osucd;
	 wire [14:0] osucolour;
	
	 reg [7:0] circlecounter;
	
	 reg [11:0] gameoveradd;
	 wire [2:0] gameovercolour;
		
	 wire [2:0] colour;
	 wire [14:0] bgcolour;
	 reg [25:0] freq;
	 reg [25:0] scorefreq;
	 reg [4:0] scoreweight;
	// wire clock;
	// RateDivider r1(clk, reset, 26'b0100111110101111000001111, freq);
	// assign clock = (freq  == 26'b00000000000000000000000000)? 1'b1 : 1'b0;
	 
//	 always@(posedge clock)
//	 begin
//		if() begin
//			keyboard_data1 <= keyboard_data2;
//			keyboard_data2 <= datareceived;
//		end
//	 end
	reg pressed;
	 always@(posedge clk)
	 begin 
			
			if(!reset)
				begin
				scoreweight = 5'd7;
				 scorefreq <= 26'd0;
				end
			else if(ld_coord)
			begin
				scoreweight = 5'd7;
				 scorefreq <= 26'd0;
				end
			else if(scorefreq == 26'b0100111110101111000001111)
			begin
				if(scoreweight > 5'd1)
					scoreweight = scoreweight - 1'b1;
				else
					scoreweight = scoreweight;
				
				scorefreq <= 26'd0;
//					done <= 1'b0;
			end
			else
			begin
			
			scoreweight = scoreweight;
			 scorefreq <=  scorefreq + 1'b1;
			end
		
	
			scoreid1 = scoreid1;
			scoreid2 = scoreid2;
			scoreid3 = scoreid3;
			gameover = 1'b0;
			if(!reset)
				begin
					id <= 3'd0;
//					done <= 1'b0;
					freq <= 26'b0;
					score <= 12'b0;
					scoreid1 = 5'b0;
					scoreid2 = 5'b0;
					scoreid3 = 5'b0;
					pressed <= 1'b0;
					circlecounter <= 8'b0;
					gameover = 1'b0;
				end
			else if (ld_coord)
				begin 
					id <= 3'd0;
					freq <= freq;
				
//					done <= 1'b0;
				end 
			else if(id == 3'd4)
				begin
					freq <= freq;
					scorefreq <= scorefreq;
//					done <= 1'b1;
					id <= 3'd1;
			
				end
			else if(freq == 26'b0100111110101111000001111)
				begin
					id <= id + 1'b1;
					
					freq <= 26'b0;
//					done <= 1'b0;
				end
			else
				begin
				id<= id;
				
				freq <= freq + 1'b1;
				end
				
			if(id2 == 2'd0 && datareceived == 8'h1C) 
					begin 
					if(pressed == 1'b0)
					begin
							score <= score + scoreweight;
							if(scoreid3 + scoreweight > 5'd9)
							begin
							scoreid3 = scoreid3 + scoreweight - 5'd9;
							scoreid2 = scoreid2 + 1'd1;
							end
							else
							begin
							scoreid3 = scoreid3 + scoreweight;
							end
						if(scoreid2 > 5'd9)
							begin
							scoreid2 = 5'd0;
							if(scoreid1 < 5'd9)
								scoreid1 = scoreid1 + 1'b1;
							else
								scoreid1 = scoreid1;
						end
						else
							begin
							scoreid1 <= scoreid1;
							scoreid2 <= scoreid2;
							
							
							end
						pressed <= 1'b1;
							
						circlecounter <= circlecounter + 1'b1;
						if(circlecounter >= 8'd100)
							gameover = 1'b1;
						else
							begin
							done <= 1'b1;
							gameover = 1'b0;
							end
						
					end
					
						
					end
				else if(id2 == 2'd1 && datareceived == 8'h1b)
					begin
					 		if(pressed == 1'b0)
					begin
							score <= score + scoreweight;
							if(scoreid3 + scoreweight > 5'd9)
							begin
							scoreid3 = scoreid3 + scoreweight - 5'd9;
							scoreid2 = scoreid2 + 1'd1;
							end
							else
							begin
							scoreid3 = scoreid3 + scoreweight;
							end
						if(scoreid2 > 5'd9)
							begin
							scoreid2 = 5'd0;
							if(scoreid1 < 5'd9)
								scoreid1 = scoreid1 + 1'b1;
							else
								scoreid1 = scoreid1;
						end
						else
							begin
							scoreid1 <= scoreid1;
							scoreid2 <= scoreid2;
							
							
							end
						pressed <= 1'b1;
						circlecounter <= circlecounter + 1'b1;
						if(circlecounter >= 8'd100)
							gameover = 1'b1;
						else
							begin
							done <= 1'b1;
							gameover = 1'b0;
							end
					end
						
						
					end
				else if(id2 == 2'd2 && datareceived == 8'h23)
					begin
							if(pressed == 1'b0)
					begin
							score <= score + scoreweight;
							if(scoreid3 + scoreweight > 5'd9)
							begin
							scoreid3 = scoreid3 + scoreweight - 5'd9;
							scoreid2 = scoreid2 + 1'd1;
							end
							else
							begin
							scoreid3 = scoreid3 + scoreweight;
							end
						if(scoreid2 > 5'd9)
							begin
							scoreid2 = 5'd0;
							if(scoreid1 < 5'd9)
								scoreid1 = scoreid1 + 1'b1;
							else
								scoreid1 = scoreid1;
						end
						else
							begin
							scoreid1 <= scoreid1;
							scoreid2 <= scoreid2;
							
							
							end
						pressed <= 1'b1;
						circlecounter <= circlecounter + 1'b1;
						if(circlecounter >= 8'd100)
							gameover = 1'b1;
						else
							begin
							done <= 1'b1;
							gameover = 1'b0;
							end
					end
						
						
					end
				else if(id2 == 2'd3 && datareceived == 8'h2b)
					begin
							if(pressed == 1'b0)
					begin
							score <= score + scoreweight;
							if(scoreid3 + scoreweight > 5'd9)
							begin
							scoreid3 = scoreid3 + scoreweight - 5'd9;
							scoreid2 = scoreid2 + 1'd1;
							end
							else
							begin
							scoreid3 = scoreid3 + scoreweight;
							end
						if(scoreid2 > 5'd9)
							begin
							scoreid2 = 5'd0;
							if(scoreid1 < 5'd9)
								scoreid1 = scoreid1 + 1'b1;
							else
								scoreid1 = scoreid1;
						end
						else
							begin
							scoreid1 <= scoreid1;
							scoreid2 <= scoreid2;
							
							
							end
						pressed <= 1'b1;
						circlecounter <= circlecounter + 1'b1;
						if(circlecounter >= 8'd100)
							gameover = 1'b1;
						else
							begin
							done <= 1'b1;
							end
					end
				
					end
				else
					begin 
						score <= score;
						scoreid1 = scoreid1;
						pressed <= 1'b0;
						scoreid2 = scoreid2;
						circlecounter <= circlecounter;
						scoreid3 = scoreid3;
						done <= 1'b0;
						gameover = 1'b0;
					end
					
	 end
	 
	 
	 // RateDivider r4(clock, reset, 26'b101111101011110000 01111111, w5);	
	 loadImage la (clk, reset, id,id2, i , j ,colour);
	 loadBG bg (clk, reset, bgi, bgj, bgcolour);
	 loadosu lo (clk, reset, osucd, osucolour);	
	 loadgameover lgm (clk, reset, gameoveradd, gameovercolour);
	 
	 reg [11:0] tempscore;
	 
	
	 
	 reg [4:0] tempid;
	 always@(posedge clk)
	 begin:scoreids
		
		
			
		if(scoreid == 5'd0)
			tempid <= scoreid1;
		
		else if(scoreid == 5'd1)
		
			tempid <= scoreid2;
		else if(scoreid == 5'd2)
			
			tempid <= scoreid3;
		else
			tempid <= scoreid1;
	 
	 end
	 
	 loadscore ls (clk, reset, tempid, scorei, scorej, scorecolour);
		
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
		writeEn = 1'b1;
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
							drewOsu <= 1'b0;
							drewScore  <= 1'b0;
							Colour <= 15'b0;
							osucd[10:0] <= 11'd0;
							scorei <= 5'd0;
							scorej <= 7'd0;
							scoreid <= 3'b0;
						
							
							gameoveradd <= 13'b0;
	                
							
				end
			else if(ld_black)
				begin
					Colour <= 15'b0;
					if(blackcounter <= 17'b11111111111111111)
						begin
							cleared <= 1'b0;
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
			else if(ld_score)
			
			begin
				X <= 9'd272 + scorei + scoreid * (5'd16);
				Y <= 8'b0 + scorej;
				
		
			if(scorecolour == 3'b0)
				begin
				Colour <= 15'b0;
				writeEn = 1'b0;
				end
			else
				Colour <= 15'b111111111111111;
				
			if(scorej < (7'd32))
				begin
				drewScore <= 1'b0;
					if(scorei < (5'd16))
						begin
							scorei <= scorei + 1'b1;
							scorej <= scorej + 1'b0;
							
						end
					else
						begin
							scorei <= 5'd0;
							scorej <= scorej + 1'b1;
						end
				end
			else
				begin
			
					scoreid <= scoreid +  1'b1;
					scorej <= 7'd0;
					scorei <= 5'd0;
				end
				
				if(scoreid == 3'd3)
				begin
					scoreid <= 3'd0;
					drewScore <= 1'b1;
					end
					
			end
				
			
			else if(ld_osu)
			begin
				
				X <= osucd[4:0] + 9'd144;
				Y <= osucd[9:5] + 8'd104;
				Colour <= osucolour;
			
				
				if(osucd < (11'd10000000000))
					begin
					osucd <= osucd + 1'b1;
					drewOsu <= 1'b0;
					end
				else
					begin
						osucd[10:0] <= 11'd0;
						drewOsu <= 1'b1;
					end
				
			
			end
			else if(ld_plot)
			begin
				draw <= 1'b0;
				if(colour == 3'b111)
					Colour<=15'b111111111111111;
				else
					begin
					Colour<=15'b0;
					
					end
				
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
			else if(ld_gameover)
			begin
				if(gameovercolour == 3'b000)
					Colour<=15'b0; 
				else
				Colour<=15'b111111111111111;
					
				X <= 8'd144 + gameoveradd [5:0];
				Y <= 7'd112 + gameoveradd [9:6];
				if(gameoveradd == 12'b001000000000)
				begin
					gameoveradd <= 12'b0;
				end
				else
				begin 
					gameoveradd <= gameoveradd + 1'b1;
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