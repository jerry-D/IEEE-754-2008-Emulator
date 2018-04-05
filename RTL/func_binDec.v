// func_binDec.v
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

module func_binDec (
    RESET,
    CLK,
    round_mode_q2,
    Away_q2,
    Src_Size_q2,
    Sext_SrcA_q1,
    Sext_SrcB_q1,        
    wren,
    wraddrs,
    wrdata,
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
input [1:0] Src_Size_q2;
input Sext_SrcA_q1;
input Sext_SrcB_q1;
input [5:0] wraddrs, rdaddrsA, rdaddrsB;   // {thread, addrs}
input [63:0] wrdata;

output [65:0] rddataA, rddataB;
output ready;

//precision (size) encodings
parameter DP = 2'b11;
parameter SP = 2'b10;
parameter HP = 2'b01;
parameter BT = 2'b00;

//rounding mode encodings
parameter NEAREST = 2'b00;
parameter POSINF  = 2'b01;
parameter NEGINF  = 2'b10;
parameter ZERO    = 2'b11;
                       
reg [63:0] semaphor;  // one for each memory location
reg readyA;
reg readyB;

reg wren_del_0,  
    wren_del_1, 
    wren_del_2, 
    wren_del_3, 
    wren_del_4, 
    wren_del_5, 
    wren_del_6; 
    
reg [5:0] wraddrs_del_0,    
          wraddrs_del_1,
          wraddrs_del_2,
          wraddrs_del_3,
          wraddrs_del_4,
          wraddrs_del_5,
          wraddrs_del_6;
          
reg overflow;
reg underflow;
reg inexact;
reg [15:0] wrdata_510;

wire ready;

wire [65:0] rddataA, rddataB; 
wire [129:0] rddataA_, rddataB_; 


assign rddataA = Sext_SrcA_q1 ? rddataA_[129:64] : {rddataA_[129:128], rddataA_[63:0]};
assign rddataB = Sext_SrcB_q1 ? rddataB_[129:64] : {rddataB_[129:128], rddataB_[63:0]};

assign ready = readyA && readyB;

reg [4:0] DP_exp;
reg [9:0] DP_fract;
reg [63:0] DP_fract_shifted;

reg [4:0] SP_exp;
reg [9:0] SP_fract;
reg [34:0] SP_fract_shifted;

reg SP_roundit;
wire [2:0] SP_GRS;
assign SP_GRS = {SP_fract_shifted[24:23], |SP_fract_shifted[22:0]};

reg DP_roundit;
wire [2:0] DP_GRS;
assign DP_GRS = {DP_fract_shifted[53:52], |DP_fract_shifted[51:0]};


wire DP_sign;
wire [10:0] DP_exp_interm;
wire [4:0] DP_exp_510;
wire DP_overflow;
wire DP_underflow;
wire DP_is_NaN;
wire DP_is_subnormal;
wire DP_is_infinite;
wire DP_is_zero;


assign DP_overflow = (wrdata[62:52] > (1023 + 15)) || (&wrdata[51:42] && DP_roundit && (wrdata[62:52]==(1023 + 15)));
assign DP_is_NaN = &wrdata[62:52] && |wrdata[50:0];
assign DP_is_infinite = (&wrdata[62:52] && ~|wrdata[51:0]) || DP_overflow;
assign DP_is_zero = ~|wrdata[62:0];
assign DP_underflow = ((wrdata[62:52] < (1023 - 14)) && ~((wrdata[62:52]==(1023 - 15)) && &wrdata[51:42] && DP_roundit));
assign DP_is_subnormal = ~|wrdata[62:52] && |wrdata[51:0] || DP_underflow;
assign DP_exp_interm = wrdata[62:52];
assign DP_exp_510 = wrdata[62:52] - 1008;
assign DP_sign = wrdata[63];


// to handle DP subnormal cases
always @(*)
    casex(DP_exp_interm)
         11'b1xxxxxxxxxx,
         11'h3FF,
         11'h3FE,
         11'h3FD,
         11'h3FC,
         11'h3FB,
         11'h3FA,
         11'h3F9,
         11'h3F8,
         11'h3F7,
         11'h3F6,
         11'h3F5,
         11'h3F4,
         11'h3F3,
         11'h3F2,
         11'h3F1 : DP_fract_shifted = {             wrdata[51:0], 12'b0};   // for normal numbers to get GRS bits
         11'h3F0 : DP_fract_shifted = {       1'b1, wrdata[51:0], 11'b0};   //-15
         11'h3EF : DP_fract_shifted = { 1'b0, 1'b1, wrdata[51:0], 10'b0};   //-16
         11'h3EE : DP_fract_shifted = { 2'b0, 1'b1, wrdata[51:0],  9'b0};   //-17
         11'h3ED : DP_fract_shifted = { 3'b0, 1'b1, wrdata[51:0],  8'b0};   //-18
         11'h3EC : DP_fract_shifted = { 4'b0, 1'b1, wrdata[51:0],  7'b0};   //-19
         11'h3EB : DP_fract_shifted = { 5'b0, 1'b1, wrdata[51:0],  6'b0};   //-20
         11'h3EA : DP_fract_shifted = { 6'b0, 1'b1, wrdata[51:0],  5'b0};   //-21
         11'h3E9 : DP_fract_shifted = { 7'b0, 1'b1, wrdata[51:0],  4'b0};   //-22
         11'h3E8 : DP_fract_shifted = { 8'b0, 1'b1, wrdata[51:0],  3'b0};   //-23
         11'h3E7 : DP_fract_shifted = { 9'b0, 1'b1, wrdata[51:0],  2'b0};   //-24
         11'h3E6 : DP_fract_shifted = {10'b0, 1'b1, wrdata[51:0],  1'b0};   //-25
         11'h3E5 : DP_fract_shifted = {11'b0, 1'b1, wrdata[51:0]       };   //-26
         11'h3E4 : DP_fract_shifted = {12'b0, 1'b1, wrdata[51:1]       };   //-27
         default : DP_fract_shifted = {13'b0, 1'b1, wrdata[51:2]       };   //-28 and smaller
    endcase                                                          

