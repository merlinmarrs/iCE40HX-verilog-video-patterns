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
clk100, hdmi_p, hdmi_n
);

input clk100;
output [3:0] hdmi_p;
output [3:0] hdmi_n;


reg [0:1023] heart =

{
32'b11111111111111111111111111111111,
32'b00010001000100010001000100010001,
32'b01101101011011010110110101101101,
32'b01111101011111010111110101111101,
32'b01111101011111010111110101111101,
32'b10111011101110111011101110111011,
32'b11000111110001111100011111000111,
32'b11101111111011111110111111101111,
32'b11111111111111111111111111111111,
32'b00010001000100010001000100010001,
32'b01101101011011010110110101101101,
32'b01111101011111010111110101111101,
32'b01111101011111010111110101111101,
32'b10111011101110111011101110111011,
32'b11000111110001111100011111000111,
32'b11101111111011111110111111101111,
32'b11111111111111111111111111111111,
32'b00010001000100010001000100010001,
32'b01101101011011010110110101101101,
32'b01111101011111010111110101111101,
32'b01111101011111010111110101111101,
32'b10111011101110111011101110111011,
32'b11000111110001111100011111000111,
32'b11101111111011111110111111101111,
32'b11111111111111111111111111111111,
32'b00010001000100010001000100010001,
32'b01101101011011010110110101101101,
32'b01111101011111010111110101111101,
32'b01111101011111010111110101111101,
32'b10111011101110111011101110111011,
32'b11000111110001111100011111000111,
32'b11101111111011111110111111101111
};

reg [10:0] hcount;
reg [10:0] vcount;
reg pixel;


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

// registers for storing the horizontal & vertical counters
reg [9:0] vc;
reg [9:0] hc;
// generate sync pulses (active high)
assign vsync = (vc < vpulse);
assign hsync = (hc < hpulse);

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

always @(*) // display 100% saturation colourbars
begin
pixel = heart[hcount+vcount];
// first check if we're within vertical active video range
if (vc >= vbp && vc < vfp)
begin
// now display different colours every 80 pixels
// while we're within the active horizontal range
// -----------------
			 if (vc >= vbp && vc < (vbp+15))        vcount = 0;
		else if (vc >= (vbp+15) && vc < (vbp+30))   vcount = 32;
		else if (vc >= (vbp+30) && vc < (vbp+45))   vcount = 64;
		else if (vc >= (vbp+45) && vc < (vbp+60))   vcount = 96;
		else if (vc >= (vbp+60) && vc < (vbp+75))	vcount = 128;
		else if (vc >= (vbp+75) && vc < (vbp+90))   vcount = 160;
		else if (vc >= (vbp+90) && vc <  (vbp+105)) vcount = 192;
		else if (vc >= (vbp+105) && vc < (vbp+120)) vcount = 224;
		else if (vc >= (vbp+120) && vc < (vbp+135)) vcount = 256;
		else if (vc >= (vbp+135) && vc < (vbp+150)) vcount = 288;
		else if (vc >= (vbp+150) && vc < (vbp+165))	vcount = 320;
		else if (vc >= (vbp+165) && vc < (vbp+180)) vcount = 352;
		else if (vc >= (vbp+180) && vc < (vbp+195)) vcount = 384;
		else if (vc >= (vbp+195) && vc < (vbp+210)) vcount = 416;
		else if (vc >= (vbp+210) && vc < (vbp+225)) vcount = 448;
		else if (vc >= (vbp+225) && vc < (vbp+240)) vcount = 480;
		else if (vc >= (vbp+240) && vc < (vbp+255)) vcount = 512;
		else if (vc >= (vbp+255) && vc < (vbp+270)) vcount = 544;
		else if (vc >= (vbp+270) && vc < (vbp+285))	vcount = 576;
		else if (vc >= (vbp+285) && vc < (vbp+300)) vcount = 608;
		else if (vc >= (vbp+300) && vc < (vbp+315)) vcount = 640;
		else if (vc >= (vbp+315) && vc < (vbp+330)) vcount = 672;
		else if (vc >= (vbp+330) && vc < (vbp+345)) vcount = 704;
		else if (vc >= (vbp+345) && vc < (vbp+360)) vcount = 736;
		else if (vc >= (vbp+360) && vc < (vbp+375))	vcount = 768;
		else if (vc >= (vbp+375) && vc < (vbp+390)) vcount = 800;
		else if (vc >= (vbp+390) && vc < (vbp+405)) vcount = 832;
		else if (vc >= (vbp+405) && vc < (vbp+420)) vcount = 864;
		else if (vc >= (vbp+420) && vc < (vbp+435)) vcount = 896;
		else if (vc >= (vbp+435) && vc < (vbp+450)) vcount = 928;
		else if (vc >= (vbp+450) && vc < (vbp+465)) vcount = 960;
		else 									    vcount = 992;

