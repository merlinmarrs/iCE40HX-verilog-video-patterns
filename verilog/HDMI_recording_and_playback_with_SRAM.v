`default_nettype none // disable implicit definitions by Verilog
//-----------------------------------------------------------------
// minimalDVID_encoder.vhd : A quick and dirty DVI-D implementation
//
// Author: Mike Field <hamster@snap.net.nz>
//
// DVI-D uses TMDS as the 'on the wire' protocol, where each 8-bit
// value is mapped to one or two 10-bit symbols, depending on how
// many 1s or 0s have been sent. This makes it a DC balanced protocol,
// as a correctly implemented stream will have (almost) an equal
// number of 1s and 0s.
//
// Because of this implementation quite complex. By restricting the
// symbols to a subset of eight symbols, all of which having have
// five ones (and therefore five zeros) this complexity drops away
// leaving a simple implementation. Combined with a DDR register to
// send the symbols the complexity is kept very low.
//-----------------------------------------------------------------

module top(
clk100, hdmi_p, hdmi_n, rec, addr, io, cs, we, oe, key, reset
);


input wire rec, // the record button IS ACTIVE LOW !!
input clk100;
output [3:0] hdmi_p;
output [3:0] hdmi_n;

input reset;

input [7:0] key;

output reg [17:0] addr;
inout wire [7:0] io; // inout must be type wire

output wire cs;
output reg we;
output wire oe;

wire [7:0] data_in;
wire [7:0] data_out;

reg [7:0] a, b;

assign io = (rec==0) ? a : 8'bzzzzzzzz;

assign data_out = b;

// for our bittiness
reg [9:0] again_xnor;

// registers for storing the horizontal & vertical counters
reg [9:0] vc;
reg [9:0] hc;


assign cs = 0; //change this
assign oe = 0; //change this


// to store values from other modules
wire half_sec;

wire [12:0] random_number_0;
wire [12:0] random_number_1;
wire [12:0] random_number_2;
wire [12:0] random_number_3;
wire [12:0] random_number_4;
wire [12:0] random_number_5;
wire [12:0] random_number_6;
wire [12:0] random_number_7;
wire [12:0] random_number_8;
wire [12:0] random_number_9;
wire [7:0] sine_wave;




// For holding the outward bound TMDS symbols in the slow and fast domain
reg [9:0] c0_symbol; reg [9:0] c0_high_speed;
reg [9:0] c1_symbol; reg [9:0] c1_high_speed;
reg [9:0] c2_symbol; reg [9:0] c2_high_speed;
reg [9:0] clk_high_speed;

reg [1:0] c2_output_bits;
reg [1:0] c1_output_bits;
reg [1:0] c0_output_bits;
reg [1:0] clk_output_bits;

wire clk_x5;
reg [2:0] latch_high_speed = 3'b100; // Controlling the transfers into the high speed domain

wire vsync, hsync;
wire [1:0] syncs; // To glue the HSYNC and VSYNC into the control character
assign syncs = {vsync, hsync};

// video structure constants
parameter hpixels = 800; // horizontal pixels per line
parameter vlines = 525; // vertical lines per frame
parameter hpulse = 96; // hsync pulse length
parameter vpulse = 2; // vsync pulse length
parameter hbp = 144; // end of horizontal back porch (96 + 48)
parameter hfp = 784; // beginning of horizontal front porch (800 - 16)
parameter vbp = 35; // end of vertical back porch (2 + 33)
parameter vfp = 515; // beginning of vertical front porch (525 - 10)


// generate sync pulses (active high)
assign vsync = (vc < vpulse);
assign hsync = (hc < hpulse);


assign data_in[7:0] = (again_xnor[7:0] == key[7:0]) ? 8'b11111111 : 8'b00000000; // output from FPGA

always @(*) begin

again_xnor[9:0] = hc[9:0]^ ~vc[9:0];



end

//SRAM address counter

always @(posedge latch_high_speed[2]) begin

        addr <= addr+1;

    end

//REC control


//assign io = rec ? a : 8'bzzzzzzzz;

always @(posedge latch_high_speed[2]) begin
      b <= io;
      a <= data_in;
     if (rec==0) begin
          we <= addr[0]; //not sure why it isn't the inverse of addr[0] but that doesn't make the inverse on 'scope
     end
     else begin
          we <= 1;
     end
end

always @(posedge clk_x5) begin
//-------------------------------------------------------------
// Now take the 10-bit words and take it into the high-speed
// clock domain once every five cycles.
//
// Then send out two bits every clock cycle using DDR output
// registers.
//-------------------------------------------------------------
c0_output_bits <= c0_high_speed[1:0];
c1_output_bits <= c1_high_speed[1:0];
c2_output_bits <= c2_high_speed[1:0];
clk_output_bits <= clk_high_speed[1:0];
if (latch_high_speed[2]) begin // pixel clock 25MHz
c0_high_speed <= c0_symbol;
c1_high_speed <= c1_symbol;
c2_high_speed <= c2_symbol;
clk_high_speed <= 10'b0000011111;
latch_high_speed <= 3'b000;
if (hc < hpixels)
hc <= hc + 1;
else
begin
hc <= 0;
if (vc < vlines)
vc <= vc + 1;
else
vc <= 0;
end
end
else begin
c0_high_speed <= {2'b00, c0_high_speed[9:2]};
c1_high_speed <= {2'b00, c1_high_speed[9:2]};
c2_high_speed <= {2'b00, c2_high_speed[9:2]};
clk_high_speed <= {2'b00, clk_high_speed[9:2]};
latch_high_speed <= latch_high_speed + 1'b1;
end
end

always @(posedge latch_high_speed[2]) // display 100% saturation colourbars
begin
// first check if we're within vertical active video range
if (vc >= vbp && vc < vfp)
begin
// now display different colours every 80 pixels
// while we're within the active horizontal range
// -----------------
	if(hc >= hbp && hc < hfp) begin
		// display white bar
		if ((rec==0) && (a==8'b11111111))
		begin
			c2_symbol = 10'b1011110000; // red
			c1_symbol = 10'b1011110000; // green
			c0_symbol = 10'b0111110000; // blue
		end
		// display black bar
		else if ((rec==0) && (a==8'b00000000))
		begin
			c2_symbol = 10'b0111110000; // red
			c1_symbol = 10'b1011110000; // green
			c0_symbol = 10'b1011110000; // blue
		end

		else if ((rec==1) && (b==8'b11111111)) //data_out not b ??
		begin
			c2_symbol = 10'b0111110000; // red
			c1_symbol = 10'b1011110000; // green
			c0_symbol = 10'b0111110000; // blue
		end
		// display black bar
		else
		begin
			c2_symbol = 10'b1011110000; // red
			c1_symbol = 10'b0111110000; // green
			c0_symbol = 10'b1011110000; // blue
		end	
	
	end

// we're outside active horizontal range
	else
	begin
	c2_symbol = 10'b1101010100; // red
	c1_symbol = 10'b1101010100; // green
//---------------------------------------------
// Channel 0 carries the blue pixels, and also
// includes the HSYNC and VSYNCs during
// the CTL (blanking) periods.
//---------------------------------------------
	case (syncs)
	2'b00 : c0_symbol = 10'b1101010100;
	2'b01 : c0_symbol = 10'b0010101011;
	2'b10 : c0_symbol = 10'b0101010100;
	default : c0_symbol = 10'b1010101011;
	endcase
	end
end //if (vc >= vbp && vc < vfp)
// we're outside active vertical range
else
begin
c2_symbol = 10'b1101010100; // red
c1_symbol = 10'b1101010100; // green
//---------------------------------------------
// Channel 0 carries the blue pixels, and also
// includes the HSYNC and VSYNCs during
// the CTL (blanking) periods.
//---------------------------------------------
case (syncs)
2'b00 : c0_symbol = 10'b1101010100;
2'b01 : c0_symbol = 10'b0010101011;
2'b10 : c0_symbol = 10'b0101010100;
default : c0_symbol = 10'b1010101011;
endcase
end 
end //always @(posedge latch_high_speed[2])

// red N
defparam hdmin2.PIN_TYPE = 6'b010000;
defparam hdmin2.IO_STANDARD = "SB_LVCMOS";
SB_IO hdmin2 (
.PACKAGE_PIN (hdmi_n[2]),
.CLOCK_ENABLE (1'b1),
.OUTPUT_CLK (clk_x5),
.OUTPUT_ENABLE (1'b1),
.D_OUT_0 (~c2_output_bits[1]),
.D_OUT_1 (~c2_output_bits[0])
);

// red P
defparam hdmip2.PIN_TYPE = 6'b010000;
defparam hdmip2.IO_STANDARD = "SB_LVCMOS";
SB_IO hdmip2 (
.PACKAGE_PIN (hdmi_p[2]),
.CLOCK_ENABLE (1'b1),
.OUTPUT_CLK (clk_x5),
.OUTPUT_ENABLE (1'b1),
.D_OUT_0 (c2_output_bits[1]),
.D_OUT_1 (c2_output_bits[0])
);

// green N
defparam hdmin1.PIN_TYPE = 6'b010000;
defparam hdmin1.IO_STANDARD = "SB_LVCMOS";
SB_IO hdmin1 (
.PACKAGE_PIN (hdmi_n[1]),
.CLOCK_ENABLE (1'b1),
.OUTPUT_CLK (clk_x5),
.OUTPUT_ENABLE (1'b1),
.D_OUT_0 (~c1_output_bits[1]),
.D_OUT_1 (~c1_output_bits[0])
);

// green P
defparam hdmip1.PIN_TYPE = 6'b010000;
defparam hdmip1.IO_STANDARD = "SB_LVCMOS";
SB_IO hdmip1 (
.PACKAGE_PIN (hdmi_p[1]),
.CLOCK_ENABLE (1'b1),
.OUTPUT_CLK (clk_x5),
.OUTPUT_ENABLE (1'b1),
.D_OUT_0 (c1_output_bits[1]),
.D_OUT_1 (c1_output_bits[0])
);


// blue N
defparam hdmin0.PIN_TYPE = 6'b010000;
defparam hdmin0.IO_STANDARD = "SB_LVCMOS";
SB_IO hdmin0 (
.PACKAGE_PIN (hdmi_n[0]),
.CLOCK_ENABLE (1'b1),
.OUTPUT_CLK (clk_x5),
.OUTPUT_ENABLE (1'b1),
.D_OUT_0 (~c0_output_bits[1]),
.D_OUT_1 (~c0_output_bits[0])
);

// blue P
defparam hdmip0.PIN_TYPE = 6'b010000;
defparam hdmip0.IO_STANDARD = "SB_LVCMOS";
SB_IO hdmip0 (
.PACKAGE_PIN (hdmi_p[0]),
.CLOCK_ENABLE (1'b1),
.OUTPUT_CLK (clk_x5),
.OUTPUT_ENABLE (1'b1),
.D_OUT_0 (c0_output_bits[1]),
.D_OUT_1 (c0_output_bits[0])
);

// clock N
defparam hdmin3.PIN_TYPE = 6'b010000;
defparam hdmin3.IO_STANDARD = "SB_LVCMOS";
SB_IO hdmin3 (
.PACKAGE_PIN (hdmi_n[3]),
.CLOCK_ENABLE (1'b1),
.OUTPUT_CLK (clk_x5),
.OUTPUT_ENABLE (1'b1),
.D_OUT_0 (~clk_output_bits[1]),
.D_OUT_1 (~clk_output_bits[0])
);


// clock P
defparam hdmip3.PIN_TYPE = 6'b010000;
defparam hdmip3.IO_STANDARD = "SB_LVCMOS";
SB_IO hdmip3 (
.PACKAGE_PIN (hdmi_p[3]),
.CLOCK_ENABLE (1'b1),
.OUTPUT_CLK (clk_x5),
.OUTPUT_ENABLE (1'b1),
.D_OUT_0 (clk_output_bits[1]),
.D_OUT_1 (clk_output_bits[0])
);
// D_OUT_0 and D_OUT_1 swapped?
// https://github.com/YosysHQ/yosys/issues/330


SB_PLL40_PAD #(
.FEEDBACK_PATH ("SIMPLE"),
.DIVR (4'b0000),
.DIVF (7'b0001001),
.DIVQ (3'b011),
.FILTER_RANGE (3'b101)
) uut (
.RESETB (1'b1),
.BYPASS (1'b0),
.PACKAGEPIN (clk100),
.PLLOUTGLOBAL (clk_x5) // DVI clock 125MHz
);

endmodule