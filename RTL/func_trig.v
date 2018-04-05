 // func_trig.v
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

//SINd COSd TANd COTd with one degree resolution accepts 10-bit integer and delivers rounded 16-bit result plus two exception bits in MSBs 
module func_trig(                                   
    CLK,                   
    RESET,                 
    SIN_wren,              
    COS_wren,              
    TAN_wren,              
    COT_wren,
    round_mode,
    Away,              
    wraddrs,                             
    wrdataA,                
    SIN_rdenA,             
    COS_rdenA,             
    TAN_rdenA,             
    COT_rdenA,             
    rdaddrsA,              
    SIN_rddataA,    
    COS_rddataA,    
    TAN_rddataA,    
    COT_rddataA,    
    SIN_rdenB,             
    COS_rdenB,             
    TAN_rdenB,             
    COT_rdenB,             
    rdaddrsB,              
    SIN_rddataB,
    COS_rddataB,
    TAN_rddataB,
    COT_rddataB,
    SIN_ready,    
    COS_ready,
    TAN_ready,
    COT_ready    
    );                                                             


input  CLK;
input  RESET;
input  SIN_wren;   
input  COS_wren;   
input  TAN_wren;   
input  COT_wren; 
input [1:0] round_mode;
input Away;  
input  [3:0]  wraddrs;    
input  [9:0]  wrdataA;
input  SIN_rdenA;  
input  COS_rdenA;  
input  TAN_rdenA;  
input  COT_rdenA;  
input  [3:0]  rdaddrsA; 
output [17:0] SIN_rddataA;                                               
output [17:0] COS_rddataA;                                               
output [17:0] TAN_rddataA;                                               
output [17:0] COT_rddataA;                                               
input  SIN_rdenB;                                                        
input  COS_rdenB;                                                        
input  TAN_rdenB;                                                        
input  COT_rdenB;                                                        
input  [3:0]  rdaddrsB;                                                  
output [17:0] SIN_rddataB;                                               
output [17:0] COS_rddataB;                                               
output [17:0] TAN_rddataB;                                               
output [17:0] COT_rddataB;                                               
output SIN_ready;
output COS_ready;
output TAN_ready;
output COT_ready;

//rounding mode encodings
parameter NEAREST = 2'b00;
parameter POSINF  = 2'b01;
parameter NEGINF  = 2'b10;
parameter ZERO    = 2'b11;

// exception codes for two MSBs [18:17] of result
parameter _no_excpt_   = 2'b00;  // no exception--all good
parameter _overflow_   = 2'b01;  // the operation has overflowed--inexact is always implied--
parameter _invalid_    = 2'b01;  // a NaN will either have exception code of _no_excpt_ or _invalid_.  Read the last three bits of the NaN to determine cause of invalid exception.
parameter _underflow_  = 2'b10;  // inexact underflow (underflows that are also exact are not signaled--per IEEE754-2008)
parameter _div_x_0_    = 2'b10;  // infinity never shows underflow, so we use the same except code for underflow to signal div x 0
parameter _inexact_    = 2'b11;  // inexact due to rounding only (overflow and underflow excluded)

 
reg SIN_readyA;
reg SIN_readyB;
reg COS_readyA;
reg COS_readyB;
reg TAN_readyA;
reg TAN_readyB;
reg COT_readyA;
reg COT_readyB;
reg [15:0] SIN_semaphor;
reg [15:0] COS_semaphor;
reg [15:0] TAN_semaphor;
reg [15:0] COT_semaphor;
reg [7:0] delay0;

wire SIN_ready;
wire COS_ready;
wire TAN_ready;
wire COT_ready;

wire [3:0] wraddrsq;

wire SIN_wrenq;
wire COS_wrenq;
wire TAN_wrenq;
wire COT_wrenq;

assign SIN_ready = SIN_readyA && SIN_readyB;  
assign COS_ready = COS_readyA && COS_readyB;  
assign TAN_ready = TAN_readyA && TAN_readyB;  
assign COT_ready = COT_readyA && COT_readyB;  

