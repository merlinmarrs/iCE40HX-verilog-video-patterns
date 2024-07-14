`default_nettype none

module LFSR (
    input wire clock,
    input wire reset,
    input wire half_sec_pulse,
    output reg [12:0] rnd_0,
    output reg [12:0] rnd_1,
    output reg [12:0] rnd_2,
    output reg [12:0] rnd_3,
    output reg [12:0] rnd_4,
    output reg [12:0] rnd_5,
    output reg [12:0] rnd_6,
    output reg [12:0] rnd_7,
    output reg [12:0] rnd_8,
    output reg [12:0] rnd_9
    );

wire feedback;
reg [12:0] random, random_done_0, random_done_1, random_done_2, random_done_3, random_done_4, random_done_5, random_done_6, random_done_7, random_done_8,random_done_9;
reg [3:0] count; //to keep track of the shifts
reg [3:0] count2; //to keep track of the shifts

assign feedback = random[12] ^ random[3] ^ random[2] ^ random[0]; 

always @ (posedge clock)
begin
if (half_sec_pulse == 1 ) 
begin
rnd_0 <= random_done_0;
rnd_1 <= random_done_1;
rnd_2 <= random_done_2;
rnd_3 <= random_done_3;
rnd_4 <= random_done_4;
rnd_5 <= random_done_5;
rnd_6 <= random_done_6;
rnd_7 <= random_done_7;
rnd_8 <= random_done_8;
rnd_9 <= random_done_9;
end
else begin
rnd_0 <= rnd_0;
rnd_1 <= rnd_1;
rnd_2 <= rnd_2;
rnd_3 <= rnd_3;
rnd_4 <= rnd_4;
rnd_5 <= rnd_5;
rnd_6 <= rnd_6;
rnd_7 <= rnd_7;
rnd_8 <= rnd_8;
rnd_9 <= rnd_9;

end
end

always @ (posedge clock)
begin
 	if (reset)
 		begin
  			random <= 13'hF; //An LFSR cannot have an all 0 state, thus reset to FF
  			count <= 0;
 		end
	else
 		begin
 			if (count == 13)
				
 				begin
  					count <= 0;
      						  case(count2)
         						 4'b0000: random_done_0 = random;  
         						 4'b0001: random_done_1 = random;
          						 4'b0010: random_done_2 = random;
          					        4'b0011: random_done_3 = random;			
         						 4'b0100: random_done_4 = random;
          						 4'b0101: random_done_5 = random;
         						 4'b0111: random_done_6 = random;
          						 4'b1000: random_done_7 = random;
          					        4'b1001: random_done_8 = random;			
         						 4'b1010: random_done_9 = random;
                                              default: random_done_0 = 4'b0000;
                                              endcase
					count2  <= count2 + 1;
 				end
			else 
				begin
  					random <= {random[11:0], feedback}; //shift left the xor'd every posedge clock
  					count <= count + 1;
 				end
 		end
end 

endmodule