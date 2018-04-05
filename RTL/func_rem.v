 // func_rem.v
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

module func_rem (
    RESET,
    CLK,
    NaN_del,
    wren,
    A_sign_del,
    A_invalid_del,
    A_is_infinite_del,
    A_is_NaN_del,
    A_is_normal_del,
    A_is_subnormal_del,
    B_invalid_del,
    B_is_infinite_del,    
    B_is_zero_del,
    B_is_NaN_del,
    wraddrs,
    wraddrs_del,
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
input [9:0] NaN_del;
input [5:0] wraddrs, wraddrs_del, rdaddrsA, rdaddrsB;
input [18:0] wrdataA, wrdataB;
input A_sign_del;
input A_invalid_del;
input A_is_infinite_del;
input A_is_NaN_del;
input A_is_normal_del;
input A_is_subnormal_del;
input B_invalid_del;
input B_is_infinite_del;
input B_is_zero_del;
input B_is_NaN_del;

output [17:0] rddataA, rddataB;
output ready;

//input precision (size) encodings for NaN diagnostic payload generation
parameter _1152_ = 2'b11;     //DP
parameter _823_  = 2'b10;     //SP
parameter _510_  = 2'b01;     //HP
parameter _610_  = 2'b00;     //FP610

// pipe position where exception detected for NaN diagnostic payload generation
parameter _head_  = 2'b01;    // converted input
parameter _trunk_ = 2'b10;    // ie, the actual operator output
parameter _tail_  = 2'b11;    // converted output

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

parameter sig_NaN      = 3'b000;  // singnaling NaN is an operand
parameter mult_oob     = 3'b001;  // multiply operands out of bounds, multiplication(0, INF) or multiplication(?INF, 0)
parameter fsd_mult_oob = 3'b010;  // fused multiply operands out of bounds
parameter add_oob      = 3'b011;  // add or subract or fusedmultadd operands out of bounds
parameter div_oob      = 3'b100;  // division operands out of bounds, division(0, 0) or division(?INF, INF) 
parameter rem_oob      = 3'b101;  // remainder operands out of bounds, remainder(x, y), when y is zero or x is infinite (and neither is NaN)
parameter sqrt_oob     = 3'b110;  // square-root or log operand out of bounds, operand is less than zero
parameter quantize     = 3'b111;  

                       
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

reg [18:0] wrdataA_del_0,
           wrdataA_del_1,
           wrdataA_del_2,
           wrdataA_del_3,
           wrdataA_del_4,
           wrdataA_del_5,
           wrdataA_del_6,
           wrdataA_del_7,
           wrdataA_del_8,
           wrdataA_del_9,
           wrdataA_del_10,
           wrdataA_del_11;

reg [18:0] wrdataB_del_0,
           wrdataB_del_1,
           wrdataB_del_2,
           wrdataB_del_3,
           wrdataB_del_4,
           wrdataB_del_5,
           wrdataB_del_6;
           
wire guard, 
     round, 
     sticky;
           

wire ready;

wire [17:0] rddataA, rddataB;
wire [18:0] R610_div;
wire [17:0] R18;

assign ready = readyA && readyB;
wire G_div;
wire R_div;
wire S_div;
wire [2:0] GRS_div;
assign GRS_div = {G_div, R_div, S_div}; 
wire roundit_div;
assign roundit_div = ((GRS_div==3'b100) && R610_div[0]) || (GRS_div[2] && |GRS_div[1:0]);  //nearest

FPDiv610 FPDiv610(
    .clk (CLK   ), 
    .rst (RESET ),
    .X   (wrdataA),
    .Y   (wrdataB),  
    .R   (R610_div ),       
    .IEEEg_d1 (G_div ),    
    .IEEEr_d1 (R_div ),    
    .IEEEs_d1 (S_div ),     
    .roundit (1'b0)          
    );

wire [16:0] R17_integer;
reg  [16:0] R17_integerq;

FP610_To_FXP FP610_To_FXP(          
    .clk  (CLK      ),
    .rst  (RESET    ),
    .I    ({R610_div[18:16], (R610_div[15:0] + roundit_div)}),     
    .O    (R17_integer)   //signed
    );

always @(posedge CLK or posedge RESET) begin
    if (RESET) R17_integerq <= 17'b0;
    else  R17_integerq <= R17_integer;
end

wire [18:0] R19_integral;
reg  [18:0] R19_integralq;

FXP_To_FP610 FXP_To_FP610(             
    .clk  (CLK      ),
    .rst  (RESET    ),
    .I    (R17_integerq),     
    .O    (R19_integral)   //signed
    );
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) R19_integralq <= 19'b0;
    else  R19_integralq <= R19_integral;
end

reg [18:0] Rmult_q;
wire [18:0] Rmult;
wire G_mul;
wire R_mul;
wire S_mul;
wire [2:0] GRS_mul;
assign GRS_mul = {G_mul, R_mul, S_mul}; 
wire roundit_mul;
assign roundit_mul = ((GRS_mul==3'b100) && Rmult[0]) || (GRS_mul[2] && |GRS_mul[1:0]);  //nearest
                                                         
FPMul610 MUL(
    .clk (CLK ), 
    .rst (RESET ),
    .X   (wrdataB_del_6),
    .Y   (R19_integralq),  
    .R   (Rmult ), 
    .IEEEg ( G_mul),    
    .IEEEr ( R_mul),    
    .IEEEs ( S_mul),    
    .roundit (1'b0)    
    );


always @(posedge CLK or posedge RESET)
    if (RESET) begin
        Rmult_q <= 19'b0;
    end    
    else begin
        Rmult_q <= {Rmult[18:16], (Rmult[15:0] + roundit_mul)};                                        
    end
wire [18:0] Radd;       
// this operator pipe is 2 clocks deep FP 6 10
FPAdd610 ADD(
    .clk (CLK ), 
    .rst (RESET ),
    .X   (wrdataA_del_7),
    .Y   (Rmult_q),  
    .R   (Radd  ),    
    .grd (guard  ),              
    .rnd (round  ),        
    .stk (sticky ),        
    .addToRoundBit (1'b0)   
    );

wire trunk_invalid;
assign trunk_invalid = (B_is_zero_del || A_is_infinite_del) && ~A_is_NaN_del && ~B_is_NaN_del;

FP610_To_IEEE754_510_filtered FP610toIEEE510(
    .CLK               (CLK          ),
    .RESET             (RESET        ),
    .wren              (wren_del_9   ),     
    .round_mode        (2'b00        ),     
    .Away              (1'b0         ),
    .trunk_invalid     (trunk_invalid),
    .NaN_in            (NaN_del      ),     
    .invalid_code      (rem_oob      ),      
    .operator_overflow (1'b0         ), 
    .operator_underflow(1'b0         ),    
    .div_by_0_del      (1'b0         ),    
    .A_invalid_del     (A_invalid_del),   //only signaling NaN on input can yank this high  
    .B_invalid_del     (B_invalid_del),   //only signaling NaN on input can yank this high  
    .A_inexact_del     (1'b0         ),    //presumed to be exact 
    .B_inexact_del     (1'b0         ),    //presumed to be exact 
    .X                 (Radd         ),       
    .Rq                (R18          ),        
    .G_in              (guard        ),        
    .R_in              (round        ),        
    .S_in              (sticky       )         
    );   
                        
    
reg [17:0] R18q;
// all these need the same delay as wraddrs_del
always @(*)
    if (~|R18[14:0]) R18q = {R18[17:16], A_sign_del, 15'b0};  
    else if (A_is_subnormal_del && B_is_infinite_del) R18q = {_underFlowExact_, wrdataA_del_10[15:0]};
    else if (A_is_normal_del && B_is_infinite_del)  R18q = {_no_excpt_, wrdataA_del_10[15:0]};
    else R18q = R18;

RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(18))
    ram64_rem(
    .CLK        (CLK      ),
    .wren       (wren_del_10 ),
    .wraddrs    (wraddrs_del),   
    .wrdata     (R18q  ),  
    .rdenA      (rdenA    ), 
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (rddataA  ),
    .rdenB      (rdenB    ),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (rddataB  )
    );
                                 

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
        wrdataA_del_0  <= 19'b0;
        wrdataA_del_1  <= 19'b0;
        wrdataA_del_2  <= 19'b0;
        wrdataA_del_3  <= 19'b0;
        wrdataA_del_4  <= 19'b0;
        wrdataA_del_5  <= 19'b0;
        wrdataA_del_6  <= 19'b0;
        wrdataA_del_7  <= 19'b0;
        wrdataA_del_8  <= 19'b0;
        wrdataA_del_9  <= 19'b0;
        wrdataA_del_10 <= 19'b0;
        wrdataA_del_11 <= 19'b0;
    end    
    else begin
        wrdataA_del_0  <= wrdataA;
        wrdataA_del_1  <= wrdataA_del_0;
        wrdataA_del_2  <= wrdataA_del_1;
        wrdataA_del_3  <= wrdataA_del_2;
        wrdataA_del_4  <= wrdataA_del_3;
        wrdataA_del_5  <= wrdataA_del_4;
        wrdataA_del_6  <= wrdataA_del_5;
        wrdataA_del_7  <= wrdataA_del_6;
        wrdataA_del_8  <= wrdataA_del_7;
        wrdataA_del_9  <= wrdataA_del_8;
        wrdataA_del_10 <= wrdataA_del_9; 
        wrdataA_del_11 <= wrdataA_del_10;
    end                    
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        wrdataB_del_0 <= 19'b0;
        wrdataB_del_1 <= 19'b0;
        wrdataB_del_2 <= 19'b0;
        wrdataB_del_3 <= 19'b0;
        wrdataB_del_4 <= 19'b0;
        wrdataB_del_5 <= 19'b0;
        wrdataB_del_6 <= 19'b0;
    end    
    else begin
        wrdataB_del_0 <= {wrdataB[18:17], ~wrdataB[16], wrdataB[15:0]};        //this delay line is only used for subtraction
        wrdataB_del_1 <= wrdataB_del_0;
        wrdataB_del_2 <= wrdataB_del_1;
        wrdataB_del_3 <= wrdataB_del_2;
        wrdataB_del_4 <= wrdataB_del_3;
        wrdataB_del_5 <= wrdataB_del_4;
        wrdataB_del_6 <= wrdataB_del_5;
    end                    
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (wren) semaphor[wraddrs] <= 1'b0;
        if (wren_del_10) semaphor[wraddrs_del] <= 1'b1;
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