assign SIN_wrenq = delay0[7];
assign COS_wrenq = delay0[6];
assign TAN_wrenq = delay0[5];
assign COT_wrenq = delay0[4];
assign wraddrsq = delay0[3:0]; 

wire [17:0] SIN_rddataA;
wire [17:0] SIN_rddataB;
wire [17:0] COS_rddataA;
wire [17:0] COS_rddataB;
wire [17:0] TAN_rddataA;
wire [17:0] TAN_rddataB;
wire [17:0] COT_rddataA;
wire [17:0] COT_rddataB;

reg [9:0] TRIGin;

reg sin_roundit;
reg cos_roundit;
reg tan_roundit;
reg cot_roundit;


wire [18:0] SINout;                         
wire [18:0] COSout;                         
wire [18:0] TANout;                         
wire [18:0] COTout;                         

wire wren;
assign wren = SIN_wren || COS_wren || TAN_wren || COT_wren;

wire [1:0] thread_q2;
assign thread_q2 = wraddrs[3:2];

                  
wire [4:0] SINoutEXP;
wire [4:0] COSoutEXP;
wire [4:0] TANoutEXP;
wire [4:0] COToutEXP;

wire [9:0] SINoutFRACT;
wire [9:0] COSoutFRACT;
wire [9:0] TANoutFRACT;
wire [9:0] COToutFRACT;

wire [17:0] SINout510;
wire [17:0] COSout510;
wire [17:0] TANout510;
wire [17:0] COTout510;

wire sin_guard ;
wire sin_round ;
wire sin_sticky;
 
wire cos_guard ;
wire cos_round ;
wire cos_sticky;

wire tan_guard ;
wire tan_round ;
wire tan_sticky;

wire cot_guard ;
wire cot_round ;
wire cot_sticky; 

wire [2:0] sin_GRS;
wire [2:0] cos_GRS;
wire [2:0] tan_GRS;
wire [2:0] cot_GRS;

wire sin_inexact;
wire cos_inexact;
wire tan_inexact;
wire cot_inexact;

assign SINoutEXP = SINout[17:13];
assign COSoutEXP = COSout[17:13];
assign TANoutEXP = TANout[17:13];
assign COToutEXP = COTout[17:13];

assign SINoutFRACT = SINout[12:3];
assign COSoutFRACT = COSout[12:3];
assign TANoutFRACT = TANout[12:3];
assign COToutFRACT = COTout[12:3];

assign sin_guard  = SINout[2];
assign sin_round  = SINout[1];
assign sin_sticky = SINout[0];
                   
assign cos_guard  = COSout[2];
assign cos_round  = COSout[1];
assign cos_sticky = COSout[0];
                   
assign tan_guard  = TANout[2];
assign tan_round  = TANout[1];
assign tan_sticky = TANout[0];
                   
assign cot_guard  = COTout[2];
assign cot_round  = COTout[1];
assign cot_sticky = COTout[0];

assign sin_inexact = |SINout[11:0];
assign cos_inexact = |COSout[11:0];
assign tan_inexact = |TANout[11:0];
assign cot_inexact = |COTout[11:0];

assign  sin_GRS = {sin_guard, sin_round, (sin_sticky || sin_inexact)};
assign  cos_GRS = {cos_guard, cos_round, (cos_sticky || cos_inexact)};
assign  tan_GRS = {tan_guard, tan_round, (tan_sticky || tan_inexact)};
assign  cot_GRS = {cot_guard, cot_round, (cot_sticky || cot_inexact)};

assign SINout510 = {sin_inexact, sin_inexact, SINout[18], ({SINoutEXP, SINoutFRACT} + sin_roundit)};

assign COSout510 = {cos_inexact, cos_inexact, COSout[18], ({COSoutEXP, COSoutFRACT} + cos_roundit)};

assign TANout510 = {(tan_inexact || &TANoutEXP), tan_inexact, (TANout[18] || &TANoutEXP), ({TANoutEXP, TANoutFRACT} + tan_roundit)};

assign COTout510 = {(cot_inexact || &COToutEXP), cot_inexact, (COTout[18] || &COToutEXP), ({COToutEXP, COToutFRACT} + cot_roundit)};

