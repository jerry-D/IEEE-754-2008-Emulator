// func_scaleB.v
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

module func_scaleB (
    RESET,
    CLK,
    Size_SrcA_q2,
    round_mode_del,
    Away_del,
    NaN_del,
    A_invalid_del,
    A_inexact_del,
    B_invalid_del,
    B_inexact_del,
    wren,
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
input [1:0] Size_SrcA_q2;
input [1:0] round_mode_del;
input Away_del;
input [9:0] NaN_del;
input [5:0] wraddrs, wraddrs_del, rdaddrsA, rdaddrsB;   // {thread, addrs}
input [63:0] wrdataA; 
input [18:0] wrdataB;
input A_invalid_del;
input A_inexact_del;
input B_invalid_del;
input B_inexact_del;

output [17:0] rddataA, rddataB;
output ready;

//FloPoCo exception codes
parameter zero = 2'b00;
parameter infinity = 2'b10;
parameter NaN = 2'b11;
parameter normal = 2'b01;

//precision (size) encodings
parameter DP = 2'b11;
parameter SP = 2'b10;
parameter HP = 2'b01;
                       
reg [63:0] semaphor;  // one for each memory location
reg readyA;
reg readyB;

reg [63:0] wrdataAq;

reg wren_del_0,  
    wren_del_1; 
    
reg [18:0] R610;
reg [18:0] R610q;

reg  [10:0] Xe;
reg X_sign;
reg [51:0] X_fraction;
reg X_is_infinite;
reg X_is_zero;
reg X_is_NaN;
wire S_is_NaN;

wire [17:0] R18;    
wire ready;

wire [17:0] rddataA, rddataB; 

wire signed [17:0] scale;
wire [17:0] Rinteger;
wire [17:0] scaled_Xe;
wire S_is_zero;
wire [18:0] scaled_X;
wire overflow;
wire [17:0] reBiasedXe;

assign S_is_zero = ~|wrdataB[15:0];
assign S_is_NaN = (wrdataB[18:17]==NaN);
assign scale = Rinteger[17:0];   //Rinteger[17] is the sign of the scale factor
assign scaled_Xe = Xe + scale;
assign reBiasedXe = (scaled_Xe + 31);
assign scaled_X = {1'b0, ~X_is_zero, X_sign, reBiasedXe[5:0], X_fraction[51:42]}; 
assign overflow = |reBiasedXe[17:6] && ~X_is_infinite;

assign ready = readyA && readyB;

always @(posedge CLK or posedge RESET) 
    if (RESET) wrdataAq <= 64'b0;
    else wrdataAq <= wrdataA;

always @(*)
    casex(Size_SrcA_q2)
        DP : begin
                Xe = wrdataAq[62:52] - 1023;
                X_fraction = wrdataAq[51:0];
                X_is_NaN = &wrdataAq[62:52] && |wrdataAq[50:0];
                X_is_infinite = &wrdataAq[62:52] && ~|wrdataAq[51:0];
                X_is_zero = ~|wrdataAq[62:0];
                X_sign = wrdataAq[63];
             end
        SP : begin
                Xe = {3'b000, wrdataAq[30:23]} - 127;
                X_fraction = {wrdataAq[22:0], 29'b0};                
                X_is_NaN = &wrdataAq[30:23] && |wrdataAq[21:0];
                X_is_infinite = &wrdataAq[30:23] && ~|wrdataAq[22:0];
                X_is_zero = ~|wrdataAq[30:0];
                X_sign = wrdataAq[31];
             end
        HP : begin
                Xe = {6'b000000, wrdataAq[14:10]} - 15;
                X_fraction = {wrdataAq[9:0], 42'b0};                
                X_is_NaN = &wrdataAq[14:10] && |wrdataAq[8:0];
                X_is_infinite = &wrdataAq[14:10] && ~|wrdataAq[9:0];
                X_is_zero = ~|wrdataAq[14:0];
                X_sign = wrdataAq[15];
             end
   default : begin
                Xe = 11'b0;
                X_fraction = 52'b0;
                X_is_NaN = 1'b0;
                X_is_infinite = 1'b0;
                X_is_zero = 1'b0;
                X_sign = 1'b0;
             end
                         
    endcase    


always @(*)
    if (S_is_NaN) R610 = wrdataB;
    else if (X_is_NaN) R610 = {NaN, X_sign, (Xe[5:0] + 31), X_fraction[51:42]}; 
    else if (X_is_zero && ~S_is_zero) R610 = {zero, X_sign, 16'b0};
    else if (X_is_infinite) R610 = {infinity, X_sign, 6'b111111, 10'b0};
    else R610 = scaled_X;


to_int to_int(       //convert to (signed) integer
    .A_is_inexact  (B_inexact_del),
    .X             (wrdataB       ),
    .R             (Rinteger      )
    );

FP610_To_IEEE754_510_filtered FP610toIEEE510(
    .CLK               (CLK          ),
    .RESET             (RESET        ),
    .wren              (wren_del_0   ),  
    .round_mode        (round_mode_del), 
    .Away              (Away_del     ),
    .trunk_invalid     (1'b0         ),
    .NaN_in            (NaN_del      ),  
    .invalid_code      (3'b0         ),  
    .operator_overflow (overflow     ),  
    .operator_underflow(1'b0         ),    
    .div_by_0_del      (1'b0         ),  
    .A_invalid_del     (A_invalid_del),  
    .B_invalid_del     (B_invalid_del),  
    .A_inexact_del     (A_inexact_del),  
    .B_inexact_del     (B_inexact_del),  
    .X                 (R610q        ),  
    .Rq                (R18          ),  
    .G_in              (X_fraction[41]),  
    .R_in              (X_fraction[40]),  
    .S_in              (|X_fraction[39:0])   
    );                       


//RAM64x34tp ram64(
RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(18))
    ram64_scaleB(
    .CLK        (CLK     ),
    .wren       (wren_del_1 ),
    .wraddrs    (wraddrs_del ),                                                         
    .wrdata     (R18     ),                                                             
    .rdenA      (rdenA   ),   
    .rdaddrsA   (rdaddrsA),
    .rddataA    (rddataA ),
    .rdenB      (rdenB   ),
    .rdaddrsB   (rdaddrsB),
    .rddataB    (rddataB ));


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
    if (RESET) begin
        R610q <= 19'b0;
    end    
    else begin
        R610q <= R610;
    end                    
end
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (wren) semaphor[wraddrs] <= 1'b0;
        if (wren_del_1) semaphor[wraddrs_del] <= 1'b1;
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
