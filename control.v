module control(
	input clk,
	input go, black, reset,
	input cleared, done, draw, drewOsu, drewScore, gameover,
	output reg  [9:0] LED,
	output reg  ld_plot, ld_coord,ld_BG, ld_osu, ld_line, ld_score, ld_gameover
);

    reg [4:0] current_state;
	 reg [4:0] next_state;
	 

	 localparam 		S_Reset  = 5'd0,
							S_ClearScreen = 5'd1,
							S_DrawBG = 5'd2,
							S_DrawScore = 5'd3,
							S_DrawOSU = 5'd4,
							S_DrawLine = 5'd5,
							S_GenerateLocation = 5'd6,
							S_StartAnimation = 5'd7,
							S_Done = 5'd8;
	 


	always @(*)
	begin: state_table
		case(current_state)
			S_Reset: next_state = reset? S_Reset: S_DrawBG	;
			//S_Reset: next_state = S_GenerateLocation;
			S_DrawBG: next_state = draw? S_DrawScore: S_DrawBG;
			S_DrawScore: next_state = drewScore? S_DrawOSU: S_DrawScore;
			S_DrawOSU: next_state = drewOsu? S_DrawLine: S_DrawOSU;
			S_DrawLine: next_state = S_GenerateLocation;
			S_GenerateLocation: next_state = S_StartAnimation;
			S_StartAnimation:  
					begin
						if(done) 
							next_state = S_DrawBG;
						else if(gameover)
							next_state = S_Done;
						else 
							next_state = S_StartAnimation;
					end
			S_Done: next_state = S_Done;
			//S_Done: next_state = S_GenerateLocation;
			endcase
	end
	 
	 always @(*)
	 begin: enable
		ld_plot = 1'b0;
		ld_coord = 1'b0;
		ld_BG = 1'b0;
		ld_osu = 1'b0;
		ld_line = 1'b0;
		ld_score = 1'b0;
		ld_gameover = 1'b0;
		LED[0] = 1'b0;
		LED[1] = 1'b0;
		LED[2] = 1'b0;
		LED[3] = 1'b0;
		LED[4] = 1'b0;
		LED[5] = 1'b0;
		LED[6] = 1'b0;
		LED[7] = 1'b0;
		LED[8] = 1'b0;
		LED[9] = 1'b1;
		case(current_state)
		
			S_DrawBG: 
				begin
					ld_BG = 1'b1;
					LED[0] = 1'b1;
				end
			S_DrawScore:
				begin
					ld_score = 1'b1;
				end
			S_DrawOSU:
				begin 
					ld_osu = 1'b1;
				end
			S_DrawLine:
				begin
					ld_line = 1'b1;
				end
			S_GenerateLocation: 
				begin
					ld_coord = 1'b1;
					LED[1] = 1'b1;
				end
			S_StartAnimation: 
				begin 
					ld_coord = 1'b0;
					ld_plot = 1'b1;
					LED[2] = 1'b1;
				end
			S_Done:
				begin
				ld_gameover = 1'b1;
				LED[3] = 1'b1;
				end
			
		endcase
	end

	 always@(posedge clk)
    begin: state_FFs
            current_state <= next_state;
			
    end 
endmodule