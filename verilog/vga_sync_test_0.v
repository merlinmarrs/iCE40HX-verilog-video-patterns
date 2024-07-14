`default_nettype none

module vga_sync_test(

input wire clk_in,
input wire reset,

//VGA OUT
output reg [3:0] r_out,
output reg [3:0] b_out,
output reg [3:0] g_out,

output wire h_sync,
output wire v_sync

);


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

wire display_en;
wire [11:0] h_count;
wire [11:0] v_count;

localparam h_pixel_max = 1280;
localparam v_pixel_max = 960;
localparam h_pixel_half = 640;
localparam v_pixel_half = 480;

reg [4:0] increment = 0;

wire[11:0] bit_xor;
assign bit_xor = h_count[7:0]^sine_wave[7:0];
reg [9:0] a = 3'd600;

//VGA COLOR OUT

always @(posedge clk_in) begin


if (display_en) begin

increment = increment + 1;

if (h_count % 100 < random_number_0[9:0] % 100 && v_count % 100 < random_number_1[9:0] % 100) begin

r_out <= random_number_2[3:0];
g_out <= random_number_3[3:0];
b_out <= random_number_4[3:0];

end 

else begin

r_out <= random_number_5[3:0];
g_out <= random_number_6[3:0];
b_out <= random_number_7[3:0];

end 

end 

else begin

increment = increment -2;

r_out <= 4'b0000;
g_out <= 4'b0000;
b_out <= 4'b0000;
end

end 

vga_sync vga_s(
.clk_in(clk_in),
.reset(reset),
.h_sync(h_sync),
.v_sync(v_sync),
.h_count(h_count),
.v_count(v_count),
.display_en(display_en) // '1' => pixel region
);

LFSR random_s(
    .clock(clk_in),
    .reset(reset),
    .half_sec_pulse(half_sec),
    .rnd_0(random_number_0),
    .rnd_1(random_number_1),
    .rnd_2(random_number_2),
    .rnd_3(random_number_3),
    .rnd_4(random_number_4),
    .rnd_5(random_number_5),
    .rnd_6(random_number_6),
    .rnd_7(random_number_7),
    .rnd_8(random_number_8),
    .rnd_9(random_number_9)
    );

sine_wave_gen sine_wave_s(
    .clk(clk_in),
    .data_out(sine_wave)
    );

tempo tempo_s(
    .clk(clk_in),
    .half_sec_pulse(half_sec)
    );

endmodule
