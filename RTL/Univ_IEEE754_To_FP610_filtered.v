 // Univ_IEEE754_To_FP610_filtered.v
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

module Univ_IEEE754_To_FP610_filtered(
    CLK,
    RESET,
    wren,
    X,
    R,
    round_mode,
    Away,
    Src_Size_q2,        
    input_is_infinite ,
    input_is_normal   ,
    input_is_NaN      ,
    input_is_zero     ,
    input_is_subnormal,
    input_is_invalid  ,
    conv_overflow     ,   
    conv_underflow    ,   
    conv_inexact          
    );
    
input CLK;
input RESET;
input wren;
input [63:0] X;
output [18:0] R;
input [1:0] round_mode; 
input Away;    
input [1:0] Src_Size_q2;
output input_is_infinite;
output input_is_normal;
output input_is_NaN;
output input_is_zero;
output input_is_subnormal;
output input_is_invalid;       
output conv_overflow; 
output conv_underflow;
output conv_inexact;    

//precision (size) encodings
parameter DP = 2'b11;
parameter SP = 2'b10;
parameter HP = 2'b01;

// pipe position where exception detected for NaN diagnostic payload generation
parameter _head_  = 2'b01;
parameter _trunk_ = 2'b10;
parameter _tail_  = 2'b11;

// frontend invalid operation codes for NaN diagnostic payload generation
parameter sig_NaN      = 3'b000;  // singnaling NaN is an operand
parameter mult_oob     = 3'b001;  // multiply operands out of bounds, multiplication(0, INF) or multiplication(?INF, 0)
parameter fsd_mult_oob = 3'b010;  // fused multiply operands out of bounds
parameter add_oob      = 3'b011;  // add or subract or fusedmultadd operands out of bounds
parameter div_oob      = 3'b100;  // division operands out of bounds, division(0, 0) or division(?INF, INF) 
parameter rem_oob      = 3'b101;  // remainder operands out of bounds, remainder(x, y), when y is zero or x is infinite (and neither is NaN)
parameter sqrt_oob     = 3'b110;  // square-root operand out of bounds, operand is less than zero
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

// exception codes for two MSBs [18:17] of result
parameter _no_excpt_   = 2'b00;  // no exception--all good
parameter _overflow_   = 2'b01;  // the operation has overflowed--inexact is always implied--
parameter _invalid_    = 2'b01;  // a NaN will either have exception code of _no_excpt_ or _invalid_.  Read the last three bits of the NaN to determine cause of invalid exception.
parameter _underFlowExact_ = 2'b01;
parameter _underFlowInexact_  = 2'b10;  // inexact underflow (underflows that are also exact are not signaled--per IEEE754-2008, unless immediate alternate handling is enabled)
parameter _div_x_0_    = 2'b10;  // infinity never shows underflow, so we use the same except code for underflow to signal div x 0
parameter _inexact_    = 2'b11;                     

reg [18:0] R;
reg DP_roundit;
reg SP_roundit;

reg input_is_infinite; 
reg input_is_normal; 
reg input_is_NaN;      
reg input_is_zero;     
reg input_is_subnormal;
reg input_is_invalid;
reg conv_overflow;  
reg conv_underflow; 
reg conv_inexact;   

reg [9:0] fraction_in;
reg [5:0] exponent_in;
reg sign_in;

wire [10:0] DP_input_exponent;
wire [51:0] DP_input_fraction;
wire DP_input_sign;
wire DP_input_is_infinite; 
wire DP_input_is_normal; 
wire DP_input_is_NaN;      
wire DP_input_is_zero;     
wire DP_input_is_subnormal;
wire DP_input_is_invalid;

wire [7:0] SP_input_exponent;
wire [22:0] SP_input_fraction;
wire SP_input_sign;
wire SP_input_is_infinite; 
wire SP_input_is_normal; 
wire SP_input_is_NaN;      
wire SP_input_is_zero;     
wire SP_input_is_subnormal;
wire SP_input_is_invalid;

wire [4:0] HP_input_exponent;
wire [9:0] HP_input_fraction;
wire HP_input_sign;
wire HP_input_is_infinite; 
wire HP_input_is_normal; 
wire HP_input_is_NaN;      
wire HP_input_is_zero;     
wire HP_input_is_subnormal;
wire HP_input_is_invalid;

