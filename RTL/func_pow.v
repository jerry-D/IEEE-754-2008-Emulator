// func_pow.v
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

module func_pow (
    RESET,
    CLK,
    wren,
    Sext_SrcB_q2,
    Sext_SrcA_q2,
    round_mode_del,
    Away_del,
    NaN_del,
    A_sign_del,
    A_invalid_del,
    B_invalid_del,
    A_inexact_del,
    B_inexact_del,
    wraddrs_del,
    wraddrs,
    wrdataA,
    wrdataB,
    rdenA,
    rdaddrsA,
    rddataA,
    rdenB,
    rdaddrsB,
    rddataB,
    ready
    );

input RESET, CLK, wren, rdenA, rdenB;
input [5:0] wraddrs, wraddrs_del, rdaddrsA, rdaddrsB;   // {thread, addrs}
input [18:0] wrdataA, wrdataB;
input Sext_SrcB_q2;
input Sext_SrcA_q2;
input [1:0] round_mode_del;
input Away_del;
input [9:0] NaN_del;
input A_sign_del;
input A_invalid_del;
input B_invalid_del;
input A_inexact_del;
input B_inexact_del;

output [17:0] rddataA, rddataB;
output ready;

//input precision (size) encodings for NaN diagnostic payload generation
parameter _1152_ = 2'b11;
parameter _823_  = 2'b10;
parameter _610_  = 2'b01;
parameter _510_  = 2'b00;

// pipe position where exception detected for NaN diagnostic payload generation
parameter _head_  = 2'b01;    // converted input
parameter _trunk_ = 2'b10;    // ie, the actual operator output
parameter _tail_  = 2'b11;    // converted output

// exception codes for two MSBs [18:17] of result
parameter _no_excpt_   = 2'b00;  // no exception--all good
parameter _overflow_   = 2'b01;  // the operation has overflowed--inexact is always implied--
parameter _invalid_    = 2'b01;  // a NaN will either have exception code of _no_excpt_ or _invalid_.  Read the last three bits of the NaN to determine cause of invalid exception.
parameter _underFlowExact_ = 2'b01;
parameter _underFlowInexact_  = 2'b10;  // inexact underflow (underflows that are also exact are not signaled--per IEEE754-2008, unless immediate alternate handling is enabled)
parameter _div_x_0_    = 2'b10;  // infinity never shows underflow, so we use the same except code for underflow to signal div x 0
parameter _inexact_    = 2'b11;                     

//NaN payload descriptors for out-of-bounds (invalid) operands
parameter sig_NaN      = 3'b000;  // singnaling NaN is an operand--if possible, an incoming sNaN should have the last 3 bits equal to this code
parameter mult_oob     = 3'b001;  // multiply operands out of bounds, multiplication(0, INF) or multiplication(?INF, 0)
parameter fsd_mult_oob = 3'b010;  // fused multiply operands out of bounds
parameter add_oob      = 3'b011;  // add or subract or fusedmultadd operands out of bounds
parameter div_oob      = 3'b100;  // division operands out of bounds, division(0, 0) or division(?INF, INF) 
parameter rem_oob      = 3'b101;  // remainder operands out of bounds, remainder(x, y), when y is zero or x is infinite (and neither is NaN)
parameter sqrt_oob     = 3'b110;  // square-root or log operand out of bounds, operand is less than zero
parameter quantize     = 3'b111;  

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
                       
reg [63:0] semaphor;  // one for each memory location
reg readyA;
reg readyB;

reg wren_del_0,  
    wren_del_1, 
    wren_del_2, 
    wren_del_3, 
    wren_del_4, 
    wren_del_5, 
    wren_del_6, 
    wren_del_7, 
    wren_del_8, 
    wren_del_9, 
    wren_del_10, 
    wren_del_11; 
    
reg [9:0] specCasePowSel_del_0, 
          specCasePowSel_del_1, 
          specCasePowSel_del_2, 
          specCasePowSel_del_3, 
          specCasePowSel_del_4, 
          specCasePowSel_del_5, 
          specCasePowSel_del_6, 
          specCasePowSel_del_7, 
          specCasePowSel_del_8, 
          specCasePowSel_del_9, 
          specCasePowSel_del_10,
          specCasePowSel_del_11;
          
reg [4:0] specCasePownSel_del_0, 
          specCasePownSel_del_1, 
          specCasePownSel_del_2, 
          specCasePownSel_del_3, 
          specCasePownSel_del_4, 
          specCasePownSel_del_5, 
          specCasePownSel_del_6, 
          specCasePownSel_del_7, 
          specCasePownSel_del_8, 
          specCasePownSel_del_9, 
          specCasePownSel_del_10,
          specCasePownSel_del_11;