trigd trigd(
    .func_sel({SIN_wrenq, COS_wrenq, TAN_wrenq, COT_wrenq}),
    .x       (TRIGin),
    .sin     (SINout),
    .cos     (COSout),
    .tan     (TANout),
    .cot     (COTout)
    ); 
 
RAM_func #(.ADDRS_WIDTH(4), .DATA_WIDTH(18))
    ram32_SIN(
    .CLK        (CLK      ),
    .wren       (SIN_wrenq),
    .wraddrs    (wraddrsq[3:0]),     //includes thread#
    .wrdata     (SINout510),
    .rdenA      (SIN_rdenA),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (SIN_rddataA),                                  
    .rdenB      (SIN_rdenB),                                      
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (SIN_rddataB)
    );

RAM_func #(.ADDRS_WIDTH(4), .DATA_WIDTH(18))
    ram32_COS(
    .CLK        (CLK      ),
    .wren       (COS_wrenq),
    .wraddrs    (wraddrsq[3:0]),
    .wrdata     (COSout510),
    .rdenA      (COS_rdenA),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (COS_rddataA),
    .rdenB      (COS_rdenB),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (COS_rddataB)
    );

RAM_func #(.ADDRS_WIDTH(4), .DATA_WIDTH(18))
    ram32_TAN(
    .CLK        (CLK      ),
    .wren       (TAN_wrenq),
    .wraddrs    (wraddrsq[3:0]),
    .wrdata     (TANout510),
    .rdenA      (TAN_rdenA),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (TAN_rddataA),
    .rdenB      (TAN_rdenB),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (TAN_rddataB)
    );

RAM_func #(.ADDRS_WIDTH(4), .DATA_WIDTH(18))
    ram32_COT(
    .CLK        (CLK      ),
    .wren       (COT_wrenq),
    .wraddrs    (wraddrsq[3:0]),
    .wrdata     (COTout510),
    .rdenA      (COT_rdenA),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (COT_rddataA),
    .rdenB      (COT_rdenB),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (COT_rddataB)
    );
    
