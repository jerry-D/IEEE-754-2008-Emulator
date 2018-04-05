// binToDecChar.v
 `timescale 1ns/100ps
 // Author:  Jerry D. Harthcock
 // Version:  1.02  March. 16, 2018
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


module binToDecChar(
    RESET ,
    CLK   ,
    wren,
    overflow,
    underflow,
    inexact,
    Away,
    round_mode,
    wrdata,
    ascOut
    );   

input RESET;
input CLK;
input wren;
input underflow;
input overflow;
input inexact;
input Away;
input [1:0] round_mode;
input [15:0] wrdata;
output [129:0] ascOut; //ascii string out, right-justified, padded with 8'h00 on the left

//rounding mode encodings
parameter NEAREST = 2'b00;
parameter POSINF  = 2'b01;
parameter NEGINF  = 2'b10;
parameter ZERO    = 2'b11;


// exception codes for two MSBs [18:17] of result
parameter _no_excpt_   = 2'b00;  // no exception--all good
parameter _overflow_   = 2'b01;  // the operation has overflowed--inexact is always implied--
parameter _invalid_    = 2'b01;  // a NaN will either have exception code of _no_excpt_ or _invalid_.  Read the last three bits of the NaN to determine cause of invalid exception.
parameter _underFlowExact_ = 2'b01;
parameter _underFlowInexact_  = 2'b10;  // inexact underflow (underflows that are also exact are not signaled--per IEEE754-2008, unless immediate alternate handling is enabled)
parameter _div_x_0_    = 2'b10;  // infinity never shows underflow, so we use the same except code for underflow to signal div x 0
parameter _inexact_    = 2'b11;                     

parameter sig_NaN      = 3'b000;  // signaling NaN is an operand
parameter mult_oob     = 3'b001;  // multiply operands out of bounds, multiplication(0, INF) or multiplication(?INF, 0)
parameter fsd_mult_oob = 3'b010;  // fused multiply operands out of bounds
parameter add_oob      = 3'b011;  // add or subract or fusedmultadd operands out of bounds
parameter div_oob      = 3'b100;  // division operands out of bounds, division(0, 0) or division(?INF, INF) 
parameter rem_oob      = 3'b101;  // remainder operands out of bounds, remainder(x, y), when y is zero or x is infinite (and neither is NaN)
parameter sqrt_oob     = 3'b110;  // square-root or log operand out of bounds, operand is less than zero
parameter quantize     = 3'b111;  

parameter char_0 = 8'h30;
parameter char_Plus = 8'h2B;
parameter char_Minus = 8'h2D;
parameter char_e = 8'h65;
parameter inf_string = 24'h696E66;
parameter nan_string = 24'h6E616E;
parameter snan_string = 32'h736E616E;


reg [26:0] d23;
reg [26:0]  d22;
reg [26:0]  d21;
reg [26:0]  d20;
reg [26:0]  d19;
reg [26:0]  d18;
reg [26:0]  d17;
reg [26:0]  d16;
reg [26:0]  d15;
reg [26:0]  d14;
reg [26:0]  d13;
reg [26:0]  d12;
reg [26:0]  d11;
reg [26:0]  d10;
reg [26:0]  d9 ;
reg [26:0]  d8 ;
reg [26:0]  d7 ;
reg [26:0]  d6 ;
reg [26:0]  d5 ;
reg [26:0]  d4 ;
reg [26:0]  d3 ;
reg [26:0]  d2 ;
reg [26:0]  d1 ;
reg [26:0]  d0 ;

reg [39:0] d23Trunc;
reg [39:0] d22Trunc;
reg [39:0] d21Trunc;
reg [39:0] d20Trunc;
reg [39:0] d19Trunc;
reg [39:0] d18Trunc;
reg [39:0] d17Trunc;
reg [39:0] d16Trunc;
reg [39:0] d15Trunc;
reg [39:0] d14Trunc;
reg [39:0] d13Trunc;
reg [39:0] d12Trunc;
reg [39:0] d11Trunc;
reg [39:0] d10Trunc;
reg [39:0]  d9Trunc;
reg [39:0]  d8Trunc;
reg [39:0]  d7Trunc;
reg [39:0]  d6Trunc;
reg [39:0]  d5Trunc;
reg [39:0]  d4Trunc;
reg [39:0]  d3Trunc;
reg [39:0]  d2Trunc;
reg [39:0]  d1Trunc;
reg [39:0]  d0Trunc;
reg roundit;

reg [15:0] wrdata_del_0;
reg [15:0] wrdata_del_1;
reg [15:0] wrdata_del_2;
reg [15:0] wrdata_del_3;
reg [15:0] wrdata_del_4;
reg [15:0] wrdata_del_5;

reg [26:0] Sum_q;
reg [15:0] integerPart_q0;
reg [15:0] integerPart_q1;
reg [2:0] orderBias;                   
reg [2:0] orderBias_del_1;
reg [2:0] orderBias_del_2;
reg [2:0] orderBias_del_3;
reg [2:0] orderBias_del_4;
reg [2:0] orderBias_del_5;

reg [2:0] intgrTrailZeros;
reg [3:0] fracTrailZeros;

reg [3:0] resultExponent;
reg [7:0] resultSign;
reg [7:0] expSign;

reg [31:0] expString;

reg [129:0] ascOut;
reg roundit_del_1;
reg roundit_del_2;
reg roundit_del_3;
reg roundit_del_4; 
reg roundit_del_5; 

reg inexact_del_0;
reg inexact_del_1;
reg inexact_del_2;
reg inexact_del_3;
reg inexact_del_4;
reg inexact_del_5;

reg underflow_del_0;
reg underflow_del_1;
reg underflow_del_2;
reg underflow_del_3;
reg underflow_del_4;
reg underflow_del_5;

reg overflow_del_0;
reg overflow_del_1;
reg overflow_del_2;
reg overflow_del_3;
reg overflow_del_4;
reg overflow_del_5;

reg Away_del_0;
reg Away_del_1;
reg Away_del_2;
reg Away_del_3;
reg Away_del_4;
reg Away_del_5;

reg [1:0] round_mode_del_0;
reg [1:0] round_mode_del_1;
reg [1:0] round_mode_del_2;
reg [1:0] round_mode_del_3;
reg [1:0] round_mode_del_4;
reg [1:0] round_mode_del_5;

 
wire [3:0] integerDigit4;
wire [3:0] integerDigit3;
wire [3:0] integerDigit2;
wire [3:0] integerDigit1;
wire [3:0] integerDigit0;

wire [3:0] fractDigit8;
wire [3:0] fractDigit7;
wire [3:0] fractDigit6;
wire [3:0] fractDigit5;
wire [3:0] fractDigit4;
wire [3:0] fractDigit3;
wire [3:0] fractDigit2;
wire [3:0] fractDigit1;
wire [3:0] fractDigit0;

wire [27:0] partialSum;
wire [43:0] truncSum;

wire [2:0] GRS;

wire [7:0] order;


wire [4:0] exp_bin;
wire [10:0] fract_bin;   //includes "hidden" bit as MSB

wire [41:0] shiftedSource;
wire [15:0] integerPart;
wire [23:0] fractionPart;

wire input_is_subnormal;
wire input_is_zero;

assign input_is_subnormal = ~|wrdata_del_0[14:10] && |wrdata_del_0[9:0];
assign input_is_zero = ~|wrdata_del_0[14:10] && ~|wrdata_del_0[9:0];

assign order = |integerPart[15:0] ? 8'b10000000 : {|fractionPart[23:21],  //if there is any integer part, then force 1st order
                                                   |fractionPart[20:18], 
                                                   |fractionPart[17:15], 
                                                   |fractionPart[14:11], 
                                                   |fractionPart[10:8], 
                                                   |fractionPart[7:5], 
                                                   |fractionPart[4:1], 
                                                   |fractionPart[0]};    
 
assign GRS = {truncSum[39:38], |truncSum[37:0]};

assign exp_bin = input_is_subnormal ? 5'b00001 : wrdata_del_0[14:10];
assign fract_bin = (input_is_subnormal || input_is_zero) ? {1'b0, wrdata_del_0[9:0]} : {1'b1, wrdata_del_0[9:0]};   

assign shiftedSource[41:0] = fract_bin[10:0] << exp_bin;
assign integerPart[15:0] = shiftedSource[41:25];
assign fractionPart = shiftedSource[24:1];

wire [7:0] payload_d7_del;
wire [7:0] payload_d6_del;
wire [7:0] payload_d5_del;
wire [7:0] payload_d4_del;
wire [7:0] payload_d3_del;
wire [7:0] payload_d2_del;
wire [7:0] payload_d1_del;
wire [7:0] payload_d0_del;

assign payload_d7_del = wrdata_del_5[7] ? 8'h31 : 8'h30;
assign payload_d6_del = wrdata_del_5[6] ? 8'h31 : 8'h30;
assign payload_d5_del = wrdata_del_5[5] ? 8'h31 : 8'h30;
assign payload_d4_del = wrdata_del_5[4] ? 8'h31 : 8'h30;
assign payload_d3_del = wrdata_del_5[3] ? 8'h31 : 8'h30;
assign payload_d2_del = wrdata_del_5[2] ? 8'h31 : 8'h30;
assign payload_d1_del = wrdata_del_5[1] ? 8'h31 : 8'h30;
assign payload_d0_del = wrdata_del_5[0] ? 8'h31 : 8'h30;

wire input_is_infinite_del;
wire input_is_nan_del;
wire input_is_snan_del;
wire input_is_qnan_del;
wire input_sign_del;

assign input_is_infinite_del = &wrdata_del_5[14:10] && ~|wrdata_del_5[9:0];
assign input_is_nan_del = &wrdata_del_5[14:10] && |wrdata_del_5[8:0];
assign input_is_snan_del = input_is_nan_del && ~wrdata_del_5[9];
assign input_is_qnan_del = input_is_nan_del && wrdata_del_5[9];
assign input_sign_del = wrdata_del_5[15];


always @(posedge CLK or posedge RESET)
    if (RESET) Sum_q <= 27'b0;
    else Sum_q <= partialSum + truncSum[43:40] + roundit;
    
    
always @(posedge CLK or posedge RESET)
    if (RESET)  begin
        integerPart_q0 <= 16'b0;
        integerPart_q1 <= 16'b0;
    end    
    else begin 
        integerPart_q0 <= integerPart;
        integerPart_q1 <= integerPart_q0;
    end    
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        wrdata_del_0 <= 16'b0;
        wrdata_del_1 <= 16'b0;
        wrdata_del_2 <= 16'b0;
        wrdata_del_3 <= 16'b0;
        wrdata_del_4 <= 16'b0;
        wrdata_del_5 <= 16'b0;
    end    
    else begin
        if (wren) wrdata_del_0 <= wrdata;
        wrdata_del_1 <= wrdata_del_0;
        wrdata_del_2 <= wrdata_del_1;
        wrdata_del_3 <= wrdata_del_2;
        wrdata_del_4 <= wrdata_del_3; 
        wrdata_del_5 <= wrdata_del_4;
    end     
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        roundit_del_1 <= 1'b0;
        roundit_del_2 <= 1'b0;
        roundit_del_3 <= 1'b0;
        roundit_del_4 <= 1'b0;
        roundit_del_5 <= 1'b0;
    end
    else begin
        roundit_del_1 <= roundit;
        roundit_del_2 <= roundit_del_1;
        roundit_del_3 <= roundit_del_2;
        roundit_del_4 <= roundit_del_3;
        roundit_del_5 <= roundit_del_4;
    end
end        

always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        overflow_del_0 <= 1'b0;        
        overflow_del_1 <= 1'b0;        
        overflow_del_2 <= 1'b0;        
        overflow_del_3 <= 1'b0;        
        overflow_del_4 <= 1'b0;        
        overflow_del_5 <= 1'b0;        
    end
    else begin
        overflow_del_0 <= overflow;        
        overflow_del_1 <= overflow_del_0;        
        overflow_del_2 <= overflow_del_1;        
        overflow_del_3 <= overflow_del_2;        
        overflow_del_4 <= overflow_del_3;        
        overflow_del_5 <= overflow_del_4;        
    end    
    
always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        underflow_del_0 <= 1'b0;        
        underflow_del_1 <= 1'b0;        
        underflow_del_2 <= 1'b0;        
        underflow_del_3 <= 1'b0;        
        underflow_del_4 <= 1'b0;        
        underflow_del_5 <= 1'b0;        
    end
    else begin
        underflow_del_0 <= underflow;        
        underflow_del_1 <= underflow_del_0;        
        underflow_del_2 <= underflow_del_1;        
        underflow_del_3 <= underflow_del_2;        
        underflow_del_4 <= underflow_del_3;        
        underflow_del_5 <= underflow_del_4;        
    end    



    
always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        inexact_del_0 <= 1'b0;        
        inexact_del_1 <= 1'b0;        
        inexact_del_2 <= 1'b0;        
        inexact_del_3 <= 1'b0;        
        inexact_del_4 <= 1'b0;        
        inexact_del_5 <= 1'b0;        
    end
    else begin
        inexact_del_0 <= inexact;        
        inexact_del_1 <= inexact_del_0;        
        inexact_del_2 <= inexact_del_1;        
        inexact_del_3 <= inexact_del_2;        
        inexact_del_4 <= inexact_del_3;        
        inexact_del_5 <= inexact_del_4;        
    end    
    
always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        round_mode_del_0 <= 2'b0;        
        round_mode_del_1 <= 2'b0;        
        round_mode_del_2 <= 2'b0;        
        round_mode_del_3 <= 2'b0;        
        round_mode_del_4 <= 2'b0;        
        round_mode_del_5 <= 2'b0;        
    end
    else begin
        round_mode_del_0 <= round_mode;        
        round_mode_del_1 <= round_mode_del_0;        
        round_mode_del_2 <= round_mode_del_1;        
        round_mode_del_3 <= round_mode_del_2;        
        round_mode_del_4 <= round_mode_del_3;        
        round_mode_del_5 <= round_mode_del_4;        
    end    

always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        Away_del_0 <= 1'b0;        
        Away_del_1 <= 1'b0;        
        Away_del_2 <= 1'b0;        
        Away_del_3 <= 1'b0;        
        Away_del_4 <= 1'b0;        
        Away_del_5 <= 1'b0;        
    end
    else begin
        Away_del_0 <= Away;        
        Away_del_1 <= Away_del_0;        
        Away_del_2 <= Away_del_1;        
        Away_del_3 <= Away_del_2;        
        Away_del_4 <= Away_del_3;        
        Away_del_5 <= Away_del_4;        
    end    
    
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        orderBias_del_1 <= 3'b0;
        orderBias_del_2 <= 3'b0;
        orderBias_del_3 <= 3'b0;
        orderBias_del_4 <= 3'b0;
        orderBias_del_5 <= 3'b0;
    end
    else begin
        orderBias_del_1 <= orderBias;
        orderBias_del_2 <= orderBias_del_1;
        orderBias_del_3 <= orderBias_del_2;
        orderBias_del_4 <= orderBias_del_3;
        orderBias_del_5 <= orderBias_del_4;
    end
end
    
always @(*)
    if      (|integerDigit0) intgrTrailZeros = 3'b000;
    else if (|integerDigit1) intgrTrailZeros = 3'b001;    
    else if (|integerDigit2) intgrTrailZeros = 3'b010;    
    else if (|integerDigit3) intgrTrailZeros = 3'b011;    
    else if (|integerDigit4) intgrTrailZeros = 3'b100;    
    else intgrTrailZeros = 3'b101;  
    
always @(*)
    if      (|fractDigit0) fracTrailZeros = 4'b0000;
    else if (|fractDigit1) fracTrailZeros = 4'b0001;
    else if (|fractDigit2) fracTrailZeros = 4'b0010;
    else if (|fractDigit3) fracTrailZeros = 4'b0011;
    else if (|fractDigit4) fracTrailZeros = 4'b0100;
    else if (|fractDigit5) fracTrailZeros = 4'b0101;
    else if (|fractDigit6) fracTrailZeros = 4'b0110;
    else if (|fractDigit7) fracTrailZeros = 4'b0111;
    else fracTrailZeros = 4'b1000;


reg [71:0] integerFractFinal; //9 bytes
wire [103:0] integerFractWork;    //13 bytes
reg [55:0] bitbucket;
assign integerFractWork = {{4'b0000, integerDigit4} | char_0, 
                           {4'b0000, integerDigit3} | char_0, 
                           {4'b0000, integerDigit2} | char_0, 
                           {4'b0000, integerDigit1} | char_0, 
                           {4'b0000, integerDigit0} | char_0,  
                           {4'b0000, fractDigit7}   | char_0, 
                           {4'b0000, fractDigit6}   | char_0, 
                           {4'b0000, fractDigit5}   | char_0, 
                           {4'b0000, fractDigit4}   | char_0, 
                           {4'b0000, fractDigit3}   | char_0, 
                           {4'b0000, fractDigit2}   | char_0, 
                           {4'b0000, fractDigit1}   | char_0, 
                           {4'b0000, fractDigit0}   | char_0};

always @(*)        
    if ((intgrTrailZeros==3'b101) && (fracTrailZeros==4'b1000)) begin //zero
        expSign = char_Plus;
        resultSign = input_sign_del ? char_Minus : char_Plus;    
        resultExponent = 4'b0000;
        integerFractFinal = 72'h303030303030303030;
    end    
    else if ((intgrTrailZeros==3'b000) && (fracTrailZeros==4'b1000)) begin    //integer only with no trailing zeros
        expSign = char_Plus;
        resultSign = input_sign_del ? char_Minus : char_Plus;
        resultExponent = 4'b0000;
        integerFractFinal = {32'h30303030, integerFractWork[103:64]}; 
    end
    else if (fracTrailZeros==4'b1000) begin  //integer only but with at least one trailing zero
        expSign = char_Plus;
        resultSign = input_sign_del ? char_Minus : char_Plus;
        resultExponent = {1'b0, intgrTrailZeros};
        integerFractFinal = integerFractWork[103:32] >> ((intgrTrailZeros * 8) + 64);
    end
    else begin                   //fraction part present with or without integer part
        expSign = char_Minus;
        resultSign = input_sign_del ? char_Minus : char_Plus;
        resultExponent = (8 - fracTrailZeros) + orderBias_del_5;
        {bitbucket, integerFractFinal} = {24'h303030, integerFractWork} >> (fracTrailZeros * 8);
    end    


always @(posedge CLK or posedge RESET)
    if (RESET) ascOut <= 130'b0; 
    else if (input_is_infinite_del) ascOut = {1'b0, overflow_del_5, 96'h202020202020202020202020, (input_sign_del ? char_Minus : char_Plus), inf_string};
    else if (input_is_qnan_del) ascOut = {2'b00, 16'h2020, 
                                           input_sign_del ? char_Minus : char_Plus, 
                                           nan_string, 
                                           8'h20, 
                                           payload_d7_del, 
                                           payload_d6_del,
                                           payload_d5_del,
                                           payload_d4_del,
                                           payload_d3_del,
                                           payload_d2_del,
                                           payload_d1_del,
                                           payload_d0_del};
    else if (input_is_snan_del) ascOut = {2'b00, 8'h20, 
                                           input_sign_del ? char_Minus : char_Plus, 
                                           snan_string, 
                                           8'h20, 
                                           payload_d7_del, 
                                           payload_d6_del,
                                           payload_d5_del,
                                           payload_d4_del,
                                           payload_d3_del,
                                           payload_d2_del,
                                           payload_d1_del,
                                           payload_d0_del};
                                           
    else if (underflow_del_5) ascOut = {underflow_del_5, 1'b0, 16'h2020, resultSign, integerFractFinal[71:0], expString};  //with this H=8 format, all underflows are inexact                                        
    else ascOut = {roundit_del_5 || inexact_del_5, roundit_del_5 || inexact_del_5, 16'h2020, resultSign, integerFractFinal[71:0], expString};                                       
      
always @(*)
    case(resultExponent)
        4'h0 : expString = {char_e, expSign, 16'h3030};  
        4'h1 : expString = {char_e, expSign, 16'h3031};  
        4'h2 : expString = {char_e, expSign, 16'h3032};  
        4'h3 : expString = {char_e, expSign, 16'h3033};  
        4'h4 : expString = {char_e, expSign, 16'h3034};  
        4'h5 : expString = {char_e, expSign, 16'h3035};  
        4'h6 : expString = {char_e, expSign, 16'h3036};  
        4'h7 : expString = {char_e, expSign, 16'h3037};  
        4'h8 : expString = {char_e, expSign, 16'h3038};  
        4'h9 : expString = {char_e, expSign, 16'h3039};  
        4'hA : expString = {char_e, expSign, 16'h3130};  
        4'hB : expString = {char_e, expSign, 16'h3131};  
        4'hC : expString = {char_e, expSign, 16'h3132};  
        4'hD : expString = {char_e, expSign, 16'h3133};  
        4'hE : expString = {char_e, expSign, 16'h3134};  
        4'hF : expString = {char_e, expSign, 16'h3135};  
    endcase                  

wire [26:0] d23d22;
wire [26:0] d21d20;
wire [26:0] d19d18;
wire [26:0] d17d16;
wire [26:0] d15d14;
wire [26:0] d13d12;
wire [26:0] d11d10;
wire [26:0] d9d8;
wire [26:0] d7d6;
wire [26:0] d5d4;
wire [26:0] d3d2;
wire [26:0] d1d0;

assign d23d22 = d23 + d22;
assign d21d20 = d21 + d20;
assign d19d18 = d19 + d18;
assign d17d16 = d17 + d16;
assign d15d14 = d15 + d14;
assign d13d12 = d13 + d12;
assign d11d10 = d11 + d10;
assign d9d8   = d9  + d8;  
assign d7d6   = d7  + d6;  
assign d5d4   = d5  + d4;  
assign d3d2   = d3  + d2;  
assign d1d0   = d1  + d0;  


reg [26:0] d23d22_d21d20;
reg [26:0] d19d18_d17d16;
reg [26:0] d15d14_d13d12;
reg [26:0] d11d10_d9d8;
reg [26:0] d7d6_d5d4;
reg [26:0] d3d2_d1d0;

always @(posedge CLK or posedge RESET)
    if (RESET) begin
        d23d22_d21d20 <= 27'b0;
        d19d18_d17d16 <= 27'b0;
        d15d14_d13d12 <= 27'b0;
        d11d10_d9d8   <= 27'b0;
        d7d6_d5d4     <= 27'b0;
        d3d2_d1d0     <= 27'b0;
     end
     else begin
        d23d22_d21d20 <= d23d22 + d21d20;   
        d19d18_d17d16 <= d19d18 + d17d16;
        d15d14_d13d12 <= d15d14 + d13d12;
        d11d10_d9d8   <= d11d10 + d9d8;    
        d7d6_d5d4     <= d7d6   + d5d4;
        d3d2_d1d0     <= d3d2   + d1d0;    
     end

wire [26:0] d23d22_d21d20_d19d18_d17d16;            
wire [26:0] d15d14_d13d12_d11d10_d9d8;
wire [26:0] d7d6_d5d4_d3d2_d1d0;

assign d23d22_d21d20_d19d18_d17d16 = d23d22_d21d20  + d19d18_d17d16;
assign d15d14_d13d12_d11d10_d9d8   = d15d14_d13d12  + d11d10_d9d8;
assign d7d6_d5d4_d3d2_d1d0         = d7d6_d5d4      + d3d2_d1d0;
 

wire [26:0] d23d22_d21d20_d19d18_d17d16__d15d14_d13d12_d11d10_d9d8;
assign      d23d22_d21d20_d19d18_d17d16__d15d14_d13d12_d11d10_d9d8 = d23d22_d21d20_d19d18_d17d16 + d15d14_d13d12_d11d10_d9d8;

assign partialSum = d23d22_d21d20_d19d18_d17d16__d15d14_d13d12_d11d10_d9d8 + d7d6_d5d4_d3d2_d1d0;
                    
                    
wire [43:0] d23Td22T;                    
wire [43:0] d21Td20T;
wire [43:0] d19Td18T;
wire [43:0] d17Td16T;
wire [43:0] d15Td14T;
wire [43:0] d13Td12T;
wire [43:0] d11Td10T;
wire [43:0] d9Td8T;
wire [43:0] d7Td6T;
wire [43:0] d5Td4T;
wire [43:0] d3Td2T;
wire [43:0] d1Td0T;
                    
assign d23Td22T = d23Trunc + d22Trunc;                  
assign d21Td20T = d21Trunc + d20Trunc;
assign d19Td18T = d19Trunc + d18Trunc;
assign d17Td16T = d17Trunc + d16Trunc;
assign d15Td14T = d15Trunc + d14Trunc;
assign d13Td12T = d13Trunc + d12Trunc;
assign d11Td10T = d11Trunc + d10Trunc;
assign d9Td8T   = d9Trunc  + d8Trunc;  
assign d7Td6T   = d7Trunc  + d6Trunc;  
assign d5Td4T   = d5Trunc  + d4Trunc;  
assign d3Td2T   = d3Trunc  + d2Trunc;  
assign d1Td0T   = d1Trunc  + d0Trunc;  
                    
reg [43:0] d23Td22T_d21Td20T;
reg [43:0] d19Td18T_d17Td16T;
reg [43:0] d15Td14T_d13Td12T;
reg [43:0] d11Td10T_d9Td8T;                   
reg [43:0] d7Td6T_d5Td4T;
reg [43:0] d3Td2T_d1Td0T;

always @(posedge CLK or posedge RESET)
    if (RESET) begin
        d23Td22T_d21Td20T <= 44'b0;
        d19Td18T_d17Td16T <= 44'b0;
        d15Td14T_d13Td12T <= 44'b0;
        d11Td10T_d9Td8T   <= 44'b0;
        d7Td6T_d5Td4T     <= 44'b0;
        d3Td2T_d1Td0T     <= 44'b0;
    end
    else begin
        d23Td22T_d21Td20T <= d23Td22T + d21Td20T;
        d19Td18T_d17Td16T <= d19Td18T + d17Td16T;
        d15Td14T_d13Td12T <= d15Td14T + d13Td12T;
        d11Td10T_d9Td8T   <= d11Td10T + d9Td8T;  
        d7Td6T_d5Td4T     <= d7Td6T   + d5Td4T;    
        d3Td2T_d1Td0T     <= d3Td2T   + d1Td0T;    
   end 

wire [43:0] d23Td22T_d21Td20T__d19Td18T_d17Td16T;   
wire [43:0] d15Td14T_d13Td12T__d11Td10T_d9Td8T;   
wire [43:0] d7Td6T_d5Td4T__d3Td2T_d1Td0T;   

assign d23Td22T_d21Td20T__d19Td18T_d17Td16T = d23Td22T_d21Td20T + d19Td18T_d17Td16T;
assign d15Td14T_d13Td12T__d11Td10T_d9Td8T   = d15Td14T_d13Td12T + d11Td10T_d9Td8T;
assign d7Td6T_d5Td4T__d3Td2T_d1Td0T         = d7Td6T_d5Td4T + d3Td2T_d1Td0T;

wire [43:0] d23Td22T_d21Td20T_d19Td18T_d17Td16T__d15Td14T_d13Td12T_d11Td10T_d9Td8T;
assign d23Td22T_d21Td20T_d19Td18T_d17Td16T__d15Td14T_d13Td12T_d11Td10T_d9Td8T = d23Td22T_d21Td20T__d19Td18T_d17Td16T + d15Td14T_d13Td12T__d11Td10T_d9Td8T;

assign truncSum = d23Td22T_d21Td20T_d19Td18T_d17Td16T__d15Td14T_d13Td12T_d11Td10T_d9Td8T + d7Td6T_d5Td4T__d3Td2T_d1Td0T;                   
                   
binToBCD16 BCD16(
    .RESET    (RESET        ),
    .CLK      (CLK          ),
    .binIn    (integerPart_q1),
    .decDigit4(integerDigit4),
    .decDigit3(integerDigit3),
    .decDigit2(integerDigit2),
    .decDigit1(integerDigit1),
    .decDigit0(integerDigit0)
    );

binToBCD27 BCD27(
    .RESET    (RESET    ),
    .CLK      (CLK      ),
    .binIn    (Sum_q[26:0]),
    .decDigit8(fractDigit8),
    .decDigit7(fractDigit7),
    .decDigit6(fractDigit6),
    .decDigit5(fractDigit5),
    .decDigit4(fractDigit4),
    .decDigit3(fractDigit3),
    .decDigit2(fractDigit2),
    .decDigit1(fractDigit1),
    .decDigit0(fractDigit0)
    );
                   
                   
always @(*)
        case(round_mode_del_1)
            NEAREST : if (((GRS==3'b100) && (partialSum[0] || Away_del_1) ) || (GRS[2] && |GRS[1:0]))roundit = 1'b1;    
                      else roundit = 1'b0;
            POSINF  : if (~wrdata_del_0[15] && |GRS) roundit = 1'b1;
                      else roundit = 1'b0;
            NEGINF  : if (wrdata_del_0[15] && |GRS) roundit = 1'b1;
                      else roundit = 1'b0;
            ZERO    : roundit = 1'b0;
        endcase
                   
                   
always @(*)                    
    casex(order)
        8'b1xxxxxxx : begin
                        d23 = fractionPart[23] ? 27'd50000000 : 27'd00000000; 
                        d22 = fractionPart[22] ? 27'd25000000 : 27'd00000000;
                        d21 = fractionPart[21] ? 27'd12500000 : 27'd00000000;
                        d20 = fractionPart[20] ? 27'd06250000 : 27'd00000000;
                        d19 = fractionPart[19] ? 27'd03125000 : 27'd00000000;
                        d18 = fractionPart[18] ? 27'd01562500 : 27'd00000000;
                        d17 = fractionPart[17] ? 27'd00781250 : 27'd00000000;
                        d16 = fractionPart[16] ? 27'd00390625 : 27'd00000000;
                        d15 = fractionPart[15] ? 27'd00195312 : 27'd00000000;
                        d14 = fractionPart[14] ? 27'd00097656 : 27'd00000000;
                        d13 = fractionPart[13] ? 27'd00048828 : 27'd00000000;
                        d12 = fractionPart[12] ? 27'd00024414 : 27'd00000000;
                        d11 = fractionPart[11] ? 27'd00012207 : 27'd00000000;
                        d10 = 27'd00000000;
                        d9  = 27'd00000000;
                        d8  = 27'd00000000;
                        d7  = 27'd00000000;
                        d6  = 27'd00000000;
                        d5  = 27'd00000000;
                        d4  = 27'd00000000;
                        d3  = 27'd00000000;
                        d2  = 27'd00000000;
                        d1  = 27'd00000000;
                        d0  = 27'd00000000;
                        
                        d23Trunc = 40'd000000000000;
                        d22Trunc = 40'd000000000000;
                        d21Trunc = 40'd000000000000;
                        d20Trunc = 40'd000000000000;
                        d19Trunc = 40'd000000000000;
                        d18Trunc = 40'd000000000000;
                        d17Trunc = 40'd000000000000;
                        d16Trunc = 40'd000000000000;
                        d15Trunc = fractionPart[15] ? 40'd500000000000 : 40'd000000000000;
                        d14Trunc = fractionPart[14] ? 40'd250000000000 : 40'd000000000000;
                        d13Trunc = fractionPart[13] ? 40'd125000000000 : 40'd000000000000;
                        d12Trunc = fractionPart[12] ? 40'd062500000000 : 40'd000000000000;
                        d11Trunc = fractionPart[11] ? 40'd031250000000 : 40'd000000000000;
                        d10Trunc = 40'd000000000000;
                         d9Trunc = 40'd000000000000;
                         d8Trunc = 40'd000000000000;
                         d7Trunc = 40'd000000000000;
                         d6Trunc = 40'd000000000000;
                         d5Trunc = 40'd000000000000;
                         d4Trunc = 40'd000000000000; 
                         d3Trunc = 40'd000000000000;
                         d2Trunc = 40'd000000000000;
                         d1Trunc = 40'd000000000000;
                         d0Trunc = 40'd000000000000;
                         
                         orderBias = 3'b000;
                      end 
        8'b01xxxxxx : begin
                        d23 = 27'd00000000; 
                        d22 = 27'd00000000;
                        d21 = 27'd00000000;
                        d20 = fractionPart[20] ? 27'd62500000 : 27'd00000000;
                        d19 = fractionPart[19] ? 27'd31250000 : 27'd00000000;
                        d18 = fractionPart[18] ? 27'd15625000 : 27'd00000000;
                        d17 = fractionPart[17] ? 27'd07812500 : 27'd00000000;
                        d16 = fractionPart[16] ? 27'd03906250 : 27'd00000000;
                        d15 = fractionPart[15] ? 27'd01953125 : 27'd00000000;
                        d14 = fractionPart[14] ? 27'd00976562 : 27'd00000000;
                        d13 = fractionPart[13] ? 27'd00488281 : 27'd00000000;
                        d12 = fractionPart[12] ? 27'd00244140 : 27'd00000000;
                        d11 = fractionPart[11] ? 27'd00122070 : 27'd00000000;
                        d10 = fractionPart[10] ? 27'd00061035 : 27'd00000000;
                        d9  = fractionPart[ 9] ? 27'd00030517 : 27'd00000000;
                        d8  = fractionPart[ 8] ? 27'd00015258 : 27'd00000000;
                        d7  = 27'd00000000;
                        d6  = 27'd00000000;
                        d5  = 27'd00000000;
                        d4  = 27'd00000000;
                        d3  = 27'd00000000;
                        d2  = 27'd00000000;
                        d1  = 27'd00000000;
                        d0  = 27'd00000000;
                        
                        d23Trunc = 40'd000000000000;
                        d22Trunc = 40'd000000000000;
                        d21Trunc = 40'd000000000000;
                        d20Trunc = 40'd000000000000;
                        d19Trunc = 40'd000000000000;
                        d18Trunc = 40'd000000000000;
                        d17Trunc = 40'd000000000000;
                        d16Trunc = 40'd000000000000;
                        d15Trunc = 40'd000000000000;
                        d14Trunc = fractionPart[14] ? 40'd500000000000 : 40'd000000000000;
                        d13Trunc = fractionPart[13] ? 40'd250000000000 : 40'd000000000000;
                        d12Trunc = fractionPart[12] ? 40'd625000000000 : 40'd000000000000;
                        d11Trunc = fractionPart[11] ? 40'd312500000000 : 40'd000000000000;
                        d10Trunc = fractionPart[10] ? 40'd156250000000 : 40'd000000000000;
                         d9Trunc = fractionPart[ 9] ? 40'd578125000000 : 40'd000000000000;
                         d8Trunc = fractionPart[ 8] ? 40'd789062500000 : 40'd000000000000;
                         d7Trunc = 40'd000000000000; 
                         d6Trunc = 40'd000000000000;
                         d5Trunc = 40'd000000000000;
                         d4Trunc = 40'd000000000000;  
                         d3Trunc = 40'd000000000000;
                         d2Trunc = 40'd000000000000;
                         d1Trunc = 40'd000000000000;
                         d0Trunc = 40'd000000000000;
                         
                         orderBias = 3'b001;
                      end 
        8'b001xxxxx : begin
                        d23 = 27'd00000000; 
                        d22 = 27'd00000000;
                        d21 = 27'd00000000;
                        d20 = 27'd00000000;
                        d19 = 27'd00000000;
                        d18 = 27'd00000000;
                        d17 = fractionPart[17] ? 27'd78125000 : 27'd00000000;
                        d16 = fractionPart[16] ? 27'd39062500 : 27'd00000000;
                        d15 = fractionPart[15] ? 27'd19531250 : 27'd00000000;
                        d14 = fractionPart[14] ? 27'd09765625 : 27'd00000000;
                        d13 = fractionPart[13] ? 27'd04882812 : 27'd00000000;
                        d12 = fractionPart[12] ? 27'd02441406 : 27'd00000000;
                        d11 = fractionPart[11] ? 27'd01220703 : 27'd00000000;
                        d10 = fractionPart[10] ? 27'd00610351 : 27'd00000000;
                        d9  = fractionPart[ 9] ? 27'd00305175 : 27'd00000000;
                        d8  = fractionPart[ 8] ? 27'd00152587 : 27'd00000000;
                        d7  = fractionPart[ 7] ? 27'd00076293 : 27'd00000000;
                        d6  = fractionPart[ 6] ? 27'd00038146 : 27'd00000000;
                        d5  = 27'd00000000;
                        d4  = 27'd00000000;
                        d3  = 27'd00000000;
                        d2  = 27'd00000000;
                        d1  = 27'd00000000;
                        d0  = 27'd00000000;
                        
                        d23Trunc = 40'd000000000000;
                        d22Trunc = 40'd000000000000;
                        d21Trunc = 40'd000000000000;
                        d20Trunc = 40'd000000000000;
                        d19Trunc = 40'd000000000000;
                        d18Trunc = 40'd000000000000;
                        d17Trunc = 40'd000000000000;
                        d16Trunc = 40'd000000000000;
                        d15Trunc = 40'd000000000000;
                        d14Trunc = 40'd000000000000;
                        d13Trunc = fractionPart[13] ? 40'd500000000000 : 40'd000000000000;
                        d12Trunc = fractionPart[12] ? 40'd250000000000 : 40'd000000000000;
                        d11Trunc = fractionPart[11] ? 40'd125000000000 : 40'd000000000000;
                        d10Trunc = fractionPart[10] ? 40'd562500000000 : 40'd000000000000;
                         d9Trunc = fractionPart[ 9] ? 40'd781250000000 : 40'd000000000000;
                         d8Trunc = fractionPart[ 8] ? 40'd890625000000 : 40'd000000000000;
                         d7Trunc = fractionPart[ 7] ? 40'd945312500000 : 40'd000000000000; 
                         d6Trunc = fractionPart[ 6] ? 40'd972656200000 : 40'd000000000000;
                         d5Trunc = 40'd000000000000;
                         d4Trunc = 40'd000000000000;  
                         d3Trunc = 40'd000000000000;
                         d2Trunc = 40'd000000000000;
                         d1Trunc = 40'd000000000000;
                         d0Trunc = 40'd000000000000;
                         
                         orderBias = 3'b010;
                      end 
        8'b0001xxxx : begin
                        d23 = 27'd00000000; 
                        d22 = 27'd00000000;
                        d21 = 27'd00000000;
                        d20 = 27'd00000000;
                        d19 = 27'd00000000;
                        d18 = 27'd00000000;
                        d17 = 27'd00000000;
                        d16 = 27'd00000000;
                        d15 = 27'd00000000;
                        d14 = fractionPart[14] ? 27'd97656250 : 27'd00000000;
                        d13 = fractionPart[13] ? 27'd48828125 : 27'd00000000;
                        d12 = fractionPart[12] ? 27'd24414062 : 27'd00000000;
                        d11 = fractionPart[11] ? 27'd12207031 : 27'd00000000;
                        d10 = fractionPart[10] ? 27'd06103515 : 27'd00000000;
                        d9  = fractionPart[9 ] ? 27'd03051757 : 27'd00000000;
                        d8  = fractionPart[8 ] ? 27'd01525878 : 27'd00000000;
                        d7  = fractionPart[7 ] ? 27'd00762939 : 27'd00000000;
                        d6  = fractionPart[6 ] ? 27'd00381469 : 27'd00000000;
                        d5  = fractionPart[5 ] ? 27'd00190734 : 27'd00000000;
                        d4  = fractionPart[4 ] ? 27'd00095367 : 27'd00000000;
                        d3  = fractionPart[3 ] ? 27'd00047683 : 27'd00000000;
                        d2  = fractionPart[2 ] ? 27'd00023841 : 27'd00000000;
                        d1  = fractionPart[1 ] ? 27'd00011920 : 27'd00000000;
                        d0  = 27'd00000000;
                        
                        d23Trunc = 40'd000000000000;
                        d22Trunc = 40'd000000000000;
                        d21Trunc = 40'd000000000000;
                        d20Trunc = 40'd000000000000;
                        d19Trunc = 40'd000000000000;
                        d18Trunc = 40'd000000000000;
                        d17Trunc = 40'd000000000000;
                        d16Trunc = 40'd000000000000;
                        d15Trunc = 40'd000000000000;
                        d14Trunc = 40'd000000000000;
                        d13Trunc = 40'd000000000000;
                        d12Trunc = fractionPart[12] ? 40'd500000000000 : 40'd000000000000;
                        d11Trunc = fractionPart[11] ? 40'd250000000000 : 40'd000000000000;
                        d10Trunc = fractionPart[10] ? 40'd625000000000 : 40'd000000000000;
                         d9Trunc = fractionPart[ 9] ? 40'd812500000000 : 40'd000000000000;
                         d8Trunc = fractionPart[ 8] ? 40'd906250000000 : 40'd000000000000;
                         d7Trunc = fractionPart[ 7] ? 40'd453125000000 : 40'd000000000000; 
                         d6Trunc = fractionPart[ 6] ? 40'd726562500000 : 40'd000000000000;
                         d5Trunc = fractionPart[ 5] ? 40'd863281250000 : 40'd000000000000;
                         d4Trunc = fractionPart[ 4] ? 40'd431640625000 : 40'd000000000000;  
                         d3Trunc = fractionPart[ 3] ? 40'd715820312500 : 40'd000000000000;
                         d2Trunc = fractionPart[ 2] ? 40'd857910156250 : 40'd000000000000;
                         d1Trunc = fractionPart[ 1] ? 40'd928955078125 : 40'd000000000000;
                         d0Trunc = 40'd000000000000;
                         
                         orderBias = 3'b011;
                      end 
        8'b00001xxx : begin
                        d23 = 27'd00000000; 
                        d22 = 27'd00000000;
                        d21 = 27'd00000000;
                        d20 = 27'd00000000;
                        d19 = 27'd00000000;
                        d18 = 27'd00000000;
                        d17 = 27'd00000000;
                        d16 = 27'd00000000;
                        d15 = 27'd00000000;
                        d14 = 27'd00000000;
                        d13 = 27'd00000000;
                        d12 = 27'd00000000;
                        d11 = 27'd00000000;
                        d10 = fractionPart[10] ? 27'd61035156 : 27'd00000000;
                        d9  = fractionPart[ 9] ? 27'd30517578 : 27'd00000000;
                        d8  = fractionPart[ 8] ? 27'd15258789 : 27'd00000000;
                        d7  = fractionPart[ 7] ? 27'd07629394 : 27'd00000000;
                        d6  = fractionPart[ 6] ? 27'd03814697 : 27'd00000000;
                        d5  = fractionPart[ 5] ? 27'd01907348 : 27'd00000000;
                        d4  = fractionPart[ 4] ? 27'd00953674 : 27'd00000000;
                        d3  = fractionPart[ 3] ? 27'd00476837 : 27'd00000000;
                        d2  = fractionPart[ 2] ? 27'd00238418 : 27'd00000000;
                        d1  = fractionPart[ 1] ? 27'd00119209 : 27'd00000000;
                        d0  = fractionPart[ 0] ? 27'd00059604 : 27'd00000000;
                        
                        d23Trunc = 40'd000000000000;
                        d22Trunc = 40'd000000000000;
                        d21Trunc = 40'd000000000000;
                        d20Trunc = 40'd000000000000;
                        d19Trunc = 40'd000000000000;
                        d18Trunc = 40'd000000000000;
                        d17Trunc = 40'd000000000000;
                        d16Trunc = 40'd000000000000;
                        d15Trunc = 40'd000000000000;
                        d14Trunc = 40'd000000000000;
                        d13Trunc = 40'd000000000000;
                        d12Trunc = 40'd000000000000;
                        d11Trunc = 40'd000000000000;
                        d10Trunc = fractionPart[10] ? 40'd250000000000 : 40'd000000000000;
                         d9Trunc = fractionPart[ 9] ? 40'd125000000000 : 40'd000000000000;
                         d8Trunc = fractionPart[ 8] ? 40'd062500000000 : 40'd000000000000;
                         d7Trunc = fractionPart[ 7] ? 40'd531250000000 : 40'd000000000000; 
                         d6Trunc = fractionPart[ 6] ? 40'd265625000000 : 40'd000000000000;
                         d5Trunc = fractionPart[ 5] ? 40'd632812500000 : 40'd000000000000;
                         d4Trunc = fractionPart[ 4] ? 40'd316406250000 : 40'd000000000000;  
                         d3Trunc = fractionPart[ 3] ? 40'd158203125000 : 40'd000000000000;
                         d2Trunc = fractionPart[ 2] ? 40'd579101562500 : 40'd000000000000;
                         d1Trunc = fractionPart[ 1] ? 40'd289550781250 : 40'd000000000000;
                         d0Trunc = fractionPart[ 0] ? 40'd644775390625 : 40'd000000000000;
                         
                         orderBias = 3'b100;
                      end 
        8'b000001xx : begin
                        d23 = 27'd00000000; 
                        d22 = 27'd00000000;
                        d21 = 27'd00000000;
                        d20 = 27'd00000000;
                        d19 = 27'd00000000;
                        d18 = 27'd00000000;
                        d17 = 27'd00000000;
                        d16 = 27'd00000000;
                        d15 = 27'd00000000;
                        d14 = 27'd00000000;
                        d13 = 27'd00000000;
                        d12 = 27'd00000000;
                        d11 = 27'd00000000;
                        d10 = 27'd00000000;
                        d9  = 27'd00000000;
                        d8  = 27'd00000000;
                        d7  = fractionPart[7] ? 27'd76293945 : 27'd00000000;
                        d6  = fractionPart[6] ? 27'd38146972 : 27'd00000000;
                        d5  = fractionPart[5] ? 27'd19073486 : 27'd00000000;
                        d4  = fractionPart[4] ? 27'd09536743 : 27'd00000000;
                        d3  = fractionPart[3] ? 27'd04768371 : 27'd00000000;
                        d2  = fractionPart[2] ? 27'd02384185 : 27'd00000000;
                        d1  = fractionPart[1] ? 27'd01192092 : 27'd00000000;
                        d0  = fractionPart[0] ? 27'd00596046 : 27'd00000000;
                        
                        d23Trunc = 40'd000000000000;
                        d22Trunc = 40'd000000000000;
                        d21Trunc = 40'd000000000000;
                        d20Trunc = 40'd000000000000;
                        d19Trunc = 40'd000000000000;
                        d18Trunc = 40'd000000000000;
                        d17Trunc = 40'd000000000000;
                        d16Trunc = 40'd000000000000;
                        d15Trunc = 40'd000000000000;
                        d14Trunc = 40'd000000000000;
                        d13Trunc = 40'd000000000000;
                        d12Trunc = 40'd000000000000;
                        d11Trunc = 40'd000000000000;
                        d10Trunc = 40'd000000000000;
                         d9Trunc = 40'd000000000000;
                         d8Trunc = 40'd000000000000;
                         d7Trunc = fractionPart[7] ? 40'd312500000000 : 40'd000000000000; 
                         d6Trunc = fractionPart[6] ? 40'd656250000000 : 40'd000000000000;
                         d5Trunc = fractionPart[5] ? 40'd328125000000 : 40'd000000000000;
                         d4Trunc = fractionPart[4] ? 40'd164062500000 : 40'd000000000000;  
                         d3Trunc = fractionPart[3] ? 40'd582031250000 : 40'd000000000000;
                         d2Trunc = fractionPart[2] ? 40'd791015625000 : 40'd000000000000;
                         d1Trunc = fractionPart[1] ? 40'd895507812500 : 40'd000000000000;
                         d0Trunc = fractionPart[0] ? 40'd447753906250 : 40'd000000000000;
                         
                         orderBias = 3'b101;
                      end 
        8'b0000001x : begin
                        d23 = 27'd00000000; 
                        d22 = 27'd00000000;
                        d21 = 27'd00000000;
                        d20 = 27'd00000000;
                        d19 = 27'd00000000;
                        d18 = 27'd00000000;
                        d17 = 27'd00000000;
                        d16 = 27'd00000000;
                        d15 = 27'd00000000;
                        d14 = 27'd00000000;
                        d13 = 27'd00000000;
                        d12 = 27'd00000000;
                        d11 = 27'd00000000;
                        d10 = 27'd00000000;
                        d9  = 27'd00000000;
                        d8  = 27'd00000000;
                        d7  = 27'd00000000;
                        d6  = 27'd00000000;
                        d5  = 27'd00000000;
                        d4  = fractionPart[4] ? 27'd95367431 : 27'd00000000;
                        d3  = fractionPart[3] ? 27'd47683715 : 27'd00000000;
                        d2  = fractionPart[2] ? 27'd23841857 : 27'd00000000;
                        d1  = fractionPart[1] ? 27'd11920928 : 27'd00000000;
                        d0  = fractionPart[0] ? 27'd05960464 : 27'd00000000;
                        
                        d23Trunc = 40'd000000000000;
                        d22Trunc = 40'd000000000000;
                        d21Trunc = 40'd000000000000;
                        d20Trunc = 40'd000000000000;
                        d19Trunc = 40'd000000000000;
                        d18Trunc = 40'd000000000000;
                        d17Trunc = 40'd000000000000;
                        d16Trunc = 40'd000000000000;
                        d15Trunc = 40'd000000000000;
                        d14Trunc = 40'd000000000000;
                        d13Trunc = 40'd000000000000;
                        d12Trunc = 40'd000000000000;
                        d11Trunc = 40'd000000000000;
                        d10Trunc = 40'd000000000000;
                         d9Trunc = 40'd000000000000;
                         d8Trunc = 40'd000000000000;
                         d7Trunc = 40'd000000000000; 
                         d6Trunc = 40'd000000000000;
                         d5Trunc = 40'd000000000000;
                         d4Trunc = fractionPart[4] ? 40'd640625000000 : 40'd000000000000;  
                         d3Trunc = fractionPart[3] ? 40'd820312500000 : 40'd000000000000;
                         d2Trunc = fractionPart[2] ? 40'd910156250000 : 40'd000000000000;
                         d1Trunc = fractionPart[1] ? 40'd955078125000 : 40'd000000000000;
                         d0Trunc = fractionPart[0] ? 40'd477539062500 : 40'd000000000000;
                         
                         orderBias = 3'b110;
                      end 
        8'b00000001 : begin
                        d23 = 27'd00000000; 
                        d22 = 27'd00000000;
                        d21 = 27'd00000000;
                        d20 = 27'd00000000;
                        d19 = 27'd00000000;
                        d18 = 27'd00000000;
                        d17 = 27'd00000000;
                        d16 = 27'd00000000;
                        d15 = 27'd00000000;
                        d14 = 27'd00000000;
                        d13 = 27'd00000000;
                        d12 = 27'd00000000;
                        d11 = 27'd00000000;
                        d10 = 27'd00000000;
                        d9  = 27'd00000000;
                        d8  = 27'd00000000;
                        d7  = 27'd00000000;
                        d6  = 27'd00000000;
                        d5  = 27'd00000000;
                        d4  = 27'd00000000;
                        d3  = 27'd00000000;
                        d2  = 27'd00000000;
                        d1  = 27'd00000000;
                        d0  = fractionPart[0] ? 27'd59604644 : 27'd00000000;
                        
                        d23Trunc = 40'd000000000000;
                        d22Trunc = 40'd000000000000;
                        d21Trunc = 40'd000000000000;
                        d20Trunc = 40'd000000000000;
                        d19Trunc = 40'd000000000000;
                        d18Trunc = 40'd000000000000;
                        d17Trunc = 40'd000000000000;
                        d16Trunc = 40'd000000000000;
                        d15Trunc = 40'd000000000000;
                        d14Trunc = 40'd000000000000;
                        d13Trunc = 40'd000000000000;
                        d12Trunc = 40'd000000000000;
                        d11Trunc = 40'd000000000000;
                        d10Trunc = 40'd000000000000;
                         d9Trunc = 40'd000000000000;
                         d8Trunc = 40'd000000000000;
                         d7Trunc = 40'd000000000000; 
                         d6Trunc = 40'd000000000000;
                         d5Trunc = 40'd000000000000;
                         d4Trunc = 40'd000000000000;  
                         d3Trunc = 40'd000000000000;
                         d2Trunc = 40'd000000000000;
                         d1Trunc = 40'd000000000000;
                         d0Trunc = fractionPart[0] ? 40'd775390625000 : 40'd000000000000;
                         
                         orderBias = 3'b111;
                      end 
            default : begin
                        d23 = 27'd00000000; 
                        d22 = 27'd00000000;
                        d21 = 27'd00000000;
                        d20 = 27'd00000000;
                        d19 = 27'd00000000;
                        d18 = 27'd00000000;
                        d17 = 27'd00000000;
                        d16 = 27'd00000000;
                        d15 = 27'd00000000;
                        d14 = 27'd00000000;
                        d13 = 27'd00000000;
                        d12 = 27'd00000000;
                        d11 = 27'd00000000;
                        d10 = 27'd00000000;
                        d9  = 27'd00000000;
                        d8  = 27'd00000000;
                        d7  = 27'd00000000;
                        d6  = 27'd00000000;
                        d5  = 27'd00000000;
                        d4  = 27'd00000000;
                        d3  = 27'd00000000;
                        d2  = 27'd00000000;
                        d1  = 27'd00000000;
                        d0  = 27'd00000000;
                        
                        d23Trunc = 40'd000000000000;
                        d22Trunc = 40'd000000000000;
                        d21Trunc = 40'd000000000000;
                        d20Trunc = 40'd000000000000;
                        d19Trunc = 40'd000000000000;
                        d18Trunc = 40'd000000000000;
                        d17Trunc = 40'd000000000000;
                        d16Trunc = 40'd000000000000;
                        d15Trunc = 40'd000000000000;
                        d14Trunc = 40'd000000000000;
                        d13Trunc = 40'd000000000000;
                        d12Trunc = 40'd000000000000;
                        d11Trunc = 40'd000000000000;
                        d10Trunc = 40'd000000000000;
                         d9Trunc = 40'd000000000000;
                         d8Trunc = 40'd000000000000;
                         d7Trunc = 40'd000000000000; 
                         d6Trunc = 40'd000000000000;
                         d5Trunc = 40'd000000000000;
                         d4Trunc = 40'd000000000000;  
                         d3Trunc = 40'd000000000000;
                         d2Trunc = 40'd000000000000;
                         d1Trunc = 40'd000000000000;
                         d0Trunc = 40'd000000000000;
                         
                         orderBias = 3'b000;
                      end  
    endcase                  
                  
endmodule              