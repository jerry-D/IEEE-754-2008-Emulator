// func_hexBin.v
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

module func_hexBin (
    RESET,
    CLK,
    round_mode_q2,
    Away_q2,
    wren,
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
input [1:0] round_mode_q2;
input Away_q2;
input [5:0] wraddrs, rdaddrsA, rdaddrsB;   // {thread, addrs}
input [63:0] wrdataA;
input [63:0] wrdataB;

output [17:0] rddataA, rddataB;
output ready;

                    
reg [63:0] semaphor;  // one for each memory location
reg readyA;
reg readyB;

reg wren_del_0,  
    wren_del_1, 
    wren_del_2, 
    wren_del_3, 
    wren_del_4, 
    wren_del_5; 
    
reg [5:0] wraddrs_del_0,    
          wraddrs_del_1,
          wraddrs_del_2,
          wraddrs_del_3,
          wraddrs_del_4,
          wraddrs_del_5;

wire ready;

wire [17:0] rddataA, rddataB; 

assign ready = readyA && readyB;


wire [17:0] binOut;
hexCharToBin hexCharToBin(
    .RESET     (RESET),     
    .CLK       (CLK  ),     
    .round_mode(round_mode_q2),
    .Away      (Away_q2),
    .wren      (wren   ),
    .wrdata    ({wrdataB, wrdataA}),
    .binOut    (binOut)
    );

//RAM64x34tp ram64(
RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(18))
    ram64_hexBin(
    .CLK        (CLK     ),
    .wren       (wren_del_5 ),
    .wraddrs    (wraddrs_del_5 ),   
    .wrdata     (binOut  ), 
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
        wren_del_2 <= 1'b0;
        wren_del_3 <= 1'b0;
        wren_del_4 <= 1'b0;
        wren_del_5 <= 1'b0;
    end    
    else begin
        wren_del_0 <= wren;
        wren_del_1 <= wren_del_0;
        wren_del_2 <= wren_del_1;
        wren_del_3 <= wren_del_2;
        wren_del_4 <= wren_del_3;
        wren_del_5 <= wren_del_4;
    end                    
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        wraddrs_del_0 <= 6'b0;
        wraddrs_del_1 <= 6'b0;
        wraddrs_del_2 <= 6'b0;
        wraddrs_del_3 <= 6'b0;
        wraddrs_del_4 <= 6'b0;
        wraddrs_del_5 <= 6'b0;
    end    
    else begin
        wraddrs_del_0 <= wraddrs;
        wraddrs_del_1 <= wraddrs_del_0;
        wraddrs_del_2 <= wraddrs_del_1;
        wraddrs_del_3 <= wraddrs_del_2;
        wraddrs_del_4 <= wraddrs_del_3;
        wraddrs_del_5 <= wraddrs_del_4;
    end                    
end
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (wren) semaphor[wraddrs] <= 1'b0;
        if (wren_del_5) semaphor[wraddrs_del_5] <= 1'b1;
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
