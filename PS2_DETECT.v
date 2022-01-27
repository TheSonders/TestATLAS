`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
/*
MIT License

Copyright (c) 2021 Antonio S�nchez (@TheSonders)
THE EXPERIMENT GROUP (@agnuca @Nabateo @subcriticalia)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
//////////////////////////////////////////////////////////////////////////////////
module PS2_DETECT(
    input wire clk,				//12MHz
    inout wire PS2CLK,			//Direct wire from the keyboard
    inout wire PS2DTA,			//Direct wire from the keyboard
	 output wire PS2_CLOCK,		//Wire to the main core 
	 output wire PS2_DATA,		//Wire to the main core
	 output wire [5:0] LEDS		//Just for debug (LEds are Active HIGH)
    );

	assign LEDS[0]=DETECTED;
	assign LEDS[5]=SWAP;
	assign LEDS[4:1]=4'h00;
	 
localparam CLKFREQ=12_000_000;
localparam microseconds=(CLKFREQ/1_000_000);
localparam milliseconds=(CLKFREQ/1_000);
localparam startup=800*milliseconds;
localparam lowCLK=startup+(100*microseconds);
localparam totalWait=lowCLK+(20*milliseconds);

assign PS2CLK=(SWAP==0 && regCLK==0)?1'b0:
               (SWAP==1 && regDTA==0)?1'b0:1'bZ;
assign PS2DTA=(SWAP==0 && regDTA==0)?1'b0:
               (SWAP==1 && regCLK==0)?1'b0:1'bZ;
					
assign PS2_CLOCK=(DETECTED==1)?(SWAP==1)?PS2DTA:PS2CLK:1'b1;
assign PS2_DATA=(DETECTED==1)?(SWAP==1)?PS2CLK:PS2DTA:1'b1;
					

reg [$clog2(totalWait)-1:0] Counter=0;
reg [1:0]EDGE=0;
reg regCLK=0;
reg regDTA=0;
reg ENABLE=0;
reg Prev_PS2CLK=0;
reg DETECTED=0;
reg SWAP=0;


always @(posedge clk)begin
	if (DETECTED==0)begin
    case (Counter)
        totalWait:  begin
                        ENABLE<=0;									
								regDTA<=1;
								regCLK<=1;
                        if (SWAP==0)begin
                            if (EDGE==3)begin
                                DETECTED<=1;
										  Counter<=0;
                            end
                            else begin
                                SWAP<=1;
										  Counter<=(startup/2);
                            end
                        end
                        else begin
									DETECTED<=1;
									Counter<=0;
                            if (EDGE<3)begin
										SWAP<=0;										
                            end
                        end
                    end
			0:          begin
                        regDTA<=1;
                        regCLK<=1;
                        Counter<=Counter+1;
                    end 
        startup:     begin
                        regDTA<=1;
                        regCLK<=0;
                        Counter<=Counter+1;
                    end 
        lowCLK:     begin
                        regDTA<=0;
                        Counter<=Counter+1;
                    end
        (lowCLK+2): begin
                        regCLK<=1;
                        Counter<=Counter+1;
                        EDGE<=0;
                        ENABLE<=1;
                    end
        default:    begin
                        Counter<=Counter+1;
                        if (ENABLE==1)begin
                            if (SWAP==0) begin
                                Prev_PS2CLK<=PS2CLK;
                                if (PS2CLK!=Prev_PS2CLK && PS2CLK==0)begin
												if (EDGE<3)EDGE<=EDGE+1;
												else regDTA<=1;
											 end
                            end
                            else begin
                                Prev_PS2CLK<=PS2DTA;
                                if (PS2DTA!=Prev_PS2CLK && PS2DTA==0) begin
													if (EDGE<3)EDGE<=EDGE+1;
													else regDTA<=1;
												end
                            end
                        end
                    end
    endcase
	 end
end

endmodule
