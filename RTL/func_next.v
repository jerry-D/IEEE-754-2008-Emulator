// func_next.v
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

module func_next (
    RESET,
    CLK,
    NaN_del,
    wren,
    wraddrs,
    wraddrs_del,
    wrdataA,
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
input [5:0] wraddrs, wraddrs_del, rdaddrsA, rdaddrsB;   // {thread, addrs}
input [18:0] wrdataA;


output [17:0] rddataA, rddataB;
output ready;

//FloPoCo exception codes
parameter zero = 2'b00;
parameter infinity = 2'b10;
parameter NaN = 2'b11;
parameter normal = 2'b01;

                       
reg [63:0] semaphor;  // one for each memory location
reg readyA;
reg readyB;

reg [18:0] R610_nextUp;
reg [18:0] R610_nextDown;

reg wren_del_0,  
    wren_del_1; 

wire ready;

wire [17:0] rddataA, rddataB; 

wire [17:0] R18;

wire nextUp;
wire nextDown;
wire A_sign;
wire [16:0] nextUp_interm;
wire A_is_least_mag;
wire A_is_zero;
wire A_is_pos_infinity;
wire A_is_neg_infinity;
wire A_is_NaN;

wire [18:0] A_in;

assign A_in = wrdataA[18:0];

assign A_is_NaN = &wrdataA[18:17];  

assign A_sign = (nextDown ^ A_in[16]);
assign A_is_least_mag = ({A_sign, A_in[15:0]}==17'b1_000000_00_0000_0001);
assign A_is_zero = ~|A_in[15:0];
assign A_is_pos_infinity = ({A_sign, A_in[15:0]}==17'b0_111111_00_0000_0000);
assign A_is_neg_infinity = ({A_sign, A_in[15:0]}==17'b1_111111_00_0000_0000);
assign nextUp_interm[16:0] = A_in[15:0] + (A_sign ? 16'hFFFF : 16'h0001);
assign nextUp = wraddrs[3];  // 1=nextUp 0=nextDown
assign nextDown = ~wraddrs[3];

assign ready = readyA && readyB;

always @(*)
    if (A_is_NaN) R610_nextUp = wrdataA;
    else if (A_is_least_mag) R610_nextUp = {zero, 17'b1_000000_00_0000_0000}; 
    else if (A_is_zero) R610_nextUp = {normal, 17'b0_000000_00_0000_0001};
    else if (A_is_pos_infinity && nextUp) R610_nextUp = {infinity, 17'b0_111111_00_0000_0000};
    else if (A_is_neg_infinity && nextUp) R610_nextUp = {normal, 17'b1_111110_11_1111_1111};
    else R610_nextUp = {normal, (nextDown ^ A_sign), nextUp_interm[15:0]};

          
FP610_To_IEEE754_510_filtered FP610toIEEE510(
    .CLK               (CLK        ),
    .RESET             (RESET      ),
    .wren              (wren       ),  
    .round_mode        (2'b00      ), 
    .Away              (1'b0       ),
    .trunk_invalid     (1'b0       ),
    .NaN_in            (NaN_del    ),  
    .invalid_code      (3'b0       ),  
    .operator_overflow (1'b0       ),  
    .operator_underflow(1'b0       ),    
    .div_by_0_del      (1'b0       ),  
    .A_invalid_del     (1'b0       ),  
    .B_invalid_del     (1'b0       ),  
    .A_inexact_del     (1'b0       ),  
    .B_inexact_del     (1'b0       ),  
    .X                 (R610_nextUp),  
    .Rq                (R18        ),  
    .G_in              (1'b0       ),  
    .R_in              (1'b0       ),  
    .S_in              (1'b0       )   
    );                       


//RAM64x34tp ram64(
RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(18))
    ram64_next(
    .CLK        (CLK     ),
    .wren       (wren_del_0 ),
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