always @(*)
        case(round_mode_q2)
            NEAREST : if (((DP_GRS==3'b100) && (DP_fract_shifted[54] || Away_q2) ) || (DP_GRS[2] && |DP_GRS[1:0])) DP_roundit = 1'b1;    
                      else DP_roundit = 1'b0;
            POSINF  : if (~DP_sign && |DP_GRS) DP_roundit = 1'b1;
                      else DP_roundit = 1'b0;
            NEGINF  : if (DP_sign && |DP_GRS) DP_roundit = 1'b1;
                      else DP_roundit = 1'b0;
            ZERO    : DP_roundit = 1'b0;
        endcase


always @(*)
    if (DP_is_NaN || DP_is_infinite) begin
        DP_exp = 5'b11111;
        DP_fract = wrdata[51:42];   //signal included
    end
    else if (DP_is_zero) begin
        DP_exp = 5'b00000;
        DP_fract = 10'b00_0000_0000;
    end
    else if(DP_is_subnormal) begin
        DP_exp = 5'b00000; 
        DP_fract = DP_fract_shifted[63:54];
    end
    else begin
        DP_exp = DP_exp_510;    
        DP_fract = wrdata[51:42];
    end
        

wire SP_sign;
wire [7:0] SP_exp_interm;
wire [4:0] SP_exp_510;
wire SP_overflow;
wire SP_underflow;
wire SP_is_NaN;
wire SP_is_subnormal;
wire SP_is_infinite;
wire SP_is_zero;

assign SP_overflow = (wrdata[30:23] > (127 + 15)) || (&wrdata[22:13] && SP_roundit && (wrdata[30:23]==(127 + 15)));
assign SP_is_NaN = &wrdata[30:23] && |wrdata[21:0];
assign SP_is_infinite = (&wrdata[30:23] && ~|wrdata[22:0]) || SP_overflow;
assign SP_is_zero = ~|wrdata[30:0];
assign SP_underflow = ((wrdata[30:23] < (127 - 14)) && ~((wrdata[30:23]==(127 - 15)) && &wrdata[22:13] && SP_roundit));
assign SP_is_subnormal = ~|wrdata[30:23] && |wrdata[22:0] || SP_underflow;
assign SP_exp_interm = wrdata[30:23];
assign SP_sign = wrdata[31];
assign SP_exp_510 = wrdata[30:23] - 112;

// to handle SP subnormal cases
always @(*)                                                                                                   
    case(SP_exp_interm)  
           8'b1xxxxxxx,
           8'h7F,
           8'h7E,                                                                                     
           8'h7D,                                                                                     
           8'h7C,                                                                                     
           8'h7B,                                                                                     
           8'h7A,                                                                                     
           8'h79,                                                                                     
           8'h78,                                                                                     
           8'h77,                                                                                     
           8'h76,                                                                                     
           8'h75,                                                                                     
           8'h74,                                                                                     
           8'h73,                                                                                     
           8'h72,                                                                                     
           8'h71 : SP_fract_shifted = {             wrdata[22:0], 12'b0};   // for normal numbers to get GRS bits                                                                       
           8'h70 : SP_fract_shifted = {       1'b1, wrdata[22:0], 11'b0};   //-15                              
           8'h6F : SP_fract_shifted = { 1'b0, 1'b1, wrdata[22:0], 10'b0};   //-16                              
           8'h6E : SP_fract_shifted = { 2'b0, 1'b1, wrdata[22:0],  9'b0};   //-17                              
           8'h6D : SP_fract_shifted = { 3'b0, 1'b1, wrdata[22:0],  8'b0};   //-18                              
           8'h6C : SP_fract_shifted = { 4'b0, 1'b1, wrdata[22:0],  7'b0};   //-19                              
           8'h6B : SP_fract_shifted = { 5'b0, 1'b1, wrdata[22:0],  6'b0};   //-20                              
           8'h6A : SP_fract_shifted = { 6'b0, 1'b1, wrdata[22:0],  5'b0};   //-21                              
           8'h69 : SP_fract_shifted = { 7'b0, 1'b1, wrdata[22:0],  4'b0};   //-22                              
           8'h68 : SP_fract_shifted = { 8'b0, 1'b1, wrdata[22:0],  3'b0};   //-23                              
           8'h67 : SP_fract_shifted = { 9'b0, 1'b1, wrdata[22:0],  2'b0};   //-24                              
           8'h66 : SP_fract_shifted = {10'b0, 1'b1, wrdata[22:0],  1'b0};   //-25                              
           8'h65 : SP_fract_shifted = {11'b0, 1'b1, wrdata[22:0]      };    //-26
           8'h64 : SP_fract_shifted = {12'b0, 1'b1, wrdata[22:1]      };    //-27
         default : SP_fract_shifted = {13'b0, 1'b1, wrdata[22:2]      };    //-28 and smaller
    endcase                                                          

