`default_nettype none

 module sine_wave_gen(clk, data_out);
//declare input and output
    input clk;
    output [7:0] data_out;
//declare the sine ROM - 30 registers each 8 bit wide.  
    reg [7:0] sine [0:29];
//Internal signals  
    integer i;  
    reg [7:0] data_out; 
//Initialize the sine rom with samples. 
    initial begin
        i = 0;
        sine[0] = 0;
        sine[1] = 16;
        sine[2] = 31;
        sine[3] = 45;
        sine[4] = 58;
        sine[5] = 67;
        sine[6] = 74;
        sine[7] = 77;
        sine[8] = 77;
        sine[9] = 74;
        sine[10] = 67;
        sine[11] = 58;
        sine[12] = 45;
        sine[13] = 31;
        sine[14] = 16;
        sine[15] = 0;
        sine[16] = -16;
        sine[17] = -31;
        sine[18] = -45;
        sine[19] = -58;
        sine[20] = -67;
        sine[21] = -74;
        sine[22] = -77;
        sine[23] = -77;
        sine[24] = -74;
        sine[25] = -67;
        sine[26] = -58;
        sine[27] = -45;
        sine[28] = -31;
        sine[29] = -16;
    end
    
    //At every positive edge of the clock, output a sine wave sample.
    always@ (posedge(clk))
    begin
        data_out = sine[i];
        i = i + 1;
        if(i == 29)
            i = 0;
    end

endmodule