// sin_roundit           
always @(*)
    if (wren)
        case(round_mode)
            NEAREST : if (((sin_GRS==3'b100) && (SINoutFRACT[0] || Away)) || (sin_GRS[2] && |sin_GRS[1:0])) sin_roundit = 1'b1;    
                      else sin_roundit = 1'b0;
            POSINF  : if (~SINout[18] && |sin_GRS) sin_roundit = 1'b1;
                      else sin_roundit = 1'b0;
            NEGINF  : if (SINout[18] && |sin_GRS) sin_roundit = 1'b1;
                      else sin_roundit = 1'b0;
            ZERO    : sin_roundit = 1'b0;
        endcase
   else sin_roundit = 1'b0;                  

// cos_roundit           
always @(*)
    if (wren)
        case(round_mode)
            NEAREST : if (((cos_GRS==3'b100) && (COSoutFRACT[0] || Away)) || (cos_GRS[2] && |cos_GRS[1:0])) cos_roundit = 1'b1;    
                      else cos_roundit = 1'b0;
            POSINF  : if (~COSout[18] && |cos_GRS) cos_roundit = 1'b1;
                      else cos_roundit = 1'b0;
            NEGINF  : if (COSout[18] && |cos_GRS) cos_roundit = 1'b1;
                      else cos_roundit = 1'b0;
            ZERO    : cos_roundit = 1'b0;
        endcase
   else cos_roundit = 1'b0;                  

// tan_roundit           
always @(*)
    if (wren)
        case(round_mode)
            NEAREST : if (((tan_GRS==3'b100) && (TANoutFRACT[0] || Away)) || (tan_GRS[2] && |tan_GRS[1:0])) tan_roundit = 1'b1;    
                      else tan_roundit = 1'b0;
            POSINF  : if (~TANout[18] && |tan_GRS) tan_roundit = 1'b1;
                      else tan_roundit = 1'b0;
            NEGINF  : if (TANout[18] && |tan_GRS) tan_roundit = 1'b1;
                      else tan_roundit = 1'b0;
            ZERO    : tan_roundit = 1'b0;
        endcase
   else tan_roundit = 1'b0;                  

// cot_roundit           
always @(*)
    if (wren)
        case(round_mode)
            NEAREST : if (((cot_GRS==3'b100) && (COToutFRACT[0] || Away)) || (cot_GRS[2] && |cot_GRS[1:0])) cot_roundit = 1'b1;    
                      else cot_roundit = 1'b0;
            POSINF  : if (~COTout[18] && |cot_GRS) cot_roundit = 1'b1;
                      else cot_roundit = 1'b0;
            NEGINF  : if (COTout[18] && |cot_GRS) cot_roundit = 1'b1;
                      else cot_roundit = 1'b0;
            ZERO    : cot_roundit = 1'b0;
        endcase
   else cot_roundit = 1'b0;      
   
always @(posedge CLK or posedge RESET)
    if (RESET) TRIGin <= 10'b0;
    else if (wren) TRIGin <= wrdataA;

always@(posedge CLK or posedge RESET) begin
    if (RESET) begin
        delay0  <= 8'b0;
    end    
    else begin                                                                            
        delay0  <= {SIN_wren, COS_wren, TAN_wren, COT_wren, wraddrs};                     
    end                                                                                   
end                                                                                       

always @(posedge CLK or posedge RESET) begin
//    if (RESET) SIN_semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    if (RESET) SIN_semaphor <= 16'hFFFF;
    else begin
        if (SIN_wren) SIN_semaphor[wraddrs] <= 1'b0;
        if (SIN_wrenq) SIN_semaphor[wraddrsq] <= 1'b1;
    end
end

always @(posedge CLK or posedge RESET) begin
//    if (RESET) COS_semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    if (RESET) COS_semaphor <= 16'hFFFF;
    else begin
        if (COS_wren) COS_semaphor[wraddrs] <= 1'b0;
        if (COS_wrenq) COS_semaphor[wraddrsq] <= 1'b1;
    end
end

always @(posedge CLK or posedge RESET) begin
//    if (RESET) TAN_semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    if (RESET) TAN_semaphor <= 16'hFFFF;
    else begin
        if (TAN_wren) TAN_semaphor[wraddrs] <= 1'b0;
        if (TAN_wrenq) TAN_semaphor[wraddrsq] <= 1'b1;
    end
end

always @(posedge CLK or posedge RESET) begin
//    if (RESET) COT_semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    if (RESET) COT_semaphor <= 16'hFFFF;
    else begin
        if (COT_wren) COT_semaphor[wraddrs] <= 1'b0;
        if (COT_wrenq) COT_semaphor[wraddrsq] <= 1'b1;
    end
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        SIN_readyA <= 1'b1;
        SIN_readyB <= 1'b1;
    end  
    else begin
         SIN_readyA <= SIN_rdenA ? SIN_semaphor[rdaddrsA] : 1'b1;
         SIN_readyB <= SIN_rdenB ? SIN_semaphor[rdaddrsB] : 1'b1;
    end   
end


always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        COS_readyA <= 1'b1;
        COS_readyB <= 1'b1;
    end  
    else begin
         COS_readyA <= COS_rdenA ? COS_semaphor[rdaddrsA] : 1'b1;
         COS_readyB <= COS_rdenB ? COS_semaphor[rdaddrsB] : 1'b1;
    end   
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        TAN_readyA <= 1'b1;
        TAN_readyB <= 1'b1;
    end  
    else begin
         TAN_readyA <= TAN_rdenA ? TAN_semaphor[rdaddrsA] : 1'b1;
         TAN_readyB <= TAN_rdenB ? TAN_semaphor[rdaddrsB] : 1'b1;
    end   
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        COT_readyA <= 1'b1;
        COT_readyB <= 1'b1;
    end  
    else begin
         COT_readyA <= COT_rdenA ? COT_semaphor[rdaddrsA] : 1'b1;
         COT_readyB <= COT_rdenB ? COT_semaphor[rdaddrsB] : 1'b1;
    end   
end

endmodule