wire [5:0] normalized_exponent;
wire [9:0] normalized_fract;   
wire All_0;

wire roundit; 
       
wire DP_rounding_overflow;
wire SP_rounding_overflow;

wire [15:0] interm_R;

wire [10:0] interm_DP_exponent_in;
wire [7:0]  interm_SP_exponent_in;

wire DP_input_guard;
wire DP_input_round;
wire DP_input_sticky;

wire [2:0] DP_GRS;

wire SP_input_guard;
wire SP_input_round;
wire SP_input_sticky;

wire [2:0] SP_GRS;


assign DP_input_guard = X[41];
assign DP_input_round = X[40];
assign DP_input_sticky = |X[39:0];
assign DP_GRS = {DP_input_guard, DP_input_round, DP_input_sticky}; 

assign DP_input_exponent = X[62:52];
assign DP_input_fraction = X[51:0];
assign DP_input_sign = X[63];
assign DP_input_is_infinite = wren && &X[62:52] && ~|X[51:0];
assign DP_input_is_zero = wren && ~|X[62:0];
assign DP_input_is_NaN = wren && &X[62:52] && |X[51:0];
assign DP_input_is_normal = wren && ~DP_input_is_infinite && ~DP_input_is_subnormal && ~DP_input_is_NaN && ~DP_input_is_invalid;

assign DP_input_is_subnormal = 1'b0;  // subnormal DP inputs are invalid for FP 6 10 operator  


               //                       too large-------|              signaling NaN                        too small-----------|
               //           15 + 1023 = 1038 = 11'h40E  |                   |                       -14 + 1023 = 1009           |
               //                                       |                   |                     1009 - 10 bits for gradual    |
               //                                       |                   |                     underflow = 999 = 11'h3E7     |
               //                                       v                   v                                                   v
//assign DP_input_is_invalid = wren && ((DP_input_exponent > 11'h40E)  /*  leave signaling NaN term out  */  || (DP_input_exponent < 11'h3E7)) && ~DP_input_is_infinite && ~DP_input_is_NaN && ~DP_input_is_zero;
assign DP_input_is_invalid = wren && DP_input_is_NaN && ~X[51];   //signaling NaN

