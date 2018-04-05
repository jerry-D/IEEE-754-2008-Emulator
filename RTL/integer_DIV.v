 // integer_DIV.v
 `timescale 1ns/100ps
 
 // Author:  Jerry D. Harthcock
 // Version:  1.02  March 16, 2018
 // Copyright (C) 2018.  All rights reserved.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                 //
//                          SYMPL 64-BIT IEEE 754-2008 Floating-Point Emulator                                     //
//                              Evaluation and Product Development License                                         //
//                                                                                                                 //
// Provided that you comply with all the terms and conditions set forth herein, Jerry D. Harthcock ("licensor"),   //
// the original author and exclusive copyright owner of these SYMPL SYMPL 64-BIT IEEE 754-2008 Floating-Point      //
// Emulator and related development software ("this IP") hereby grants recipient of this IP ("licensee"), a        //
// world-wide, paid-up, non-exclusive license to implement this IP within the programmable fabric of Xilinx,       //
// Altera, MicroSemi or Lattice Semiconductor brand FPGAs only and used only for the purposes of evaluation,       //
// education, and development of end products and related development tools.  Furthermore, limited to the purposes //
// of prototyping, evaluation, characterization and testing of implementations in a hard, custom or semi-custom    //
// ASIC, any university or institution of higher education may have their implementation of this IP produced for   //
// said limited purposes at any foundary of their choosing provided that such prototypes do not ever wind up in    //
// commercial circulation with such license extending to said foundary and is in connection with said academic     //
// pursuit and under the supervision of said university or institution of higher education.                        //                                  
//                                                                                                                 //
// Any customization, modification, or derivative work of this IP must include an exact copy of this license       //
// and original copyright notice at the very top of each source file and derived netlist, and, in the case of      //
// binaries, a printed copy of this license and/or a text format copy in a separate file distributed with said     //
// netlists or binary files having the file name, "LICENSE.txt".  You, the licensee, also agree not to remove      //
// any copyright notices from any source file covered under this Evaluation and Product Development License.       //
//                                                                                                                 //
// LICENSOR DOES NOT WARRANT OR GUARANTEE THAT YOUR USE OF THIS IP WILL NOT INFRINGE THE RIGHTS OF OTHERS OR       //
// THAT IT IS SUITABLE OR FIT FOR ANY PURPOSE AND THAT YOU, THE LICENSEE, AGREE TO HOLD LICENSOR HARMLESS FROM     //
// ANY CLAIM BROUGHT BY YOU OR ANY THIRD PARTY FOR YOUR SUCH USE.                                                  //
//                                                                                                                 //
// Licensor reserves all his rights without prejudice, including, but in no way limited to, the right to change    //
// or modify the terms and conditions of this Evaluation and Product Development License anytime without notice    //
// of any kind to anyone. By using this IP for any purpose, you agree to all the terms and conditions set forth    //
// in this Evaluation and Product Development License.                                                             //
//                                                                                                                 //
// This Evaluation and Product Development License does not include the right to sell products that incorporate    //
// this IP or any IP derived from this IP.  If you would like to obtain such a license, please contact Licensor.   //
//                                                                                                                 //
// Licensor can be contacted at:  SYMPL.gpu@gmail.com                                                              //
//                                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  module integer_DIV(
      CLK,
      RESET,
      wren,
      wraddrs,     
      oprndA,
      oprndB,
      rdenA,
      rdaddrsA,    
      rddataA,
      rdenB,
      rdaddrsB,    
      rddataB,
      ready
      );

input CLK;
input RESET;
input wren;
input [5:0] wraddrs;
input [32:0] oprndA; //msb is sign
input [32:0] oprndB; //msb is sign
input rdenA;
input [5:0] rdaddrsA;
output [67:0] rddataA;
input rdenB;
input [5:0] rdaddrsB;
output [67:0] rddataB;
output ready;

//FloPoCo exception codes
parameter zero = 2'b00;
parameter infinity = 2'b10;
parameter NaN = 2'b11;
parameter normal = 2'b01;

reg readyA;
reg readyB;
reg [63:0] semaphor;

reg [5:0] wraddrs_del_0,
          wraddrs_del_1,
          wraddrs_del_2,
          wraddrs_del_3,
          wraddrs_del_4,
          wraddrs_del_5,
          wraddrs_del_6,
          wraddrs_del_7,
          wraddrs_del_8,
          wraddrs_del_9;
          
reg wren_del_0,          
    wren_del_1,
    wren_del_2,
    wren_del_3,
    wren_del_4,
    wren_del_5,
    wren_del_6,
    wren_del_7,
    wren_del_8,
    wren_del_9;
    
reg [39:0] fAq;
reg [39:0] fBq;

wire z_flag;
wire n_flag;
wire c_flag;
wire v_flag;
wire ready;

wire [67:0] rddataA;
wire [67:0] rddataB;

wire [39:0] fA;
wire [39:0] fB;
wire [39:0] Rdiv;
wire [32:0] iR33; 
wire [63:0] iR64;  

wire [5:0] rExp;
wire [93:0] rShifter;   
wire [31:0] rIntegerPart;

wire [4:0] leadingZerosA;
wire [4:0] leadingZerosB;
wire [4:0] A_shiftAmount;
wire [4:0] B_shiftAmount;
wire [62:0] shifterA;
wire [62:0] shifterB;
wire [62:0] A;
wire [62:0] B;
wire [5:0] expA;
wire [5:0] expB;
wire signA;
wire signB;
wire [30:0] fractionA;
wire [30:0] fractionB;

assign rExp = Rdiv[36:31]; 
assign rShifter = {1'b1, Rdiv[30:0]} << rExp;
assign rIntegerPart = rShifter[93:62];
assign iR33 = {Rdiv[37], rIntegerPart};
assign iR64 = v_flag ? 64'hFFFF_FFFF_FFFF_FFFF : {{31{iR33[32]}}, iR33[31:0]};           
assign z_flag = (Rdiv[39:38]==zero);
assign n_flag = Rdiv[37];
assign v_flag = Rdiv[39];  //set if infinity or NaN
assign c_flag = (Rdiv[39:38]==NaN); //set only if NaN
assign ready = readyA & readyB; 

assign A_shiftAmount = ~leadingZerosA;
assign B_shiftAmount = ~leadingZerosB;
assign A = {oprndA[31:0], 31'b0};
assign B = {oprndB[31:0], 31'b0};

assign shifterA = A >> A_shiftAmount;
assign shifterB = B >> B_shiftAmount;
assign expA = A_shiftAmount + 31;
assign expB = B_shiftAmount + 31;
assign signA = &oprndA[32:31];
assign signB = &oprndB[32:31];
assign fractionA = shifterA[30:0];
assign fractionB = shifterB[30:0];
assign fA = {1'b0, ~All_0_A, signA, expA, fractionA}; 
assign fB = {1'b0, ~All_0_B, signB, expB, fractionB}; 


LZC_32 LZC_32A(
    .In    (oprndA[31:0]),
    .R     (leadingZerosA),
    .All_0 (All_0_A)
    );

LZC_32 LZC_32B(
    .In    (oprndB[31:0]),
    .R     (leadingZerosB),
    .All_0 (All_0_B)
    );

always @(posedge CLK or posedge RESET) 
    if (RESET) fAq <= 40'b0;
    else fAq <= All_0_A ? {2'b00, signA, 6'b0, 31'b0} : fA;

always @(posedge CLK or posedge RESET) 
    if (RESET) fBq <= 40'b0;
    else fBq <= All_0_B ? {2'b00, signB, 6'b0, 31'b0} : fB;


FPDiv631 FPDiv631( //pipe 9 clocks deep
   .clk (CLK   ),
   .rst (RESET ),
   .X   (fAq   ),
   .Y   (fBq   ),
   .R   (Rdiv  )
   ); 

RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(68))
    ram32_integer_DIV(
    .CLK        (CLK      ),
    .wren       (wren_del_9    ),
    .wraddrs    (wraddrs_del_9 ),
    .wrdata     ({c_flag, v_flag, n_flag, z_flag, (z_flag ? 64'b0 : iR64)}),
    .rdenA      (rdenA    ),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (rddataA  ),
    .rdenB      (rdenB    ),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (rddataB  ));


always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        wraddrs_del_0 <= 6'b0;
        wraddrs_del_1 <= 6'b0;
        wraddrs_del_2 <= 6'b0;
        wraddrs_del_3 <= 6'b0;
        wraddrs_del_4 <= 6'b0;
        wraddrs_del_5 <= 6'b0;
        wraddrs_del_6 <= 6'b0;
        wraddrs_del_7 <= 6'b0;
        wraddrs_del_8 <= 6'b0;
        wraddrs_del_9 <= 6'b0;
    end
    else begin
        wraddrs_del_0 <= wraddrs;
        wraddrs_del_1 <= wraddrs_del_0;
        wraddrs_del_2 <= wraddrs_del_1;
        wraddrs_del_3 <= wraddrs_del_2;
        wraddrs_del_4 <= wraddrs_del_3;
        wraddrs_del_5 <= wraddrs_del_4;
        wraddrs_del_6 <= wraddrs_del_5;
        wraddrs_del_7 <= wraddrs_del_6;
        wraddrs_del_8 <= wraddrs_del_7;
        wraddrs_del_9 <= wraddrs_del_8;
    end
end 

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        wren_del_0 <= 6'b0;
        wren_del_1 <= 6'b0;
        wren_del_2 <= 6'b0;
        wren_del_3 <= 6'b0;
        wren_del_4 <= 6'b0;
        wren_del_5 <= 6'b0;
        wren_del_6 <= 6'b0;
        wren_del_7 <= 6'b0;
        wren_del_8 <= 6'b0;
        wren_del_9 <= 6'b0;
    end
    else begin
        wren_del_0 <= wren;
        wren_del_1 <= wren_del_0;
        wren_del_2 <= wren_del_1;
        wren_del_3 <= wren_del_2;
        wren_del_4 <= wren_del_3;
        wren_del_5 <= wren_del_4;
        wren_del_6 <= wren_del_5;
        wren_del_7 <= wren_del_6;
        wren_del_8 <= wren_del_7;
        wren_del_9 <= wren_del_8;
    end
end         

always @(posedge CLK or posedge RESET) begin
    if (RESET) semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (wren) semaphor[wraddrs] <= 1'b0;
        if (wren_del_9) semaphor[wraddrs_del_9] <= 1'b1;
    end
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        readyA <= 1'b1;
        readyB <= 1'b1;
    end  
    else begin
         readyA <= rdenA ? semaphor[rdaddrsA] : 1'b1;
         readyB <= rdenB ? semaphor[rdaddrsB] : 1'b1;
    end   
end

endmodule