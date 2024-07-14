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

//160x120
reg [0:19199] heart =

{
160'b0000000000000000000000000000000000000011111111111111111111111111111111111101111100001111110000011111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000000011111111111111111111111111111111111100000111111111111111000011100111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000000011111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000110000110001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000110000011011111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000110000011111111111111111111111111111111111111111111111111111111111111111100111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111000111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111000111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000000000001101111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000000000101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000000000111111111111111111111111001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000000001111001111111111111111111111111111111111111111111111111111111111111111111111111101111111111111111111111111111111111111111,
160'b0000000000000000000000000000000111000001111001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000010011001111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000001000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000011000000000000000101111001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000001111110000000011111111001111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000001111111110000011111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000011111111111000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000001111111111111111111111111111111111111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000001100111111111111111111111111111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000111111111111111111111111111111101111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000100000111111111111111111111111111111111111111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000111111111111111111111111111111111111111111111101111100000011111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000000000111111111111111111111111111111111111111111111111111111110001111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000110000001111111111111111111111111111111111111111111111110001111111000001111100001111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000001110000001111111111111111111111111111111111111111111111100001111111000001111110001111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000110000000011111111111111111111111111111111111111111111111000000111111100000111111000111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000100000000111111111111111111111111111111111111110111111110000000000000000001111111000000001111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000111111111111111111111111111111111111111110111111111100000000001111111111111110110000111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000111111111111111111111111111111111111111111111111111100000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000000011111101111111111111111111111111111111111111111111100011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000001100000111000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000001100011111100111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000001100011111111111111111111111111111111111111111111111110011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000110011111111111111111111111111111111111111111111111110001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000001110111111111111111111111111111111111111111111111111110001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000011110011111111111111111111111111111111111111111111111110001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000111111011111111111111111111111111111111111111111111111110001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000111111111111111111111111111111111111111111111111111111111110001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1000111011111111111111111111111111111111111111111111111111111110001111111111110011111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1100100000001111111111110111111111111111111111111110111111111100001111111111110000111011111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1100000000000111111110011111111111111111111111111100111111111100001111111111110000010001111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1000000000000111111100011111111111111111111111111000111111111000000111111111110000000000111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1000000000000111111100111111111111111111111111111100111111111100010111111111100000000000111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0000000000001111111111111111111111111111111111111111111111111111110111111111000110000100111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0111000000000111111111111111111111111111111111110110011111111111111111100010001111111110011111111111111111111111111111111111111111111111111111111111111111111111,
160'b0111100000000001011111111111111111111111111111111110011111111111101111000000001111111110001111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111110000000000011111111111111111111111111111111111011111111111100110000000000110000000011111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111110000011111111111111111111111111111111111111111111111111000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111101110001111111111111111111111111111111111111111111111011110000000000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111,
160'b1110011111001111111111111111111111111111111111111111111111111100000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111001111111111111111111111111111111111111111111111111000000000000000000000110000000000111111111111111111111111111111111111111111111111111111111111111111,
160'b1001111111000001001111111111111111111111111111111111111111111000000000000000000001111000000000011111111111111111111111111111111111111111111111111111111111111111,
160'b0001111111000001000011101111111111111111111111111111111111111110000000000000000011111110000000000111111111111111111111111111111111111111111111111111111111111111,
160'b0001111111000001100011100011111111111111111111111111111111111111100000000000000011110111100000000011111111111111111111111111111111111111111111111111111111111111,
160'b0000111111000001110011100001111111111111111111111111111111111111100000000111111111000111110000000001111111111111111111111111001111111111111111111111111111111111,
160'b1111001111110011111111110001111111111111111111111111111111111111100000001111111111011111100000000001111111111111111111111000000111111111111111111111111111111111,
160'b1111100111111011111111111110011111111111111111111111111111111111111111111111111111111111111011100001111111111111111111111000001111111111111111111111111111111111,
160'b1111100111110011111111111111111111111111111111111111111111111111111111111111111111111111111111110011111111111111111111111100011111111111111111111111111111111111,
160'b0111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100011111111111111111111111111111111111,
160'b0111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110001111111111111111111111111111111111,
160'b0111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110001111111111111111111111111111111111,
160'b0111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110001111111111111111111111111111111111,
160'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111011111111111111111111111111111111111,
160'b1111111111000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0111111111101111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b0111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111111111111111111111111111111111111100000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111111111111111111111111111111111000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111111111111111111111111111111000000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111111111111111111111111111100000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
160'b1111111111111111111111111111111111000000000000000000000001111111111111111111111111111111111111111111111111111111111111111110000111111111111111111111111111111111,
160'b1111111111111111111111111111111110000000000000000000000001111111111111111111111111111111111111111111111111111111111111111000000001111111111111111111111111111111,
160'b1111111111111111111111111111111110000000000000000000000000111111111111111111111111111111111111111111111111111111111111111000000000111111111111111111111111111111,
160'b1111111111111111111111111111111100000000000000000000000000111111111111111111111111111111111111111111111111111111111110000000000000011111111111111111111111111111,
160'b1111111111111111111111111111111000000000000000000000000000011111111111111111111111111111111111111111111111111111111110000000000000000111111111111111111111111111,
160'b1111111111111111111111111111111000000000000000000000000000001111111111111111111111111111111111111111111111111111111110000000000000000001111111111111111111111111,
160'b1111111111111111111111111111110000000000000000000000000000000111111111111111111111111111111111111111111111111111111110000000000100000000011111111111111111111111,
160'b1111111111111111111111111111110000000000000000000000000000000111111111111111111111111111111111111111111110011111111100000000000000001100000111111111111111111111,
160'b1111111111111111111111111111110000000000000000000000000000001111111111111111111111111111111111111111111000000111111100000000000000001110000011111111111111111111,
160'b1111111111111111111111111111100000000000000000000000000000011111111111111111111111111111111111111111000000000011100000000000000000001110000000111111111111111111,
160'b1111111111111111111111111111000000000000000000000000000001111111111111111111111111111111111111111110000000000000000000000000000000001111000000011111111111111111,
160'b1111111111111111111111111110000000000000000000000000000011111111111111111111111111111111111100000000000000000000000000000000000001111000000000001111111111111111,
160'b1111111111111111111111111110000000000000000000000000000111111111111111111111111111111111111000000000000000000000000000000011110011111000000100001111111111111111,
160'b1111111111111111111111111100000000000000000000000000001111111111111111111111111111001111000000000000000000000000000000100011111111111000011000111111111111111111,
160'b1111111111111111111111111000000000000000000000000000011111111111111111111111111110000000000000000000000000000000000011110000111111110000111000111111111111111111,
160'b1111111111111111111111110000000000000000000000000000111111111111111111111111111000000000000000000000000110000000001111000001111111110011110001111111111111111111,
160'b1111111111111111111111100000000000000000000000000001111111111111111111111111110000000000000000000000001100000001111000000011111111100111100011111111111111111111,
160'b1111111111111111111111000000000000000000000000000011111111111111111111111111100000000000000000000000011100000011111000001111111111000111000111111111111111111111,
160'b1111111111111111111110000000000000000000000000000111111111111111111111111111000000000000000000000000111000000111110000011111111110001110001111111111111111111111,
160'b1111111111111111111110000000000000000000000000001111111111111111111111111111000000000000000000000001110000001111110000111111111110001111111111111111111111111111,
160'b1111111111111111111100000000000000000000000000011111111111111111111111111110001011001100000000000001100000111111110011111111111100011111111111111111111111111111,
160'b1111111111111111111100000000000000000000010000111111111111111111111111111100011111111110001100000011100011111111100011111111111100111111111111111111111111111111,
160'b1111111111111111111000000000000000000000000001111111111111111111111111111000111111111110001110000111000111111111100111111111111101111111111111111111111111111111,
160'b1111111111111111110000000000000000000001000011111111111111111111111111110001111111111110001110001111001111111111000111111111111011111111111111111111111111111111,
160'b1111111111111111110000000000000000000010000111111111111111111111111111110011111111111110001111111110011111111111011111111111111111111111111111111111111001111111,
160'b1111111111111111100000000000000000000100001111111111111111111111111111101111111111111110000111111111111111111110111111111111111111111111111111111111110011111111,
160'b1111111111111111100000000000000000000000011111111111111111111111111111001111111111111111000000011111111111111111111111101111111111111111111111111111100011111111,
160'b1111111111111111000000000000000000000000111111111111111111111111111100011111111111111111100000000111111111111111111111001111111111111111111111111111100111111111
};

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

// first check if we're within vertical active video range
if (vc >= vbp && vc < vfp)
begin
// now display different colours every 80 pixels
// while we're within the active horizontal range
// -----------------

// display white bar
if (hc >= hbp && hc < hfp)
begin
		//divide hc (once in visible area) by 4, divide vc (once in visible area) by 4 and multiply by the row width
		pixel = heart[(((hc-hbp)>>2)+(((vc-vbp)>>2)*160))];
		
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