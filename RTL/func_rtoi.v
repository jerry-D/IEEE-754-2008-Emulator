 // func_rtoi.v
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
 

module func_rtoi (
    RESET,
    CLK,
    round_mode_del,
    Away_del,
    NaN_del,
    wren,
    A_is_inexact_del,
    A_is_infinite_del,    
    wraddrs_del,
    wraddrs,
    wrdataA,
    fwrsrcBdata,
    rdenA,
    rdaddrsA,
    rddataA,
    rdenB,
    rdaddrsB,
    rddataB,
    ready
    );

input RESET, CLK, wren, rdenA, rdenB;
input [5:0] wraddrs_del, wraddrs, rdaddrsA, rdaddrsB;
input [18:0] wrdataA;
input [4:0] fwrsrcBdata;
input [1:0] round_mode_del;
input Away_del;
input [9:0] NaN_del;
input A_is_inexact_del;
input A_is_infinite_del;

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

//2-bit exception codes for back-end
parameter _no_excpt_   = 2'b00;  // no exception--all good
parameter _overflow_   = 2'b01;  // the operation has overflowed--inexact is always implied--
parameter _underflow_  = 2'b10;  // inexact underflow (underflows that are also exact are not signaled--per IEEE754-2008)
parameter _inexact_    = 2'b11;  // inexact result

parameter sig_NaN      = 3'b000;  // singnaling NaN is an operand
parameter mult_oob     = 3'b001;  // multiply operands out of bounds, multiplication(0, INF) or multiplication(?INF, 0)
parameter fsd_mult_oob = 3'b010;  // fused multiply operands out of bounds
parameter add_oob      = 3'b011;  // add or subract or fusedmultadd operands out of bounds
parameter div_oob      = 3'b100;  // division operands out of bounds, division(0, 0) or division(?INF, INF) 
parameter rem_oob      = 3'b101;  // remainder operands out of bounds, remainder(x, y), when y is zero or x is infinite (and neither is NaN)
parameter sqrt_oob     = 3'b110;  // square-root or log operand out of bounds, operand is less than zero
parameter quantize     = 3'b111;  // conversion result does not fit in dest, or a converted finite yields (or would yield) infinite result


parameter _invalid_ = 2'b01;  // for use with NaN delivery when this module detects invalid operation
                       
reg [63:0] semaphor;  // one for each memory location
reg readyA;
reg readyB;
reg wren_del_0,
    wren_del_1; 
    
reg A_is_infinite_del_0;
reg [25:0] integr_grs;
reg roundit;

reg [4:0] wrdataB;

wire ready;

reg [15:0] R_int; // 16-bit signed float without exception code
reg [17:0] R; // final result including exception code

wire [17:0] rddataA, rddataB;

wire inexact_result;
wire less_than_1;
wire [5:0] exponent_in;
wire [9:0] fraction_in;
wire sign_in;
wire [3:0] shift_amount;
wire [5:0] shift_amount_interm;
wire [15:0] integr_interm;          //17-bit unsigned  msb should always be 0
wire result_is_zero;
wire [2:0] GRS;
wire lsb;
wire out_of_bounds;
wire infinite_input;
wire NaN_input;

assign exponent_in = wrdataA[15:10];
assign fraction_in = wrdataA[9:0];
assign sign_in = wrdataA[16];
assign shift_amount_interm = exponent_in - 5'h1F; // 5'h1F = 31 which is the bias for FP610
assign shift_amount = less_than_1 ? 4'b0 : shift_amount_interm[3:0]; // if input is less than one, then don't shift
assign GRS = {integr_grs[9:8], |integr_grs[7:0]};
assign lsb = integr_grs[10];
assign out_of_bounds = (exponent_in > 6'h2E);  // 15 + 31 = 46 = 6'h2E  
assign infinite_input = A_is_infinite_del; 
assign NaN_input = (wrdataA[18:17]==NaN);

assign less_than_1 = (exponent_in < 6'h1F) && ~(wrdataA[18:17]==zero);   // 6'h1F = 31 (1 unbiased for FP610)  anything less than that is less than 1 (unrounded)

assign inexact_result = |GRS || A_is_inexact_del;

assign integr_interm = integr_grs[25:10] + roundit;

assign ready = readyA && readyB;

assign result_is_zero = (wrdataA[18:17]==zero) || ~|integr_interm;

always @(posedge CLK or posedge RESET)
    if (RESET) wrdataB <= 5'b0;
    else wrdataB <= fwrsrcBdata[4:0];

RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(18))
    ram64_ftoi(
    .CLK        (CLK      ),
    .wren       (wren_del_0 ),
    .wraddrs    (wraddrs_del),   
    .wrdata     (R  ),  
    .rdenA      (rdenA    ), 
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (rddataA  ),
    .rdenB      (rdenB    ),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (rddataB  )
    );
                                 
always @(*)                      
    case(shift_amount)           
        4'h0 : integr_grs = {15'b0, ~less_than_1, fraction_in[9:0]}; 
        4'h1 : integr_grs = {14'b0, 1'b1, fraction_in[9:0],  1'b0}; 
        4'h2 : integr_grs = {13'b0, 1'b1, fraction_in[9:0],  2'b0}; 
        4'h3 : integr_grs = {12'b0, 1'b1, fraction_in[9:0],  3'b0}; 
        4'h4 : integr_grs = {11'b0, 1'b1, fraction_in[9:0],  4'b0}; 
        4'h5 : integr_grs = {10'b0, 1'b1, fraction_in[9:0],  5'b0}; 
        4'h6 : integr_grs = { 9'b0, 1'b1, fraction_in[9:0],  6'b0}; 
        4'h7 : integr_grs = { 8'b0, 1'b1, fraction_in[9:0],  7'b0}; 
        4'h8 : integr_grs = { 7'b0, 1'b1, fraction_in[9:0],  8'b0}; 
        4'h9 : integr_grs = { 6'b0, 1'b1, fraction_in[9:0],  9'b0}; 
        4'hA : integr_grs = { 5'b0, 1'b1, fraction_in[9:0], 10'b0}; 
        4'hB : integr_grs = { 4'b0, 1'b1, fraction_in[9:0], 11'b0}; 
        4'hC : integr_grs = { 3'b0, 1'b1, fraction_in[9:0], 12'b0}; 
        4'hD : integr_grs = { 2'b0, 1'b1, fraction_in[9:0], 13'b0}; 
        4'hE : integr_grs = { 1'b0, 1'b1, fraction_in[9:0], 14'b0}; 
        4'hF : integr_grs = { 1'b1,       fraction_in[9:0], 15'b0}; 
    endcase

