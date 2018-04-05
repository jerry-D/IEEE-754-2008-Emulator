// to_int.v
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

module to_int (     //requires integral 

    A_is_inexact,    
    X,
    R
    );

input [18:0] X;
input A_is_inexact;

output [17:0] R;

//FloPoCo exception codes
parameter zero = 2'b00;
parameter infinity = 2'b10;
parameter NaN = 2'b11;
parameter normal = 2'b01;
                       
reg [25:0] integr_grs;

reg [17:0] R; // 17-bit signed integer result plus msb is the inexact signal


wire inexact_result;
wire less_than_1;
wire [5:0] exponent_in;
wire [9:0] fraction_in;
wire sign_in;
wire [3:0] shift_amount;
wire [5:0] shift_amount_interm;
wire [16:0] signed_integr;
wire [16:0] integr_interm;
wire result_is_zero;
wire [2:0] GRS;
wire lsb;
wire out_of_bounds;
wire infinite_input;
wire NaN_input;

assign exponent_in = X[15:10];
assign fraction_in = X[9:0];
assign sign_in = X[16];
assign shift_amount_interm = exponent_in - 5'h1F; // 5'h1F = 31 which is the bias for FP610
assign shift_amount = less_than_1 ? 4'b0 : shift_amount_interm[3:0]; // if input is less than one, then don't shift
assign GRS = {integr_grs[9:8], |integr_grs[7:0]};
assign lsb = integr_grs[10];
assign out_of_bounds = (exponent_in > 6'h2E);  // 15 + 31 = 46 = 6'h2E  note an input in this format cannot overflow due to rounding up
assign infinite_input = (X[18:17]==infinity); 
assign NaN_input = (X[18:17]==NaN);

assign less_than_1 = (exponent_in < 6'h1F) && ~(X[18:17]==zero);   // 6'h1F = 31 (1 unbiased for FP610)  anything less than that is less than 1 (unrounded)

assign inexact_result = |GRS || A_is_inexact;

assign integr_interm = integr_grs[25:10];
assign signed_integr = sign_in ? ~(integr_interm + 1'b1) : integr_interm;

assign result_is_zero = (X[18:17]==zero) || ~|integr_interm;
                                 
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


// we need only one bit for exceptions because, apart from "invalid" (which can be signaled implicitly in the result as 18'h2FFE3)
// inexact is the only exception, thus requiring only one exception bit
always @(*)
    if (out_of_bounds) R = 18'h2FFE3;        // 16'hFFE3 = 65507 -- signed NaN with 3 indicating out of bounds.  The inexact bit is set
    else if (infinite_input) R = 18'h2FFE2;  // 16'hFFE2 = 65506 -- signed NaN with 2 indicating infinite input. The inexact bit is set
    else if (NaN_input) R = 18'h2FFE1;       // 16'hFFE1 = 65505 -- signed NaN with 1 indicating NaN input. The inexact bit is set 
    else if (result_is_zero) R = {inexact_result, 17'b0};  //if an attempt to read result is half-word and the result is negative that can't be represented in 16'bits, invalid will/should be signaled
    else  R = {inexact_result, signed_integr};                    

endmodule
