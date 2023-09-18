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

localparam h_pixel_25 = 320;
localparam v_pixel_25 = 240;

localparam h_pixel_75 = 960;
localparam v_pixel_75 = 700;


//VGA COLOR OUT

always @(posedge clk_in) begin


if (display_en) begin


if (

h_count < h_pixel_25 + random_number_1[4:0] && v_count < v_pixel_25 + random_number_7[8:5] &&
h_count > h_pixel_25 - random_number_2[4:0] && v_count > v_pixel_25 - random_number_2[8:5] 

) begin

r_out <= random_number_1[3:0];
g_out <= random_number_5[3:0];
b_out <= random_number_9[6:4];

end

else if (

h_count < h_pixel_half + random_number_7[5:0] && v_count < v_pixel_half + random_number_7[10:5] &&
h_count > h_pixel_25 - random_number_6[5:0] && v_count > v_pixel_25 - random_number_6[10:5] 

) begin

r_out <= random_number_3[7:5];
g_out <= random_number_3[3:0];
b_out <= random_number_6[6:4];

end

else if (

h_count < h_pixel_25 + random_number_8[6:0] && v_count < v_pixel_25 + random_number_8[12:6] &&
h_count > h_pixel_half - random_number_9[6:0] && v_count > v_pixel_half - random_number_9[11:5] 

) begin

r_out <= random_number_4[7:5];
g_out <= random_number_5[3:0];
b_out <= random_number_7[6:4];

end

else if (

h_count < h_pixel_half + random_number_0[7:0] && v_count < v_pixel_half + random_number_0[7:0] &&
h_count > h_pixel_half - random_number_3[7:0] && v_count > v_pixel_half - random_number_3[11:4] 

) begin

r_out <= random_number_8[7:5];
g_out <= random_number_8[3:0];
b_out <= random_number_8[6:4];

end

else if (

h_count < h_pixel_75 + random_number_2[8:0] && v_count < v_pixel_half + random_number_2[11:3] &&
h_count > h_pixel_75 - random_number_4[8:0] && v_count > v_pixel_half - random_number_4[11:3] 

) begin

r_out <= random_number_7[7:5];
g_out <= random_number_7[3:0];
b_out <= random_number_7[6:4];

end

else if (

h_count < h_pixel_half + random_number_3[9:0] && v_count < v_pixel_75 + random_number_3[11:2] &&
h_count > h_pixel_half - random_number_8[9:0] && v_count > v_pixel_75 - random_number_8[11:2] 

) begin

r_out <= random_number_5[7:5];
g_out <= random_number_5[3:0];
b_out <= random_number_5[6:4];

end

else if (

h_count < h_pixel_75 + random_number_4[10:0] && v_count < v_pixel_75 + random_number_4[11:1] &&
h_count > h_pixel_75 - random_number_6[10:0] && v_count > v_pixel_75 - random_number_6[11:1] 

) begin

r_out <= random_number_4[7:5];
g_out <= random_number_4[3:0];
b_out <= random_number_4[6:4];

end


else begin

r_out <= random_number_2[3:0];
g_out <= random_number_3[6:4];
b_out <= random_number_4[3:0];

end

end 

else begin

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