wire Away;
wire silent_mode;   //silent_mode: the rounding mode is indicated in the operation name and does not depend on RM attribute --inexact is not signaled
assign silent_mode = wrdataB[4];
wire [1:0] round_mode_sel;
assign round_mode_sel = silent_mode ? wrdataB[1:0] : round_mode_del; 
assign Away = silent_mode ? wrdataB[3] : Away_del;

always @(*)
    case(round_mode_sel)
        NEAREST : if (((GRS==3'b100) && (lsb || Away)) || (GRS[2] && |GRS[1:0])) roundit = 1'b1;    //when GRS = (3'b100 && lsb) OR when GRS = 101 or 110 or 111 then lsb is don't care
                  else roundit = 1'b0;
        POSINF  : if (~sign_in && |GRS) roundit = 1'b1;
                  else roundit = 1'b0;
        NEGINF  : if (sign_in && |GRS) roundit = 1'b1;
                  else roundit = 1'b0;
        ZERO    : roundit = 1'b0;
    endcase

always @(posedge CLK or posedge RESET) begin
    if (RESET) R <= 18'b0;
    else if (infinite_input) R <= {_no_excpt_, sign_in, 5'b11111, 10'b0};  
    else if (NaN_input) R <= {_no_excpt_, sign_in, 5'b11111, 1'b1, NaN_del[8:0]};       
    else if (result_is_zero) R <= {((inexact_result && ~silent_mode) ? _inexact_ : 2'b00), sign_in, 15'b0};  
    else  R <= {((inexact_result && ~silent_mode) ? _inexact_ : 2'b00), R_int};                    
end

//now that we have a bona fide integer, let's turn it back into float by shifting it right the specified number of times
//and adding bias to exponent
always @(*)                      
    case(shift_amount)           
        4'h0 : R_int = {sign_in, 5'b01111, 10'b0};                      //  0 + 15 = 15 = 5'b01111        1 
        4'h1 : R_int = {sign_in, 5'b10000, integr_interm[0],   9'b0};   //  1 + 15 = 16 = 5'b10000        2, 3
        4'h2 : R_int = {sign_in, 5'b10001, integr_interm[1:0], 8'b0};   //  2 + 15 = 17 = 5'b10001        4 - 7
        4'h3 : R_int = {sign_in, 5'b10010, integr_interm[2:0], 7'b0};   //  3 + 15 = 18 = 5'b10010        8 - 15
        4'h4 : R_int = {sign_in, 5'b10011, integr_interm[3:0], 6'b0};   //  4 + 15 = 19 = 5'b10011        16 - 31
        4'h5 : R_int = {sign_in, 5'b10100, integr_interm[4:0], 5'b0};   //  5 + 15 = 20 = 5'b10100        32 - 63
        4'h6 : R_int = {sign_in, 5'b10101, integr_interm[5:0], 4'b0};   //  6 + 15 = 21 = 5'b10101        64 - 127
        4'h7 : R_int = {sign_in, 5'b10110, integr_interm[6:0], 3'b0};   //  7 + 15 = 22 = 5'b10110        128 - 255
        4'h8 : R_int = {sign_in, 5'b10111, integr_interm[7:0], 2'b0};   //  8 + 15 = 23 = 5'b10111        256 - 511
        4'h9 : R_int = {sign_in, 5'b11000, integr_interm[8:0], 1'b0};   //  9 + 15 = 24 = 5'b11000        512 - 1023
        4'hA : R_int = {sign_in, 5'b11001, integr_interm[9:0]};         // 10 + 15 = 25 = 5'b11001        1024 - 2047
        4'hB : R_int = {sign_in, 5'b11010, integr_interm[10:1]};        // 11 + 15 = 26 = 5'b11010        2048 - 4095
        4'hC : R_int = {sign_in, 5'b11011, integr_interm[11:2]};        // 12 + 15 = 27 = 5'b11011        4096 - 8191
        4'hD : R_int = {sign_in, 5'b11100, integr_interm[12:3]};        // 13 + 15 = 28 = 5'b11100        8192 - 16383
        4'hE : R_int = {sign_in, 5'b11101, integr_interm[13:4]};        // 14 + 15 = 29 = 5'b11101        16384 - 32767
        4'hF : R_int = {sign_in, 5'b11110, integr_interm[14:5]};        // 15 + 15 = 30 = 5'b11110        32768 - 65504
    endcase
                     
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        wren_del_0 <= 1'b0;
        wren_del_1 <= 1'b0;
    end    
    else begin
        wren_del_0 <= wren;
        wren_del_1 <= wren_del_0;
    end                    
end


always @(posedge CLK or posedge RESET) begin
    if (RESET) semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (wren) semaphor[wraddrs] <= 1'b0;
        if (wren_del_0) semaphor[wraddrs_del] <= 1'b1;
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
