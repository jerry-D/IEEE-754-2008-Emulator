 // FP610_To_IEEE754_510_filtered.v
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


module FP610_To_IEEE754_510_filtered(
    CLK,
    RESET,
    wren,
    round_mode,
    Away,
    trunk_invalid,
    NaN_in,
    invalid_code,
    operator_overflow,
    operator_underflow,
    div_by_0_del,
    A_invalid_del,
    B_invalid_del,
    A_inexact_del,
    B_inexact_del,
    X,
    Rq,
    G_in,     //FP 6 10 operator guard
    R_in,     //FP 6 10 operator round
    S_in      //FP 6 10 operator sticky
    );
    
input CLK;
input RESET;
input wren;
input [1:0] round_mode;
input Away;
input trunk_invalid;
input [9:0] NaN_in;       //this is a piped NaN including "signal" bit
input [2:0] invalid_code;
input operator_overflow;
input operator_underflow;
input div_by_0_del;
input A_invalid_del;
input B_invalid_del;
input A_inexact_del;
input B_inexact_del;
input [18:0] X;
output [17:0] Rq;      //all results are aligned right
input G_in;
input R_in;
input S_in;

//input precision (size) encodings for NaN diagnostic payload generation
parameter _1152_ = 2'b11;     //DP
parameter _823_  = 2'b10;     //SP
parameter _510_  = 2'b01;     //HP
parameter _610_  = 2'b00;     //FP610

// pipe position where exception detected for NaN diagnostic payload generation
parameter _head_  = 2'b01;
parameter _trunk_ = 2'b10;
parameter _tail_  = 2'b11;

// exception codes for two MSBs [18:17] of result
parameter _no_excpt_   = 2'b00;  // no exception--all good
parameter _overflow_   = 2'b01;  // the operation has overflowed--inexact is always implied--
parameter _invalid_    = 2'b01;  // a NaN will either have exception code of _no_excpt_ or _invalid_.  Read the last three bits of the NaN to determine cause of invalid exception.
parameter _underFlowExact_ = 2'b01;
parameter _underFlowInexact_  = 2'b10;  // inexact underflow (underflows that are also exact are not signaled--per IEEE754-2008, unless immediate alternate handling is enabled for it)
parameter _div_x_0_    = 2'b10;  // infinity never shows underflow, so we use the same except code for underflow to signal div x 0
parameter _inexact_    = 2'b11;                     

// frontend invalid operation codes for NaN diagnostic payload generation
parameter sig_NaN      = 3'b000;  // singnaling NaN is an operand
parameter mult_oob     = 3'b001;  // multiply operands out of bounds, multiplication(0, INF) or multiplication(?INF, 0)
parameter fsd_mult_oob = 3'b010;  // fused multiply operands out of bounds
parameter add_oob      = 3'b011;  // add or subract or fusedmultadd operands out of bounds
parameter div_oob      = 3'b100;  // division operands out of bounds, division(0, 0) or division(?INF, INF) 
parameter rem_oob      = 3'b101;  // remainder operands out of bounds, remainder(x, y), when y is zero or x is infinite (and neither is NaN)
parameter sqrt_oob     = 3'b110;  // square-root or log operand out of bounds, operand is less than zero
parameter quantize     = 3'b111;  // conversion result does not fit in dest, or a converted finite yields (or would yield) infinite result

//rounding mode encodings
parameter NEAREST = 2'b00;
parameter POSINF  = 2'b01;
parameter NEGINF  = 2'b10;
parameter ZERO    = 2'b11;

//FloPoCo exception codes
parameter zero = 2'b00;
parameter infinity = 2'b10;
parameter NaN = 2'b11;
parameter normal = 2'b01;

reg [17:0] Rq;

reg [9:0] interm_HP_fraction;
reg HP_roundit;
reg G, R, S;

reg [1:0] exception_code;

wire [1:0] FPin_exception;
wire FPin_sign;
wire [5:0] FPin_exponent;
wire [9:0] FPin_fraction;
wire FPin_is_invalid;
wire FPin_is_infinite; 
wire FPin_is_normal; 
wire FPin_is_NaN;      
wire FPin_is_zero;     
wire FPin_is_subnormal; 

wire HP_conv_overflow; 
wire HP_conv_underflow;
wire HP_conv_inexact;
  
