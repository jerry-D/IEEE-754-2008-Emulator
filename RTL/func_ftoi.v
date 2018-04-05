 // func_ftoi.v
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

module func_ftoi (
    RESET,
    CLK,
    wren,
    A_inexact,
    A_is_infinite,    
    wraddrs,
    wraddrs_del,
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
input A_inexact;
input A_is_infinite;

output [17:0] rddataA, rddataB;
output ready;

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
reg wren_del_0; 
reg [25:0] integr_grs;
reg roundit;

reg [4:0] wrdataB;

reg [17:0] R; // 17-bit signed integer result plus msb is the inexact signal

wire ready;

wire [17:0] rddataA, rddataB;

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
wire [1:0] round_mode;

assign round_mode = wrdataB[1:0];
assign Away = wrdataB[3];
assign inexact_enable = wrdataB[4];

assign exponent_in = wrdataA[15:10];
assign fraction_in = wrdataA[9:0];
assign sign_in = wrdataA[16];
assign shift_amount_interm = exponent_in - 5'h1F; // 5'h1F = 31 which is the bias for FP610
assign shift_amount = less_than_1 ? 4'b0 : shift_amount_interm[3:0]; // if input is less than one, then don't shift
assign GRS = {integr_grs[9:8], |integr_grs[7:0]};
assign lsb = integr_grs[10];
assign out_of_bounds = (exponent_in > 6'h2E);  // 15 + 31 = 46 = 6'h2E  note an input in this format cannot overflow due to rounding up
assign infinite_input = (wrdataA[18:17]==infinity) || A_is_infinite; 
assign NaN_input = (wrdataA[18:17]==NaN);
assign less_than_1 = (exponent_in < 6'h1F) && ~(wrdataA[18:17]==zero);   // 6'h1F = 31 (1 unbiased for FP610)  anything less than that is less than 1 (unrounded)

assign inexact_result = |GRS || A_inexact;

assign integr_interm = integr_grs[25:10] + roundit;
assign signed_integr = sign_in ? ~(integr_interm + 1'b1) : integr_interm;

assign ready = readyA && readyB;

assign result_is_zero = (wrdataA[18:17]==zero) || ~|integr_interm;

always @(posedge CLK or posedge RESET)
    if (RESET) wrdataB <= 5'b0;
    else wrdataB <= fwrsrcBdata;

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

always @(*)
    case(round_mode)
        NEAREST : if (((GRS==3'b100) && (lsb || Away)) || (GRS[2] && |GRS[1:0])) roundit = 1'b1;    //when GRS = (3'b100 && lsb) OR when GRS = 101 or 110 or 111 then lsb is don't care
                  else roundit = 1'b0;
        POSINF  : if (~sign_in && |GRS) roundit = 1'b1;
                  else roundit = 1'b0;
        NEGINF  : if (sign_in && |GRS) roundit = 1'b1;
                  else roundit = 1'b0;
        ZERO    : roundit = 1'b0;
    endcase

// we need only one bit for exceptions because, apart from "invalid" (which can be signaled implicitly in the result as 17'h1001F)
// inexact is the only exception, thus requiring only one exception bit
always @(posedge CLK or posedge RESET)
    if (RESET) R <= 18'b0;
    else if (out_of_bounds) R <= 18'h2FFE3;   // 16'hFFE3 = 65507 -- signed NaN with 3 indicating out of bounds.  The inexact bit is set
    else if (infinite_input) R <= 18'h2FFE2;  // 16'hFFE2 = 65506 -- signed NaN with 2 indicating infinite input. The inexact bit is set
    else if (NaN_input) R <= 18'h2FFE1;       // 16'hFFE1 = 65505 -- signed NaN with 1 indicating NaN input. The inexact bit is set 
    else if (result_is_zero) R <= {(inexact_result && inexact_enable), 17'b0};  //if an attempt to read result is half-word and the result is negative that can't be represented in 16'bits, invalid will/should be signaled
    else  R <= {(inexact_result && inexact_enable), signed_integr};                    
                     
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        wren_del_0 <= 1'b0;
    end    
    else begin
        wren_del_0 <= wren;
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