reg [10:0] specCasePowrSel_del_0, 
           specCasePowrSel_del_1, 
           specCasePowrSel_del_2, 
           specCasePowrSel_del_3, 
           specCasePowrSel_del_4, 
           specCasePowrSel_del_5, 
           specCasePowrSel_del_6, 
           specCasePowrSel_del_7, 
           specCasePowrSel_del_8, 
           specCasePowrSel_del_9, 
           specCasePowrSel_del_10,
           specCasePowrSel_del_11;

                              
reg [18:0] y_del_0,
           y_del_1,   
           y_del_2,
           y_del_3,
           y_del_4,
           y_del_5,
           y_del_6,
           y_del_7,
           y_del_8,
           y_del_9,
           y_del_10,
           y_del_11;
           
reg [18:0] x_del_0,
           x_del_1,   
           x_del_2,
           x_del_3,
           x_del_4,
           x_del_5,
           x_del_6,
           x_del_7,
           x_del_8,
           x_del_9,
           x_del_10,
           x_del_11;

reg y_is_odd_integer_del_0,
    y_is_odd_integer_del_1,       
    y_is_odd_integer_del_2,       
    y_is_odd_integer_del_3,       
    y_is_odd_integer_del_4,       
    y_is_odd_integer_del_5,       
    y_is_odd_integer_del_6,
    y_is_odd_integer_del_7,
    y_is_odd_integer_del_8,
    y_is_odd_integer_del_9;
    
reg Sext_SrcB_q2_del_0, 
    Sext_SrcB_q2_del_1,        
    Sext_SrcB_q2_del_2,        
    Sext_SrcB_q2_del_3,        
    Sext_SrcB_q2_del_4,        
    Sext_SrcB_q2_del_5,        
    Sext_SrcB_q2_del_6,        
    Sext_SrcB_q2_del_7,        
    Sext_SrcB_q2_del_8,        
    Sext_SrcB_q2_del_9,        
    Sext_SrcB_q2_del_10,       
    Sext_SrcB_q2_del_11;
    
reg Sext_SrcA_q2_del_0, 
    Sext_SrcA_q2_del_1, 
    Sext_SrcA_q2_del_2, 
    Sext_SrcA_q2_del_3, 
    Sext_SrcA_q2_del_4, 
    Sext_SrcA_q2_del_5, 
    Sext_SrcA_q2_del_6, 
    Sext_SrcA_q2_del_7, 
    Sext_SrcA_q2_del_8, 
    Sext_SrcA_q2_del_9, 
    Sext_SrcA_q2_del_10,
    Sext_SrcA_q2_del_11;

    
reg [21:0] Rlog613_q1;
reg [21:0] Rmul613_q1;      
reg [21:0] Rexp613_q1;

wire ready;

wire [17:0] rddataA, rddataB; 

wire [18:0] x;
wire [18:0] y;

wire x_sign_del;

wire [21:0] Rlog613;
wire [21:0] Rmul613;
wire [21:0] Rexp613;
wire [17:0] R18;

wire y_is_pos_zero;
wire y_is_neg_zero;
wire y_is_pos_neg_zero;
wire y_is_neg_infinity;
wire y_is_pos_infinity;
wire y_is_pos_neg_infinity;
wire y_is_odd_integer_LT_zero;
wire y_is_finite_LT_zero_and_not_odd_integer;
wire y_is_finite_GT_zero_and_odd_integer;
wire y_is_finite_GT_zero_and_not_odd_integer;
wire y_is_finite_non_integer;
wire y_is_integer;

wire x_is_infinite;
wire x_is_finite_and_LT_zero;
wire x_is_minus_one;
wire x_is_plus_one;
wire x_is_plus_or_minus_one;
wire x_is_pos_zero;
wire x_is_neg_zero;
wire x_is_pos_or_neg_zero;
wire x_is_LT_zero;
wire x_is_LT_zero_and_y_is_integer;

wire [5:0]  xExp;
wire [73:0] xShifter;
wire [31:0] xIntegerPart;
wire [40:0] xFractionPart;
                       
wire [5:0]  yExp;
wire [73:0] yShifter;
wire [31:0] yIntegerPart;
wire [40:0] yFractionPart;

wire y_is_odd_integer;
wire x_is_pos_neg_zero_and_y_is_odd_integer_LT_zero;
wire x_is_pos_neg_zero_and_y_is_neg_infinity;
wire x_is_pos_neg_zero_and_y_is_pos_infinity;
wire x_is_pos_neg_zero_and_y_is_finite_LT_zero_and_not_odd_integer;
wire x_is_pos_neg_zero_and_y_is_finite_GT_zero_and_odd_integer;
wire x_is_pos_neg_zero_and_y_is_finite_GT_zero_and_not_odd_integer;
wire x_is_minus_one_and_y_is_pos_neg_infinity;
wire x_is_finite_and_LT_zero_and_y_is_finite_non_integer;

