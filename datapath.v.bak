
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