`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
MIT License

Copyright (c) 2021 Antonio Sánchez (@TheSonders)
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
    input wire clk,
    inout wire PS2CLK,
    inout wire PS2DTA,
    output reg  DETECTED=0,
    output reg SWAPPED=0
    );

localparam CLKFREQ=50_000_000;
localparam microseconds=(CLKFREQ/1_000_000);
localparam milliseconds=(CLKFREQ/1_000);
localparam lowCLK=100*microseconds;
localparam totalWait=20*milliseconds;

assign PS2CLK=(SWAP==0 && regCLK==0)?1'b0:
               (SWAP==1 && regDTA==0)?1'b0:1'bZ;
assign PS2DTA=(SWAP==0 && regDTA==0)?1'b0:
               (SWAP==1 && regCLK==0)?1'b0:1'bZ;

reg [$clog2(totalWait)-1:0] Counter=0;
reg [1:0]EDGE=0;
reg regCLK=0;
reg regDTA=0;
reg ENABLE=0;
reg Prev_PS2CLK=0;
reg SWAP=0;

always @(posedge clk)begin
    case (Counter)
        totalWait:  begin
                        Counter<=0;
                        ENABLE<=0;
                        if (SWAP==0)begin
                            if (EDGE==3)begin
                                DETECTED<=1;
                                SWAPPED<=0;
                            end
                            else begin
                                SWAP<=1;
                            end
                        end
                        else begin
                            if (EDGE==3)begin
                                DETECTED<=1;
                                SWAPPED<=1;
                            end
                            else begin
                                SWAP<=0;
                                DETECTED<=0;
                            end
                        end
                    end
        0:          begin
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
                                if (PS2CLK!=Prev_PS2CLK) 
                                    if (EDGE<3)EDGE<=EDGE+1;
                            end
                            else begin
                                Prev_PS2CLK<=PS2DTA;
                                if (PS2DTA!=Prev_PS2CLK)
                                    if (EDGE<3)EDGE<=EDGE+1;
                            end
                        end
                    end
    endcase
end

endmodule
