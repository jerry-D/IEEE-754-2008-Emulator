 // STATUS_REG.v
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

module STATUS_REG (
    CLK,
    RESET,
    wrcycl,           
    thread_q2_sel,
    OPdest_q2,
    Ind_Dest_q2,
    Sext_SrcA_q2,
    Sext_SrcB_q2,
    Size_SrcA_q2,
    Size_SrcB_q2,
    Size_Dest_q2,
    wrsrcAdata, 
    wrsrcBdata, 
    V_q2,
    N_q2, 
    C_q2, 
    Z_q2,
    V,
    N,
    C,
    Z,
    IRQ,
    done,
    enAltImmInexactHandl,  
    enAltImmUnderflowHandl,
    enAltImmOverflowHandl, 
    enAltImmDivByZeroHandl,
    enAltImmInvalidHandl,  
    IRQ_IE,
    STATUS,
    class,
    exc_codeA, 
    exc_codeB, 
    rd_float_q1_selA ,
    rd_float_q1_selB ,
    rd_integr_q1_selA,
    rd_integr_q1_selB,
    fp_ready_q2
);

input  CLK;
input  RESET;
input  wrcycl;           
input  thread_q2_sel;
input  [15:0] OPdest_q2;
input Ind_Dest_q2;
input Sext_SrcA_q2;
input Sext_SrcB_q2;
input [1:0] Size_SrcA_q2; 
input [1:0] Size_SrcB_q2;
input [1:0] Size_Dest_q2; 
input  [63:0] wrsrcAdata; 
input  [63:0] wrsrcBdata; 
input  V_q2;
input  N_q2; 
input  C_q2; 
input  Z_q2; 
output V;
output N;
output C;
output Z;
input  IRQ;
output done;
output IRQ_IE;
output [63:0] STATUS;
output [3:0] class;
input  [1:0] exc_codeA; 
input  [1:0] exc_codeB; 
input  rd_float_q1_selA;
input  rd_float_q1_selB;
input  rd_integr_q1_selA;
input  rd_integr_q1_selB;
input  fp_ready_q2;

output enAltImmInexactHandl;  
output enAltImmUnderflowHandl;
output enAltImmOverflowHandl; 
output enAltImmDivByZeroHandl;
output enAltImmInvalidHandl;  


parameter ST_ADDRS = 18'h0FF88;
parameter compare_ADDRS   = 16'hFF89;     //integer compare address (size of destination must be 2'b00, ie, byte)
parameter cmpSE_ADDRS     = 16'hFF1F;     //cmpSE  byte address compareSignalingEqual(source1, source2)           
parameter cmpQE_ADDRS     = 16'hFF1E;     //cmpQE   byte address compareQuietEqual(source1, source2)               
parameter cmpSNE_ADDRS    = 16'hFF1D;     //cmpSNE  byte address compareSignalingNotEqual(source1, source2)        
parameter cmpQNE_ADDRS    = 16'hFF1C;     //cmpQNE  byte address compareQuietNotEqual(source1, source2)            
parameter cmpSG_ADDRS     = 16'hFF1B;     //cmpSG  byte address compareSignalingGreater(source1, source2)         
parameter cmpQG_ADDRS     = 16'hFF1A;     //cmpQG  byte address compareQuietGreater(source1, source2)             
parameter cmpSGE_ADDRS    = 16'hFF19;     //cmpSGE  byte address compareSignalingGreaterEqual(source1, source2)    
parameter cmpQGE_ADDRS    = 16'hFF18;     //cmpQGE  byte address compareQuietGreaterEqual(source1, source2)        
parameter cmpSL_ADDRS     = 16'hFF17;     //cmpSL  byte address compareSignalingLess(source1, source2)            
parameter cmpQL_ADDRS     = 16'hFF16;     //cmpQL  byte address compareQuietLess(source1, source2)                
parameter cmpSLE_ADDRS    = 16'hFF15;     //cmpSLE  byte address compareSignalingLessEqual(source1, source2)       
parameter cmpQLE_ADDRS    = 16'hFF14;     //cmpQLE  byte address compareQuietLessEqual(source1, source2)           
parameter cmpSNG_ADDRS    = 16'hFF13;     //cmpSNG  byte address compareSignalingNotGreater(source1, source2)      
parameter cmpQNG_ADDRS    = 16'hFF12;     //cmpQNG  byte address compareQuietNotGreater(source1, source2)          
parameter cmpSLU_ADDRS    = 16'hFF11;     //cmpSLU  byte address compareSignalingLessUnordered(source1, source2)   
parameter cmpQLU_ADDRS    = 16'hFF10;     //cmpQLU  byte address compareQuietLessUnordered(source1, source2)       
parameter cmpSNL_ADDRS    = 16'hFF0F;     //cmpSNL  byte address compareSignalingNotLess(source1, source2)         
parameter cmpQNL_ADDRS    = 16'hFF0E;     //cmpQNL  byte address compareQuietNotLess(source1, source2)             
parameter cmpSGU_ADDRS    = 16'hFF0D;     //cmpSGU  byte address compareSignalingGreaterUnordered(source1, source2)
parameter cmpQGU_ADDRS    = 16'hFF0C;     //cmpQGU  byte address compareQuietGreaterUnordered(source1, source2)    
parameter cmpQU_ADDRS     = 16'hFF0B;     //cmpQU  byte address compareQuietUnordered(source1, source2) 
parameter cmpQO_ADDRS     = 16'hFF0A;     //cmpQO  byte address compareQuietOrdered(source1, source2)             
parameter is_ADDRS        = 16'hFF09;     //all the is(es) go here          
parameter clas_ADDRS      = 16'hFF08;     //class(x)--clas is a 1-byte readable register at this location
parameter tOrd_ADDRS      = 16'hFF07;     //total order
parameter tOrdM_ADDRS     = 16'hFF06;     //total order magnitude           
parameter lowFlg_ADDRS    = 16'hFF05;                                      
parameter rasFlg_ADDRS    = 16'hFF04;     
parameter tstFlg_ADDRS    = 16'hFF03;                                            
parameter tstSFlg_ADDRS   = 16'hFF02;                                                        
parameter rstFlg_ADDRS    = 16'hFF01;
parameter sAlFlg_ADDRS    = 16'hFF00;
parameter setBinRnd_ADDRS = 16'hFF8F;     //must be uh to set and ub to put back to default mode
parameter setSubstt_ADDRS = 16'hFF8E;     //must be uh
parameter setDVNCZ_ADDRS  = 16'hFF8C;     //must be uh
parameter rasSig_ADDRS    = 16'hFF8B;     //must be uh
parameter lowSig_ADDRS    = 16'hFF8B;     //must be uw
parameter rasNoFlag_ADDRS = 16'hFF8A;     //must be uh
parameter enAltImm_ADDRS  = 16'hFF8D;     //must be uh
parameter saveModes_ADDRS = 16'hFE08;


parameter DP = 2'b11;
parameter SP = 2'b10;
parameter HP = 2'b01; 
 