wire [5:0] denormal_shift_amount;
wire [3:0] shift_amount;
wire [5:0] interm_HP_exponent;  
wire [15:0] HP_interm;     
wire [2:0] GRS;

assign FPin_exception = X[18:17];
assign FPin_sign = X[16];
assign FPin_exponent = X[15:10];
assign FPin_fraction = X[9:0];
assign FPin_is_infinite = wren && (X[18:17]==infinity);  
assign FPin_is_zero = wren && (X[18:17]==zero);
assign FPin_is_NaN = wren && (X[18:17]==NaN);
assign FPin_is_normal = wren && ((X[18:17]==normal) || FPin_is_zero);
assign FPin_is_subnormal = wren && (X[15:10] < 17) && FPin_is_normal && ~FPin_is_zero;                         // -14 + 31 = 17
assign FPin_is_invalid = 1'b0;

assign HP_conv_overflow  = wren && (HP_interm[15:10] > 46) && FPin_is_normal && ~FPin_is_zero;                 //  15 + 31 = 46  overflow due to rounding

assign HP_conv_underflow = wren && ((HP_interm[15:10] < 17) || operator_underflow) && HP_roundit  && ~FPin_is_invalid;  // -14 + 31 = 17  only signal underflow if it is also inexact after rounding--per IEEE754-2008
assign HP_conv_inexact   = wren && (HP_conv_overflow || HP_conv_underflow || HP_roundit || |GRS) && ~FPin_is_invalid;    

