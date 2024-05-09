`default_nettype none
module tempo(
input wire clk100,
output reg half_sec_pulse,
output wire LED1,
output wire LED5
);

assign LED1 = half_sec_pulse;
assign LED5 = half_sec_pulse;

reg[25:0] div_cntr1;
reg[25:0] div_cntr2;
always@(posedge clk100)
begin
div_cntr1 <= div_cntr1 + 1;
if (div_cntr1 == 0)
if (div_cntr2 == 0)
begin
div_cntr2 <= 0;
half_sec_pulse <= ~half_sec_pulse;
end

else
div_cntr2 <= div_cntr2 + 1;
else
half_sec_pulse <= half_sec_pulse;
end

endmodule