// exception codes for two MSBs [18:17] of result
parameter _no_excpt_   = 2'b00;  // no exception--all good
parameter _overflow_   = 2'b01;  // the operation has overflowed--inexact is always implied--
parameter _invalid_    = 2'b01;  // a NaN will either have exception code of _no_excpt_ or _invalid_.  Read the last three bits of the NaN to determine cause of invalid exception.
parameter _underFlowExact_ = 2'b01;
parameter _underFlowInexact_  = 2'b10;  // inexact underflow (underflows that are also exact are not signaled--per IEEE754-2008, unless immediate alternate handling is enabled)
parameter _div_x_0_    = 2'b10;  // infinity never shows underflow, so we use the same except code for underflow to signal div x 0
parameter _inexact_    = 2'b11;                     

reg invalid_q2;  
reg divby0_q2;   
reg overflow_q2; 
reg underflow_q2;
reg inexact_q2;
reg operand_q2;

                       // bit position
reg RM0;               //  EQU 63
reg RM1;               //  EQU 62
reg AWAY;              //  EQU 61
reg RM_ATR_EN;         //  EQU 60
                        
// alternate delayed substitution
reg subsInexact;       //  EQU 59
reg subsUnderflow;     //  EQU 58
reg subsOverflow;      //  EQU 57
reg subsDivByZero;     //  EQU 56
reg subsInvalid;       //  EQU 55


// total Order
reg compareTrue;       //  EQU 54
reg aFlagRaised;       //  EQU 53
reg totlOrderMag;      //  EQU 52
reg totlOrder;         //  EQU 51

// is
reg Canonical;         //  EQU 50
reg Signaling;         //  EQU 49
reg NaN;               //  EQU 48
reg Infinite;          //  EQU 47
reg Subnormal;         //  EQU 46
reg Zero;              //  EQU 45
reg Finite;            //  EQU 44
reg Normal;            //  EQU 43
reg SignMinus;         //  EQU 42

// class
reg positiveInfinity;  //  EQU 41
reg positiveNormal;    //  EQU 40
reg positiveSubnormal; //  EQU 39
reg positiveZero;      //  EQU 38
reg negativeZero;      //  EQU 37
reg negativeSubnormal; //  EQU 36
reg negativeNormal;    //  EQU 35
reg negativeInfinity;  //  EQU 34
reg quietNaN;          //  EQU 33
reg signalingNaN;      //  EQU 32                       

reg IRQ_IE;                  //  EQU 26

reg inexact_signal;          //  EQU 25
reg underflow_signal;        //  EQU 24
reg overflow_signal;         //  EQU 23
reg divby0_signal;           //  EQU 22
reg invalid_signal;          //  EQU 21

reg razNoInexactFlag;        //  EQU 20
reg razNoUnderflowFlag;      //  EQU 19
reg razNoOverflowFlag;       //  EQU 18
reg razNoDivByZeroFlag;      //  EQU 17
reg razNoInvalidFlag;        //  EQU 16

reg enAltImmInexactHandl;    //  EQU 15
reg enAltImmUnderflowHandl;  //  EQU 14
reg enAltImmOverflowHandl;   //  EQU 13
reg enAltImmDivByZeroHandl;  //  EQU 12
reg enAltImmInvalidHandl;    //  EQU 11

reg inexact_flag;            //  EQU 10
reg underflow_flag;          //  EQU 9
reg overflow_flag;           //  EQU 8
reg divby0_flag;             //  EQU 7
reg invalid_flag;            //  EQU 6

reg done;                    //  EQU 4
reg V;                       //  EQU 3
reg N;                       //  EQU 2
reg C;                       //  EQU 1
reg Z;                       //  EQU 0

reg [10:0] Xe; //X exponent
reg [10:0] Ye; //Y exponent
reg X_sign;
reg Y_sign;
reg [51:0] X_fraction;
reg [51:0] Y_fraction;

reg [3:0] class;
reg ExcSource_q2;

reg cmprEnable;

reg rd_float_q2_sel;
reg rd_integr_q2_sel;

wire [9:0] class_sel;

wire Status_wren;     

wire [63:0] STATUS;

wire [63:0] X;
wire [63:0] Y;

wire X_signalingNaN;     
wire X_quietNaN;         
wire X_negativeInfinity; 
wire X_negativeNormal;   
wire X_negativeSubnormal;
wire X_negativeZero;     
wire X_positiveZero;     
wire X_positiveSubnormal;
wire X_positiveNormal;   
wire X_positiveInfinity; 

wire X_SignMinus;         
wire X_Normal;            
wire X_Finite;            
wire X_Zero;              
wire X_Subnormal;         
wire X_Infinite;          
wire X_NaN;               
wire X_Signaling;         
wire X_Canonical; 
     
wire Y_SignMinus;         
wire Y_Normal;            
wire Y_Finite;            
wire Y_Zero;              
wire Y_Subnormal;         
wire Y_Infinite;          
wire Y_NaN;               
wire Y_Signaling;         
wire Y_Canonical;         
        
wire _totlOrder;         
wire _totlOrderMag;      

wire _compareTrue;  

wire X_LT_Y;
wire X_GT_Y;
wire X_EQ_Y;
wire UNORDERED; 

wire cmpSE; 
wire cmpQE; 
wire cmpSNE;
wire cmpQNE;
wire cmpSG; 
wire cmpQG; 
wire cmpSGE;
wire cmpQGE;
wire cmpSL; 
wire cmpQL; 
wire cmpSLE;
wire cmpQLE;
wire cmpSNG;
wire cmpQNG;
wire cmpSLU;
wire cmpQLU;
wire cmpSNL;
wire cmpQNL;                                                  
wire cmpSGU;                                                  
wire cmpQGU;                                                  
wire cmpQU;                                                   
wire cmpQO;                                                   

wire _aFlagRaised;

wire _aSFlagRaised;
                    
wire X_Invalid;
wire X_DivX0;
wire X_Overflow;
wire X_Underflow;
wire X_inexact;
                                                              
wire Y_Invalid;                                               
wire Y_DivX0;                                                 
wire Y_Overflow;                                              
wire Y_Underflow;                                             
wire Y_inexact;                            
wire [9:0] exc_sel;

wire cmprInvalid;  

wire signed [64:0] compareAdata;
wire signed [64:0] compareBdata;  

assign compareAdata = {(Sext_SrcA_q2 && wrsrcAdata[63]), wrsrcAdata};            
assign compareBdata = {(Sext_SrcB_q2 && wrsrcBdata[63]), wrsrcBdata};            

assign X = {X_sign, Xe, X_fraction};
assign Y = {Y_sign, Ye, Y_fraction};         

assign X_LT_Y = (X_Zero && Y_Zero) ? 1'b0 : ({~X[63], X[62:0]} < {~Y[63], Y[62:0]});
assign X_GT_Y = (X_Zero && Y_Zero) ? 1'b0 : ({~X[63], X[62:0]} > {~Y[63], Y[62:0]});                          
assign X_EQ_Y = (X_Zero && Y_Zero) ? 1'b1 : ({~X[63], X[62:0]}=={~Y[63], Y[62:0]});
assign UNORDERED = X_NaN || Y_NaN; 