always @(*)
        case(round_mode_q2)
            NEAREST : if (((SP_GRS==3'b100) && (SP_fract_shifted[25] || Away_q2) ) || (SP_GRS[2] && |SP_GRS[1:0])) SP_roundit = 1'b1;    
                      else SP_roundit = 1'b0;
            POSINF  : if (~SP_sign && |SP_GRS) SP_roundit = 1'b1;
                      else SP_roundit = 1'b0;
            NEGINF  : if (SP_sign && |SP_GRS) SP_roundit = 1'b1;
                      else SP_roundit = 1'b0;
            ZERO    : SP_roundit = 1'b0;
        endcase



always @(*)
    if (SP_is_NaN || SP_is_infinite) begin
        SP_exp = 5'b11111;
        SP_fract = wrdata[22:12];
    end
    else if (SP_is_zero) begin
        SP_exp = 5'b00000;
        SP_fract = 10'b00_0000_0000;
    end
    else if(SP_is_subnormal) begin
        SP_exp = 5'b00000; 
        SP_fract = SP_fract_shifted[34:25];
    end
    else begin
        SP_exp = SP_exp_510;    
        SP_fract = wrdata[22:12];
    end
        
always @(*)
    case(Src_Size_q2)
      DP : begin
              wrdata_510 = {DP_sign, ({DP_exp, DP_fract} + DP_roundit)};
              overflow = DP_overflow;
              underflow = DP_underflow;
              inexact = DP_roundit;
           end
      SP : begin
              wrdata_510 = {SP_sign, ({SP_exp, SP_fract} + SP_roundit)};
              overflow = SP_overflow;
              underflow = SP_underflow;
              inexact = SP_roundit;
           end
      HP : begin
              wrdata_510 = wrdata[15:0];
              overflow = 1'b0;
              underflow = 1'b0;
              inexact = 1'b0;
           end
      BT : begin
              wrdata_510 = {8'b0, wrdata[7:0]};
              overflow = 1'b0;
              underflow = 1'b1;
              inexact = 1'b0;
           end
 endcase

wire [129:0] ascOut;
binToDecChar binToDecChar(
    .RESET      (RESET ),
    .CLK        (CLK   ),
    .wren       (wren  ),
    .overflow   (overflow),
    .underflow  (underflow),
    .inexact    (inexact),
    .Away       (Away_q2),
    .round_mode (round_mode_q2),
    .wrdata     (wrdata_510),
    .ascOut     (ascOut)
    );          



//RAM64x34tp ram64(
RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(130))
    ram64_binDec(
    .CLK        (CLK     ),
    .wren       (wren_del_6 ),
    .wraddrs    (wraddrs_del_6 ),   
    .wrdata     (ascOut  ), 
    .rdenA      (rdenA   ),   
    .rdaddrsA   (rdaddrsA),
    .rddataA    (rddataA_ ),
    .rdenB      (rdenB   ),
    .rdaddrsB   (rdaddrsB),
    .rddataB    (rddataB_ ));


always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        wren_del_0 <= 1'b0;
        wren_del_1 <= 1'b0;
        wren_del_2 <= 1'b0;
        wren_del_3 <= 1'b0;
        wren_del_4 <= 1'b0;
        wren_del_5 <= 1'b0;
        wren_del_6 <= 1'b0;
    end    
    else begin
        wren_del_0 <= wren;
        wren_del_1 <= wren_del_0;
        wren_del_2 <= wren_del_1;
        wren_del_3 <= wren_del_2;
        wren_del_4 <= wren_del_3;
        wren_del_5 <= wren_del_4;
        wren_del_6 <= wren_del_5;
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
        wraddrs_del_6 <= 6'b0;
    end    
    else begin
        wraddrs_del_0 <= wraddrs;
        wraddrs_del_1 <= wraddrs_del_0;
        wraddrs_del_2 <= wraddrs_del_1;
        wraddrs_del_3 <= wraddrs_del_2;
        wraddrs_del_4 <= wraddrs_del_3;
        wraddrs_del_5 <= wraddrs_del_4;
        wraddrs_del_6 <= wraddrs_del_5;
    end                    
end
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (wren) semaphor[wraddrs] <= 1'b0;
        if (wren_del_6) semaphor[wraddrs_del_6] <= 1'b1;
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
