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


module binToHexChar(
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

parameter sig_NaN      = 3'b000;  // singnaling NaN is an operand
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


wire [47:0]  d23;
wire [47:0]  d22;
wire [47:0]  d21;
wire [47:0]  d20;
wire [47:0]  d19;
wire [47:0]  d18;
wire [47:0]  d17;
wire [47:0]  d16;
wire [47:0]  d15;
wire [47:0]  d14;
wire [47:0]  d13;
wire [47:0]  d12;
wire [47:0]  d11;
wire [47:0]  d10;
wire [47:0]  d9 ;
wire [47:0]  d8 ;
wire [47:0]  d7 ;
wire [47:0]  d6 ;
wire [47:0]  d5 ;
wire [47:0]  d4 ;
wire [47:0]  d3 ;
wire [47:0]  d2 ;
wire [47:0]  d1 ;
wire [47:0]  d0 ;

wire [32:0] d23Trunc;
wire [32:0] d22Trunc;
wire [32:0] d21Trunc;
wire [32:0] d20Trunc;
wire [32:0] d19Trunc;
wire [32:0] d18Trunc;
wire [32:0] d17Trunc;
wire [32:0] d16Trunc;
wire [32:0] d15Trunc;
wire [32:0] d14Trunc;
wire [32:0] d13Trunc;
wire [32:0] d12Trunc;
wire [32:0] d11Trunc;
wire [32:0] d10Trunc;
wire [32:0]  d9Trunc;
wire [32:0]  d8Trunc;
wire [32:0]  d7Trunc;
wire [32:0]  d6Trunc;
wire [32:0]  d5Trunc;
wire [32:0]  d4Trunc;
wire [32:0]  d3Trunc;
wire [32:0]  d2Trunc;
wire [32:0]  d1Trunc;
wire [32:0]  d0Trunc;

reg roundit;

reg [15:0] wrdata_del_0;
reg [15:0] wrdata_del_1;
reg [15:0] wrdata_del_2;

reg [47:0] Sum_q;
reg [15:0] integerPart_q0;
reg [15:0] integerPart_q1;

reg [129:0] ascOut;
reg roundit_del_1;
reg roundit_del_2;

reg inexact_del_0;
reg inexact_del_1;
reg inexact_del_2;

reg input_is_zero_del_0;
reg input_is_zero_del_1;
reg input_is_zero_del_2;

reg underflow_del_0;
reg underflow_del_1;
reg underflow_del_2;

reg overflow_del_0;
reg overflow_del_1;
reg overflow_del_2;

reg Away_del_0;
reg Away_del_1;

reg [1:0] round_mode_del_0;
reg [1:0] round_mode_del_1;

 
wire [7:0] integerDigit3;
wire [7:0] integerDigit2;
wire [7:0] integerDigit1;
wire [7:0] integerDigit0;

wire [7:0] fractDigit11;
wire [7:0] fractDigit10;
wire [7:0] fractDigit9;
wire [7:0] fractDigit8;
wire [7:0] fractDigit7;
wire [7:0] fractDigit6;
wire [7:0] fractDigit5;
wire [7:0] fractDigit4;
wire [7:0] fractDigit3;
wire [7:0] fractDigit2;
wire [7:0] fractDigit1;
wire [7:0] fractDigit0;

wire [47:0] partialSum;
wire [35:0] truncSum;

wire [2:0] GRS;

wire [4:0] exp_bin;
wire [10:0] fract_bin;   //includes "hidden" bit as MSB

wire [41:0] shiftedSource;
wire [15:0] integerPart;
wire [23:0] fractionPart;

wire input_is_subnormal;
wire input_is_zero;

assign input_is_subnormal = ~|wrdata_del_0[14:10] && |wrdata_del_0[9:0];
assign input_is_zero = ~|wrdata_del_0[14:10] && ~|wrdata_del_0[9:0];

 
assign GRS = {truncSum[32:31], |truncSum[30:0]};

assign exp_bin = input_is_subnormal ? 5'b00001 : wrdata_del_0[14:10];
assign fract_bin = (input_is_subnormal || input_is_zero) ? {1'b0, wrdata_del_0[9:0]} : {1'b1, wrdata_del_0[9:0]};   

assign shiftedSource[41:0] = fract_bin[10:0] << exp_bin;
assign integerPart[15:0] = shiftedSource[41:25];
assign fractionPart = shiftedSource[24:1];

assign d23 = fractionPart[23] ? 48'h2D79883D2000 : 48'h00000000000000;  // 48'd50000000000000
assign d22 = fractionPart[22] ? 48'h16BCC41E9000 : 48'h00000000000000;  // 48'd25000000000000
assign d21 = fractionPart[21] ? 48'h0B5E620F4800 : 48'h00000000000000;  // 48'd12500000000000
assign d20 = fractionPart[20] ? 48'h05AF3107A400 : 48'h00000000000000;  // 48'd06250000000000
assign d19 = fractionPart[19] ? 48'h02D79883D200 : 48'h00000000000000;  // 48'd03125000000000
assign d18 = fractionPart[18] ? 48'h016BCC41E900 : 48'h00000000000000;  // 48'd01562500000000
assign d17 = fractionPart[17] ? 48'h00B5E620F480 : 48'h00000000000000;  // 48'd00781250000000
assign d16 = fractionPart[16] ? 48'h005AF3107A40 : 48'h00000000000000;  // 48'd00390625000000
assign d15 = fractionPart[15] ? 48'h002D79883D20 : 48'h00000000000000;  // 48'd00195312500000
assign d14 = fractionPart[14] ? 48'h0016BCC41E90 : 48'h00000000000000;  // 48'd00097656250000
assign d13 = fractionPart[13] ? 48'h000B5E620F48 : 48'h00000000000000;  // 48'd00048828125000
assign d12 = fractionPart[12] ? 48'h0005AF3107A4 : 48'h00000000000000;  // 48'd00024414062500
assign d11 = fractionPart[11] ? 48'h0002D79883D2 : 48'h00000000000000;  // 48'd00012207031250
assign d10 = fractionPart[10] ? 48'h00016BCC41E9 : 48'h00000000000000;  // 48'd00006103515625
assign d9  = fractionPart[ 9] ? 48'h0000B5E620F4 : 48'h00000000000000;  // 48'd00003051757812   //inexact
assign d8  = fractionPart[ 8] ? 48'h00005AF3107A : 48'h00000000000000;  // 48'd00001525878906   //inexact
assign d7  = fractionPart[ 7] ? 48'h00002D79883D : 48'h00000000000000;  // 48'd00000762939453   //inexact
assign d6  = fractionPart[ 6] ? 48'h000016BCC41E : 48'h00000000000000;  // 48'd00000381469726   //inexact
assign d5  = fractionPart[ 5] ? 48'h00000B5E620F : 48'h00000000000000;  // 48'd00000190734863   //inexact
assign d4  = fractionPart[ 4] ? 48'h000005AF3107 : 48'h00000000000000;  // 48'd00000095367431   //inexact
assign d3  = fractionPart[ 3] ? 48'h000002D79883 : 48'h00000000000000;  // 48'd00000047683715   //inexact
assign d2  = fractionPart[ 2] ? 48'h0000016BCC41 : 48'h00000000000000;  // 48'd00000023841857   //inexact
assign d1  = fractionPart[ 1] ? 48'h000000B5E620 : 48'h00000000000000;  // 48'd00000011920928   //inexact
assign d0  = fractionPart[ 0] ? 48'h0000005AF310 : 48'h00000000000000;  // 48'd00000005960464   //inexact

assign d23Trunc = 33'h000000000;
assign d22Trunc = 33'h000000000;
assign d21Trunc = 33'h000000000;
assign d20Trunc = 33'h000000000;
assign d19Trunc = 33'h000000000;
assign d18Trunc = 33'h000000000;
assign d17Trunc = 33'h000000000;
assign d16Trunc = 33'h000000000;
assign d15Trunc = 33'h000000000;
assign d14Trunc = 33'h000000000;
assign d13Trunc = 33'h000000000;
assign d12Trunc = 33'h000000000;
assign d11Trunc = 33'h000000000;
assign d10Trunc = 33'h000000000;
assign  d9Trunc = fractionPart[9] ? 33'h12A05F200 : 33'h000000000;   // 33'd5000000000
assign  d8Trunc = fractionPart[8] ? 33'h09502F900 : 33'h000000000;   // 33'd2500000000
assign  d7Trunc = fractionPart[7] ? 33'h04A817C80 : 33'h000000000;   // 33'd1250000000
assign  d6Trunc = fractionPart[6] ? 33'h14F46B040 : 33'h000000000;   // 33'd5625000000
assign  d5Trunc = fractionPart[5] ? 33'h0A7A35820 : 33'h000000000;   // 33'd2812500000
assign  d4Trunc = fractionPart[4] ? 33'h17DD79E10 : 33'h000000000;   // 33'd6406250000
assign  d3Trunc = fractionPart[3] ? 33'h1E8F1C108 : 33'h000000000;   // 33'd8203125000
assign  d2Trunc = fractionPart[2] ? 33'h21E7ED284 : 33'h000000000;   // 33'd9101562500
assign  d1Trunc = fractionPart[1] ? 33'h239455B42 : 33'h000000000;   // 33'd9550781250
assign  d0Trunc = fractionPart[0] ? 33'h11CA2ADA1 : 33'h000000000;   // 33'd4775390625


wire [7:0] payload_d7_del;
wire [7:0] payload_d6_del;
wire [7:0] payload_d5_del;
wire [7:0] payload_d4_del;
wire [7:0] payload_d3_del;
wire [7:0] payload_d2_del;
wire [7:0] payload_d1_del;
wire [7:0] payload_d0_del;

//assign payload_d7_del = wrdata_del_5[7] ? 8'h31 : 8'h30;
assign payload_d7_del = wrdata_del_2[7] ? 8'h31 : 8'h30;
assign payload_d6_del = wrdata_del_2[6] ? 8'h31 : 8'h30;
assign payload_d5_del = wrdata_del_2[5] ? 8'h31 : 8'h30;
assign payload_d4_del = wrdata_del_2[4] ? 8'h31 : 8'h30;
assign payload_d3_del = wrdata_del_2[3] ? 8'h31 : 8'h30;
assign payload_d2_del = wrdata_del_2[2] ? 8'h31 : 8'h30;
assign payload_d1_del = wrdata_del_2[1] ? 8'h31 : 8'h30;
assign payload_d0_del = wrdata_del_2[0] ? 8'h31 : 8'h30;

wire input_is_infinite_del;
wire input_is_nan_del;
wire input_is_snan_del;
wire input_is_qnan_del;
wire input_sign_del;

assign input_is_infinite_del = &wrdata_del_2[14:10] && ~|wrdata_del_2[9:0];
assign input_is_nan_del = &wrdata_del_2[14:10] && |wrdata_del_2[8:0];
assign input_is_snan_del = input_is_nan_del && ~wrdata_del_2[9];
assign input_is_qnan_del = input_is_nan_del && wrdata_del_2[9];
assign input_sign_del = wrdata_del_2[15];

wire [127:0] integerFractFinal; 

assign integerFractFinal =  {integerDigit3,
                             integerDigit2,
                             integerDigit1,
                             integerDigit0,
                             fractDigit11 ,
                             fractDigit10 ,
                             fractDigit9  ,
                             fractDigit8  ,
                             fractDigit7  ,
                             fractDigit6  ,
                             fractDigit5  ,
                             fractDigit4  ,
                             fractDigit3  ,
                             fractDigit2  ,
                             fractDigit1  ,
                             fractDigit0  };
    

always @(posedge CLK or posedge RESET)
    if (RESET) Sum_q <= 48'b0;
    else Sum_q <= partialSum + truncSum[35:33] + roundit;
    
    
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
    end    
    else begin
        if (wren) wrdata_del_0 <= wrdata;
        wrdata_del_1 <= wrdata_del_0;
        wrdata_del_2 <= wrdata_del_1;
    end     
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        roundit_del_1 <= 1'b0;
        roundit_del_2 <= 1'b0;
    end
    else begin
        roundit_del_1 <= roundit;
        roundit_del_2 <= roundit_del_1;
    end
end        

always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        overflow_del_0 <= 1'b0;        
        overflow_del_1 <= 1'b0;        
        overflow_del_2 <= 1'b0;        
    end
    else begin
        overflow_del_0 <= overflow;        
        overflow_del_1 <= overflow_del_0;        
        overflow_del_2 <= overflow_del_1;        
    end    
    
always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        underflow_del_0 <= 1'b0;        
        underflow_del_1 <= 1'b0;        
        underflow_del_2 <= 1'b0;        
    end
    else begin
        underflow_del_0 <= underflow;        
        underflow_del_1 <= underflow_del_0;        
        underflow_del_2 <= underflow_del_1;        
    end    

always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        inexact_del_0 <= 1'b0;        
        inexact_del_1 <= 1'b0;        
        inexact_del_2 <= 1'b0;        
    end
    else begin
        inexact_del_0 <= inexact;        
        inexact_del_1 <= inexact_del_0;        
        inexact_del_2 <= inexact_del_1;        
    end    
  
always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        input_is_zero_del_0 <= 1'b0;        
        input_is_zero_del_1 <= 1'b0;        
        input_is_zero_del_2 <= 1'b0;        
    end
    else begin
        input_is_zero_del_0 <= input_is_zero;        
        input_is_zero_del_1 <= input_is_zero_del_0;        
        input_is_zero_del_2 <= input_is_zero_del_1;        
    end    
  
    
always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        round_mode_del_0 <= 2'b0;        
        round_mode_del_1 <= 2'b0;        
    end
    else begin
        round_mode_del_0 <= round_mode;        
        round_mode_del_1 <= round_mode_del_0;        
    end    

always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        Away_del_0 <= 1'b0;        
        Away_del_1 <= 1'b0;        
    end
    else begin
        Away_del_0 <= Away;        
        Away_del_1 <= Away_del_0;        
    end    
    

always @(posedge CLK or posedge RESET)
    if (RESET) ascOut <= 130'b0; 
    else if (input_is_infinite_del) ascOut = {1'b0, overflow_del_2, 96'h202020202020202020202020, (input_sign_del ? char_Minus : char_Plus), inf_string};
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
                                           
    else if (underflow_del_2) ascOut = {underflow_del_2, 1'b0,  integerFractFinal[127:0]};  //with this H=15 format, all underflows are inexact                                        
    else ascOut = {roundit_del_2 || inexact_del_2, roundit_del_2 || inexact_del_2, integerFractFinal[127:0]};                                       

wire [47:0] d23d22;
wire [47:0] d21d20;
wire [47:0] d19d18;
wire [47:0] d17d16;
wire [47:0] d15d14;
wire [47:0] d13d12;
wire [47:0] d11d10;
wire [47:0] d9d8;
wire [47:0] d7d6;
wire [47:0] d5d4;
wire [47:0] d3d2;
wire [47:0] d1d0;

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


reg [47:0] d23d22_d21d20;
reg [47:0] d19d18_d17d16;
reg [47:0] d15d14_d13d12;
reg [47:0] d11d10_d9d8;
reg [47:0] d7d6_d5d4;
reg [47:0] d3d2_d1d0;

always @(posedge CLK or posedge RESET)
    if (RESET) begin
        d23d22_d21d20 <= 48'b0;
        d19d18_d17d16 <= 48'b0;
        d15d14_d13d12 <= 48'b0;
        d11d10_d9d8   <= 48'b0;
        d7d6_d5d4     <= 48'b0;
        d3d2_d1d0     <= 48'b0;
     end
     else begin
        d23d22_d21d20 <= d23d22 + d21d20;   
        d19d18_d17d16 <= d19d18 + d17d16;
        d15d14_d13d12 <= d15d14 + d13d12;
        d11d10_d9d8   <= d11d10 + d9d8;    
        d7d6_d5d4     <= d7d6   + d5d4;
        d3d2_d1d0     <= d3d2   + d1d0;    
     end

wire [47:0] d23d22_d21d20_d19d18_d17d16;            
wire [47:0] d15d14_d13d12_d11d10_d9d8;
wire [47:0] d7d6_d5d4_d3d2_d1d0;

assign d23d22_d21d20_d19d18_d17d16 = d23d22_d21d20  + d19d18_d17d16;
assign d15d14_d13d12_d11d10_d9d8   = d15d14_d13d12  + d11d10_d9d8;
assign d7d6_d5d4_d3d2_d1d0         = d7d6_d5d4      + d3d2_d1d0;
 

wire [47:0] d23d22_d21d20_d19d18_d17d16__d15d14_d13d12_d11d10_d9d8;
assign      d23d22_d21d20_d19d18_d17d16__d15d14_d13d12_d11d10_d9d8 = d23d22_d21d20_d19d18_d17d16 + d15d14_d13d12_d11d10_d9d8;

assign partialSum = d23d22_d21d20_d19d18_d17d16__d15d14_d13d12_d11d10_d9d8 + d7d6_d5d4_d3d2_d1d0;
                    
                    
wire [32:0] d23Td22T;                    
wire [32:0] d21Td20T;
wire [32:0] d19Td18T;
wire [32:0] d17Td16T;
wire [32:0] d15Td14T;
wire [32:0] d13Td12T;
wire [32:0] d11Td10T;
wire [32:0] d9Td8T;
wire [32:0] d7Td6T;
wire [32:0] d5Td4T;
wire [32:0] d3Td2T;
wire [32:0] d1Td0T;
                    
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
                    
reg [32:0] d23Td22T_d21Td20T;
reg [32:0] d19Td18T_d17Td16T;
reg [32:0] d15Td14T_d13Td12T;
reg [32:0] d11Td10T_d9Td8T;                   
reg [32:0] d7Td6T_d5Td4T;
reg [32:0] d3Td2T_d1Td0T;

always @(posedge CLK or posedge RESET)
    if (RESET) begin
        d23Td22T_d21Td20T <= 33'b0;
        d19Td18T_d17Td16T <= 33'b0;
        d15Td14T_d13Td12T <= 33'b0;
        d11Td10T_d9Td8T   <= 33'b0;
        d7Td6T_d5Td4T     <= 33'b0;
        d3Td2T_d1Td0T     <= 33'b0;
    end
    else begin
        d23Td22T_d21Td20T <= d23Td22T + d21Td20T;
        d19Td18T_d17Td16T <= d19Td18T + d17Td16T;
        d15Td14T_d13Td12T <= d15Td14T + d13Td12T;
        d11Td10T_d9Td8T   <= d11Td10T + d9Td8T;  
        d7Td6T_d5Td4T     <= d7Td6T   + d5Td4T;    
        d3Td2T_d1Td0T     <= d3Td2T   + d1Td0T;    
   end 

wire [32:0] d23Td22T_d21Td20T__d19Td18T_d17Td16T;   
wire [32:0] d15Td14T_d13Td12T__d11Td10T_d9Td8T;   
wire [32:0] d7Td6T_d5Td4T__d3Td2T_d1Td0T;   

assign d23Td22T_d21Td20T__d19Td18T_d17Td16T = d23Td22T_d21Td20T + d19Td18T_d17Td16T;
assign d15Td14T_d13Td12T__d11Td10T_d9Td8T   = d15Td14T_d13Td12T + d11Td10T_d9Td8T;
assign d7Td6T_d5Td4T__d3Td2T_d1Td0T         = d7Td6T_d5Td4T + d3Td2T_d1Td0T;

wire [32:0] d23Td22T_d21Td20T_d19Td18T_d17Td16T__d15Td14T_d13Td12T_d11Td10T_d9Td8T;
assign d23Td22T_d21Td20T_d19Td18T_d17Td16T__d15Td14T_d13Td12T_d11Td10T_d9Td8T = d23Td22T_d21Td20T__d19Td18T_d17Td16T + d15Td14T_d13Td12T__d11Td10T_d9Td8T;

assign truncSum = d23Td22T_d21Td20T_d19Td18T_d17Td16T__d15Td14T_d13Td12T_d11Td10T_d9Td8T + d7Td6T_d5Td4T__d3Td2T_d1Td0T;                   


cnvTHC cnvTHC15(.nybleIn (input_sign_del ? (integerPart_q1[15:12] ^ 4'hF) : integerPart_q1[15:12]), .charOut (integerDigit3));
cnvTHC cnvTHC14(.nybleIn (input_sign_del ? (integerPart_q1[11: 8] ^ 4'hF) : integerPart_q1[11: 8]), .charOut (integerDigit2));
cnvTHC cnvTHC13(.nybleIn (input_sign_del ? (integerPart_q1[ 7: 4] ^ 4'hF) : integerPart_q1[ 7: 4]), .charOut (integerDigit1));
cnvTHC cnvTHC12(.nybleIn (input_sign_del ? (integerPart_q1[ 3: 0] ^ 4'hF) : integerPart_q1[ 3: 0]), .charOut (integerDigit0));
 
cnvTHC cnvTHC11(.nybleIn (input_sign_del ? (Sum_q[47:44] ^ 4'hF) : Sum_q[47:44]), .charOut (fractDigit11));
cnvTHC cnvTHC10(.nybleIn (input_sign_del ? (Sum_q[43:40] ^ 4'hF) : Sum_q[43:40]), .charOut (fractDigit10));                                
cnvTHC cnvTHC9 (.nybleIn (input_sign_del ? (Sum_q[39:36] ^ 4'hF) : Sum_q[39:36]), .charOut (fractDigit9 ));
cnvTHC cnvTHC8 (.nybleIn (input_sign_del ? (Sum_q[35:32] ^ 4'hF) : Sum_q[35:32]), .charOut (fractDigit8 ));
cnvTHC cnvTHC7 (.nybleIn (input_sign_del ? (Sum_q[31:28] ^ 4'hF) : Sum_q[31:28]), .charOut (fractDigit7 ));
cnvTHC cnvTHC6 (.nybleIn (input_sign_del ? (Sum_q[27:24] ^ 4'hF) : Sum_q[27:24]), .charOut (fractDigit6 ));
cnvTHC cnvTHC5 (.nybleIn (input_sign_del ? (Sum_q[23:20] ^ 4'hF) : Sum_q[23:20]), .charOut (fractDigit5 ));
cnvTHC cnvTHC4 (.nybleIn (input_sign_del ? (Sum_q[19:16] ^ 4'hF) : Sum_q[19:16]), .charOut (fractDigit4 ));
cnvTHC cnvTHC3 (.nybleIn (input_sign_del ? (Sum_q[15:12] ^ 4'hF) : Sum_q[15:12]), .charOut (fractDigit3 ));
cnvTHC cnvTHC2 (.nybleIn (input_sign_del ? (Sum_q[11: 8] ^ 4'hF) : Sum_q[11: 8]), .charOut (fractDigit2 ));
cnvTHC cnvTHC1 (.nybleIn (input_sign_del ? (Sum_q[ 7: 4] ^ 4'hF) : Sum_q[ 7: 4]), .charOut (fractDigit1 ));
cnvTHC cnvTHC0 (.nybleIn (input_sign_del ? (Sum_q[ 3: 0] ^ 4'hF) : Sum_q[ 3: 0]), .charOut (fractDigit0 ));
                   
                   
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
                   
                   

endmodule              