assign cmpSE  = ((OPdest_q2[15:0]==cmpSE_ADDRS[15:0])  && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && X_EQ_Y);
assign cmpQE  = ((OPdest_q2[15:0]==cmpQE_ADDRS[15:0])  && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && X_EQ_Y);
assign cmpSNE = ((OPdest_q2[15:0]==cmpSNE_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && ~X_EQ_Y);
assign cmpQNE = ((OPdest_q2[15:0]==cmpQNE_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && ~X_EQ_Y);
assign cmpSG  = ((OPdest_q2[15:0]==cmpSG_ADDRS[15:0])  && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && X_GT_Y);
assign cmpQG  = ((OPdest_q2[15:0]==cmpQG_ADDRS[15:0])  && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && X_GT_Y);
assign cmpSGE = ((OPdest_q2[15:0]==cmpSGE_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && (X_GT_Y || X_EQ_Y));
assign cmpQGE = ((OPdest_q2[15:0]==cmpQGE_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && (X_GT_Y || X_EQ_Y));
assign cmpSL  = ((OPdest_q2[15:0]==cmpSL_ADDRS[15:0])  && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && X_LT_Y);
assign cmpQL  = ((OPdest_q2[15:0]==cmpQL_ADDRS[15:0])  && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && X_LT_Y);
assign cmpSLE = ((OPdest_q2[15:0]==cmpSLE_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && (X_LT_Y || X_EQ_Y));
assign cmpQLE = ((OPdest_q2[15:0]==cmpQLE_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && (X_LT_Y || X_EQ_Y));
assign cmpSNG = ((OPdest_q2[15:0]==cmpSNG_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && ~X_GT_Y);
assign cmpQNG = ((OPdest_q2[15:0]==cmpQNG_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && ~X_GT_Y);
assign cmpSLU = ((OPdest_q2[15:0]==cmpSLU_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && (X_LT_Y || UNORDERED));
assign cmpQLU = ((OPdest_q2[15:0]==cmpQLU_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && (X_LT_Y || UNORDERED));
assign cmpSNL = ((OPdest_q2[15:0]==cmpSNL_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && ~X_LT_Y);
assign cmpQNL = ((OPdest_q2[15:0]==cmpQNL_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && ~X_LT_Y);
assign cmpSGU = ((OPdest_q2[15:0]==cmpSGU_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && (X_GT_Y || UNORDERED));
assign cmpQGU = ((OPdest_q2[15:0]==cmpQGU_ADDRS[15:0]) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && (X_GT_Y || UNORDERED));
assign cmpQU  = ((OPdest_q2[15:0]==cmpQU_ADDRS[15:0])  && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && UNORDERED);
assign cmpQO  = ((OPdest_q2[15:0]==cmpQO_ADDRS[15:0])  && ~Ind_Dest_q2 && wrcycl && thread_q2_sel && ~UNORDERED);

assign _compareTrue = cmpSE  || 
                      cmpQE  || 
                      cmpSNE || 
                      cmpQNE || 
                      cmpSG  || 
                      cmpQG  || 
                      cmpSGE || 
                      cmpQGE || 
                      cmpSL  || 
                      cmpQL  || 
                      cmpSLE || 
                      cmpQLE || 
                      cmpSNG || 
                      cmpQNG || 
                      cmpSLU || 
                      cmpQLU || 
                      cmpSNL || 
                      cmpQNL || 
                      cmpSGU || 
                      cmpQGU || 
                      cmpQU  || 
                      cmpQO  ;


 always @(*)
    casex(OPdest_q2)
      cmpSE_ADDRS  ,
      cmpQE_ADDRS  ,
      cmpSNE_ADDRS ,
      cmpQNE_ADDRS ,
      cmpSG_ADDRS  ,
      cmpQG_ADDRS  ,
      cmpSGE_ADDRS ,
      cmpQGE_ADDRS ,
      cmpSL_ADDRS  ,
      cmpQL_ADDRS  ,
      cmpSLE_ADDRS ,
      cmpQLE_ADDRS ,
      cmpSNG_ADDRS ,
      cmpQNG_ADDRS ,
      cmpSLU_ADDRS ,
      cmpQLU_ADDRS ,
      cmpSNL_ADDRS ,
      cmpQNL_ADDRS ,
      cmpSGU_ADDRS ,
      cmpQGU_ADDRS ,
      cmpQU_ADDRS  ,
      cmpQO_ADDRS  : cmprEnable = 1'b1;
           default : cmprEnable = 1'b0;
    endcase 
                      
assign cmprInvalid =    (cmprEnable && (X_Signaling || Y_Signaling)) ||
                        ((X_NaN || Y_NaN) && 
                         (cmpSE          ||
                          cmpSNE         ||
                          cmpSG          ||
                          cmpSGE         ||
                          cmpSL          ||
                          cmpSLE         ||
                          cmpSNG         ||
                          cmpSLU         ||
                          cmpSNL         ||
                          cmpSGU)) ;
                         
assign X_signalingNaN      = (Xe==11'b111_1111_1111) && ~X_fraction[51] &&  |X_fraction[50:0];
assign X_quietNaN          = (Xe==11'b111_1111_1111) &&  X_fraction[51] &&  |X_fraction[50:0];
assign X_negativeInfinity  =  X_sign && (Xe==11'b111_1111_1111) && ~|X_fraction;
assign X_negativeNormal    =  X_sign &&  (Xe > 11'h000) && (Xe < 11'h7FF);
assign X_negativeSubnormal =  X_sign && (Xe==11'b0) && |X_fraction;
assign X_negativeZero      = ~X_sign && ~|Xe && ~|X_fraction;
assign X_positiveZero      =  X_sign && ~|Xe && ~|X_fraction;
assign X_positiveSubnormal = ~X_sign && (Xe==11'b0) && |X_fraction;
assign X_positiveNormal    = ~X_sign &&  (Xe > 11'h000) && (Xe < 11'h7FF);
assign X_positiveInfinity  = ~X_sign && (Xe==11'b111_1111_1111) && ~|X_fraction;

assign X_SignMinus    =  X_sign;   
assign X_Normal       =  (Xe > 11'h000) && (Xe < 11'h7FF);   
assign X_Finite       =  X_Normal || X_Subnormal || X_Zero;    
assign X_Zero         = ~|Xe && ~|X_fraction;    
assign X_Subnormal    = (Xe==11'b0) && |X_fraction;    
assign X_Infinite     = (Xe==11'b111_1111_1111) && ~|X_fraction;    
assign X_NaN          = (Xe==11'b111_1111_1111) &&  |X_fraction[50:0];     
assign X_Signaling    = (Xe==11'b111_1111_1111) && ~X_fraction[51] &&  |X_fraction[50:0];    
assign X_Canonical    = X_Finite || X_Infinite || X_NaN; 
       
assign Y_SignMinus   =  Y_sign;   
assign Y_Normal      =  (Ye > 11'h000) && (Ye < 11'h7FF);   
assign Y_Finite      =  Y_Normal || Y_Subnormal || Y_Zero;    
assign Y_Zero        = ~|Ye && ~|Y_fraction;    
assign Y_Subnormal   = (Ye==11'b0) && |Y_fraction;    
assign Y_Infinite    = (Ye==11'b111_1111_1111) && ~|Y_fraction;    
assign Y_NaN         = (Ye==11'b111_1111_1111) &&  |Y_fraction[50:0];     
assign Y_Signaling   = (Ye==11'b111_1111_1111) && ~Y_fraction[51] &&  |Y_fraction[50:0];    
assign Y_Canonical   = Y_Finite || Y_Infinite || Y_NaN; 

assign _totlOrder    = ({~X[63], X[62:0]} <= {~Y[63], Y[62:0]}) && Y_Canonical && X_Canonical;
                       
assign _totlOrderMag = (X[62:0] <= Y[62:0]) && Y_Canonical && X_Canonical;

assign Status_wren = ((OPdest_q2[15:0]==ST_ADDRS[15:0]) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b11) && wrcycl && thread_q2_sel);

assign _aFlagRaised = (inexact_flag && wrsrcAdata[4]) || (underflow_flag && wrsrcAdata[3]) || (overflow_flag && wrsrcAdata[2]) || (divby0_flag && wrsrcAdata[1]) || (invalid_flag && wrsrcAdata[0]);

//a saved flag is raised test
assign _aSFlagRaised = (wrsrcBdata[4] && wrsrcAdata[4]) || (wrsrcBdata[3] && wrsrcAdata[3]) || (wrsrcBdata[2] && wrsrcAdata[2]) || (wrsrcBdata[1] && wrsrcAdata[1]) || (wrsrcBdata[0] && wrsrcAdata[0]);

assign class_sel = {X_signalingNaN,     
                    X_quietNaN,         
                    X_negativeInfinity, 
                    X_negativeNormal,   
                    X_negativeSubnormal,
                    X_negativeZero,     
                    X_positiveZero,     
                    X_positiveSubnormal,
                    X_positiveNormal,   
                    X_positiveInfinity};
                    


assign  STATUS = {RM_ATR_EN             , //bit 63
                  AWAY                  , //bit 62
                  RM1                   , //bit 61
                  RM0                   , //bit 60
        
                  subsInexact           , //bit 59
                  subsUnderflow         , //bit 58
                  subsOverflow          , //bit 57
                  subsDivByZero         , //bit 56
                  subsInvalid           , //bit 55
        
                  compareTrue           , //bit 54
                  aFlagRaised           , //bit 53
        
                  // total Order   
                  totlOrderMag          , //bit 52
                  totlOrder             , //bit 51
        
                   // is          
                  Canonical             , //bit 50
                  Signaling             , //bit 49
                  NaN                   , //bit 48
                  Infinite              , //bit 47
                  Subnormal             , //bit 46
                  Zero                  , //bit 45
                  Finite                , //bit 44
                  Normal                , //bit 43
                  SignMinus             , //bit 42
        
                   // class        
                  positiveInfinity      , //bit 41
                  positiveNormal        , //bit 40
                  positiveSubnormal     , //bit 39
                  positiveZero          , //bit 38
                  negativeZero          , //bit 37
                  negativeSubnormal     , //bit 36
                  negativeNormal        , //bit 35
                  negativeInfinity      , //bit 34
                  quietNaN              , //bit 33
                  signalingNaN          , //bit 32
                  
                  1'b1                  , //bit 31 always  (for btbs "branch always"
                  1'b0                  , //bit 30 never   (for btbs "branch never"
                  (V || Z)              , //bit 29  LTE (less than or equal)
                  (V && ~Z)             , //bit 28  LT  (less than)
                  
                  IRQ                   , //bit 27  interrupt request (read-only)
                  IRQ_IE                , //bit 26  interrupt enable
                                   
                  inexact_signal        , //bit 25
                  underflow_signal      , //bit 24
                  overflow_signal       , //bit 23
                  divby0_signal         , //bit 22
                  invalid_signal        , //bit 21
        
                  razNoInexactFlag      , //bit 20  
                  razNoUnderflowFlag    , //bit 19
                  razNoOverflowFlag     , //bit 18
                  razNoDivByZeroFlag    , //bit 17
                  razNoInvalidFlag      , //bit 16

                  enAltImmInexactHandl  , //bit 15
                  enAltImmUnderflowHandl, //bit 14
                  enAltImmOverflowHandl , //bit 13
                  enAltImmDivByZeroHandl, //bit 12
                  enAltImmInvalidHandl  , //bit 11
        
                  inexact_flag          , //bit 10
                  underflow_flag        , //bit 9
                  overflow_flag         , //bit 8
                  divby0_flag           , //bit 7
                  invalid_flag          , //bit 6
                                                 
                  ExcSource_q2          , //bit 5          
        
                  done                  , //bit 4
                  V                     , //bit 3
                  N                     , //bit 2
                  C                     , //bit 1
                  Z                       //bit 0
                  }; 
                             

assign X_Invalid   = X_NaN && (exc_codeA==_invalid_) && fp_ready_q2;
assign X_DivX0     = X_Infinite && (exc_codeA==_div_x_0_) && fp_ready_q2;
assign X_Overflow  = X_Infinite && (exc_codeA==_overflow_) && fp_ready_q2;
assign X_Underflow = X_Subnormal && (((exc_codeA==_underFlowExact_) && enAltImmUnderflowHandl) || (exc_codeA==_underFlowInexact_)) && fp_ready_q2;
assign X_inexact   = ((exc_codeA==_inexact_) || X_Overflow || (exc_codeA==_underFlowInexact_)) && fp_ready_q2; //under default exc handling, Underflow is not signaled unless it is also inexact
                                                   
assign Y_Invalid   = Y_NaN && (exc_codeB==_invalid_) && fp_ready_q2;
assign Y_DivX0     = Y_Infinite && (exc_codeB==_div_x_0_) && fp_ready_q2;
assign Y_Overflow  = Y_Infinite && (exc_codeB==_overflow_) && fp_ready_q2;
assign Y_Underflow = Y_Subnormal && (((exc_codeB==_underFlowExact_) && enAltImmUnderflowHandl) || (exc_codeB==_underFlowInexact_)) && fp_ready_q2;
assign Y_inexact   = ((exc_codeB==_inexact_) || Y_Overflow || (exc_codeB==_underFlowInexact_)) && fp_ready_q2; //under default exc handling, Underflow is not signaled unless it is also inexact

assign exc_sel = {X_Invalid, X_DivX0, X_Overflow, X_Underflow, X_inexact, Y_Invalid, Y_DivX0, Y_Overflow, Y_Underflow, Y_inexact}; 

always @(*)
    casex(exc_sel)
        10'b1xxxx_xxxxx : begin
                              invalid_q2   =  1'b1;
                              divby0_q2    =  1'b0;
                              overflow_q2  =  1'b0;
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b0;
                              ExcSource_q2 =  1'b0;
                          end   
        10'b01xxx_xxxxx : begin
                              invalid_q2   =  1'b0;
                              divby0_q2    =  1'b1;
                              overflow_q2  =  1'b0;
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b0;
                              ExcSource_q2 =  1'b0;
                          end   
        10'b001xx_xxxxx : begin
                              invalid_q2   =  1'b0;
                              divby0_q2    =  1'b0;
                              overflow_q2  =  1'b1;
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b1;
                              ExcSource_q2 =  1'b0;
                          end   
        10'b0001x_xxxxx : begin
                              invalid_q2   =  1'b0;
                              divby0_q2    =  1'b0;
                              overflow_q2  =  1'b0;
                              underflow_q2 =  1'b1;
                              inexact_q2   =  X_inexact;
                              ExcSource_q2 =  1'b0;
                          end   
        10'b00001_xxxxx : begin
                              invalid_q2   =  1'b0;
                              divby0_q2    =  1'b0;
                              overflow_q2  =  1'b0;
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b1;
                              ExcSource_q2 =  1'b0;
                          end   
                              
                              
        10'b00000_1xxxx : begin                                                
                              invalid_q2   =  1'b1;                            
                              divby0_q2    =  1'b0;                            
                              overflow_q2  =  1'b0;                            
                              underflow_q2 =  1'b0;                            
                              inexact_q2   =  1'b0;                            
                              ExcSource_q2 =  1'b1;                            
                          end                                                 
        10'b00000_01xxx : begin                                                
                              invalid_q2   =  1'b0;                            
                              divby0_q2    =  1'b1;                            
                              overflow_q2  =  1'b0;                            
                              underflow_q2 =  1'b0;                            
                              inexact_q2   =  1'b0;                            
                              ExcSource_q2 =  1'b1;                            
                          end                                                 
        10'b00000_001xx : begin                                                
                              invalid_q2   =  1'b0;                            
                              divby0_q2    =  1'b0;                            
                              overflow_q2  =  1'b1;                            
                              underflow_q2 =  1'b0;                            
                              inexact_q2   =  1'b1;                            
                              ExcSource_q2 =  1'b1;                            
                          end                                                 
        10'b00000_0001x : begin                                                
                              invalid_q2   =  1'b0;                            
                              divby0_q2    =  1'b0;                            
                              overflow_q2  =  1'b0;                            
                              underflow_q2 =  1'b1;                            
                              inexact_q2   =  Y_inexact;                            
                              ExcSource_q2 =  1'b1;                            
                           end                                                 
        10'b00000_00001 : begin                                                
                              invalid_q2   =  1'b0;                            
                              divby0_q2    =  1'b0;                                  
                              overflow_q2  =  1'b0;                                  
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b1;
                              ExcSource_q2 =  1'b1;
                          end
                default : begin
                              invalid_q2   =  1'b0;                            
                              divby0_q2    =  1'b0;                                  
                              overflow_q2  =  1'b0;                                  
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b0;
                              ExcSource_q2 =  1'b0;
                          end         
    endcase

                              
always @(*)
    casex(OPdest_q2)
        cmpSE_ADDRS  ,   
        cmpQE_ADDRS  ,
        cmpSNE_ADDRS ,
        cmpQNE_ADDRS ,
        cmpSG_ADDRS  ,
        cmpQG_ADDRS  ,
        cmpSGE_ADDRS ,
        cmpQGE_ADDRS ,
        cmpSL_ADDRS  ,
        cmpQL_ADDRS  ,
        cmpSLE_ADDRS ,
        cmpQLE_ADDRS ,
        cmpSNG_ADDRS ,
        cmpQNG_ADDRS ,
        cmpSLU_ADDRS ,
        cmpQLU_ADDRS ,
        cmpSNL_ADDRS ,
        cmpQNL_ADDRS ,
        cmpSGU_ADDRS ,
        cmpQGU_ADDRS ,
        cmpQU_ADDRS  ,
        cmpQO_ADDRS  : cmprEnable = 1'b1;
    default : cmprEnable = 1'b0;               
    endcase

always @(posedge CLK or posedge RESET)
    if (RESET) class <= 4'b0;
    else if ((OPdest_q2[15:0]==clas_ADDRS) && ~Ind_Dest_q2 && wrcycl && thread_q2_sel)
        casex(class_sel)
            10'b1xxxxxxxxx : class <= 4'h1;
            10'b01xxxxxxxx : class <= 4'h2;
            10'b001xxxxxxx : class <= 4'h3;
            10'b0001xxxxxx : class <= 4'h4;
            10'b00001xxxxx : class <= 4'h5;
            10'b000001xxxx : class <= 4'h6;
            10'b0000001xxx : class <= 4'h7;
            10'b00000001xx : class <= 4'h8;
            10'b000000001x : class <= 4'h9;
            10'b0000000001 : class <= 4'hA;
                   default : class <= 4'h0;   //4'hB = undefined
        endcase    
    

always @(*)
    if (Size_SrcA_q2==DP) {X_sign, Xe, X_fraction} =  wrsrcAdata[63:0];  // convert to DP
    else if (Size_SrcA_q2==SP) begin   
        X_sign     = wrsrcAdata[31];
        Xe[10:0]   = &wrsrcAdata[30:23] ? {3'b111, wrsrcAdata[30:23]} : (wrsrcAdata[30:23] + 10'h380);
        X_fraction = {wrsrcAdata[22:0], 32'b0};
    end    
    else begin   
        X_sign     = wrsrcAdata[15];
        Xe[10:0]   = &wrsrcAdata[14:10] ? {6'b111111, wrsrcAdata[14:10]} : (wrsrcAdata[14:10] + 10'h3F0);
        X_fraction = {wrsrcAdata[9:0], 48'b0};
    end    

always @(*)
    if (Size_SrcB_q2==DP) {Y_sign, Ye, Y_fraction} =  wrsrcBdata[63:0];  // convert to DP
    else if (Size_SrcB_q2==SP) begin   
        Y_sign     = wrsrcBdata[31];
        Ye[10:0]   = &wrsrcBdata[30:23] ? {3'b111, wrsrcBdata[30:23]} : (wrsrcBdata[30:23] + 10'h380);
        Y_fraction = {wrsrcBdata[22:0], 32'b0};
    end    
    else begin  
        Y_sign     = wrsrcBdata[15];
        Ye[10:0]   = &wrsrcBdata[14:10] ? {6'b111111, wrsrcBdata[14:10]} : (wrsrcBdata[14:10] + 10'h3F0);
        Y_fraction = {wrsrcBdata[9:0], 48'b0};
    end    


always@(posedge CLK or posedge RESET) begin
    if (RESET) begin
        RM_ATR_EN         <= 1'b0;         //bit 63
        AWAY              <= 1'b0;         //bit 62
        RM1               <= 1'b0;         //bit 61
        RM0               <= 1'b0;         //bit 60
        
        subsInexact       <= 1'b0;         //bit 59
        subsUnderflow     <= 1'b0;         //bit 58
        subsOverflow      <= 1'b0;         //bit 57
        subsDivByZero     <= 1'b0;         //bit 56
        subsInvalid       <= 1'b0;         //bit 55
        
        compareTrue       <= 1'b0;         //bit 54
        aFlagRaised       <= 1'b0;         //bit 53
        
        // total Order            
        totlOrderMag      <= 1'b0;         //bit 52
        totlOrder         <= 1'b0;         //bit 51
        
         // is          
        Canonical         <= 1'b0;         //bit 50
        Signaling         <= 1'b0;         //bit 49
        NaN               <= 1'b0;         //bit 48
        Infinite          <= 1'b0;         //bit 47
        Subnormal         <= 1'b0;         //bit 46
        Zero              <= 1'b0;         //bit 45
        Finite            <= 1'b0;         //bit 44
        Normal            <= 1'b0;         //bit 43
        SignMinus         <= 1'b0;         //bit 42
        
         // class         <= 1'b0;
        positiveInfinity  <= 1'b0;         //bit 41
        positiveNormal    <= 1'b0;         //bit 40
        positiveSubnormal <= 1'b0;         //bit 39
        positiveZero      <= 1'b0;         //bit 38
        negativeZero      <= 1'b0;         //bit 37
        negativeSubnormal <= 1'b0;         //bit 36
        negativeNormal    <= 1'b0;         //bit 35
        negativeInfinity  <= 1'b0;         //bit 34
        quietNaN          <= 1'b0;         //bit 33
        signalingNaN      <= 1'b0;         //bit 32
        
        IRQ_IE            <= 1'b0;         //bit 26
                           
        inexact_signal    <= 1'b0;         //bit 25
        underflow_signal  <= 1'b0;         //bit 24
        overflow_signal   <= 1'b0;         //bit 23
        divby0_signal     <= 1'b0;         //bit 22
        invalid_signal    <= 1'b0;         //bit 21
        
        razNoInexactFlag   <= 1'b1;        //bit 20  
        razNoUnderflowFlag <= 1'b0;        //bit 19
        razNoOverflowFlag  <= 1'b0;        //bit 18
        razNoDivByZeroFlag <= 1'b0;        //bit 17
        razNoInvalidFlag   <= 1'b0;        //bit 16

        enAltImmInexactHandl   <= 1'b0;    //bit 15
        enAltImmUnderflowHandl <= 1'b0;    //bit 14
        enAltImmOverflowHandl  <= 1'b0;    //bit 13
        enAltImmDivByZeroHandl <= 1'b0;    //bit 12
        enAltImmInvalidHandl   <= 1'b0;    //bit 11
        
        inexact_flag    <= 1'b0;           //bit 10
        underflow_flag  <= 1'b0;           //bit 9
        overflow_flag   <= 1'b0;           //bit 8
        
        divby0_flag     <= 1'b0;           //bit 7
        invalid_flag    <= 1'b0;           //bit 6
                                                 
        
        done   <= 1'b1;                    //bit 4
        V      <= 1'b0;                    //bit 3
        N      <= 1'b0;                    //bit 2
        C      <= 1'b0;                    //bit 1
        Z      <= 1'b1;                    //bit 0
        operand_q2   <= 1'b0;                                    
                                                                 
        rd_float_q2_sel  <= 1'b0;                                
        rd_integr_q2_sel <= 1'b0;                                             
    end                                                             
    else begin                                                        

       rd_float_q2_sel  <= rd_float_q1_selA || rd_float_q1_selB;
       rd_integr_q2_sel <= rd_integr_q1_selA;

//these five bits can be used as general-purpose status bits if not used as substitution attribute bits, since such function is optional according to the spec
       if (Status_wren) {subsInexact, subsUnderflow, subsOverflow, subsDivByZero, subsInvalid} <=  wrsrcAdata[59:55];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==setSubstt_ADDRS) && (Size_Dest_q2==2'b01) && ~Ind_Dest_q2)
          {subsInexact, 
           subsUnderflow,   //  |-- write enable
           subsOverflow,    //  |                 |-- data to write (if enabled)
           subsDivByZero,   //  v                 v
           subsInvalid} <= {(wrsrcAdata[9] ? wrsrcAdata[8] : subsInexact),
                            (wrsrcAdata[7] ? wrsrcAdata[6] : subsUnderflow),
                            (wrsrcAdata[5] ? wrsrcAdata[4] : subsOverflow),
                            (wrsrcAdata[3] ? wrsrcAdata[2] : subsDivByZero),
                            (wrsrcAdata[1] ? wrsrcAdata[0] : subsInvalid)};
//these five bits are the "flags"              
       if (Status_wren) invalid_flag <= wrsrcAdata[6];                                 
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==lowFlg_ADDRS) && ~Ind_Dest_q2) invalid_flag <= wrsrcAdata[0] ? 1'b0 : invalid_flag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasFlg_ADDRS) && ~Ind_Dest_q2) invalid_flag <= wrsrcAdata[0] ? 1'b1 : invalid_flag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rstFlg_ADDRS) && ~Ind_Dest_q2) invalid_flag <= wrsrcAdata[0];                                                                  
       else if ((invalid_q2 && ~enAltImmInvalidHandl && ~razNoInvalidFlag && rd_float_q2_sel && thread_q2_sel) || (cmprInvalid && ~enAltImmInvalidHandl && ~razNoInvalidFlag)) invalid_flag <= 1'b1; 

       if (Status_wren) divby0_flag <= wrsrcAdata[7];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==lowFlg_ADDRS) && ~Ind_Dest_q2) divby0_flag <= wrsrcAdata[1] ? 1'b0 : divby0_flag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasFlg_ADDRS) && ~Ind_Dest_q2) divby0_flag <= wrsrcAdata[1] ? 1'b1 : divby0_flag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rstFlg_ADDRS) && ~Ind_Dest_q2) divby0_flag <= wrsrcAdata[1];                                                                  
       else if (divby0_q2 && ~enAltImmDivByZeroHandl && ~razNoDivByZeroFlag && rd_float_q2_sel && thread_q2_sel) divby0_flag <= 1'b1;

       if (Status_wren) overflow_flag <= wrsrcAdata[8];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==lowFlg_ADDRS) && ~Ind_Dest_q2) overflow_flag <= wrsrcAdata[2] ? 1'b0 : overflow_flag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasFlg_ADDRS) && ~Ind_Dest_q2) overflow_flag <= wrsrcAdata[2] ? 1'b1 : overflow_flag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rstFlg_ADDRS) && ~Ind_Dest_q2) overflow_flag <= wrsrcAdata[2];                                                                  
       else if (overflow_q2 && ~enAltImmOverflowHandl && ~razNoOverflowFlag && rd_float_q2_sel && thread_q2_sel) overflow_flag <= 1'b1;

       if (Status_wren) underflow_flag <= wrsrcAdata[9];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==lowFlg_ADDRS) && ~Ind_Dest_q2) underflow_flag <= wrsrcAdata[3] ? 1'b0 : underflow_flag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasFlg_ADDRS) && ~Ind_Dest_q2) underflow_flag <= wrsrcAdata[3] ? 1'b1 : underflow_flag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rstFlg_ADDRS) && ~Ind_Dest_q2) underflow_flag <= wrsrcAdata[3];                                                                  
       else if (underflow_q2 && ~enAltImmUnderflowHandl && ~razNoUnderflowFlag && rd_float_q2_sel && thread_q2_sel) underflow_flag <= 1'b1;

       if (Status_wren) inexact_flag <= wrsrcAdata[10];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==lowFlg_ADDRS) && ~Ind_Dest_q2) inexact_flag <= wrsrcAdata[4] ? 1'b0 : inexact_flag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasFlg_ADDRS) && ~Ind_Dest_q2) inexact_flag <= wrsrcAdata[4] ? 1'b1 : inexact_flag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rstFlg_ADDRS) && ~Ind_Dest_q2) inexact_flag <= wrsrcAdata[4];                                                                  
       else if (inexact_q2 && ~enAltImmInexactHandl && ~razNoInexactFlag && rd_float_q2_sel && thread_q2_sel) inexact_flag <= 1'b1;   //note: ~razNoInexactFlag is set to "1" on reset, which is default setting for this flag
       
//these next five bits are "signals"
       if (Status_wren) invalid_signal <= wrsrcAdata[21];                                 
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==lowSig_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) invalid_signal <= wrsrcAdata[0] ? 1'b0 : invalid_signal;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasSig_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) invalid_signal <= wrsrcAdata[0] ? 1'b1 : invalid_signal;                                                                  
       else if (((invalid_q2 && rd_float_q2_sel && thread_q2_sel) || cmprInvalid) && (enAltImmInvalidHandl || razNoInvalidFlag)) invalid_signal <= 1'b1; 

       if ( Status_wren) divby0_signal <= wrsrcAdata[22];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==lowSig_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) divby0_signal <= wrsrcAdata[1] ? 1'b0 : divby0_signal;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasSig_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) divby0_signal <= wrsrcAdata[1] ? 1'b1 : divby0_signal;                                                                  
       else if (divby0_q2 && rd_float_q2_sel && thread_q2_sel && (enAltImmDivByZeroHandl || razNoDivByZeroFlag)) divby0_signal <= 1'b1;

       if (Status_wren) overflow_signal <= wrsrcAdata[23];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==lowSig_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) overflow_signal <= wrsrcAdata[2] ? 1'b0 : overflow_signal;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasSig_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) overflow_signal <= wrsrcAdata[2] ? 1'b1 : overflow_signal;                                                                  
       else if (overflow_q2 && rd_float_q2_sel && thread_q2_sel && (enAltImmOverflowHandl || razNoOverflowFlag)) overflow_signal <= 1'b1;

       if (Status_wren) underflow_signal <= wrsrcAdata[24];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==lowSig_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) underflow_signal <= wrsrcAdata[3] ? 1'b0 : underflow_signal;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasSig_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) underflow_signal <= wrsrcAdata[3] ? 1'b1 : underflow_signal;                                                                  
       else if (underflow_q2 && rd_float_q2_sel && thread_q2_sel && (enAltImmUnderflowHandl || razNoUnderflowFlag)) underflow_signal <= 1'b1;

       if (Status_wren) inexact_signal <= wrsrcAdata[25];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==lowSig_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) inexact_signal <= wrsrcAdata[4] ? 1'b0 : inexact_signal;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasSig_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) inexact_signal <= wrsrcAdata[4] ? 1'b1 : inexact_signal;                                                                  
       else if (inexact_q2 && rd_float_q2_sel && thread_q2_sel && (enAltImmInexactHandl || razNoInexactFlag)) inexact_signal <= 1'b1;


//alternate Immediate Handler enables    size==01 to clear and size==10 to set
       if (Status_wren) enAltImmInexactHandl <= wrsrcAdata[15];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==enAltImm_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) enAltImmInexactHandl <= wrsrcAdata[4] ? 1'b0 : enAltImmInexactHandl;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==enAltImm_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) enAltImmInexactHandl <= wrsrcAdata[4] ? 1'b1 : enAltImmInexactHandl;                                                                  
 
       if (Status_wren) enAltImmUnderflowHandl <= wrsrcAdata[14];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==enAltImm_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) enAltImmUnderflowHandl <= wrsrcAdata[3] ? 1'b0 : enAltImmUnderflowHandl;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==enAltImm_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) enAltImmUnderflowHandl <= wrsrcAdata[3] ? 1'b1 : enAltImmUnderflowHandl;                                                                  
 
       if (Status_wren) enAltImmOverflowHandl <= wrsrcAdata[13];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==enAltImm_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) enAltImmOverflowHandl <= wrsrcAdata[2] ? 1'b0 : enAltImmOverflowHandl;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==enAltImm_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) enAltImmOverflowHandl <= wrsrcAdata[2] ? 1'b1 : enAltImmOverflowHandl;                                                                  
 
       if (Status_wren) enAltImmDivByZeroHandl <= wrsrcAdata[12];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==enAltImm_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) enAltImmDivByZeroHandl <= wrsrcAdata[1] ? 1'b0 : enAltImmDivByZeroHandl;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==enAltImm_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) enAltImmDivByZeroHandl <= wrsrcAdata[1] ? 1'b1 : enAltImmDivByZeroHandl;                                                                  
 
       if (Status_wren) enAltImmInvalidHandl <= wrsrcAdata[11];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==enAltImm_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) enAltImmInvalidHandl <= wrsrcAdata[0] ? 1'b0 : enAltImmInvalidHandl;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==enAltImm_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) enAltImmInvalidHandl <= wrsrcAdata[0] ? 1'b1 : enAltImmInvalidHandl;                                                                  

