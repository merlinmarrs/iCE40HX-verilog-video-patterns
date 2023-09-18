/*
640x480 VGA singal generator
============================

- Creates h_sync,v_sync signals
- Creates display enable signal and horizontal, vertical
pixel position in display (h,v)
*/

`default_nettype none


module vga_sync(
input wire clk_in,
input wire reset,
output reg h_sync,
output reg v_sync,
output reg [11:0] h_count,
output reg [11:0] v_count,
output reg display_en
);


// Pixel counters
reg [11:0] h_counter = 0;
reg [11:0] v_counter = 0;

/*

//FOR 100MHz

localparam h_pixel_total = 3200;
localparam h_pixel_display = 2560;
localparam h_pixel_front_porch_amount = 64;
localparam h_pixel_sync_amount = 384;
localparam h_pixel_back_porch_amount = 192;

localparam v_pixel_total = 2100;
localparam v_pixel_display = 1920;
localparam v_pixel_front_porch_amount = 40;
localparam v_pixel_sync_amount = 8;
localparam v_pixel_back_porch_amount = 132;

*/

// FOR 50MHz

localparam h_pixel_total = 1600;
localparam h_pixel_display = 1280;
localparam h_pixel_front_porch_amount = 32;
localparam h_pixel_sync_amount = 192;
localparam h_pixel_back_porch_amount = 96;

localparam v_pixel_total = 1050;
localparam v_pixel_display = 960;
localparam v_pixel_front_porch_amount = 20;
localparam v_pixel_sync_amount = 4;
localparam v_pixel_back_porch_amount = 66;


/*

//FOR 25MHz

localparam h_pixel_total = 800;
localparam h_pixel_display = 640;
localparam h_pixel_front_porch_amount = 16;
localparam h_pixel_sync_amount = 96;
localparam h_pixel_back_porch_amount = 48;

localparam v_pixel_total = 525;
localparam v_pixel_display = 480;
localparam v_pixel_front_porch_amount = 10;
localparam v_pixel_sync_amount = 2;
localparam v_pixel_back_porch_amount = 33;

*/

always @(posedge clk_in) begin

if (reset) begin
//Reset counter values
h_counter <= 0;
v_counter <= 0;
display_en <= 0;
end
else
begin
// Generate display enable signal
if (h_counter < h_pixel_display && v_counter < v_pixel_display)
display_en <= 1;
else
display_en <= 0;

//Check if horizontal has arrived to the end
if (h_counter >= h_pixel_total)
begin
h_counter <= 0;
v_counter <= v_counter + 1;
end
else
//horizontal increment pixel value
h_counter <= h_counter + 1;
// check if vertical has arrived to the end
if (v_counter >= v_pixel_total)
v_counter <= 0;
end
end

always @(posedge clk_in) begin
// Check if sync_pulse needs to be created
if (h_counter >= (h_pixel_display + h_pixel_front_porch_amount)
&& h_counter < (h_pixel_display + h_pixel_front_porch_amount + h_pixel_sync_amount) )
h_sync <= 0;
else
h_sync <= 1;
// Check if sync_pulse needs to be created
if (v_counter >= (v_pixel_display + v_pixel_front_porch_amount)
&& v_counter < (v_pixel_display + v_pixel_front_porch_amount + v_pixel_sync_amount) )
v_sync <= 0;
else
v_sync <= 1;
end

// Route h_/v_counter to out
always @ (posedge clk_in) begin
h_count <= h_counter;
v_count <= v_counter;
end

endmodule