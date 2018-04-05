// func_cnacs.v
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

module func_cnacs (
    RESET,
    CLK,
    NaN_del,
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
input [9:0] NaN_del;
input [5:0] wraddrs, wraddrs_del, rdaddrsA, rdaddrsB;   // {thread, addrs}
input [18:0] wrdataA, wrdataB;

output [17:0] rddataA, rddataB;
output ready;

                       
reg [63:0] semaphor;  // one for each memory location
reg readyA;
reg readyB;

reg [18:0] R610;

reg wren_del_0,  
    wren_del_1; 
    
wire copy;
wire negate;
wire abs;
wire copySign;
wire [17:0] R18;

wire ready;

wire [17:0] rddataA, rddataB; 


wire [3:0] cnacs_sel;

assign ready = readyA && readyB;
assign copy = (wraddrs[3:2]==2'b11);
assign negate = (wraddrs[3:2]==2'b10);
assign abs = (wraddrs[3:2]==2'b01);
assign copySign = (wraddrs[3:2]==2'b00);

assign cnacs_sel = {copy, negate, abs, copySign};  

always @(*)
    casex(cnacs_sel)      
        4'b1000 : R610 = wrdataA;
        4'b0100 : R610 = {wrdataA[18:17], ~wrdataA[16], wrdataA[15:0]};
        4'b0010 : R610 = {wrdataA[18:17], 1'b0, wrdataA[15:0]};
        4'b0001 : R610 = {wrdataA[18:17], wrdataB[16], wrdataA[15:0]};
        default : R610 = wrdataA;   
    endcase
          
FP610_To_IEEE754_510_filtered FP610toIEEE510(
    .CLK               (CLK          ),
    .RESET             (RESET        ),
    .wren              (wren_del_0   ),  
    .round_mode        (2'b0         ),  
    .Away              (1'b0         ),
    .trunk_invalid     (1'b0         ),
    .NaN_in            (NaN_del      ),  
    .invalid_code      (3'b0         ),  
    .operator_overflow (1'b0         ),  
    .operator_underflow(1'b0         ),  
    .div_by_0_del      (1'b0         ),  
    .A_invalid_del     (1'b0         ),  
    .B_invalid_del     (1'b0         ),  
    .A_inexact_del     (1'b0         ),  
    .B_inexact_del     (1'b0         ),  
    .X                 (R610         ),  
    .Rq                (R18          ), 
    .G_in              (1'b0         ),  
    .R_in              (1'b0         ),  
    .S_in              (1'b0         )   
    );                       


//RAM64x34tp ram64(
RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(18))
    ram64_cnacs(
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
