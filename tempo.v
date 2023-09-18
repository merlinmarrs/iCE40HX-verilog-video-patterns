`default_nettype none

module tempo(

    input wire clk,
    output reg half_sec_pulse
    );

               reg[25:0] div_cntr1;
               reg[25:0] div_cntr2;                       

               always@(posedge clk)
                              begin
                              div_cntr1 <= div_cntr1 + 1;
                              if (div_cntr1 == 0)
                                            if (div_cntr2 == 0)

                                                           begin
                                                           div_cntr2 <= 0;
                                                           half_sec_pulse <= 1; 
                                                           end
                                            else
                                                           div_cntr2 <= div_cntr2 + 1;
                              else
                                            half_sec_pulse <= 0;                            
                                       
                              end                                                            
                                                     
endmodule
