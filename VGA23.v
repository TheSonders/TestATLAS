`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
/*
MIT License

Copyright (c) 2022 Antonio Sánchez (@TheSonders)

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

// ESTE WRAPPER ESTÁ AÚN EN PRUEBAS 
// Y SE PUEDE DAÑAR TU MONITOR, ¡¡¡ÚSALO BAJO TU RESPONSABILIDAD!!!
// THIS WRAPPER IS STILL IN TESTING
// AND YOUR MONITOR MAY BE DAMAGED, USE IT AT YOUR OWN RISK!!!

module VGA23(
	input wire CLKVGA,
	input wire iHS,iVS,
	input wire [2:0]iRED,
	input wire [2:0]iGREEN,
	input wire [2:0]iBLUE,
	
	output reg HS=0,
	output reg VS=0,
	output wire [1:0]RED,
	output wire [1:0]GREEN,
	output wire [1:0]BLUE);
	
	reg [5:0]rH[0:7];
	reg [5:0]rL[0:7];
	wire CLKSerial;
	
	PLLSERIAL	PLLSERIAL (
	.inclk0 ( CLKVGA ),
	.c0 ( CLKSerial )
	);
	
	initial begin
		rH[0]=6'b000000;
		rH[1]=6'b000000;
		rH[2]=6'b000000;
		rH[3]=6'b101010;
		rH[4]=6'b101010;
		rH[5]=6'b101010;
		rH[6]=6'b111111;
		rH[7]=6'b111111;
	
		rL[0]=6'b000000;
		rL[1]=6'b010010;
		rL[2]=6'b111111;
		rL[3]=6'b000000;
		rL[4]=6'b010010;
		rL[5]=6'b111111;
		rL[6]=6'b101101;
		rL[7]=6'b111111;
	end
	
	reg [5:0]REDH=0;
	reg [5:0]REDL=0;
	reg [5:0]GREENH=0;
	reg [5:0]GREENL=0;
	reg [5:0]BLUEH=0;
	reg [5:0]BLUEL=0;
	
	
	SERDESVGA	VGARedH (
	.tx_in ( REDH ),
	.tx_inclock ( CLKVGA ),
	.tx_out ( RED[1] ),
	.tx_syncclock ( CLKSerial )
	);
	SERDESVGA	VGARedL (
	.tx_in ( REDL ),
	.tx_inclock ( CLKVGA ),
	.tx_out ( RED[0] ),
	.tx_syncclock ( CLKSerial )
	);
	SERDESVGA	VGAGreenH (
	.tx_in ( GREENH ),
	.tx_inclock ( CLKVGA ),
	.tx_out ( GREEN[1] ),
	.tx_syncclock ( CLKSerial )
	);
	SERDESVGA	VGAGreenL (
	.tx_in ( GREENL ),
	.tx_inclock ( CLKVGA ),
	.tx_out ( GREEN[0] ),
	.tx_syncclock ( CLKSerial )
	);
	SERDESVGA	VGABlueH (
	.tx_in ( BLUEH ),
	.tx_inclock ( CLKVGA ),
	.tx_out ( BLUE[1] ),
	.tx_syncclock ( CLKSerial )
	);
	SERDESVGA	VGABlueL (
	.tx_in ( BLUEL ),
	.tx_inclock ( CLKVGA ),
	.tx_out ( BLUE[0] ),
	.tx_syncclock ( CLKSerial )
	);
	
	always @(posedge CLKVGA)begin
		HS<=iHS;
		VS<=iVS;
		REDH<=rH[iRED];
		REDL<=rL[iRED];
		GREENH<=rH[iGREEN];
		GREENL<=rL[iGREEN];
		BLUEH<=rH[iBLUE];
		BLUEL<=rL[iBLUE];
	end

	
	
endmodule