assign DP_conv_overflow = wren && (DP_rounding_overflow || (DP_input_exponent > 11'h40E)) && ~DP_input_is_invalid && ~DP_input_is_infinite && ~DP_input_is_NaN; 

assign DP_conv_underflow = (DP_input_exponent < 11'h3E7) && ~DP_input_is_zero;
assign DP_conv_inexact = wren && DP_conv_overflow || roundit || |DP_GRS;    

assign SP_input_guard = X[12];
assign SP_input_round = X[11];
assign SP_input_sticky = |X[10:0];
assign SP_GRS = {SP_input_guard, SP_input_round, SP_input_sticky}; 

assign SP_input_exponent = X[30:23];
assign SP_input_fraction = X[22:0];
assign SP_input_sign = X[31];
assign SP_input_is_infinite = wren && &X[30:23] && ~|X[22:0];
assign SP_input_is_zero = wren && ~|X[30:0];
assign SP_input_is_NaN = wren && &X[30:23] && |X[21:0];
assign SP_input_is_normal = wren && ~SP_input_is_infinite && ~SP_input_is_subnormal && ~SP_input_is_NaN && ~SP_input_is_invalid;

assign SP_input_is_subnormal = 1'b0; // subnormal SP inputs are invalid for FP 6 10 operator

               //                     too large-------|            signaling NaN                      too small-----------|
               //             15 + 127 = 142 = 8'h8E  |                 |                       -14 + 127 = 113           |
               //                                     |                 |                     113 - 10 bits for gradual   |
               //                                     |                 |                     underflow = 103 = 8'h67     |
               //                                     v                 v                                                 v
//assign SP_input_is_invalid = wren && ((SP_input_exponent > 8'h8E)   /* leave signaling NaN term out */ || (SP_input_exponent < 8'h67 )) && ~SP_input_is_infinite && ~SP_input_is_NaN && ~SP_input_is_zero;
assign DP_input_is_invalid = wren && SP_input_is_NaN && ~X[22];   //signaling NaN

assign SP_conv_overflow =  wren && (SP_rounding_overflow || (SP_input_exponent > 8'h8E)) && ~SP_input_is_invalid && ~SP_input_is_infinite && ~SP_input_is_NaN;

assign SP_conv_underflow =  (SP_input_exponent < 8'h67 ) && ~SP_input_is_zero;
assign SP_conv_inexact = wren && SP_conv_overflow || roundit || |SP_GRS;    

assign HP_input_exponent = X[14:10];
assign HP_input_fraction = X[9:0];
assign HP_input_sign = X[15];
assign HP_input_is_infinite = wren && &X[14:10] && ~|X[9:0];
assign HP_input_is_zero = wren && ~|X[14:0];
assign HP_input_is_NaN = wren && &X[14:10] && |X[8:0];
assign HP_input_is_normal = wren && ~HP_input_is_infinite && ~HP_input_is_subnormal && ~HP_input_is_NaN && ~HP_input_is_invalid;
assign HP_input_is_subnormal =wren &&  ~|X[14:10] && |X[9:0];
assign HP_input_is_invalid = 1'b0;
assign HP_conv_overflow = 1'b0;
assign HP_conv_underflow = 1'b0;  
assign HP_conv_inexact = 1'b0;    

assign interm_DP_exponent_in = DP_input_exponent - 992;         // -1023 + 15 - 15 + 31 = 992
assign DP_rounding_overflow = (interm_R[15:10] > 46);           // 15 + 31 = 46

assign interm_SP_exponent_in = SP_input_exponent[7:0] - 96;     // -127 + 15 - 15 + 31 = 96
assign SP_rounding_overflow = (interm_R[15:10] > 46);           // 15 + 31 = 46 

assign roundit = (Src_Size_q2==DP) ? DP_roundit : SP_roundit;

assign interm_R = {exponent_in, fraction_in} + roundit;  

//subnormal normalizer for FP 6 10 operator               
subn_normalizer_610 normalizer_610(
    .Size_q2     (Src_Size_q2),
    .fract_in (HP_input_fraction[9:0]),
    .normalized_fract   (normalized_fract),
    .normalized_exponent(normalized_exponent),
    .All_0       (All_0)
    );

always @(*)
    if (wren)
        case(Src_Size_q2)
            DP : sign_in = DP_input_sign;
            SP : sign_in = SP_input_sign;
            HP : sign_in = HP_input_sign;
            default : sign_in = 1'b0;
        endcase
    else sign_in = 1'b0;
      
always @(*)
    if (wren)
        case(Src_Size_q2)
            DP : exponent_in = interm_DP_exponent_in[5:0];    
            SP : exponent_in = interm_SP_exponent_in[5:0];    
            HP : exponent_in = {1'b0, HP_input_exponent[4:0]} + 16;  // -15 + 31
            default : exponent_in = 6'b0;
        endcase
    else exponent_in = 6'b0;  
    
always @(*)
    if (wren && (Src_Size_q2==DP))
        case(round_mode)
            NEAREST : if (((DP_GRS==3'b100) && (X[29] || Away)) || (DP_GRS[2] && |DP_GRS[1:0])) DP_roundit = 1'b1;    //when GRS = (3'b100 && lsb) OR when GRS = 101 or 110 or 111 then lsb is don't care
                      else DP_roundit = 1'b0;
            POSINF  : if (~DP_input_sign && |DP_GRS) DP_roundit = 1'b1;
                      else DP_roundit = 1'b0;
            NEGINF  : if (DP_input_sign && |DP_GRS) DP_roundit = 1'b1;
                      else DP_roundit = 1'b0;
            ZERO    : DP_roundit = 1'b0;
        endcase
   else DP_roundit = 1'b0;                  
              
always @(*)
    if (wren && (Src_Size_q2==SP))
        case(round_mode)
            NEAREST : if (((SP_GRS==3'b100) && (X[13] || Away)) || (SP_GRS[2] && |SP_GRS[1:0])) SP_roundit = 1'b1;    //when GRS = (3'b100 && lsb) OR when GRS = 101 or 110 or 111 then lsb is don't care
                      else SP_roundit = 1'b0;
            POSINF  : if (~SP_input_sign && |SP_GRS) SP_roundit = 1'b1;
                      else SP_roundit = 1'b0;
            NEGINF  : if (SP_input_sign && |SP_GRS) SP_roundit = 1'b1;
                      else SP_roundit = 1'b0;
            ZERO    : SP_roundit = 1'b0;
        endcase
   else SP_roundit = 1'b0;                  

    
always @(*)            
    if (wren) 
        case(Src_Size_q2)
            DP : fraction_in = DP_input_fraction[51:42] ;
            SP : fraction_in = SP_input_fraction[22:13] ;
            HP : fraction_in = HP_input_fraction[9:0];
            default : fraction_in = 10'b0;
        endcase
    else fraction_in = 10'b0;
        

always @(posedge CLK or posedge RESET)
    if (RESET) R <= 19'b0;         
    else if (wren) begin
        case(Src_Size_q2)
            DP : begin
                    if (DP_conv_overflow) 
                        case(round_mode)
                            NEAREST : R <= {infinity, sign_in, 6'b111111, 10'b0};                        // infinity for overflows in either direction
                            
                            POSINF  : if (sign_in) R <= {normal, sign_in, 6'b111110, 10'b11_1111_1111};  // most neg finite number for neg overflows
                                      else R <= {infinity, sign_in, 6'b111111, 10'b0};                   // pos infinity for positive overflows
                                                                                                         
                            NEGINF  : if (sign_in) R <= {infinity, sign_in, 6'b111111, 10'b0};           // neg infinity for negative overflows
                                      else R <= {normal, sign_in, 6'b111110, 10'b11_1111_1111};          // most pos finite number for positive overflows
                                      
                            ZERO    : R <= {normal, sign_in, 6'b111110, 10'b11_1111_1111};               // largest magnitude finite number for overflow in either direction
                        endcase
                    else if (DP_input_is_NaN) R <= {NaN, sign_in, 6'b111111, 1'b1, DP_input_fraction[50:42]};  //if signaling, quiet it here 
                    else if (DP_input_is_zero) R <= {zero, sign_in, 16'b0};
                    else if (DP_input_is_infinite) R <= {infinity, sign_in, 6'b111111, 10'b0};
                    else  R <= {normal, sign_in, interm_R[15:0]}; // normal
                 end
            SP : begin
                    if (SP_conv_overflow) 
                        case(round_mode)
                            NEAREST : R <= {infinity, sign_in, 6'b111111, 10'b0};
                            
                            POSINF  : if (sign_in) R <= {normal, sign_in, 6'b111110, 10'b11_1111_1111};  // most neg finite number for neg overflows
                                      else R <= {infinity, sign_in, 6'b111111, 10'b0};                   // pos infinity for positive overflows
                                                                                                         
                            NEGINF  : if (sign_in) R <= {infinity, sign_in, 6'b111111, 10'b0};           // neg infinity for negative overflows
                                      else R <= {normal, sign_in, 6'b111110, 10'b11_1111_1111};          // most pos finite number for positive overflows
                                      
                            ZERO    : R <= {normal, sign_in, 6'b111110, 10'b11_1111_1111};
                        endcase
                    else if (SP_input_is_NaN) R <= {NaN, sign_in, 6'b111111, 1'b1, SP_input_fraction[21:13]};   //if signaling, quiet it here
                    else if (SP_input_is_zero) R <= {zero, sign_in, 16'b0};
                    else if (SP_input_is_infinite) R <= {infinity, sign_in, 6'b111111, 10'b0};
                    else  R <= {normal, sign_in, interm_R[15:0]}; // normal
                 end
            HP : begin
                    if (HP_input_is_subnormal) R <= {normal, sign_in, normalized_exponent, normalized_fract}; 
                    else if (HP_conv_overflow) 
                        case(round_mode)
                            NEAREST : R <= {infinity, sign_in, 6'b111111, 10'b0};
                            
                            POSINF  : if (sign_in) R <= {normal, sign_in, 6'b111110, 10'b11_1111_1111};  // most neg finite number for neg overflows
                                      else R <= {infinity, sign_in, 6'b111111, 10'b0};                   // pos infinity for positive overflows
                                                                                                         
                            NEGINF  : if (sign_in) R <= {infinity, sign_in, 6'b111111, 10'b0};           // neg infinity for negative overflows
                                      else R <= {normal, sign_in, 6'b111110, 10'b11_1111_1111};          // most pos finite number for positive overflows
                                      
                            ZERO    : R <= {normal, sign_in, 6'b111110, 10'b11_1111_1111};
                        endcase
                    else if (HP_input_is_NaN) R <= {NaN, sign_in, 6'b111111,1'b1,  HP_input_fraction[9:0]};  //if signaling, quiet it here
                    else if (HP_input_is_zero) R <= {zero, sign_in, 16'b0};
                    else if (HP_input_is_infinite) R <= {infinity, sign_in, 6'b111111, 10'b0};
                    else  R <= {normal, sign_in, interm_R[15:0]}; // normal
                 end
      default : R <= 19'b0;
        endcase
    end
    else R <= 19'b0;               

always @(posedge CLK or posedge RESET) begin 
    if (RESET) begin
        input_is_infinite  <= 1'b0;
        input_is_normal    <= 1'b0;
        input_is_NaN       <= 1'b0;
        input_is_zero      <= 1'b0;
        input_is_subnormal <= 1'b0;
        input_is_invalid   <= 1'b0;
        conv_overflow      <= 1'b0;
        conv_underflow     <= 1'b0;
        conv_inexact       <= 1'b0;
    end
    else if (wren)
        case(Src_Size_q2)
            DP : begin
                    input_is_infinite  <= DP_input_is_infinite;
                    input_is_normal    <= DP_input_is_normal;
                    input_is_NaN       <= DP_input_is_NaN;
                    input_is_zero      <= DP_input_is_zero;
                    input_is_subnormal <= DP_input_is_subnormal;
                    input_is_invalid   <= DP_input_is_invalid;
                    conv_overflow      <= DP_conv_overflow;
                    conv_underflow     <= DP_conv_underflow;
                    conv_inexact       <= DP_conv_inexact;
                 end   
            SP : begin
                    input_is_infinite  <= SP_input_is_infinite;
                    input_is_normal    <= SP_input_is_normal;
                    input_is_NaN       <= SP_input_is_NaN;
                    input_is_zero      <= SP_input_is_zero;
                    input_is_subnormal <= SP_input_is_subnormal;
                    input_is_invalid   <= SP_input_is_invalid;
                    conv_overflow      <= SP_conv_overflow; 
                    conv_underflow     <= SP_conv_underflow;
                    conv_inexact       <= SP_conv_inexact;  
                 end   
            HP : begin
                    input_is_infinite  <= HP_input_is_infinite;
                    input_is_normal    <= HP_input_is_normal;
                    input_is_NaN       <= HP_input_is_NaN;
                    input_is_zero      <= HP_input_is_zero;
                    input_is_subnormal <= HP_input_is_subnormal;
                    input_is_invalid   <= 1'b0;
                    conv_overflow      <= 1'b0;
                    conv_underflow     <= 1'b0;
                    conv_inexact       <= 1'b0;
                 end   
       default : begin
                    input_is_infinite  <= 1'b0;
                    input_is_normal    <= 1'b0;
                    input_is_NaN       <= 1'b0;
                    input_is_zero      <= 1'b0;
                    input_is_subnormal <= 1'b0;
                    input_is_invalid   <= 1'b0;
                    conv_overflow      <= 1'b0;
                    conv_underflow     <= 1'b0;
                    conv_inexact       <= 1'b0;
                 end   
        endcase
    else begin
            input_is_infinite  <= 1'b0;
            input_is_normal    <= 1'b0;
            input_is_NaN       <= 1'b0;
            input_is_zero      <= 1'b0;
            input_is_subnormal <= 1'b0;
            input_is_invalid   <= 1'b0;
            conv_overflow      <= 1'b0;
            conv_underflow     <= 1'b0;
            conv_inexact       <= 1'b0;
         end   
end


    
endmodule
