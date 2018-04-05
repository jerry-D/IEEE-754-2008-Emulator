 // subn_normalizer_610.v
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
 
module subn_normalizer_610 (
    Size_q2,
    fract_in,
    normalized_fract,
    normalized_exponent,
    All_0
    );

input [1:0] Size_q2;    
input [9:0] fract_in;
output [9:0] normalized_fract;
output [5:0] normalized_exponent;
output All_0;


reg [9:0] normalized_fract;


wire [3:0] first_1_position;
wire [5:0] normalized_exponent;
wire All_0;

assign normalized_exponent = first_1_position + 18;
    
// find shift amount
LZC_16 LZC_16(
    .In    ({fract_in, 6'b0}),
    .R     (first_1_position),
    .All_0 (All_0)
    );

// barrel-shifter for normalizing the fraction part of subnormal number                                                                                                  
 always @(*)                                                                                      
    case(first_1_position)                                                                     
         0 : normalized_fract = {fract_in[ 8:0],  1'b0};
         1 : normalized_fract = {fract_in[ 7:0],  2'b0};
         2 : normalized_fract = {fract_in[ 6:0],  3'b0};
         3 : normalized_fract = {fract_in[ 5:0],  4'b0};
         4 : normalized_fract = {fract_in[ 4:0],  5'b0};
         5 : normalized_fract = {fract_in[ 3:0],  6'b0};
         6 : normalized_fract = {fract_in[ 2:0],  7'b0};
         7 : normalized_fract = {fract_in[ 1:0],  8'b0};
         8 : normalized_fract = {fract_in[   0],  9'b0};
         9 : normalized_fract =                  10'b0 ;
   default : normalized_fract = 10'b0;                                              
    endcase 
      
                                                                        
endmodule                                                                      
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    