//Raise No Flag
       if (Status_wren) razNoInexactFlag <= wrsrcAdata[20];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasNoFlag_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) razNoInexactFlag <= wrsrcAdata[4] ? 1'b0 : razNoInexactFlag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasNoFlag_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) razNoInexactFlag <= wrsrcAdata[4] ? 1'b1 : razNoInexactFlag;                                                                  
 
       if (Status_wren) razNoUnderflowFlag <= wrsrcAdata[19];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasNoFlag_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) razNoUnderflowFlag <= wrsrcAdata[3] ? 1'b0 : razNoUnderflowFlag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasNoFlag_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) razNoUnderflowFlag <= wrsrcAdata[3] ? 1'b1 : razNoUnderflowFlag;                                                                  

       if (Status_wren) razNoOverflowFlag <= wrsrcAdata[18];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasNoFlag_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) razNoOverflowFlag <= wrsrcAdata[2] ? 1'b0 : razNoOverflowFlag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasNoFlag_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) razNoOverflowFlag <= wrsrcAdata[2] ? 1'b1 : razNoOverflowFlag;                                                                  

       if (Status_wren) razNoDivByZeroFlag <= wrsrcAdata[17];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasNoFlag_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) razNoDivByZeroFlag <= wrsrcAdata[1] ? 1'b0 : razNoDivByZeroFlag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasNoFlag_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) razNoDivByZeroFlag <= wrsrcAdata[1] ? 1'b1 : razNoDivByZeroFlag;                                                                  

       if (Status_wren) razNoInvalidFlag <= wrsrcAdata[16];
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasNoFlag_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b01)) razNoInvalidFlag <= wrsrcAdata[0] ? 1'b0 : razNoInvalidFlag;                                                                  
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==rasNoFlag_ADDRS) && ~Ind_Dest_q2 && (Size_Dest_q2==2'b10)) razNoInvalidFlag <= wrsrcAdata[0] ? 1'b1 : razNoInvalidFlag;                                                                  

//"is(es)" 
       if (Status_wren) begin
               Canonical <= wrsrcAdata[50];                                                                               
               Signaling <= wrsrcAdata[49];      
               NaN       <= wrsrcAdata[48];      
               Infinite  <= wrsrcAdata[47];      
               Subnormal <= wrsrcAdata[46];      
               Zero      <= wrsrcAdata[45];      
               Finite    <= wrsrcAdata[44];      
               Normal    <= wrsrcAdata[43];      
               SignMinus <= wrsrcAdata[42];      
       end
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==is_ADDRS) && ~Ind_Dest_q2) begin
               Canonical <=  wrsrcBdata[8] ? X_Canonical : Canonical ;        
               Signaling <=  wrsrcBdata[7] ? X_Signaling : Signaling ;        
               NaN       <=  wrsrcBdata[6] ? X_NaN       : NaN       ;        
               Infinite  <=  wrsrcBdata[5] ? X_Infinite  : Infinite  ;        
               Subnormal <=  wrsrcBdata[4] ? X_Subnormal : Subnormal ;        
               Zero      <=  wrsrcBdata[3] ? X_Zero      : Zero      ;        
               Finite    <=  wrsrcBdata[2] ? X_Finite    : Finite    ;        
               Normal    <=  wrsrcBdata[1] ? X_Normal    : Normal    ;        
               SignMinus <=  wrsrcBdata[0] ? X_SignMinus : SignMinus ;        
       end                   

