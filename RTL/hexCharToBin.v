//  decCharToBin.v
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

module hexCharToBin(
    RESET,
    CLK,
    round_mode,
    Away,
    wren,
    wrdata,
    binOut
    );

input CLK;
input RESET;
input [1:0] round_mode;
input Away;
input wren;
input [127:0] wrdata;
output [17:0] binOut;

parameter char_0 = 8'h30;
parameter char_Plus = 8'h2B;
parameter char_Minus = 8'h2D;
parameter char_e = 8'h65;
parameter char_E = 8'h45;
parameter inf_string = 24'h696E66;
parameter nan_string = 24'h6E616E;
parameter snan_string = 32'h736E616E;

//rounding mode encodings
parameter NEAREST = 2'b00;
parameter POSINF  = 2'b01;
parameter NEGINF  = 2'b10;
parameter ZERO    = 2'b11;


// digit                  15        14       13         12      11      10      9       8       7       6       5       4       3       2       1     0    
//                        |         |        |          |       |       |       |       |       |       |       |       |       |       |       |     |    
// Byte position          F         E        D          C       B       A       9       8       7       6       5       4       3       2       1     0
// ascii code  hex       3x         3x       3x         3x      3x      3x      3x      3x      3x      3x      3x      3x      3x      3x      3x    3x 
//                      4/6x       4/6x     4/6x       4/6x    4/6x    4/6x    4/6x    4/6x    4/6x    4/6x    4/6x    4/6x    4/6x    4/6x    4/6x  4/6x
//                        |         |        |          |       |       |       |       |       |       |       |       |       |       |       |     |  
// entire byte        [127:120] [119:112] [111:104] [103:96] [95:88] [87:80] [79:72] [71:64] [63:56] [55:48] [47:40] [39:32] [31:24] [23:16] [15:8] [7:0]
// lower nyble only   [123:120] [115:112] [107:104]  [99:96] [91:88] [83:80] [75:72] [67:64] [59:56] [51:48] [43:40] [35:32] [27:24] [19:16] [11:8] [3:0]
//                        |         |        |          |       |       |       |       |       |       |       |       |       |       |       |     |      
// nan                   20         20       20       2B/2D    6E      61      6E      20     30/31   30/31   30/31   30/31   30/31   30/31   30/31  30/31   hex
// snan                  20         20      2B/2D      73      6E      61      6E      20     30/31   30/31   30/31   30/31   30/31   30/31   30/31  30/31   
// infinity              20         20       20        20      20      20      20      20      20      20      20      20     2B/2D     69      6E     66
// positive zero         30         30       30        30      30      30      30      30      30      30      30      30     30        30      30     30 
// negative zero         46         46       46        46      46      46      46      46      46      46      46      46     46        46      46     46                                                                                                                     
//

reg input_is_negative;

wire [63:0] inputDigitsOnly;

wire input_is_nan;
wire input_is_zero;
wire input_is_snan;
wire input_is_infinite;
wire input_is_invalid;
wire input_is_overflow;
wire input_is_good_number;
wire good_payload;
wire good_number;
wire input_is_pos_zero;
wire input_is_neg_zero;
wire input_is_pos_integer;
wire input_is_neg_integer;
wire input_is_pos_fraction;
wire input_is_neg_fraction;
wire input_is_pos_intFraction; //both integer and fraction components present
wire input_is_neg_intFraction;
wire fraction_is_all_pos_zeros;
wire fraction_is_all_neg_zeros;
wire integer_is_all_pos_zeros;
wire integer_is_all_neg_zeros;
wire input_is_negative_number;
wire [7:0] payload;


cnvFHC cnvFHC15(.charIn  (wrdata[127:120]), .nybleOut(inputDigitsOnly[63:60]));
cnvFHC cnvFHC14(.charIn  (wrdata[119:112]), .nybleOut(inputDigitsOnly[59:56]));
cnvFHC cnvFHC13(.charIn  (wrdata[111:104]), .nybleOut(inputDigitsOnly[55:52]));
cnvFHC cnvFHC12(.charIn  (wrdata[103: 96]), .nybleOut(inputDigitsOnly[51:48]));
cnvFHC cnvFHC11(.charIn  (wrdata[ 95: 88]), .nybleOut(inputDigitsOnly[47:44]));
cnvFHC cnvFHC10(.charIn  (wrdata[ 87: 80]), .nybleOut(inputDigitsOnly[43:40]));
cnvFHC cnvFHC9 (.charIn  (wrdata[ 79: 72]), .nybleOut(inputDigitsOnly[39:36]));
cnvFHC cnvFHC8 (.charIn  (wrdata[ 71: 64]), .nybleOut(inputDigitsOnly[35:32]));
cnvFHC cnvFHC7 (.charIn  (wrdata[ 63: 56]), .nybleOut(inputDigitsOnly[31:28]));
cnvFHC cnvFHC6 (.charIn  (wrdata[ 55: 48]), .nybleOut(inputDigitsOnly[27:24]));
cnvFHC cnvFHC5 (.charIn  (wrdata[ 47: 40]), .nybleOut(inputDigitsOnly[23:20]));
cnvFHC cnvFHC4 (.charIn  (wrdata[ 39: 32]), .nybleOut(inputDigitsOnly[19:16]));
cnvFHC cnvFHC3 (.charIn  (wrdata[ 31: 24]), .nybleOut(inputDigitsOnly[15:12]));
cnvFHC cnvFHC2 (.charIn  (wrdata[ 23: 16]), .nybleOut(inputDigitsOnly[11: 8]));
cnvFHC cnvFHC1 (.charIn  (wrdata[ 15:  8]), .nybleOut(inputDigitsOnly[ 7: 4]));
cnvFHC cnvFHC0 (.charIn  (wrdata[  7:  0]), .nybleOut(inputDigitsOnly[ 3: 0]));

wire [47:0] inputFractionPart;
wire [15:0] inputIntegerPart;

