
module AudioV2 (
	// Inputs
	CLOCK_50,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[3:0]	KEY;
input		[3:0]	SW;

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

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;

wire resetcounter;
assign resetcounter = KEY[1];

// Internal Registers


reg [14:0] delay_cnt;
wire [14:0] delay;
reg [15:0] m;
reg [15:0] rate = 16'd 5000;
reg [15:0] counter ;
reg [15:0] a;
reg snd;

reg [8:0] cnt ;
wire [15:0] count = 16'd2000;

wire [31:0] audio_from_ram;
wire [15:0] address_count;

reg [15:0] address_count_reg = 0;
reg [20:0] clk_count = 0;



// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
 //pulsing
reg [10:0] pulse_count;
//	always @(posedge CLOCK_50)begin
//		if(clk_count == 12'd1600)  begin
//			if(address_count_reg == 16'd10000) begin
//				address_count_reg <= 16'b0;
//			end 
//	      if (audio_out_allowed && ~KEY[1]) address_count_reg <= address_count_reg + 1;
//		clk_count <= 0;	
//	end 
//	else
//		clk_count <= clk_count + 1;
//	end
	
	reg [15:0] output_counter = 0;
	
always @(posedge CLOCK_50)begin
	if (clk_count == 16'd4800) begin
		address_count_reg <= address_count_reg + 1'b1;
		clk_count <= 16'b0;
		
			if (address_count_reg == 16'd10000) begin
				address_count_reg <= 16'b0;
			end
	end
	
	else if (audio_out_allowed) begin
			address_count_reg <= address_count_reg + 1'b0;
			clk_count <= clk_count + 16'b1;
	end
end

ram_1 memory1(
.address(address_count),
.clock(CLOCK_50),
.data(1'b0),
.wren(1'b0),
.q(audio_from_ram));

assign address_count = address_count_reg;

assign left_channel_audio_out	= audio_from_ram;
assign right_channel_audio_out	= audio_from_ram;

assign read_audio_in			= audio_in_available & audio_out_allowed;
assign write_audio_out			= audio_in_available & audio_out_allowed;

//old code:
	//if (~KEY[1])  pulse_count <= 12'b0;
//	
//	if(address_count_reg == 16'd10000) begin
//			address_count_reg <= 16'b0;
//			output_counter <= 16'b0;
//	end
//	
//	if(clk_count == 12'd2000)  begin
//		address_count_reg <= address_count_reg + 1'b0; //send in the same address
//		output_counter <= address_count_reg;
//	end
//	
//	if (clk_count == 12'd2048 && audio_out_allowed) begin
//		address_count_reg <= address_count_reg + 1'b1;
//		output_counter <= address_count_reg;
//		clk_count <= 12'b0;
//	end
//	
//	else begin
//		output_counter <= 0;
//		clk_count <= clk_count + 12'b1;
//	end

//pulsing

//if (audio_out_allowed) begin
//			pulse_count <= pulse_count + 1'b1;
//			address_count_reg <= address_count_reg + 1'b0;
//			
//			if (pulse_count == 12'd48) begin
//				address_count_reg <= address_count_reg + 16'b1;
//				pulse_count <= 12'b0;
//				clk_count <= 12'b0;
//			end
//		end
		//clk_count <= 12'b0;

//reg [10:0] pulse_count;
////address_count_reg = 0;
//always @(posedge CLOCK_50) begin
//	if (audio_out_allowed) begin
//		//if (clk_count == 11'd500) begin
//			if (pulse_count == 11'd48) begin
//				address_count_reg <= address_count_reg + 1'b1;
//				pulse_count <= 11'b0;
//		end else begin
//				address_count_reg <= address_count_reg; //does nothing. 
//				pulse_count <= pulse_count + 11'b1;
//			 end
//			if(address_count_reg == 14'd998) begin
//				address_count_reg <= 14'b0;
//			end
//		//end
//	end
//end


//	
	/*
	if (!resetcounter) begin
		m <= 16'd0;
		counter <= 16'd0;
		end
	else if (counter == rate) begin
		m <= m + 1;
		counter <= 16'd0;
		end
	else
		counter <= counter + 1;
  */
 
/* always @(m)
	 begin
	 if ( m < count)
		a <= m;
		else
		m <= 16'd0;
	end */
 
/*always @(m)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;*/

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

//assign delay = {15'd100};

//wire [31:0] sound = (SW == 0) ? 0 : snd ? 32'd10000000 : -32'd10000000;



/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out ),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

endmodule