//class
       if (Status_wren) begin
              positiveInfinity  <= wrsrcAdata[41];
              positiveNormal    <= wrsrcAdata[40];
              positiveSubnormal <= wrsrcAdata[39];
              positiveZero      <= wrsrcAdata[38];
              negativeZero      <= wrsrcAdata[37];
              negativeSubnormal <= wrsrcAdata[36];
              negativeNormal    <= wrsrcAdata[35];
              negativeInfinity  <= wrsrcAdata[34];                                           
              quietNaN          <= wrsrcAdata[33];
              signalingNaN      <= wrsrcAdata[32];       
       end               
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==clas_ADDRS) && ~Ind_Dest_q2) begin      
              positiveInfinity  <= X_positiveInfinity  ;
              positiveNormal    <= X_positiveNormal    ;
              positiveSubnormal <= X_positiveSubnormal ;
              positiveZero      <= X_positiveZero      ;
              negativeZero      <= X_negativeZero      ;
              negativeSubnormal <= X_negativeSubnormal ;
              negativeNormal    <= X_negativeNormal    ;
              negativeInfinity  <= X_negativeInfinity  ;                                           
              quietNaN          <= X_quietNaN          ;                 
              signalingNaN      <= X_signalingNaN      ;                                                          
       end

       if (Status_wren) totlOrder <= wrsrcAdata[51]; 
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==tOrd_ADDRS) && ~Ind_Dest_q2) totlOrder <= _totlOrder;
       
       if (Status_wren) totlOrderMag <= wrsrcAdata[52]; 
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==tOrdM_ADDRS) && ~Ind_Dest_q2) totlOrderMag <= _totlOrderMag;      
                                                        
       if (Status_wren) compareTrue <= wrsrcAdata[54]; 
       else if (wrcycl && thread_q2_sel && ~Ind_Dest_q2 && cmprEnable) compareTrue <= _compareTrue;  
       
       if (Status_wren) aFlagRaised <= wrsrcAdata[53];       
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==tstFlg_ADDRS) && ~Ind_Dest_q2) aFlagRaised <= _aFlagRaised;      
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==tstSFlg_ADDRS) && ~Ind_Dest_q2) aFlagRaised <= _aSFlagRaised;      

