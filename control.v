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
            current_state <= next_state;
			
    end 
endmodule