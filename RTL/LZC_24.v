// LZC_24.v

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
 
 // Acknowledgement: this LZC RTL borrows from the article found in the citation below.
 // Satish Paidi, Rohit Sreerama, K.Neelima / International Journal of Engineering Research and
 // Applications (IJERA) ISSN: 2248-9622 www.ijera.com
 // Vol. 2, Issue 2,Mar-Apr 2012, pp.1103-1105
 // A Novel High Speed Leading Zero Counter For Floating Point Units
 

module LZC_24 (
    In,
    R,
    All_0
    );

input [23:0] In;
output [4:0] R;
output All_0;

wire [4:0] R;
wire [3:0] interm_R;
wire All_0_upper16;

wire [3:0] lower_R;
wire All_0_lower8;
wire All_0;

assign R = All_0_upper16 ? {1'b1, lower_R[3:0] ^ 4'hF} : {1'b0, interm_R[3:0] ^ 4'hF };
assign All_0 = All_0_upper16 && All_0_lower8;

LZC_16 LZC_16M(
    .In    (In[23:8] ),
    .R     (interm_R ),
    .All_0 (All_0_upper16 )
    );
    
LZC_16 lzc_16L(
    .In  ({In[7:0], 8'b0}),
    .R (lower_R ),
    .All_0 (All_0_lower8 )
    );
    

endmodule