//this handles SetBinRndDir, DefaultModes, RestoreModes
       if (Status_wren) {RM_ATR_EN, AWAY, RM1, RM0} <= wrsrcAdata[63:60]; //ordinary writes to STATUS
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==setBinRnd_ADDRS) && (Size_Dest_q2==2'b01) && ~Ind_Dest_q2) {RM_ATR_EN, AWAY, RM1, RM0} <= wrsrcAdata[3:0]; //writes to just the RMode  bits
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==setBinRnd_ADDRS) && (Size_Dest_q2==2'b00) && ~Ind_Dest_q2) {RM_ATR_EN, AWAY, RM1, RM0} <= 4'b0;   //restore defaults   
              
//integer & logical status bits
       if (Status_wren) {IRQ_IE, done, V, N, C, Z} <=  {wrsrcAdata[26], wrsrcAdata[3:0]};
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==compare_ADDRS) && (Size_Dest_q2==2'b00) && ~Ind_Dest_q2) begin  //compare only affects Z and V flags
          Z <= (compareAdata==compareBdata);
          V <= (compareAdata < compareBdata);
       end
       else if (wrcycl && thread_q2_sel && (OPdest_q2[15:0]==setDVNCZ_ADDRS) && (Size_Dest_q2==2'b01) && ~Ind_Dest_q2)
          {IRQ_IE,
           done, 
           V,       //  |-- write enable
           N,       //  |                 |-- data to write (if enabled)
           C,       //  v                 v
           Z} <= {(wrsrcAdata[11] ? wrsrcAdata[8] : IRQ_IE),
                  (wrsrcAdata[9]  ? wrsrcAdata[8] : done),
                  (wrsrcAdata[7]  ? wrsrcAdata[6] : V),
                  (wrsrcAdata[5]  ? wrsrcAdata[4] : N),
                  (wrsrcAdata[3]  ? wrsrcAdata[2] : C),
                  (wrsrcAdata[1]  ? wrsrcAdata[0] : Z)};
       else if (wrcycl && thread_q2_sel && rd_integr_q2_sel) {V, N, C, Z} <= {V_q2, N_q2, C_q2, Z_q2};
              
    end  
 end  
    
  endmodule