// display white bar
if (hc >= hbp && hc < hfp)
begin
		if (pixel == 1'b1) begin
		//yellow
		c2_symbol = 10'b1011110000; // red
		c1_symbol = 10'b1011110000; // green
		c0_symbol = 10'b0111110000; // blue
		end
		else begin
	    //magenta
		c2_symbol = 10'b1011110000; // red
		c1_symbol = 10'b0111110000; // green
		c0_symbol = 10'b1011110000; // blue
		end
				
		
				if (hc >= hbp && hc < (hbp+20))             hcount = 0;
				else if (hc >= (hbp+20)  && hc < (hbp+40))  hcount = 1;
				else if (hc >= (hbp+40)  && hc < (hbp+60))  hcount = 2;
				else if (hc >= (hbp+60)  && hc < (hbp+80))  hcount = 3;
				else if (hc >= (hbp+80)  && hc < (hbp+100)) hcount = 4;
				else if (hc >= (hbp+100) && hc < (hbp+120)) hcount = 5;
				else if (hc >= (hbp+120) && hc < (hbp+140)) hcount = 6;
				else if (hc >= (hbp+140) && hc < (hbp+160)) hcount = 7;
				else if (hc >= (hbp+160) && hc < (hbp+180)) hcount = 8;
				else if (hc >= (hbp+180) && hc < (hbp+200)) hcount = 9;
				else if (hc >= (hbp+200) && hc < (hbp+220)) hcount = 10;
				else if (hc >= (hbp+220) && hc < (hbp+240)) hcount = 11;
				else if (hc >= (hbp+240) && hc < (hbp+260)) hcount = 12;
				else if (hc >= (hbp+260) && hc < (hbp+280)) hcount = 13;
				else if (hc >= (hbp+280) && hc < (hbp+300)) hcount = 14;
				else if (hc >= (hbp+300) && hc < (hbp+320))	hcount = 15;
 				else if (hc >= (hbp+320) && hc < (hbp+340)) hcount = 16;
				else if (hc >= (hbp+340) && hc < (hbp+360)) hcount = 17;
				else if (hc >= (hbp+360) && hc < (hbp+380)) hcount = 18;
				else if (hc >= (hbp+380) && hc < (hbp+400)) hcount = 19;
				else if (hc >= (hbp+400) && hc < (hbp+420)) hcount = 20;
				else if (hc >= (hbp+420) && hc < (hbp+440)) hcount = 21;
				else if (hc >= (hbp+440) && hc < (hbp+460)) hcount = 22;
				else if (hc >= (hbp+460) && hc < (hbp+480)) hcount = 23;
				else if (hc >= (hbp+480) && hc < (hbp+500)) hcount = 24;
				else if (hc >= (hbp+500) && hc < (hbp+520)) hcount = 25;
				else if (hc >= (hbp+520) && hc < (hbp+540)) hcount = 26;
				else if (hc >= (hbp+540) && hc < (hbp+560)) hcount = 27;
				else if (hc >= (hbp+560) && hc < (hbp+580)) hcount = 28;
				else if (hc >= (hbp+580) && hc < (hbp+600)) hcount = 29;
				else if (hc >= (hbp+600) && hc < (hbp+620)) hcount = 30;
				else                                        hcount = 31;
		
	
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
end
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
end

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