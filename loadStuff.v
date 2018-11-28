
  
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
	wire [9:0] ii;
	assign ii = {tempj,i} + 1'b1;

	loadA a(.address(ii), .clock(clock),.wren(1'b0), .q(qa));
	loadS s(.address(ii), .clock(clock),.wren(1'b0), .q(qs));
	loadD d(.address(ii), .clock(clock),.wren(1'b0), .q(qd));
	loadF f(.address(ii), .clock(clock),.wren(1'b0), .q(qf));
	always @(posedge clock)
	begin
		if(id2 == 2'd1)
			q <= qs;
		else if(id2 == 2'd2)
			q <= qd;
		else if(id2 == 2'd3)
			q <= qf;
		else
			q <= qa;
		
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
	reg [6:0] i;
	wire[7:0] outx;
	wire[7:0] outy;
	wire[1:0] outid;
	reg bool;
	reg [1:0] counter;
	
	loadLocation la (clock,reset,i[6:0], outx, outy);
	keyRam kr (.address({i[6:0]}), .clock(clock),.wren(1'b0), .q(outid)); 
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
		else if(i >= 7'b0111111)
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
	input [6:0] i,
	output [7:0] locx,
	output [7:0] locy
);
	wire [7:0] xx;
	wire [7:0] yy;
	ramMapX rax(.address({i}), .clock(clock),.wren(1'b0), .q(xx));
	ramMapY ray(.address({i}), .clock(clock),.wren(1'b0), .q(yy));
	assign locx = xx;
	assign locy = yy;
	

endmodule