wire [9:0] specCasePowSel;
wire [4:0] specCasePownSel;
wire [10:0] specCasePowrSel;

wire y_is_finite;
wire x_is_finite;
wire x_is_NaN;
wire y_is_NaN;

wire pownMode;
wire powrMode;

assign pownMode = Sext_SrcB_q2_del_11;
assign powrMode = Sext_SrcA_q2_del_11;

assign x = wrdataA;
assign y = wrdataB;

assign x_sign_del = A_sign_del;

assign xExp = x[15:10]; 
assign xShifter = {1'b1, x[9:0]} << xExp;
assign xIntegerPart = xShifter[73:41];
assign xFractionPart = xShifter[40:0];

assign yExp = y[15:10]; 
assign yShifter = {1'b1, y[9:0]} << yExp;
assign yIntegerPart = yShifter[73:41];
assign yFractionPart = yShifter[40:0];

assign y_is_NaN = &y[15:10] && |y[9:0];
assign y_is_integer = |yIntegerPart && ~|yFractionPart && ~y_is_pos_neg_infinity;
assign y_is_odd_integer = y_is_integer && yIntegerPart[0];
assign y_is_even_integer = y_is_integer && ~yIntegerPart[0];
assign y_is_finite = ~y_is_pos_neg_infinity && ~y_is_NaN;

assign y_is_pos_zero = ~|y[15:0];
assign y_is_neg_zero = y[16] && ~|y[15:0];
assign y_is_pos_neg_zero = ~|y[15:0];
assign y_is_neg_infinity = y[16] && &y[15:10] && ~|y[9:0];
assign y_is_pos_infinity = ~y[16] && &y[15:10] && ~|y[9:0];
assign y_is_pos_neg_infinity = &y[15:10] && ~|y[9:0];
assign y_is_odd_integer_LT_zero = y[16] && ~y_is_pos_neg_zero && y_is_odd_integer;
assign y_is_finite_LT_zero_and_not_odd_integer = ~y_is_pos_neg_infinity && y[16] && ~y_is_odd_integer && ~y_is_pos_neg_zero;
assign y_is_finite_GT_zero_and_odd_integer = ~y_is_pos_neg_infinity && ~y_is_pos_neg_zero && ~y[16] && y_is_odd_integer;
assign y_is_finite_GT_zero_and_not_odd_integer = ~y_is_pos_neg_infinity && ~y_is_pos_neg_zero && ~y[16] && ~y_is_odd_integer;
assign y_is_finite_non_integer = ~y_is_pos_neg_infinity && ~y_is_integer && ~y_is_pos_neg_zero;

assign x_is_NaN = &x[15:10] && |x[9:0];
assign x_is_infinite = &x[15:10] && ~|x[9:0];
assign x_is_finite_and_LT_zero = ~x_is_infinite && ~ x_is_pos_or_neg_zero && x[16];
assign x_is_minus_one = x[16] && (xIntegerPart==32'h0001) && ~|xFractionPart;
assign x_is_plus_one = ~x[16] && (xIntegerPart==32'h0001) && ~|xFractionPart;
assign x_is_plus_or_minus_one = x_is_minus_one || x_is_plus_one;
assign x_is_pos_zero = x_is_pos_or_neg_zero && ~x[16];
assign x_is_neg_zero = x_is_pos_or_neg_zero && x[16];
assign x_is_pos_or_neg_zero = ~|x[15:0];
assign x_is_LT_zero = ~x_is_pos_or_neg_zero && x[16];
assign x_is_LT_zero_and_y_is_integer = x_is_LT_zero && y_is_integer;
assign x_is_GT_zero_and_y_is_pos_neg_zero = ~x_is_infinite && ~x_is_pos_or_neg_zero && ~x_is_NaN && ~x[16] && y_is_pos_neg_zero;
assign x_is_finite = ~x_is_infinite && ~x_is_NaN;

//"pow" special handling signals
assign x_is_pos_neg_zero_and_y_is_odd_integer_LT_zero = x_is_pos_or_neg_zero && y_is_odd_integer_LT_zero;
assign x_is_pos_neg_zero_and_y_is_neg_infinity = x_is_pos_or_neg_zero && y_is_neg_infinity;
assign x_is_pos_neg_zero_and_y_is_pos_infinity = x_is_pos_or_neg_zero && y_is_pos_infinity;
assign x_is_pos_neg_zero_and_y_is_finite_LT_zero_and_not_odd_integer = x_is_pos_or_neg_zero && y_is_finite_LT_zero_and_not_odd_integer;
assign x_is_pos_neg_zero_and_y_is_finite_GT_zero_and_odd_integer = x_is_pos_or_neg_zero && y_is_finite_GT_zero_and_odd_integer;
assign x_is_pos_neg_zero_and_y_is_finite_GT_zero_and_not_odd_integer = x_is_pos_or_neg_zero && y_is_finite_GT_zero_and_not_odd_integer;
assign x_is_minus_one_and_y_is_pos_neg_infinity = x_is_minus_one && y_is_pos_neg_infinity;
assign x_is_finite_and_LT_zero_and_y_is_finite_non_integer = x_is_finite_and_LT_zero && y_is_finite_non_integer;


assign specCasePowSel = {y_is_pos_neg_zero, 
                         x_is_pos_neg_zero_and_y_is_odd_integer_LT_zero,
                         x_is_pos_neg_zero_and_y_is_neg_infinity,
                         x_is_pos_neg_zero_and_y_is_pos_infinity,
                         x_is_pos_neg_zero_and_y_is_finite_LT_zero_and_not_odd_integer,
                         x_is_pos_neg_zero_and_y_is_finite_GT_zero_and_odd_integer,
                         x_is_minus_one_and_y_is_pos_neg_infinity,
                         x_is_plus_one,
                         x_is_finite_and_LT_zero_and_y_is_finite_non_integer};                      
                      
//"pown" special handling signals for integrals only
assign specCasePownSel = { y_is_pos_neg_zero,
                           x_is_pos_neg_zero_and_y_is_odd_integer_LT_zero,
                          (x_is_pos_neg_zero_and_y_is_finite_LT_zero_and_not_odd_integer && y_is_integer),
                          (x_is_pos_or_neg_zero && y_is_even_integer && ~y[16]),
                          (x_is_pos_or_neg_zero && y_is_odd_integer && ~y[16])};

//"powr" special handling signals for considering only x^y = e ^ (y * ln(x))
assign specCasePowrSel = { x_is_GT_zero_and_y_is_pos_neg_zero,
                          (x_is_pos_or_neg_zero && y_is_finite && ~y_is_pos_neg_zero && y[16]),
                          (x_is_pos_or_neg_zero && y_is_neg_infinity),
                          (x_is_pos_or_neg_zero && y_is_finite && ~y_is_pos_neg_zero && ~y[16]),
                          (x_is_plus_one && y_is_finite),
                           x_is_LT_zero,
                          (x_is_pos_or_neg_zero && y_is_pos_neg_zero),
                          (x_is_infinite && ~x[16] && y_is_pos_neg_zero),
                          (x_is_plus_one && y_is_pos_neg_infinity),
                          (x_is_finite && ~x[16] && y_is_NaN),
                           x_is_NaN}; 


assign ready = readyA && readyB;                        
      
FPLog613 FPLog613(      //log pipe is 6 clocks deep
    .clk (CLK ), 
    .rst (RESET ),
    .X   ({x[18:17], 1'b0, x[15:0], 3'b0}),
    .R   (Rlog613 )            
    );

always @(posedge CLK or posedge RESET)   //1 clock
    if (RESET) Rlog613_q1 <= 22'b0;
    else Rlog613_q1 <= Rlog613;

FPMul613 FPMul613(     //mul pipe is 0 clocks deep
    .clk (CLK ), 
    .rst (RESET ),
    .X   ({y_del_6, 3'b0}),
    .Y   (Rlog613_q1),  
    .R   (Rmul613 )      
    );
    
always @(posedge CLK or posedge RESET) //1 clock
    if (RESET) Rmul613_q1 <= 22'b0;
    else Rmul613_q1 <= Rmul613;

FPExp613 FPExp613(    //exp pipe is 2 clocks deep
    .clk (CLK ), 
    .rst (RESET ),
    .X   (Rmul613_q1),
    .R   (Rexp613)            
    );
    
always @(posedge CLK or posedge RESET)  //1 clock
    if (RESET) Rexp613_q1 <= 22'b0;
    else if (x_is_LT_zero_and_y_is_integer) Rexp613_q1 <= {Rexp613[21:20], y_is_odd_integer_del_9, Rexp613[18:0]};  //for x < 0 && integer Y
    else Rexp613_q1 <= Rexp613;
    
FP610_To_IEEE754_510_filtered FP610toIEEE510(
    .CLK               (CLK          ),
    .RESET             (RESET        ),
    .wren              (wren_del_10  ),     
    .round_mode        (round_mode_del),    
    .Away              (Away_del     ),
    .trunk_invalid     (1'b0         ),
    .NaN_in            (NaN_del      ),     
    .invalid_code      (3'b000       ),     
    .operator_overflow (1'b0         ),  
    .operator_underflow(1'b0         ),    
    .div_by_0_del      (1'b0         ),     
    .A_invalid_del     (A_invalid_del),     
    .B_invalid_del     (B_invalid_del),     
    .A_inexact_del     (A_inexact_del),     
    .B_inexact_del     (B_inexact_del),     
    .X                 (Rexp613_q1[21:3]),     
    .Rq                (R18          ),     
    .G_in              (Rexp613_q1[2]),     
    .R_in              (Rexp613_q1[1]),     
    .S_in              (Rexp613_q1[0])      
    );                       


reg [17:0] R18q;
reg [17:0] R18pow;
reg [17:0] R18pown;
reg [17:0] R18powr;

always @(*)
    casex(specCasePowSel_del_11)                                           //exceptional cases for "pow" cited from IEEE754-2008 spec Page 44 9.2.1 
       10'b1xxxxxxxxx : R18pow = {2'b00, 1'b0, 5'b01111, 10'b0};              //"pow (x, ±0) is 1 for any x (even a zero, quiet NaN, or infinity)"
       10'b01xxxxxxxx : R18pow = {_div_x_0_, x_sign_del, 5'b11111, 10'b0};    //"pow (+/-inf, y) is +/-inf and signals the divideByZero exception for y an odd integer < 0"
       10'b001xxxxxxx : R18pow = {2'b00, 1'b0, 5'b11111, 10'b0};              //"pow (+/-0, -inf) is +inf with no exception"
       10'b0001xxxxxx : R18pow = {2'b00, 1'b0, 5'b00000, 10'b0};              //"pow (+/-0, +inf) is +0 with no exception"
       10'b00001xxxxx : R18pow = {_div_x_0_, 1'b0, 5'b11111, 10'b0};          //"pow (+/-0, y) is +inf and signals the divideByZero exception for finite y < 0 and not an odd integer"
       10'b000001xxxx : R18pow = {2'b00, x_sign_del, 5'b00000, 10'b0};        //"pow (±0, y) is ±0 for finite y > 0 an odd integer
       10'b0000001xxx : R18pow = {2'b00, 1'b0, 5'b00000, 10'b0};              //"pow (±0, y) is +0 for finite y > 0 and not an odd integer
       10'b00000001xx : R18pow = {2'b00, 1'b0, 5'b01111, 10'b0};              //"pow (-1, +/-inf} is 1 with no exception"
       10'b000000001x : R18pow = {2'b00, 1'b0, 5'b01111, 10'b0};              //"pow (+1, y) is 1 for any y (even a quiet NaN)"
       10'b0000000001 : R18pow = {_invalid_, 1'b0, 5'b11111, 1'b1, 8'hA5};    //"pow (x, y) signals the invalid operation exception for finite x < 0 and finite non-integer y"
              default : R18pow = R18;
    endcase
    
always @(*)
    casex(specCasePownSel_del_11)
        5'b1xxxx : R18pown = {2'b00, 1'b0, 5'b01111, 10'b0}; 
        5'b01xxx : R18pown = {_div_x_0_, x_sign_del, 5'b11111, 10'b0};
        5'b001xx : R18pown = {_div_x_0_, 1'b0, 5'b11111, 10'b0};
        5'b0001x : R18pown = {2'b00, 1'b0, 5'b00000, 10'b0};
        5'b00001 : R18pown = {2'b00, x_sign_del, 5'b00000, 10'b0};
         default : R18pown = R18;
    endcase
    
always @(*)
    casex(specCasePowrSel_del_11)
       11'b1xxxxxxxxxx : R18powr = {2'b00, 1'b0, 5'b01111, 10'b0};
       11'b01xxxxxxxxx : R18powr = {_div_x_0_, 1'b0, 5'b11111, 10'b0};
       11'b001xxxxxxxx : R18powr = {2'b00, 1'b0, 5'b11111, 10'b0};
       11'b0001xxxxxxx : R18powr = {2'b00, 1'b0, 5'b00000, 10'b0};
       11'b00001xxxxxx : R18powr = {2'b00, 1'b0, 5'b01111, 10'b0};
       11'b000001xxxxx : R18powr = {_invalid_, 1'b0, 5'b11111, 1'b1, 8'hA6};
       11'b0000001xxxx : R18powr = {_invalid_, 1'b0, 5'b11111, 1'b1, 8'hA7};
       11'b00000001xxx : R18powr = {_invalid_, 1'b0, 5'b11111, 1'b1, 8'hA8};
       11'b000000001xx : R18powr = {_invalid_, 1'b0, 5'b11111, 1'b1, 8'hA9};
       11'b0000000001x : R18powr = y_del_11; 
       11'b00000000001 : R18powr = x_del_11;
               default : R18powr = R18;
    endcase

always @(*)
    if (pownMode) R18q = R18pown;
    else if (powrMode) R18q = R18powr; 
    else R18q = R18pow; 
                          
//RAM64x34tp ram64(       
RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(18))
    ram64_pow(
    .CLK        (CLK     ),
    .wren       (wren_del_11 ),
    .wraddrs    (wraddrs_del ),   
    .wrdata     (R18q    ), 
    .rdenA      (rdenA   ),   
    .rdaddrsA   (rdaddrsA),
    .rddataA    (rddataA ),
    .rdenB      (rdenB   ),
    .rdaddrsB   (rdaddrsB),
    .rddataB    (rddataB ));



always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        wren_del_0  <= 1'b0;
        wren_del_1  <= 1'b0;
        wren_del_2  <= 1'b0;
        wren_del_3  <= 1'b0;
        wren_del_4  <= 1'b0;
        wren_del_5  <= 1'b0;
        wren_del_6  <= 1'b0;
        wren_del_7  <= 1'b0;
        wren_del_8  <= 1'b0;
        wren_del_9  <= 1'b0;
        wren_del_10 <= 1'b0;
        wren_del_11 <= 1'b0;
    end    
    else begin
        wren_del_0  <= wren;
        wren_del_1  <= wren_del_0 ;
        wren_del_2  <= wren_del_1 ;
        wren_del_3  <= wren_del_2 ;
        wren_del_4  <= wren_del_3 ;
        wren_del_5  <= wren_del_4 ;
        wren_del_6  <= wren_del_5 ;
        wren_del_7  <= wren_del_6 ;
        wren_del_8  <= wren_del_7 ;
        wren_del_9  <= wren_del_8 ;
        wren_del_10 <= wren_del_9 ;
        wren_del_11 <= wren_del_10;
    end                    
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        specCasePowSel_del_0  <= 10'b0;
        specCasePowSel_del_1  <= 10'b0;
        specCasePowSel_del_2  <= 10'b0;
        specCasePowSel_del_3  <= 10'b0;
        specCasePowSel_del_4  <= 10'b0;
        specCasePowSel_del_5  <= 10'b0;
        specCasePowSel_del_6  <= 10'b0;
        specCasePowSel_del_7  <= 10'b0;
        specCasePowSel_del_8  <= 10'b0;
        specCasePowSel_del_9  <= 10'b0;
        specCasePowSel_del_10 <= 10'b0;
        specCasePowSel_del_11 <= 10'b0;
    end    
    else begin
        specCasePowSel_del_0  <= specCasePowSel;
        specCasePowSel_del_1  <= specCasePowSel_del_0 ;
        specCasePowSel_del_2  <= specCasePowSel_del_1 ;
        specCasePowSel_del_3  <= specCasePowSel_del_2 ;
        specCasePowSel_del_4  <= specCasePowSel_del_3 ;
        specCasePowSel_del_5  <= specCasePowSel_del_4 ;
        specCasePowSel_del_6  <= specCasePowSel_del_5 ;
        specCasePowSel_del_7  <= specCasePowSel_del_6 ;
        specCasePowSel_del_8  <= specCasePowSel_del_7 ;
        specCasePowSel_del_9  <= specCasePowSel_del_8 ;
        specCasePowSel_del_10 <= specCasePowSel_del_9 ;
        specCasePowSel_del_11 <= specCasePowSel_del_10;
    end                    
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        specCasePownSel_del_0  <= 5'b0;
        specCasePownSel_del_1  <= 5'b0;
        specCasePownSel_del_2  <= 5'b0;
        specCasePownSel_del_3  <= 5'b0;
        specCasePownSel_del_4  <= 5'b0;
        specCasePownSel_del_5  <= 5'b0;
        specCasePownSel_del_6  <= 5'b0;
        specCasePownSel_del_7  <= 5'b0;
        specCasePownSel_del_8  <= 5'b0;
        specCasePownSel_del_9  <= 5'b0;
        specCasePownSel_del_10 <= 5'b0;
        specCasePownSel_del_11 <= 5'b0;
    end    
    else begin
        specCasePownSel_del_0  <= specCasePownSel;
        specCasePownSel_del_1  <= specCasePownSel_del_0 ;
        specCasePownSel_del_2  <= specCasePownSel_del_1 ;
        specCasePownSel_del_3  <= specCasePownSel_del_2 ;
        specCasePownSel_del_4  <= specCasePownSel_del_3 ;
        specCasePownSel_del_5  <= specCasePownSel_del_4 ;
        specCasePownSel_del_6  <= specCasePownSel_del_5 ;
        specCasePownSel_del_7  <= specCasePownSel_del_6 ;
        specCasePownSel_del_8  <= specCasePownSel_del_7 ;
        specCasePownSel_del_9  <= specCasePownSel_del_8 ;
        specCasePownSel_del_10 <= specCasePownSel_del_9 ;
        specCasePownSel_del_11 <= specCasePownSel_del_10;
    end                    
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        specCasePowrSel_del_0  <= 11'b0;
        specCasePowrSel_del_1  <= 11'b0;
        specCasePowrSel_del_2  <= 11'b0;
        specCasePowrSel_del_3  <= 11'b0;
        specCasePowrSel_del_4  <= 11'b0;
        specCasePowrSel_del_5  <= 11'b0;
        specCasePowrSel_del_6  <= 11'b0;
        specCasePowrSel_del_7  <= 11'b0;
        specCasePowrSel_del_8  <= 11'b0;
        specCasePowrSel_del_9  <= 11'b0;
        specCasePowrSel_del_10 <= 11'b0;
        specCasePowrSel_del_11 <= 11'b0;
    end    
    else begin
        specCasePowrSel_del_0  <= specCasePowrSel;
        specCasePowrSel_del_1  <= specCasePowrSel_del_0 ;
        specCasePowrSel_del_2  <= specCasePowrSel_del_1 ;
        specCasePowrSel_del_3  <= specCasePowrSel_del_2 ;
        specCasePowrSel_del_4  <= specCasePowrSel_del_3 ;
        specCasePowrSel_del_5  <= specCasePowrSel_del_4 ;
        specCasePowrSel_del_6  <= specCasePowrSel_del_5 ;
        specCasePowrSel_del_7  <= specCasePowrSel_del_6 ;
        specCasePowrSel_del_8  <= specCasePowrSel_del_7 ;
        specCasePowrSel_del_9  <= specCasePowrSel_del_8 ;
        specCasePowrSel_del_10 <= specCasePowrSel_del_9 ;
        specCasePowrSel_del_11 <= specCasePowrSel_del_10;
    end                    
end


always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        Sext_SrcB_q2_del_0  <= 1'b0;
        Sext_SrcB_q2_del_1  <= 1'b0;
        Sext_SrcB_q2_del_2  <= 1'b0;
        Sext_SrcB_q2_del_3  <= 1'b0;
        Sext_SrcB_q2_del_4  <= 1'b0;
        Sext_SrcB_q2_del_5  <= 1'b0;
        Sext_SrcB_q2_del_6  <= 1'b0;
        Sext_SrcB_q2_del_7  <= 1'b0;
        Sext_SrcB_q2_del_8  <= 1'b0;
        Sext_SrcB_q2_del_9  <= 1'b0;
        Sext_SrcB_q2_del_10 <= 1'b0;
        Sext_SrcB_q2_del_11 <= 1'b0;
    end    
    else begin
        Sext_SrcB_q2_del_0  <= Sext_SrcB_q2;
        Sext_SrcB_q2_del_1  <= Sext_SrcB_q2_del_0 ;
        Sext_SrcB_q2_del_2  <= Sext_SrcB_q2_del_1 ;
        Sext_SrcB_q2_del_3  <= Sext_SrcB_q2_del_2 ;
        Sext_SrcB_q2_del_4  <= Sext_SrcB_q2_del_3 ;
        Sext_SrcB_q2_del_5  <= Sext_SrcB_q2_del_4 ;
        Sext_SrcB_q2_del_6  <= Sext_SrcB_q2_del_5 ;
        Sext_SrcB_q2_del_7  <= Sext_SrcB_q2_del_6 ;
        Sext_SrcB_q2_del_8  <= Sext_SrcB_q2_del_7 ;
        Sext_SrcB_q2_del_9  <= Sext_SrcB_q2_del_8 ;
        Sext_SrcB_q2_del_10 <= Sext_SrcB_q2_del_9 ;
        Sext_SrcB_q2_del_11 <= Sext_SrcB_q2_del_10;
    end                                           
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        Sext_SrcA_q2_del_0  <= 1'b0;
        Sext_SrcA_q2_del_1  <= 1'b0;
        Sext_SrcA_q2_del_2  <= 1'b0;
        Sext_SrcA_q2_del_3  <= 1'b0;
        Sext_SrcA_q2_del_4  <= 1'b0;
        Sext_SrcA_q2_del_5  <= 1'b0;
        Sext_SrcA_q2_del_6  <= 1'b0;
        Sext_SrcA_q2_del_7  <= 1'b0;
        Sext_SrcA_q2_del_8  <= 1'b0;
        Sext_SrcA_q2_del_9  <= 1'b0;
        Sext_SrcA_q2_del_10 <= 1'b0;
        Sext_SrcA_q2_del_11 <= 1'b0;
    end    
    else begin
        Sext_SrcA_q2_del_0  <= Sext_SrcA_q2;
        Sext_SrcA_q2_del_1  <= Sext_SrcA_q2_del_0 ;
        Sext_SrcA_q2_del_2  <= Sext_SrcA_q2_del_1 ;
        Sext_SrcA_q2_del_3  <= Sext_SrcA_q2_del_2 ;
        Sext_SrcA_q2_del_4  <= Sext_SrcA_q2_del_3 ;
        Sext_SrcA_q2_del_5  <= Sext_SrcA_q2_del_4 ;
        Sext_SrcA_q2_del_6  <= Sext_SrcA_q2_del_5 ;
        Sext_SrcA_q2_del_7  <= Sext_SrcA_q2_del_6 ;
        Sext_SrcA_q2_del_8  <= Sext_SrcA_q2_del_7 ;
        Sext_SrcA_q2_del_9  <= Sext_SrcA_q2_del_8 ;
        Sext_SrcA_q2_del_10 <= Sext_SrcA_q2_del_9 ;
        Sext_SrcA_q2_del_11 <= Sext_SrcA_q2_del_10;
    end                                           
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        y_del_0  <= 18'b0;
        y_del_1  <= 18'b0;
        y_del_2  <= 18'b0;
        y_del_3  <= 18'b0;
        y_del_4  <= 18'b0;
        y_del_5  <= 18'b0;
        y_del_6  <= 18'b0;
        y_del_7  <= 18'b0;
        y_del_8  <= 18'b0;
        y_del_9  <= 18'b0;
        y_del_10 <= 18'b0;
        y_del_11 <= 18'b0;
    end    
    else begin
        y_del_0  <= y;
        y_del_1  <= y_del_0 ;
        y_del_2  <= y_del_1 ;
        y_del_3  <= y_del_2 ;
        y_del_4  <= y_del_3 ;
        y_del_5  <= y_del_4 ;
        y_del_6  <= y_del_5 ;
        y_del_7  <= y_del_6 ;
        y_del_8  <= y_del_7 ;
        y_del_9  <= y_del_8 ;
        y_del_10 <= y_del_9 ;
        y_del_11 <= y_del_10 ;
    end                    
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        x_del_0  <= 18'b0;
        x_del_1  <= 18'b0;
        x_del_2  <= 18'b0;
        x_del_3  <= 18'b0;
        x_del_4  <= 18'b0;
        x_del_5  <= 18'b0;
        x_del_6  <= 18'b0;
        x_del_7  <= 18'b0;
        x_del_8  <= 18'b0;
        x_del_9  <= 18'b0;
        x_del_10 <= 18'b0;
        x_del_11 <= 18'b0;
    end    
    else begin
        x_del_0  <= x;
        x_del_1  <= x_del_0 ;
        x_del_2  <= x_del_1 ;
        x_del_3  <= x_del_2 ;
        x_del_4  <= x_del_3 ;
        x_del_5  <= x_del_4 ;
        x_del_6  <= x_del_5 ;
        x_del_7  <= x_del_6 ;
        x_del_8  <= x_del_7 ;
        x_del_9  <= x_del_8 ;
        x_del_10 <= x_del_9 ;
        x_del_11 <= x_del_10 ;
    end                    
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        y_is_odd_integer_del_0 <= 1'b0;
        y_is_odd_integer_del_1 <= 1'b0;
        y_is_odd_integer_del_2 <= 1'b0;
        y_is_odd_integer_del_3 <= 1'b0;
        y_is_odd_integer_del_4 <= 1'b0;
        y_is_odd_integer_del_5 <= 1'b0;
        y_is_odd_integer_del_6 <= 1'b0;
        y_is_odd_integer_del_7 <= 1'b0;
        y_is_odd_integer_del_8 <= 1'b0;
        y_is_odd_integer_del_9 <= 1'b0;
    end    
    else begin
        y_is_odd_integer_del_0 <= y_is_odd_integer;
        y_is_odd_integer_del_1 <= y_is_odd_integer_del_0;
        y_is_odd_integer_del_2 <= y_is_odd_integer_del_1;
        y_is_odd_integer_del_3 <= y_is_odd_integer_del_2;
        y_is_odd_integer_del_4 <= y_is_odd_integer_del_3;
        y_is_odd_integer_del_5 <= y_is_odd_integer_del_4;
        y_is_odd_integer_del_6 <= y_is_odd_integer_del_5;
        y_is_odd_integer_del_7 <= y_is_odd_integer_del_6;
        y_is_odd_integer_del_8 <= y_is_odd_integer_del_7;
        y_is_odd_integer_del_9 <= y_is_odd_integer_del_8;
    end                    
end
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (wren) semaphor[wraddrs] <= 1'b0;
        if (wren_del_11) semaphor[wraddrs_del] <= 1'b1;
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