// FP 6 10 numbers whose exponent is less than 17 (biased) are subnormal for HP 5 10 format and thus need to be denormalized 
assign denormal_shift_amount = (6'h11 - FPin_exponent[5:0]);   // -14 + 31 = 17 = 5'h11
assign shift_amount = denormal_shift_amount[3:0];

// FP 6 10 To IEEE754 5 10 conversion
assign interm_HP_exponent = FPin_is_subnormal ? 6'b0 : (FPin_exponent - 16);  // -31 + 15 --rebias for HP 5 10
assign HP_interm = {interm_HP_exponent, interm_HP_fraction} + HP_roundit;  

assign GRS = {G, R, S};


// to support IEEE754-2008 gradual underflow, for Size of HP, take the normal FP 6 10 subnormal fraction and denormalize it for HP 5 10 format
always@(*)
    if (FPin_is_subnormal)
        case(shift_amount)
            1 : begin
                    interm_HP_fraction = {1'b1, X[9:1]};
                    G = X[0];
                    R = G_in;
                    S = R_in || S_in;
                end    
            
            2 : begin
                    interm_HP_fraction = {1'b0, 1'b1, X[9:2]};
                    G = X[1];
                    R = X[0];
                    S = G_in || R_in || S_in;
                end    
            3 : begin
                    interm_HP_fraction = {2'b0, 1'b1, X[9:3]};
                    G = X[2];
                    R = X[1];
                    S = X[0] || G_in || R_in || S_in;
                end    
            4 : begin
                    interm_HP_fraction = {3'b0, 1'b1, X[9:4]};
                    G = X[3];
                    R = X[2];
                    S = |X[1:0] || G_in || R_in || S_in;
                end    
            5 : begin
                    interm_HP_fraction = {4'b0, 1'b1, X[9:5]};
                    G = X[4];
                    R = X[3];
                    S = |X[2:0] || G_in || R_in || S_in;
                end    
            6 : begin
                    interm_HP_fraction = {5'b0, 1'b1, X[9:6]};
                    G = X[5];
                    R = X[4];
                    S = |X[3:0] || G_in || R_in || S_in;
                end    
            7 : begin
                    interm_HP_fraction = {6'b0, 1'b1, X[9:7]};
                    G = X[6];
                    R = X[5];
                    S = |X[4:0] || G_in || R_in || S_in;
                end    
            8 : begin
                    interm_HP_fraction = {7'b0, 1'b1, X[9:8]};
                    G = X[7];
                    R = X[6];
                    S = |X[5:0] || G_in || R_in || S_in;
                end    
                    
            9 : begin
                    interm_HP_fraction = {8'b0, 1'b1, X[  9]};
                    G = X[8];
                    R = X[7];
                    S = |X[6:0] || G_in || R_in || S_in;
                end    
           10 : begin
                    interm_HP_fraction = {9'b0, 1'b1};
                    G = X[9];
                    R = X[8];
                    S = |X[7:0] || G_in || R_in || S_in;
                end    
           11 : begin
                    interm_HP_fraction = 10'b0;
                    G = 1'b1;
                    R = X[9];
                    S = |X[8:0] || G_in || R_in || S_in;
                end    
           12 : begin
                    interm_HP_fraction = 10'b0;
                    G = 1'b0;
                    R = 1'b1;
                    S = |X[9:0] || G_in || R_in || S_in;
                end    
      default : begin
                    interm_HP_fraction = 10'b0;
                    G = 1'b0;
                    R = 1'b0;
                    S = 1'b1;
                end
        endcase
    else begin
            interm_HP_fraction = X[9:0];
            G = G_in;
            R = R_in;
            S = S_in;
           end    

// HP_roundit           
always @(*)
    if (wren)
        case(round_mode)
            NEAREST : if (((GRS==3'b100) && (interm_HP_fraction[0] || Away) ) || (GRS[2] && |GRS[1:0])) HP_roundit = 1'b1;    //when GRS = (3'b100 && lsb) OR when GRS = 101 or 110 or 111 then lsb is don't care
                      else HP_roundit = 1'b0;
            POSINF  : if (~FPin_sign && |GRS) HP_roundit = 1'b1;
                      else HP_roundit = 1'b0;
            NEGINF  : if (FPin_sign && |GRS) HP_roundit = 1'b1;
                      else HP_roundit = 1'b0;
            ZERO    : HP_roundit = 1'b0;
        endcase
   else HP_roundit = 1'b0;                  

// prioritized 2-bit exception encoder so that 18-bit RAMs can be used for result buffer
always @(*)
    if (HP_conv_overflow || operator_overflow) exception_code = _overflow_;
    else if (HP_conv_underflow) exception_code = (A_inexact_del || B_inexact_del || HP_conv_inexact) ? _underFlowInexact_ : _underFlowExact_;
    else if (HP_conv_inexact || A_inexact_del || B_inexact_del) exception_code = _inexact_;
    else exception_code = _no_excpt_;
    
     
always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        Rq <= 18'b0;
    end    
    else if (wren) begin
        if (HP_conv_overflow) 
            case(round_mode)
                NEAREST : Rq <= {_overflow_, FPin_sign, 5'b11111, 10'b0};
                
                POSINF  : if (FPin_sign) Rq <= {_overflow_, FPin_sign, 5'b11110, 10'b11_1111_1111};  // most neg finite number for neg overflows
                          else Rq <= {_overflow_, FPin_sign, 5'b11111, 10'b0};                       // pos infinity for positive overflows
                                                                                             
                NEGINF  : if (FPin_sign) Rq <= {_overflow_, FPin_sign, 5'b11111, 10'b0};             // neg infinity for negative overflows
                          else Rq <= {_overflow_, FPin_sign, 5'b11110, 10'b11_1111_1111};            // most pos finite number for positive overflows
                          
                ZERO    : Rq <= {_overflow_, FPin_sign, 5'b11110, 10'b11_1111_1111};
            endcase
// this is for the case of original input being quiet or signaling NaN or result of invalid conversion at the head
        else if (FPin_is_NaN) Rq <= {1'b0, (A_invalid_del || B_invalid_del), FPin_sign, 5'b11111, 1'b1, NaN_in[8:0]};  // quiet and propogate all NaNs.  If original was signaling, or the input is otherwise invalid, raise invalid flag (code 2'b01 in the MSBs)
// if inputs to actual operator are invalid, then flag it here for the operation specified by "invalid_code" 
        else if (trunk_invalid) Rq <= {_invalid_, FPin_sign, 5'b11111, 1'b1, round_mode, _trunk_, _610_, invalid_code};
        else if (FPin_is_zero) Rq <= {exception_code, FPin_sign, 15'b0};                      
        else if (FPin_is_infinite || operator_overflow || div_by_0_del) Rq <= {(div_by_0_del ? _div_x_0_ : exception_code), FPin_sign, 5'b11111, 10'b0};        // if input is infinite then propogate it and its exception code
        else  Rq <= {exception_code, FPin_sign, HP_interm[14:0]};                                  // normal or subnormal
    end                
    else Rq <= 18'b0;
               

    
endmodule