assign inputFractionPart = input_is_negative ? (inputDigitsOnly[47:0] ^ 48'hFFFF_FFFF_FFFF) : inputDigitsOnly[47:0];
assign inputIntegerPart = input_is_negative ? (inputDigitsOnly[63:48] ^ 16'hFFFF) : inputDigitsOnly[63:48];

assign fraction_is_all_pos_zeros = ~|inputDigitsOnly[47:0];
assign fraction_is_all_neg_zeros =  &inputDigitsOnly[47:0];  
assign integer_is_all_pos_zeros  = ~|inputDigitsOnly[63:48];
assign integer_is_all_neg_zeros  =  &inputDigitsOnly[63:48];  

assign input_is_negative_number = input_is_good_number && (fraction_is_all_neg_zeros ||  integer_is_all_neg_zeros || input_is_neg_zero || 
                                                         (fraction_is_all_neg_zeros && ~integer_is_all_neg_zeros && &inputDigitsOnly[63:60])); 
                                                                             
assign input_is_pos_integer  = input_is_good_number && fraction_is_all_pos_zeros &&  |inputDigitsOnly[63:48];
assign input_is_neg_integer  = input_is_good_number && fraction_is_all_neg_zeros && ~&inputDigitsOnly[63:48];
assign input_is_pos_fraction = input_is_good_number && integer_is_all_pos_zeros  &&  |inputDigitsOnly[47:0];
assign input_is_neg_fraction = input_is_good_number && integer_is_all_neg_zeros  && ~&inputDigitsOnly[47:0];
assign input_is_pos_intFraction = input_is_good_number && ~input_is_pos_integer && ~input_is_pos_fraction && ~input_is_pos_zero && ~input_is_negative;
assign input_is_neg_intFraction = input_is_good_number && ~input_is_neg_integer && ~input_is_neg_fraction && ~input_is_neg_zero && input_is_negative;

assign payload = {wrdata[56], wrdata[48], wrdata[40], wrdata[32], wrdata[24], wrdata[16], wrdata[8], wrdata[0]};

assign input_is_neg_zero = &inputDigitsOnly[63:0]; 

assign input_is_pos_zero = ~|inputDigitsOnly[63:0];

assign input_is_zero = input_is_neg_zero || input_is_pos_zero; 
                           
assign input_is_infinite = (wrdata[127:32]==96'h202020202020202020202020) && ((wrdata[31:24]==8'h2B) || (wrdata[31:24]==8'h2D)) && (wrdata[23:0]==24'h696e66); 

assign good_payload = (wrdata[63:60]==4'h3) && ~|wrdata[59:57] &&
                      (wrdata[55:52]==4'h3) && ~|wrdata[51:49] &&
                      (wrdata[47:44]==4'h3) && ~|wrdata[43:41] &&
                      (wrdata[39:36]==4'h3) && ~|wrdata[35:33] &&
                      (wrdata[31:28]==4'h3) && ~|wrdata[27:25] &&
                      (wrdata[23:20]==4'h3) && ~|wrdata[19:17] &&
                      (wrdata[15:12]==4'h3) && ~|wrdata[11:9]  &&
                      (wrdata[7:4]==4'h3)   && ~|wrdata[3:1]   ;

assign input_is_nan = (wrdata[127:104]==24'h202020) && ((wrdata[103:96]==8'h2B) || (wrdata[103:96]==8'h2D) || (wrdata[103:96]==8'h20)) && 
                      (wrdata[95:64]==32'h6E616E20) && good_payload;
                      
assign input_is_snan = (wrdata[127:112]==16'h2020) && ((wrdata[111:104]==8'h2B) || (wrdata[111:104]==8'h2D) || (wrdata[111:104]==8'h20)) && 
                       (wrdata[103:64]==40'h736E616E20) && good_payload; 

assign input_is_good_number = (((wrdata[127:124]==4'h3) && (wrdata[123:120] <= 4'h9)) || ((wrdata[127:126]==2'b01) && wrdata[124]==1'b0) && (wrdata[123:120] > 4'h0) && (wrdata[123:120] < 4'h7)) &&
                              (((wrdata[119:116]==4'h3) && (wrdata[115:112] <= 4'h9)) || ((wrdata[119:118]==2'b01) && wrdata[116]==1'b0) && (wrdata[115:112] > 4'h0) && (wrdata[115:112] < 4'h7)) &&
                              (((wrdata[111:108]==4'h3) && (wrdata[107:104] <= 4'h9)) || ((wrdata[111:110]==2'b01) && wrdata[108]==1'b0) && (wrdata[107:104] > 4'h0) && (wrdata[107:104] < 4'h7)) &&
                              (((wrdata[103:100]==4'h3) && (wrdata[ 99: 96] <= 4'h9)) || ((wrdata[103:102]==2'b01) && wrdata[100]==1'b0) && (wrdata[ 99: 96] > 4'h0) && (wrdata[ 99: 96] < 4'h7)) &&
                              (((wrdata[ 95: 92]==4'h3) && (wrdata[ 91: 88] <= 4'h9)) || ((wrdata[ 95: 94]==2'b01) && wrdata[ 92]==1'b0) && (wrdata[ 91: 88] > 4'h0) && (wrdata[ 91: 88] < 4'h7)) &&
                              (((wrdata[ 87: 84]==4'h3) && (wrdata[ 83: 80] <= 4'h9)) || ((wrdata[ 87: 86]==2'b01) && wrdata[ 84]==1'b0) && (wrdata[ 83: 80] > 4'h0) && (wrdata[ 83: 80] < 4'h7)) &&
                              (((wrdata[ 79: 76]==4'h3) && (wrdata[ 75: 72] <= 4'h9)) || ((wrdata[ 79: 78]==2'b01) && wrdata[ 76]==1'b0) && (wrdata[ 75: 72] > 4'h0) && (wrdata[ 75: 72] < 4'h7)) &&
                              (((wrdata[ 71: 68]==4'h3) && (wrdata[ 67: 64] <= 4'h9)) || ((wrdata[ 71: 70]==2'b01) && wrdata[ 68]==1'b0) && (wrdata[ 67: 64] > 4'h0) && (wrdata[ 67: 64] < 4'h7)) &&
                              (((wrdata[ 63: 60]==4'h3) && (wrdata[ 59: 56] <= 4'h9)) || ((wrdata[ 63: 62]==2'b01) && wrdata[ 60]==1'b0) && (wrdata[ 59: 56] > 4'h0) && (wrdata[ 59: 56] < 4'h7)) &&
                              (((wrdata[ 55: 52]==4'h3) && (wrdata[ 51: 48] <= 4'h9)) || ((wrdata[ 55: 54]==2'b01) && wrdata[ 52]==1'b0) && (wrdata[ 51: 48] > 4'h0) && (wrdata[ 51: 48] < 4'h7)) &&
                              (((wrdata[ 47: 44]==4'h3) && (wrdata[ 43: 40] <= 4'h9)) || ((wrdata[ 47: 46]==2'b01) && wrdata[ 44]==1'b0) && (wrdata[ 43: 40] > 4'h0) && (wrdata[ 43: 40] < 4'h7)) &&
                              (((wrdata[ 39: 36]==4'h3) && (wrdata[ 35: 32] <= 4'h9)) || ((wrdata[ 39: 38]==2'b01) && wrdata[ 36]==1'b0) && (wrdata[ 35: 32] > 4'h0) && (wrdata[ 35: 32] < 4'h7)) &&
                              (((wrdata[ 31: 28]==4'h3) && (wrdata[ 27: 24] <= 4'h9)) || ((wrdata[ 31: 30]==2'b01) && wrdata[ 28]==1'b0) && (wrdata[ 27: 24] > 4'h0) && (wrdata[ 27: 24] < 4'h7)) &&
                              (((wrdata[ 23: 20]==4'h3) && (wrdata[ 19: 16] <= 4'h9)) || ((wrdata[ 23: 22]==2'b01) && wrdata[ 20]==1'b0) && (wrdata[ 19: 16] > 4'h0) && (wrdata[ 19: 16] < 4'h7)) &&
                              (((wrdata[ 15: 12]==4'h3) && (wrdata[ 11:  8] <= 4'h9)) || ((wrdata[ 15: 14]==2'b01) && wrdata[ 12]==1'b0) && (wrdata[ 11:  8] > 4'h0) && (wrdata[ 11:  8] < 4'h7)) &&
                              (((wrdata[  7:  4]==4'h3) && (wrdata[  3:  0] <= 4'h9)) || ((wrdata[  7:  6]==2'b01) && wrdata[  4]==1'b0) && (wrdata[  3:  0] > 4'h0) && (wrdata[  3:  0] < 4'h7));

                              
assign input_is_invalid = ~input_is_zero     &&
                          ~input_is_nan      &&
                          ~input_is_snan     &&
                          ~input_is_infinite &&
                          ~input_is_good_number;
                          
assign input_is_overflow = (inputIntegerPart > 65504) && 
                            ~input_is_nan             &&
                            ~input_is_snan            &&
                            ~input_is_infinite        &&
                             input_is_good_number;

always @(*)
    if (input_is_nan) input_is_negative = (wrdata[103:96]==8'h2D);
    else if (input_is_infinite) input_is_negative = (wrdata[31:24]==8'h2D); 
    else input_is_negative = input_is_negative_number;

reg [15:0] integerPartBin;
reg [47:0] fractPartBin;

always @(posedge CLK or posedge RESET)
    if (RESET) begin
        integerPartBin <= 16'b0;
        fractPartBin   <= 48'b0;
    end    
    else if (wren) begin
        integerPartBin <= inputIntegerPart;
        fractPartBin   <= inputFractionPart;  
    end    

reg sign;
always @(posedge CLK or posedge RESET)
    if (RESET) sign <= 1'b0;
    else if (wren) sign <= input_is_negative;
    
reg [1:0] round_modeq;
reg [1:0] round_mode_q0;    
reg [1:0] round_mode_q1;    
reg [1:0] round_mode_q2;    
reg [1:0] round_mode_q3;    
reg [1:0] round_mode_q4;    
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        round_modeq   <= 2'b0;
        round_mode_q0 <= 2'b0;
        round_mode_q1 <= 2'b0;
        round_mode_q2 <= 2'b0;
        round_mode_q3 <= 2'b0;
        round_mode_q4 <= 2'b0;
    end
    else begin
        if (wren) round_modeq <= round_mode;
        round_mode_q0 <= round_modeq   ; 
        round_mode_q1 <= round_mode_q0; 
        round_mode_q2 <= round_mode_q1; 
        round_mode_q3 <= round_mode_q2; 
        round_mode_q4 <= round_mode_q3; 
    end                            
    
reg Awayq;
reg Away_q0;    
reg Away_q1;    
reg Away_q2;    
reg Away_q3;    
reg Away_q4;    
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        Awayq   <= 1'b0;
        Away_q0 <= 1'b0;
        Away_q1 <= 1'b0;
        Away_q2 <= 1'b0;
        Away_q3 <= 1'b0;
        Away_q4 <= 1'b0;
    end
    else begin
        if (wren) Awayq <= Away;
        Away_q0 <= Awayq   ; 
        Away_q1 <= Away_q0; 
        Away_q2 <= Away_q1; 
        Away_q3 <= Away_q2; 
        Away_q4 <= Away_q3; 
    end                            

    
reg sign_q0;    
reg sign_q1;    
reg sign_q2;    
reg sign_q3;    
reg sign_q4;    
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        sign_q0 <= 1'b0;
        sign_q1 <= 1'b0; 
        sign_q2 <= 1'b0; 
        sign_q3 <= 1'b0; 
        sign_q4 <= 1'b0; 
    end
    else begin
        sign_q0 <= sign;
        sign_q1 <= sign_q0; 
        sign_q2 <= sign_q1; 
        sign_q3 <= sign_q2; 
        sign_q4 <= sign_q3; 
    end

reg is_invalid;
reg is_invalid_q0;    
reg is_invalid_q1;    
reg is_invalid_q2;    
reg is_invalid_q3;    
reg is_invalid_q4;    
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        is_invalid    <= 1'b0;
        is_invalid_q0 <= 1'b0;
        is_invalid_q1 <= 1'b0;
        is_invalid_q2 <= 1'b0;
        is_invalid_q3 <= 1'b0;
        is_invalid_q4 <= 1'b0;
    end
    else begin
        if (wren) is_invalid <= input_is_invalid;
        is_invalid_q0 <= is_invalid   ; 
        is_invalid_q1 <= is_invalid_q0; 
        is_invalid_q2 <= is_invalid_q1; 
        is_invalid_q3 <= is_invalid_q2; 
        is_invalid_q4 <= is_invalid_q3; 
    end                            
        
reg is_nan;
reg is_nan_q0;        
reg is_nan_q1;        
reg is_nan_q2;        
reg is_nan_q3;        
reg is_nan_q4;        
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        is_nan    <= 1'b0;
        is_nan_q0 <= 1'b0;
        is_nan_q1 <= 1'b0;
        is_nan_q2 <= 1'b0;
        is_nan_q3 <= 1'b0;
        is_nan_q4 <= 1'b0;
    end
    else begin
        if (wren) is_nan <= input_is_nan;
        is_nan_q0 <= is_nan;
        is_nan_q1 <= is_nan_q0;
        is_nan_q2 <= is_nan_q1;
        is_nan_q3 <= is_nan_q2;
        is_nan_q4 <= is_nan_q3;
    end
                              
reg is_snan;
reg is_snan_q0;        
reg is_snan_q1;        
reg is_snan_q2;        
reg is_snan_q3;        
reg is_snan_q4;        
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        is_snan    <= 1'b0;
        is_snan_q0 <= 1'b0;
        is_snan_q1 <= 1'b0;
        is_snan_q2 <= 1'b0;
        is_snan_q3 <= 1'b0;
        is_snan_q4 <= 1'b0;
    end
    else begin
        if (wren) is_snan <= input_is_snan;
        is_snan_q0 <= is_snan;
        is_snan_q1 <= is_snan_q0;
        is_snan_q2 <= is_snan_q1;
        is_snan_q3 <= is_snan_q2;
        is_snan_q4 <= is_snan_q3;
    end

reg is_zero;
reg is_zero_q0;        
reg is_zero_q1;        
reg is_zero_q2;        
reg is_zero_q3;        
reg is_zero_q4;        
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        is_zero    <= 1'b0;
        is_zero_q0 <= 1'b0;
        is_zero_q1 <= 1'b0;
        is_zero_q2 <= 1'b0;
        is_zero_q3 <= 1'b0;
        is_zero_q4 <= 1'b0;
    end
    else begin
        if (wren) is_zero <= input_is_zero;
        is_zero_q0 <= is_zero;
        is_zero_q1 <= is_zero_q0;
        is_zero_q2 <= is_zero_q1;
        is_zero_q3 <= is_zero_q2;
        is_zero_q4 <= is_zero_q3;
    end

reg is_infinite;
reg is_infinite_q0;        
reg is_infinite_q1;        
reg is_infinite_q2;        
reg is_infinite_q3;        
reg is_infinite_q4;        
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        is_infinite    <= 1'b0;
        is_infinite_q0 <= 1'b0;
        is_infinite_q1 <= 1'b0;
        is_infinite_q2 <= 1'b0;
        is_infinite_q3 <= 1'b0;
        is_infinite_q4 <= 1'b0;
    end
    else begin
        if (wren) is_infinite <= input_is_infinite;
        is_infinite_q0 <= is_infinite;
        is_infinite_q1 <= is_infinite_q0;
        is_infinite_q2 <= is_infinite_q1;
        is_infinite_q3 <= is_infinite_q2;
        is_infinite_q4 <= is_infinite_q3;
    end

reg is_overflow;
reg is_overflow_q0;        
reg is_overflow_q1;        
reg is_overflow_q2;        
reg is_overflow_q3;        
reg is_overflow_q4;        
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        is_overflow    <= 1'b0;
        is_overflow_q0 <= 1'b0;
        is_overflow_q1 <= 1'b0;
        is_overflow_q2 <= 1'b0;
        is_overflow_q3 <= 1'b0;
        is_overflow_q4 <= 1'b0;
    end
    else begin
        if (wren) is_overflow <= input_is_overflow;
        is_overflow_q0 <= is_overflow;
        is_overflow_q1 <= is_overflow_q0;
        is_overflow_q2 <= is_overflow_q1;
        is_overflow_q3 <= is_overflow_q2;
        is_overflow_q4 <= is_overflow_q3;
    end

reg [7:0] payloadq;
reg [7:0] payload_q0;
reg [7:0] payload_q1;
reg [7:0] payload_q2;
reg [7:0] payload_q3;
reg [7:0] payload_q4;
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        payloadq   <= 8'b0;
        payload_q0 <= 8'b0;
        payload_q1 <= 8'b0;
        payload_q2 <= 8'b0;
        payload_q3 <= 8'b0;
        payload_q4 <= 8'b0;
    end
    else begin
        if (wren) payloadq <= payload;
        payload_q0 <= payloadq;
        payload_q1 <= payload_q0;
        payload_q2 <= payload_q1;
        payload_q3 <= payload_q2;
        payload_q4 <= payload_q3;
    end                         
    
reg [15:0] integerPartBin_q0;    
reg [15:0] integerPartBin_q1;    
reg [15:0] integerPartBin_q2;    
reg [15:0] integerPartBin_q3;    
reg [15:0] integerPartBin_q4;    
reg [15:0] integerPartBin_q5;    
reg [15:0] integerPartBin_q6;    
reg [15:0] integerPartBin_q7;
reg [15:0] integerPartBin_q8;

always @(posedge CLK or posedge RESET)
    if (RESET) begin
       integerPartBin_q0 <= 16'b0;    
       integerPartBin_q1 <= 16'b0;    
       integerPartBin_q2 <= 16'b0;    
       integerPartBin_q3 <= 16'b0;    
       integerPartBin_q4 <= 16'b0;    
       integerPartBin_q5 <= 16'b0;    
       integerPartBin_q6 <= 16'b0;    
       integerPartBin_q7 <= 16'b0;
       integerPartBin_q8 <= 16'b0;
    end   
    else begin
       integerPartBin_q0 <= integerPartBin;    
       integerPartBin_q1 <= integerPartBin_q0;    
       integerPartBin_q2 <= integerPartBin_q1;    
       integerPartBin_q3 <= integerPartBin_q2;    
       integerPartBin_q4 <= integerPartBin_q3;    
       integerPartBin_q5 <= integerPartBin_q4;    
       integerPartBin_q6 <= integerPartBin_q5;    
       integerPartBin_q7 <= integerPartBin_q6;
       integerPartBin_q8 <= integerPartBin_q7;
    end
    
    
//  complete weights
//  d23 = .500000000000000000000000
//  d22 = .250000000000000000000000
//  d21 = .125000000000000000000000
//  d20 = .062500000000000000000000
//  d19 = .031250000000000000000000
//  d18 = .015625000000000000000000
//  d17 = .007812500000000000000000
//  d16 = .003906250000000000000000
//  d15 = .001953125000000000000000
//  d14 = .000976562500000000000000
//  d13 = .000488281250000000000000
//  d12 = .000244140625000000000000
//  d11 = .000122070312500000000000
//  d10 = .000061035156250000000000
//  d9  = .000030517578125000000000
//  d8  = .000015258789062500000000   
//  d7  = .000007629394531250000000 
//  d6  = .000003814697265625000000   
//  d5  = .000001907348632812500000   
//  d4  = .000000953674316406250000
//  d3  = .000000476837158203125000   
//  d2  = .000000238418579101562500   
//  d1  = .000000119209289550781250
//  d0  = .000000059604644775390625   
//                                     

wire weightSel_1stOrderq;
wire weightSel_2ndOrderq;
wire weightSel_3rdOrderq;
wire weightSel_4thOrderq;
wire weightSel_5thOrderq;
wire weightSel_6thOrderq;
wire weightSel_7thOrderq;
wire weightSel_8thOrderq;
wire weightSel_9thOrderq;
wire weightSel_10thOrderq;
wire weightSel_11thOrderq;
wire weightSel_12thOrderq;
wire weightSel_13thOrderq;
wire weightSel_14thOrderq;
 
assign weightSel_1stOrderq  = (fractPartBin >= 48'h2D79883D2000); //48'd50000000000000
assign weightSel_2ndOrderq  = (fractPartBin >= 48'h16BCC41E9000); //48'd25000000000000
assign weightSel_3rdOrderq  = (fractPartBin >= 48'h0B5E620F4800); //48'd12500000000000
assign weightSel_4thOrderq  = (fractPartBin >= 48'h05AF3107A400); //48'd06250000000000
assign weightSel_5thOrderq  = (fractPartBin >= 48'h02D79883D200); //48'd03125000000000
assign weightSel_6thOrderq  = (fractPartBin >= 48'h016BCC41E900); //48'd01562500000000
assign weightSel_7thOrderq  = (fractPartBin >= 48'h00B5E620F480); //48'd00781250000000
assign weightSel_8thOrderq  = (fractPartBin >= 48'h005AF3107A40); //48'd00390625000000
assign weightSel_9thOrderq  = (fractPartBin >= 48'h002D79883D20); //48'd00195312500000
assign weightSel_10thOrderq = (fractPartBin >= 48'h0016BCC41E90); //48'd00097656250000
assign weightSel_11thOrderq = (fractPartBin >= 48'h000B5E620F48); //48'd00048828125000
assign weightSel_12thOrderq = (fractPartBin >= 48'h0005AF3107A4); //48'd00024414062500       
assign weightSel_13thOrderq = (fractPartBin >= 48'h0002D79883D2); //48'd00012207031250       
assign weightSel_14thOrderq = (fractPartBin >= 48'd000000000000); // default

wire [13:0] weightSelq;
assign weightSelq = {weightSel_1stOrderq,
                     weightSel_2ndOrderq,
                     weightSel_3rdOrderq,
                     weightSel_4thOrderq,
                     weightSel_5thOrderq,
                     weightSel_6thOrderq,
                     weightSel_7thOrderq,
                     weightSel_8thOrderq,
                     weightSel_9thOrderq,
                     weightSel_10thOrderq,
                     weightSel_11thOrderq,
                     weightSel_12thOrderq,
                     weightSel_13thOrderq,
                     weightSel_14thOrderq};
                    
reg [13:0] weightSel_q0;
reg [13:0] weightSel_q1;
reg [13:0] weightSel_q2;
reg [13:0] weightSel_q3;
reg [13:0] weightSel_q4;
reg [13:0] weightSel_q5;
reg [13:0] weightSel_q6;
reg [13:0] weightSel_q7;
reg [13:0] weightSel_q8;
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        weightSel_q0 <= 14'b0;
        weightSel_q1 <= 14'b0;
        weightSel_q2 <= 14'b0;
        weightSel_q3 <= 14'b0;
        weightSel_q4 <= 14'b0;
        weightSel_q5 <= 14'b0;
        weightSel_q6 <= 14'b0;
        weightSel_q7 <= 14'b0;
        weightSel_q8 <= 14'b0;
    end    
    else begin
        if (wren) weightSel_q0 <= weightSelq; 
        weightSel_q1 <= weightSel_q0 ;
        weightSel_q2 <= weightSel_q1 ;
        weightSel_q3 <= weightSel_q2 ;
        weightSel_q4 <= weightSel_q3 ;
        weightSel_q5 <= weightSel_q4 ;
        weightSel_q6 <= weightSel_q5 ;
        weightSel_q7 <= weightSel_q6 ;
        weightSel_q8 <= weightSel_q7 ;       
    end                      

reg [47:0] weight_d10_q0;
reg [47:0] weight_d9_q0;
reg [47:0] weight_d8_q0;
reg [47:0] weight_d7_q0;
reg [47:0] weight_d6_q0;
reg [47:0] weight_d5_q0;
reg [47:0] weight_d4_q0;
reg [47:0] weight_d3_q0;
reg [47:0] weight_d2_q0;
reg [47:0] weight_d1_q0;
reg [47:0] weight_d0_q0;
reg [47:0] fractPartBin_q0;
reg wren_del_0;
always @(posedge CLK or posedge RESET)
    if (RESET) begin
        weight_d10_q0 <= 48'b0;
        weight_d9_q0  <= 48'b0;
        weight_d8_q0  <= 48'b0;
        weight_d7_q0  <= 48'b0;
        weight_d6_q0  <= 48'b0;
        weight_d5_q0  <= 48'b0;
        weight_d4_q0  <= 48'b0;
        weight_d3_q0  <= 48'b0;
        weight_d2_q0  <= 48'b0;
        weight_d1_q0  <= 48'b0;
        weight_d0_q0  <= 48'b0;                                   
        fractPartBin_q0 <= 48'b0;                                 
        wren_del_0    <= 1'b0;                                    
    end                                                           
    else begin                                                                                        
        wren_del_0 <= wren;                                                                           
        if (wren_del_0) begin                                                                         
                                                                                                      
            fractPartBin_q0 <= fractPartBin;                                                          
                                                                                                      
            casex(weightSelq)                                     
                14'b1xxxxxxxxxxxxx : begin                                     
                    weight_d10_q0 <= 48'h2D79883D2000;             // 48'd50000000000000          
                    weight_d9_q0  <= 48'h16BCC41E9000;             // 48'd25000000000000         
                    weight_d8_q0  <= 48'h0B5E620F4800;             // 48'd12500000000000                     
                    weight_d7_q0  <= 48'h05AF3107A400;             // 48'd06250000000000                     
                    weight_d6_q0  <= 48'h02D79883D200;             // 48'd03125000000000                     
                    weight_d5_q0  <= 48'h016BCC41E900;             // 48'd01562500000000                     
                    weight_d4_q0  <= 48'h00B5E620F480;             // 48'd00781250000000                     
                    weight_d3_q0  <= 48'h005AF3107A40;             // 48'd00390625000000                     
                    weight_d2_q0  <= 48'h002D79883D20;             // 48'd00195312500000                     
                    weight_d1_q0  <= 48'h0016BCC41E90;             // 48'd00097656250000                     
                    weight_d0_q0  <= 48'h000B5E620F48;             // 48'd00048828125000                     
                end                                                                                          
                14'b01xxxxxxxxxxxx : begin                                                                   
                    weight_d10_q0 <= 48'h16BCC41E9000;             // 48'd25000000000000
                    weight_d9_q0  <= 48'h0B5E620F4800;             // 48'd12500000000000
                    weight_d8_q0  <= 48'h05AF3107A400;             // 48'd06250000000000
                    weight_d7_q0  <= 48'h02D79883D200;             // 48'd03125000000000
                    weight_d6_q0  <= 48'h016BCC41E900;             // 48'd01562500000000
                    weight_d5_q0  <= 48'h00B5E620F480;             // 48'd00781250000000
                    weight_d4_q0  <= 48'h005AF3107A40;             // 48'd00390625000000
                    weight_d3_q0  <= 48'h002D79883D20;             // 48'd00195312500000
                    weight_d2_q0  <= 48'h0016BCC41E90;             // 48'd00097656250000
                    weight_d1_q0  <= 48'h000B5E620F48;             // 48'd00048828125000
                    weight_d0_q0  <= 48'h0005AF3107A4;             // 48'd00024414062500
                end
                14'b001xxxxxxxxxxx : begin 
                    weight_d10_q0 <= 48'h0B5E620F4800;             // 48'd12500000000000                  
                    weight_d9_q0  <= 48'h05AF3107A400;             // 48'd06250000000000                  
                    weight_d8_q0  <= 48'h02D79883D200;             // 48'd03125000000000                  
                    weight_d7_q0  <= 48'h016BCC41E900;             // 48'd01562500000000                  
                    weight_d6_q0  <= 48'h00B5E620F480;             // 48'd00781250000000
                    weight_d5_q0  <= 48'h005AF3107A40;             // 48'd00390625000000
                    weight_d4_q0  <= 48'h002D79883D20;             // 48'd00195312500000
                    weight_d3_q0  <= 48'h0016BCC41E90;             // 48'd00097656250000
                    weight_d2_q0  <= 48'h000B5E620F48;             // 48'd00048828125000
                    weight_d1_q0  <= 48'h0005AF3107A4;             // 48'd00024414062500
                    weight_d0_q0  <= 48'h0002D79883D2;             // 48'd00012207031250
                end
                14'b0001xxxxxxxxxx : begin 
                    weight_d10_q0 <= 48'h05AF3107A400;             // 48'd06250000000000               
                    weight_d9_q0  <= 48'h02D79883D200;             // 48'd03125000000000               
                    weight_d8_q0  <= 48'h016BCC41E900;             // 48'd01562500000000               
                    weight_d7_q0  <= 48'h00B5E620F480;             // 48'd00781250000000               
                    weight_d6_q0  <= 48'h005AF3107A40;             // 48'd00390625000000               
                    weight_d5_q0  <= 48'h002D79883D20;             // 48'd00195312500000               
                    weight_d4_q0  <= 48'h0016BCC41E90;             // 48'd00097656250000       
                    weight_d3_q0  <= 48'h000B5E620F48;             // 48'd00048828125000       
                    weight_d2_q0  <= 48'h0005AF3107A4;             // 48'd00024414062500       
                    weight_d1_q0  <= 48'h0002D79883D2;             // 48'd00012207031250       
                    weight_d0_q0  <= 48'h00016BCC41E9;             // 48'd00006103515625       
                end
                14'b00001xxxxxxxxx : begin 
                    weight_d10_q0 <= 48'h02D79883D200;             // 48'd03125000000000
                    weight_d9_q0  <= 48'h016BCC41E900;             // 48'd01562500000000
                    weight_d8_q0  <= 48'h00B5E620F480;             // 48'd00781250000000
                    weight_d7_q0  <= 48'h005AF3107A40;             // 48'd00390625000000
                    weight_d6_q0  <= 48'h002D79883D20;             // 48'd00195312500000
                    weight_d5_q0  <= 48'h0016BCC41E90;             // 48'd00097656250000
                    weight_d4_q0  <= 48'h000B5E620F48;             // 48'd00048828125000
                    weight_d3_q0  <= 48'h0005AF3107A4;             // 48'd00024414062500
                    weight_d2_q0  <= 48'h0002D79883D2;             // 48'd00012207031250
                    weight_d1_q0  <= 48'h00016BCC41E9;             // 48'd00006103515625
                    weight_d0_q0  <= 48'h0000B5E620F4;   //inexact // 48'd00003051757812
                end
                14'b000001xxxxxxxx : begin  
                    weight_d10_q0 <= 48'h016BCC41E900;             // 48'd01562500000000
                    weight_d9_q0  <= 48'h00B5E620F480;             // 48'd00781250000000            
                    weight_d8_q0  <= 48'h005AF3107A40;             // 48'd00390625000000            
                    weight_d7_q0  <= 48'h002D79883D20;             // 48'd00195312500000            
                    weight_d6_q0  <= 48'h0016BCC41E90;             // 48'd00097656250000            
                    weight_d5_q0  <= 48'h000B5E620F48;             // 48'd00048828125000            
                    weight_d4_q0  <= 48'h0005AF3107A4;             // 48'd00024414062500            
                    weight_d3_q0  <= 48'h0002D79883D2;             // 48'd00012207031250            
                    weight_d2_q0  <= 48'h00016BCC41E9;             // 48'd00006103515625
                    weight_d1_q0  <= 48'h0000B5E620F4;  //inexact  // 48'd00003051757812
                    weight_d0_q0  <= 48'h00005AF3107A;  //inexact  // 48'd00001525878906
                end
                14'b0000001xxxxxxx : begin  
                    weight_d10_q0 <= 48'h00B5E620F480;             // 48'd00781250000000          
                    weight_d9_q0  <= 48'h005AF3107A40;             // 48'd00390625000000          
                    weight_d8_q0  <= 48'h002D79883D20;             // 48'd00195312500000          
                    weight_d7_q0  <= 48'h0016BCC41E90;             // 48'd00097656250000          
                    weight_d6_q0  <= 48'h000B5E620F48;             // 48'd00048828125000                     
                    weight_d5_q0  <= 48'h0005AF3107A4;             // 48'd00024414062500                     
                    weight_d4_q0  <= 48'h0002D79883D2;             // 48'd00012207031250                     
                    weight_d3_q0  <= 48'h00016BCC41E9;             // 48'd00006103515625                     
                    weight_d2_q0  <= 48'h0000B5E620F4;  //inexact  // 48'd00003051757812                     
                    weight_d1_q0  <= 48'h00005AF3107A;  //inexact  // 48'd00001525878906
                    weight_d0_q0  <= 48'h00002D79883D;  //inexact  // 48'd00000762939453
                end
                14'b00000001xxxxxx : begin 
                    weight_d10_q0 <= 48'h005AF3107A40;             // 48'd00390625000000
                    weight_d9_q0  <= 48'h002D79883D20;             // 48'd00195312500000
                    weight_d8_q0  <= 48'h0016BCC41E90;             // 48'd00097656250000
                    weight_d7_q0  <= 48'h000B5E620F48;             // 48'd00048828125000
                    weight_d6_q0  <= 48'h0005AF3107A4;             // 48'd00024414062500
                    weight_d5_q0  <= 48'h0002D79883D2;             // 48'd00012207031250
                    weight_d4_q0  <= 48'h00016BCC41E9;             // 48'd00006103515625
                    weight_d3_q0  <= 48'h0000B5E620F4;  //inexact  // 48'd00003051757812
                    weight_d2_q0  <= 48'h00005AF3107A;  //inexact  // 48'd00001525878906
                    weight_d1_q0  <= 48'h00002D79883D;  //inexact  // 48'd00000762939453
                    weight_d0_q0  <= 48'h000016BCC41E;  //inexact  // 48'd00000381469726
                end
                14'b000000001xxxxx : begin  
                    weight_d10_q0 <= 48'h002D79883D20;             // 48'd00195312500000
                    weight_d9_q0  <= 48'h0016BCC41E90;             // 48'd00097656250000              
                    weight_d8_q0  <= 48'h000B5E620F48;             // 48'd00048828125000                         
                    weight_d7_q0  <= 48'h0005AF3107A4;             // 48'd00024414062500                         
                    weight_d6_q0  <= 48'h0002D79883D2;             // 48'd00012207031250                         
                    weight_d5_q0  <= 48'h00016BCC41E9;             // 48'd00006103515625                         
                    weight_d4_q0  <= 48'h0000B5E620F4;  //inexact  // 48'd00003051757812                         
                    weight_d3_q0  <= 48'h00005AF3107A;  //inexact  // 48'd00001525878906                         
                    weight_d2_q0  <= 48'h00002D79883D;  //inexact  // 48'd00000762939453                         
                    weight_d1_q0  <= 48'h000016BCC41E;  //inexact  // 48'd00000381469726                         
                    weight_d0_q0  <= 48'h00000B5E620F;  //inexact  // 48'd00000190734863                         
                end
                14'b0000000001xxxx : begin  
                    weight_d10_q0 <= 48'h0016BCC41E90;             // 48'd00097656250000                
                    weight_d9_q0  <= 48'h000B5E620F48;             // 48'd00048828125000                         
                    weight_d8_q0  <= 48'h0005AF3107A4;             // 48'd00024414062500                         
                    weight_d7_q0  <= 48'h0002D79883D2;             // 48'd00012207031250                         
                    weight_d6_q0  <= 48'h00016BCC41E9;             // 48'd00006103515625                         
                    weight_d5_q0  <= 48'h0000B5E620F4;  //inexact  // 48'd00003051757812                         
                    weight_d4_q0  <= 48'h00005AF3107A;  //inexact  // 48'd00001525878906                         
                    weight_d3_q0  <= 48'h00002D79883D;  //inexact  // 48'd00000762939453                         
                    weight_d2_q0  <= 48'h000016BCC41E;  //inexact  // 48'd00000381469726                         
                    weight_d1_q0  <= 48'h00000B5E620F;  //inexact  // 48'd00000190734863                         
                    weight_d0_q0  <= 48'h000005AF3107;  //inexact  // 48'd00000095367431                         
                end                                                                            
                14'b00000000001xxx : begin                                                     
                    weight_d10_q0 <= 48'h000B5E620F48;             // 48'd00048828125000
                    weight_d9_q0  <= 48'h0005AF3107A4;             // 48'd00024414062500
                    weight_d8_q0  <= 48'h0002D79883D2;             // 48'd00012207031250
                    weight_d7_q0  <= 48'h00016BCC41E9;             // 48'd00006103515625
                    weight_d6_q0  <= 48'h0000B5E620F4;  //inexact  // 48'd00003051757812
                    weight_d5_q0  <= 48'h00005AF3107A;  //inexact  // 48'd00001525878906
                    weight_d4_q0  <= 48'h00002D79883D;  //inexact  // 48'd00000762939453
                    weight_d3_q0  <= 48'h000016BCC41E;  //inexact  // 48'd00000381469726
                    weight_d2_q0  <= 48'h00000B5E620F;  //inexact  // 48'd00000190734863
                    weight_d1_q0  <= 48'h000005AF3107;  //inexact  // 48'd00000095367431
                    weight_d0_q0  <= 48'h000002D79883;  //inexact  // 48'd00000047683715
                end
                14'b000000000001xx : begin  
                    weight_d10_q0 <= 48'h0005AF3107A4;             // 48'd00024414062500
                    weight_d9_q0  <= 48'h0002D79883D2;             // 48'd00012207031250
                    weight_d8_q0  <= 48'h00016BCC41E9;             // 48'd00006103515625
                    weight_d7_q0  <= 48'h0000B5E620F4;  //inexact  // 48'd00003051757812
                    weight_d6_q0  <= 48'h00005AF3107A;  //inexact  // 48'd00001525878906
                    weight_d5_q0  <= 48'h00002D79883D;  //inexact  // 48'd00000762939453
                    weight_d4_q0  <= 48'h000016BCC41E;  //inexact  // 48'd00000381469726
                    weight_d3_q0  <= 48'h00000B5E620F;  //inexact  // 48'd00000190734863
                    weight_d2_q0  <= 48'h000005AF3107;  //inexact  // 48'd00000095367431
                    weight_d1_q0  <= 48'h000002D79883;  //inexact  // 48'd00000047683715
                    weight_d0_q0  <= 48'h0000016BCC41;  //inexact  // 48'd00000023841857
                end
                14'b0000000000001x : begin  
                    weight_d10_q0 <= 48'h0002D79883D2;             // 48'd00012207031250
                    weight_d9_q0  <= 48'h00016BCC41E9;             // 48'd00006103515625
                    weight_d8_q0  <= 48'h0000B5E620F4;  //inexact  // 48'd00003051757812
                    weight_d7_q0  <= 48'h00005AF3107A;  //inexact  // 48'd00001525878906
                    weight_d6_q0  <= 48'h00002D79883D;  //inexact  // 48'd00000762939453
                    weight_d5_q0  <= 48'h000016BCC41E;  //inexact  // 48'd00000381469726
                    weight_d4_q0  <= 48'h00000B5E620F;  //inexact  // 48'd00000190734863
                    weight_d3_q0  <= 48'h000005AF3107;  //inexact  // 48'd00000095367431
                    weight_d2_q0  <= 48'h000002D79883;  //inexact  // 48'd00000047683715
                    weight_d1_q0  <= 48'h0000016BCC41;  //inexact  // 48'd00000023841857
                    weight_d0_q0  <= 48'h000000B5E620;  //inexact  // 48'd00000011920928
                end
                14'b00000000000001 : begin    
                    weight_d10_q0 <= 48'h00016BCC41E9;             // 48'd00006103515625
                    weight_d9_q0  <= 48'h0000B5E620F4;  //inexact  // 48'd00003051757812
                    weight_d8_q0  <= 48'h00005AF3107A;  //inexact  // 48'd00001525878906
                    weight_d7_q0  <= 48'h00002D79883D;  //inexact  // 48'd00000762939453
                    weight_d6_q0  <= 48'h000016BCC41E;  //inexact  // 48'd00000381469726
                    weight_d5_q0  <= 48'h00000B5E620F;  //inexact  // 48'd00000190734863
                    weight_d4_q0  <= 48'h000005AF3107;  //inexact  // 48'd00000095367431
                    weight_d3_q0  <= 48'h000002D79883;  //inexact  // 48'd00000047683715
                    weight_d2_q0  <= 48'h0000016BCC41;  //inexact  // 48'd00000023841857
                    weight_d1_q0  <= 48'h000000B5E620;  //inexact  // 48'd00000011920928
                    weight_d0_q0  <= 48'h0000005AF310;  //inexact  // 48'd00000005960464
                end
                default : begin
                    weight_d10_q0 <= 48'h000000000000;
                    weight_d9_q0  <= 48'h000000000000;
                    weight_d8_q0  <= 48'h000000000000;
                    weight_d7_q0  <= 48'h000000000000;
                    weight_d6_q0  <= 48'h000000000000;
                    weight_d5_q0  <= 48'h000000000000;
                    weight_d4_q0  <= 48'h000000000000;
                    weight_d3_q0  <= 48'h000000000000;
                    weight_d2_q0  <= 48'h000000000000;
                    weight_d1_q0  <= 48'h000000000000;
                    weight_d0_q0  <= 48'h000000000000;
                end
            endcase
        end        
   end             

wire d10;
wire [49:0] fractBin10;
wire [50:0] fractBin10Test;
wire fractGTE10;
assign fractBin10Test = fractPartBin_q0 - weight_d10_q0;
assign fractGTE10 = ~fractBin10Test[50] || ~|fractBin10Test; 
assign fractBin10 = fractGTE10 ? fractBin10Test[49:0] : fractPartBin_q0;
assign d10 = fractGTE10;

wire d9;
wire [49:0] fractBin9;
wire [50:0] fractBin9Test;
wire fractGTE9;
assign fractBin9Test = fractBin10 - weight_d9_q0;
assign fractGTE9 = ~fractBin9Test[50] || ~|fractBin9Test; 
assign fractBin9 = fractGTE9 ? fractBin9Test[49:0] : fractBin10;
assign d9 = fractGTE9;

reg d10_q1;
reg d9_q1;
reg [49:0] fractBin9_q1;
reg [49:0] weight_d8_q1;
reg [49:0] weight_d7_q1;
reg [49:0] weight_d6_q1;
reg [49:0] weight_d5_q1;
reg [49:0] weight_d4_q1;
reg [49:0] weight_d3_q1;
reg [49:0] weight_d2_q1;
reg [49:0] weight_d1_q1;
reg [49:0] weight_d0_q1;
always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        d10_q1 <= 1'b0;    
        d9_q1 <= 1'b0;
        fractBin9_q1 <= 50'b0;
        weight_d8_q1 <= 50'b0;
        weight_d7_q1 <= 50'b0;
        weight_d6_q1 <= 50'b0;
        weight_d5_q1 <= 50'b0;
        weight_d4_q1 <= 50'b0;
        weight_d3_q1 <= 50'b0;
        weight_d2_q1 <= 50'b0;
        weight_d1_q1 <= 50'b0;
        weight_d0_q1 <= 50'b0;
    end
    else begin
        d10_q1 <= d10;        
        d9_q1 <= d9;
        fractBin9_q1 <= fractBin9;
        weight_d8_q1 <= weight_d8_q0;
        weight_d7_q1 <= weight_d7_q0;
        weight_d6_q1 <= weight_d6_q0;
        weight_d5_q1 <= weight_d5_q0;
        weight_d4_q1 <= weight_d4_q0;
        weight_d3_q1 <= weight_d3_q0;
        weight_d2_q1 <= weight_d2_q0;
        weight_d1_q1 <= weight_d1_q0;
        weight_d0_q1 <= weight_d0_q0;
    end                          

wire d8;
wire [49:0] fractBin8;
wire [50:0] fractBin8Test;
wire fractGTE8;
assign fractBin8Test = fractBin9_q1 - weight_d8_q1;
assign fractGTE8 = ~fractBin8Test[50] || ~|fractBin8Test; 
assign fractBin8 = fractGTE8 ? fractBin8Test[49:0] : fractBin9_q1;
assign d8 = fractGTE8;

wire d7;
wire [49:0] fractBin7;
wire [50:0] fractBin7Test;
wire fractGTE7;
assign fractBin7Test = fractBin8 - weight_d7_q1;
assign fractGTE7 = ~fractBin7Test[50] || ~|fractBin7Test; 
assign fractBin7 = fractGTE7 ? fractBin7Test[49:0] : fractBin8;
assign d7 = fractGTE7;

wire d6;
wire [49:0] fractBin6;
wire [50:0] fractBin6Test;
wire fractGTE6;
assign fractBin6Test = fractBin7 - weight_d6_q1;
assign fractGTE6 = ~fractBin6Test[50] || ~|fractBin6Test; 
assign fractBin6 = fractGTE6 ? fractBin6Test[49:0] : fractBin7;
assign d6 = fractGTE6;

reg d10_q2;
reg d9_q2;
reg d8_q2;
reg d7_q2;
reg d6_q2;
reg [49:0] weight_d5_q2;
reg [49:0] weight_d4_q2;
reg [49:0] weight_d3_q2;
reg [49:0] weight_d2_q2;
reg [49:0] weight_d1_q2;
reg [49:0] weight_d0_q2;

reg [49:0] fractBin6_q2;
always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        d10_q2 <= 1'b0;
         d9_q2 <= 1'b0;
         d8_q2 <= 1'b0;    
         d7_q2 <= 1'b0;
         d6_q2 <= 1'b0;
        fractBin6_q2 <= 50'b0;
        weight_d5_q2 <= 50'b0;
        weight_d4_q2 <= 50'b0;
        weight_d3_q2 <= 50'b0;
        weight_d2_q2 <= 50'b0;
        weight_d1_q2 <= 50'b0;
        weight_d0_q2 <= 50'b0;
    end
    else begin
        d10_q2 <= d10_q1;
         d9_q2 <= d9_q1;
         d8_q2 <= d8 ;        
         d7_q2 <= d7 ;
         d6_q2 <= d6 ;
        fractBin6_q2 <= fractBin6;
        weight_d5_q2 <= weight_d5_q1;
        weight_d4_q2 <= weight_d4_q1;
        weight_d3_q2 <= weight_d3_q1;
        weight_d2_q2 <= weight_d2_q1;
        weight_d1_q2 <= weight_d1_q1;
        weight_d0_q2 <= weight_d0_q1;
    end

wire d5;
wire [49:0] fractBin5;
wire [50:0] fractBin5Test;
wire fractGTE5;
assign fractBin5Test = fractBin6_q2 - weight_d5_q2;
assign fractGTE5 = ~fractBin5Test[50] || ~|fractBin5Test; 
assign fractBin5 = fractGTE5 ? fractBin5Test[49:0] : fractBin6_q2;
assign d5 = fractGTE5;

wire d4;
wire [49:0] fractBin4;
wire [50:0] fractBin4Test;
wire fractGTE4;
assign fractBin4Test = fractBin5 - weight_d4_q2;
assign fractGTE4 = ~fractBin4Test[50] || ~|fractBin4Test; 
assign fractBin4 = fractGTE4 ? fractBin4Test[49:0] : fractBin5;
assign d4 = fractGTE4;

wire d3;
wire [49:0] fractBin3;
wire [50:0] fractBin3Test;
wire fractGTE3;
assign fractBin3Test = fractBin4 - weight_d3_q2;
assign fractGTE3 = ~fractBin3Test[50] || ~|fractBin3Test; 
assign fractBin3 = fractGTE3 ? fractBin3Test[49:0] : fractBin4;
assign d3 = fractGTE3;

reg d10_q3;
reg d9_q3;
reg d8_q3;
reg d7_q3;
reg d6_q3;
reg d5_q3;
reg d4_q3;
reg d3_q3;
reg [49:0] fractBin3_q3;
reg [49:0] weight_d2_q3;
reg [49:0] weight_d1_q3;
reg [49:0] weight_d0_q3;
always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        d10_q3 <= 1'b0;
         d9_q3 <= 1'b0;
         d8_q3 <= 1'b0;
         d7_q3 <= 1'b0;
         d6_q3 <= 1'b0;
         d5_q3 <= 1'b0;    
         d4_q3 <= 1'b0;
         d3_q3 <= 1'b0;
        fractBin3_q3 <= 50'b0;
        weight_d2_q3 <= 50'b0;
        weight_d1_q3 <= 50'b0;
        weight_d0_q3 <= 50'b0;
    end
    else begin
        d10_q3 <=d10_q2;
         d9_q3 <= d9_q2;
         d8_q3 <= d8_q2;
         d7_q3 <= d7_q2;
         d6_q3 <= d6_q2;
         d5_q3 <= d5;        
         d4_q3 <= d4;
         d3_q3 <= d3;
        fractBin3_q3 <= fractBin3;
        weight_d2_q3 <= weight_d2_q2;
        weight_d1_q3 <= weight_d1_q2;
        weight_d0_q3 <= weight_d0_q2;
    end

wire d2;
wire [49:0] fractBin2;
wire [50:0] fractBin2Test;
wire fractGTE2;
assign fractBin2Test = fractBin3_q3 - weight_d2_q3;
assign fractGTE2 = ~fractBin2Test[50] || ~|fractBin2Test; 
assign fractBin2 = fractGTE2 ? fractBin2Test[49:0] : fractBin3_q3;
assign d2 = fractGTE2;

wire d1;
wire [49:0] fractBin1;
wire [50:0] fractBin1Test;
wire fractGTE1;
assign fractBin1Test = fractBin2 - weight_d1_q3;
assign fractGTE1 = ~fractBin1Test[50] || ~|fractBin1Test; 
assign fractBin1 = fractGTE1 ? fractBin1Test[49:0] : fractBin2;
assign d1 = fractGTE1;

wire d0;
wire [49:0] fractBin0;
wire [50:0] fractBin0Test;
wire fractGTE0;
assign fractBin0Test = fractBin1 - weight_d0_q3;
assign fractGTE0 = ~fractBin0Test[50] || ~|fractBin0Test; 
assign fractBin0 = fractGTE0 ? fractBin0Test[49:0] : fractBin1;
assign d0 = fractGTE0;


reg d10_q4;
reg d9_q4 ;
reg d8_q4 ;
reg d7_q4 ;
reg d6_q4 ;
reg d5_q4 ;
reg d4_q4 ;
reg d3_q4 ;
reg d2_q4 ;
reg d1_q4 ;
reg d0_q4 ;
reg [49:0] fractBin0_q4;
always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        d10_q4 <= 1'b0;
        d9_q4  <= 1'b0;
        d8_q4  <= 1'b0;
        d7_q4  <= 1'b0;
        d6_q4  <= 1'b0;
        d5_q4  <= 1'b0;
        d4_q4  <= 1'b0;
        d3_q4  <= 1'b0;
        d2_q4  <= 1'b0;    
        d1_q4  <= 1'b0;
        d0_q4  <= 1'b0;
        fractBin0_q4 <= 50'b0;
    end
    else begin
        d10_q4 <= d10_q3;
         d9_q4 <= d9_q3;
         d8_q4 <= d8_q3;
         d7_q4 <= d7_q3;
         d6_q4 <= d6_q3;
         d5_q4 <= d5_q3;
         d4_q4 <= d4_q3;
         d3_q4 <= d3_q3;
         d2_q4 <= d2;        
         d1_q4 <= d1;
         d0_q4 <= d0;
        fractBin0_q4 <= fractBin0;
    end


wire g;
wire r;
wire s;
wire [2:0] GRS;
assign g = fractBin0_q4 >= 50'd000000029802322;
assign r = fractBin0_q4 >= 50'd000000014901161;
assign s = (fractBin0_q4 < 50'd000000014901161) && (fractBin0_q4 > 50'd000000000000000);
assign GRS = {g, r, s};
wire [10:0] encodedFract_q4;
wire [4:0] fractLeadingZeros;
wire fractAll_0;
assign encodedFract_q4 = {d10_q4,
                          d9_q4 ,
                          d8_q4 ,
                          d7_q4 ,
                          d6_q4 ,
                          d5_q4 ,
                          d4_q4 ,
                          d3_q4 ,
                          d2_q4 ,
                          d1_q4 ,
                          d0_q4 };
                          
reg truncInexact;  //determines inexact due to only eight decimal digits  of smaller numbers on operator input                       
always @(*)
    casex(weightSel_q4)
        14'b1xxxxxxxxxxxxx : truncInexact = 1'b0;
        14'b01xxxxxxxxxxxx : truncInexact = 1'b0;
        14'b001xxxxxxxxxxx : truncInexact = 1'b0;
        14'b0001xxxxxxxxxx : truncInexact = 1'b0;
        14'b00001xxxxxxxxx : truncInexact = encodedFract_q4[0];
        14'b000001xxxxxxxx : truncInexact = |encodedFract_q4[1:0];
        14'b0000001xxxxxxx : truncInexact = |encodedFract_q4[2:0];
        14'b00000001xxxxxx : truncInexact = |encodedFract_q4[3:0];
        14'b000000001xxxxx : truncInexact = |encodedFract_q4[4:0];
        14'b0000000001xxxx : truncInexact = |encodedFract_q4[5:0];
        14'b00000000001xxx : truncInexact = |encodedFract_q4[6:0];
        14'b000000000001xx : truncInexact = |encodedFract_q4[7:0];
        14'b0000000000001x : truncInexact = |encodedFract_q4[8:0];
        14'b00000000000001 : truncInexact = |encodedFract_q4[9:0];
                   default : truncInexact = 1'b0;
    endcase
                          
reg [23:0] fractScaled_q4;
always @(*)
    casex(weightSel_q4)
        14'b1xxxxxxxxxxxxx : fractScaled_q4 = {encodedFract_q4, 13'b0};                          
        14'b01xxxxxxxxxxxx : fractScaled_q4 = {1'b0,  encodedFract_q4, 12'b0};                          
        14'b001xxxxxxxxxxx : fractScaled_q4 = {2'b0,  encodedFract_q4, 11'b0};                          
        14'b0001xxxxxxxxxx : fractScaled_q4 = {3'b0,  encodedFract_q4, 10'b0};                          
        14'b00001xxxxxxxxx : fractScaled_q4 = {4'b0,  encodedFract_q4, 9'b0};                          
        14'b000001xxxxxxxx : fractScaled_q4 = {5'b0,  encodedFract_q4, 8'b0};                          
        14'b0000001xxxxxxx : fractScaled_q4 = {6'b0,  encodedFract_q4, 7'b0};                          
        14'b00000001xxxxxx : fractScaled_q4 = {7'b0,  encodedFract_q4, 6'b0};                          
        14'b000000001xxxxx : fractScaled_q4 = {8'b0,  encodedFract_q4, 5'b0};                          
        14'b0000000001xxxx : fractScaled_q4 = {9'b0,  encodedFract_q4, 4'b0};                          
        14'b00000000001xxx : fractScaled_q4 = {10'b0, encodedFract_q4, 3'b0};                          
        14'b000000000001xx : fractScaled_q4 = {11'b0, encodedFract_q4, 2'b0};                          
        14'b0000000000001x : fractScaled_q4 = {12'b0, encodedFract_q4, 1'b0};                          
        14'b00000000000001 : fractScaled_q4 = {13'b0, encodedFract_q4};                          
                   default : fractScaled_q4 = {13'b0, encodedFract_q4};                          
    endcase


LZC_24 lzc_24decToBin(
    .In    (fractScaled_q4),
    .R     (fractLeadingZeros),
    .All_0 (fractAll_0       )
    );

wire [3:0] intLeadingZeros_not;
wire intAll_0;
LZC_16 lzc_16decToBin(
    .In    (integerPartBin_q4 ),
    .R     (intLeadingZeros_not),
    .All_0 (intAll_0       )
    );

//for integer-only numbers  
wire  [3:0] intLeadingZeros;
assign intLeadingZeros = intLeadingZeros_not ^ 4'b1111;  //presently outputs of LZC16 are inverted
reg [15:0] intIntermResult;
always @(*) 
        case(intLeadingZeros)
           4'b0000 : intIntermResult = {sign_q4, 5'h1E, integerPartBin_q4[14:5]}; //msb is hidden/implied
           4'b0001 : intIntermResult = {sign_q4, 5'h1D, integerPartBin_q4[13:4]};
           4'b0010 : intIntermResult = {sign_q4, 5'h1C, integerPartBin_q4[12:3]};
           4'b0011 : intIntermResult = {sign_q4, 5'h1B, integerPartBin_q4[11:2]};
           4'b0100 : intIntermResult = {sign_q4, 5'h1A, integerPartBin_q4[10:1]};
           4'b0101 : intIntermResult = {sign_q4, 5'h19, integerPartBin_q4[9:0]};
           4'b0110 : intIntermResult = {sign_q4, 5'h18, integerPartBin_q4[8:0], 1'b0};
           4'b0111 : intIntermResult = {sign_q4, 5'h17, integerPartBin_q4[7:0], 2'b0};
           4'b1000 : intIntermResult = {sign_q4, 5'h16, integerPartBin_q4[6:0], 3'b0};
           4'b1001 : intIntermResult = {sign_q4, 5'h15, integerPartBin_q4[5:0], 4'b0};
           4'b1010 : intIntermResult = {sign_q4, 5'h14, integerPartBin_q4[4:0], 5'b0};
           4'b1011 : intIntermResult = {sign_q4, 5'h13, integerPartBin_q4[3:0], 6'b0};
           4'b1100 : intIntermResult = {sign_q4, 5'h12, integerPartBin_q4[2:0], 7'b0};
           4'b1101 : intIntermResult = {sign_q4, 5'h11, integerPartBin_q4[1:0], 8'b0}; // 4-7
           4'b1110 : intIntermResult = {sign_q4, 5'h10, integerPartBin_q4[  0], 9'b0}; // 2-3
           4'b1111 : intIntermResult = {sign_q4, 5'h0F, 10'b0};                        // 1
        endcase

//for fraction-only numbers
reg [15:0] fractIntermResult; 
reg roundit;
wire underflow; 
wire inexact;      
always @(*)
    case(fractLeadingZeros)
        5'b00000 : fractIntermResult = {sign_q4, 5'h0E, fractScaled_q4[22:13]}; //msb is hidden/implied (until underflow)      
        5'b00001 : fractIntermResult = {sign_q4, 5'h0D, fractScaled_q4[21:12]};         
        5'b00010 : fractIntermResult = {sign_q4, 5'h0C, fractScaled_q4[20:11]};         
        5'b00011 : fractIntermResult = {sign_q4, 5'h0B, fractScaled_q4[19:10]};         
        5'b00100 : fractIntermResult = {sign_q4, 5'h0A, fractScaled_q4[18:9]};         
        5'b00101 : fractIntermResult = {sign_q4, 5'h09, fractScaled_q4[17:8]};         
        5'b00110 : fractIntermResult = {sign_q4, 5'h08, fractScaled_q4[16:7]};         
        5'b00111 : fractIntermResult = {sign_q4, 5'h07, fractScaled_q4[15:6]};         
        5'b01000 : fractIntermResult = {sign_q4, 5'h06, fractScaled_q4[14:5]};         
        5'b01001 : fractIntermResult = {sign_q4, 5'h05, fractScaled_q4[13:4]};         
        5'b01010 : fractIntermResult = {sign_q4, 5'h04, fractScaled_q4[12:3]};         
        5'b01011 : fractIntermResult = {sign_q4, 5'h03, fractScaled_q4[11:2]};         
        5'b01100 : fractIntermResult = {sign_q4, 5'h02, fractScaled_q4[10:1]};         
        5'b01101 : fractIntermResult = {sign_q4, 5'h01, fractScaled_q4[9:0]};         
        5'b01110 : fractIntermResult = {sign_q4, 5'h00, 1'b1,         fractScaled_q4[8:0]}; //underflow        
        5'b01111 : fractIntermResult = {sign_q4, 5'h00, 2'b01,        fractScaled_q4[7:0]};         
        5'b10000 : fractIntermResult = {sign_q4, 5'h00, 3'b001,       fractScaled_q4[6:0]};         
        5'b10001 : fractIntermResult = {sign_q4, 5'h00, 4'b0001,      fractScaled_q4[5:0]};         
        5'b10010 : fractIntermResult = {sign_q4, 5'h00, 5'b00001,     fractScaled_q4[4:0]};         
        5'b10011 : fractIntermResult = {sign_q4, 5'h00, 6'b000001,    fractScaled_q4[3:0]};         
        5'b10100 : fractIntermResult = {sign_q4, 5'h00, 7'b0000001,   fractScaled_q4[2:0]};         
        5'b10101 : fractIntermResult = {sign_q4, 5'h00, 8'b00000001,  fractScaled_q4[1:0]};         
        5'b10110 : fractIntermResult = {sign_q4, 5'h00, 9'b000000001, fractScaled_q4[0]};         
        5'b10111 : fractIntermResult = {sign_q4, 5'h00, 10'b000000001};
         default : fractIntermResult = {sign_q4, 5'h00, 10'b0};
    endcase    
assign underflow = (~|fractIntermResult[14:10] && ~fractAll_0); //resulting exponent = 5'b00000 is underflow
assign inexact = roundit || |GRS || underflow || is_overflow_q4 || (truncInexact && ~fractAll_0);

reg [15:0] intFractIntermResult;
always @(*)
        case(intLeadingZeros)
           4'b0110 : intFractIntermResult = {sign_q4, 5'h18, integerPartBin_q4[8:0], fractScaled_q4[23]};    //msb (of integer) is hidden/implied
           4'b0111 : intFractIntermResult = {sign_q4, 5'h17, integerPartBin_q4[7:0], fractScaled_q4[23:22]};
           4'b1000 : intFractIntermResult = {sign_q4, 5'h16, integerPartBin_q4[6:0], fractScaled_q4[23:21]};
           4'b1001 : intFractIntermResult = {sign_q4, 5'h15, integerPartBin_q4[5:0], fractScaled_q4[23:20]};
           4'b1010 : intFractIntermResult = {sign_q4, 5'h14, integerPartBin_q4[4:0], fractScaled_q4[23:19]};
           4'b1011 : intFractIntermResult = {sign_q4, 5'h13, integerPartBin_q4[3:0], fractScaled_q4[23:18]};
           4'b1100 : intFractIntermResult = {sign_q4, 5'h12, integerPartBin_q4[2:0], fractScaled_q4[23:17]};
           4'b1101 : intFractIntermResult = {sign_q4, 5'h11, integerPartBin_q4[1:0], fractScaled_q4[23:16]}; 
           4'b1110 : intFractIntermResult = {sign_q4, 5'h10, integerPartBin_q4[  0], fractScaled_q4[23:15]}; 
           4'b1111 : intFractIntermResult = {sign_q4, 5'h0F, fractScaled_q4[23:14]}; 
           default : intFractIntermResult = 16'b0;                     
        endcase

reg [15:0] intermResult;
always @(*)
    if (fractAll_0) intermResult = intIntermResult;  //integer-only numbers
    else if (intAll_0) intermResult = fractIntermResult; //fraction-only numbers
    else intermResult = intFractIntermResult; //integer-with-fraction numbers
    
    
always @(*)
        case(round_mode_q4)
            NEAREST : if (((GRS==3'b100) && (intermResult[0] || Away_q4) ) || (GRS[2] && |GRS[1:0]))roundit = 1'b1;    
                      else roundit = 1'b0;
            POSINF  : if (~sign_q4 && |GRS) roundit = 1'b1;
                      else roundit = 1'b0;
            NEGINF  : if (sign_q4 && |GRS) roundit = 1'b1;
                      else roundit = 1'b0;
            ZERO    : roundit = 1'b0;
        endcase

// exception codes for two MSBs [18:17] of result
parameter _no_excpt_   = 2'b00;  // no exception--all good
parameter _overflow_   = 2'b01;  // the operation has overflowed--inexact is always implied--
parameter _invalid_    = 2'b01;  
parameter _underFlowExact_ = 2'b01;
parameter _underFlowInexact_  = 2'b10;  // inexact underflow (underflows that are also exact are not signaled--per IEEE754-2008, unless immediate alternate handling is enabled)
parameter _div_x_0_    = 2'b10;  // infinity never shows underflow, so we use the same except code for underflow to signal div x 0
parameter _inexact_    = 2'b11;                     

reg [17:0] binOut;
always @(*)
    if (is_invalid_q4) binOut = {_invalid_, 1'b0, 5'b11111, 1'b1, 8'b00000111}; 
    else if (is_snan_q4 || is_nan_q4) binOut = {2'b00, sign_q4, 5'b11111, 1'b1, 1'b0, payload_q4}; //signaling snans as char input are quieted 
    else if (is_infinite_q4 || is_overflow_q4 ) binOut = {1'b0, is_overflow_q4, sign_q4, 5'b11111, 10'b0}; 
    else if (is_zero_q4) binOut = {2'b00, sign_q4, 15'b0};
    else if (underflow) binOut = {_underFlowInexact_, intermResult[15], (intermResult[14:0] + roundit)};
    else binOut = {inexact, inexact, intermResult[15], (intermResult[14:0] + roundit)};
        
endmodule
