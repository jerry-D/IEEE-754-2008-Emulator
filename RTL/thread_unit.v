 // thread_unit.v
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
 

module thread_unit(
    CLK,           
    RESET,  
    newthreadq_sel,
    thread_q1_sel,
    thread_q2_sel,
    thread_q1,
    wrsrcAdata,
    wrsrcBdata,
    rdSrcAdataT,    
    rdSrcBdata,
    priv_RAM_rddataA,                      
    priv_RAM_rddataB,                      
    glob_RAM_rddataA,                      
    glob_RAM_rddataB,                      
    Table_data,
    ld_vector,     
    rewind_PC,
    wrcycl,        
    discont_out,    
    OPsrcA_q0,        
    OPsrcA_q2,
    OPsrcB_q0,        
    OPsrcB_q2,     
    OPdest_q0,      
    OPdest_q2, 
    RPT_not_z, 
    next_PC,       
    Dam_q0, 
    Dam_q1,        
    Dam_q2,      
    Ind_Dest_q2, 
    Ind_SrcA_q0,
    Ind_SrcA_q2,    
    Ind_SrcB_q0, 
    Imod_Dest_q0,   
    Imod_Dest_q2,
    Imod_SrcA_q0,   
    Imod_SrcB_q0,   
    Ind_SrcB_q2,
    Size_SrcA_q1,
    Size_SrcB_q1,    
    Size_SrcA_q2,
    Size_SrcB_q2,
    Size_Dest_q2,
    Sext_SrcA_q2,   
    Sext_SrcB_q2,
    Sext_Dest_q2,    
    OPsrc32_q0, 
    Ind_Dest_q0,
    Dest_addrs_q2,
    SrcA_addrs_q0,
    SrcB_addrs_q0,
    SrcA_addrs_q1,
    SrcB_addrs_q1,
    PC,            
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
    IRQ_IE,
    break_q0,
    rddataA_integer,             
    rddataB_integer,
    MON_SrcA_data, // data to be written by monitor R/W instruction
    mon_srcA_data_capture, //data captured by monitor R/W instruction
    C_reg,
    exc_codeA, 
    exc_codeB,
    float_rddataA, 
    float_rddataB,
    RM_q1,
    pc_q1,
    fp_ready_q1,
    fp_ready_q2,
    writeAbort,
    RM_Attribute_on,
    Away,           
    RM_Attribute,        
    int_in_service       
    );

input  CLK;           
input  RESET; 
input  newthreadq_sel;
input  thread_q1_sel; 
input  thread_q2_sel; 
input  [63:0] wrsrcAdata;      
input  [63:0] wrsrcBdata;      
output  ld_vector;     
input  rewind_PC;
input  wrcycl; 
output discont_out;
input  [15:0] OPsrcA_q0;        
input  [15:0] OPsrcA_q2;
input  [15:0] OPsrcB_q0;        
input  [15:0] OPsrcB_q2;     
input  [15:0] OPdest_q0;      
input  [15:0] OPdest_q2;   
output RPT_not_z; 
input  [15:0] next_PC;       
input  [1:0]  Dam_q0;
input  [1:0]  Dam_q1;         
input  [1:0]  Dam_q2;      
input  Ind_Dest_q2; 
input  Ind_SrcA_q0;    
input  Ind_SrcA_q2;
input  Ind_SrcB_q0; 
input  Imod_Dest_q0;   
input  Imod_Dest_q2;
input  Imod_SrcA_q0;   
input  Imod_SrcB_q0;   
input  Ind_SrcB_q2;
input [1:0] Size_SrcA_q1;
input [1:0] Size_SrcB_q1;
input [1:0] Size_SrcA_q2;
input [1:0] Size_SrcB_q2;
input [1:0] Size_Dest_q2;
input  Sext_SrcA_q2;
input  Sext_SrcB_q2;
input  Sext_Dest_q2;
input  [31:0] OPsrc32_q0; 
input  Ind_Dest_q0;   
output [17:0] Dest_addrs_q2;        
output [17:0] SrcA_addrs_q0;        
output [17:0] SrcB_addrs_q0; 
input  [17:0] SrcA_addrs_q1;
input  [17:0] SrcB_addrs_q1;
output [15:0] PC;                                                                                                         
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
output [63:0] rdSrcAdataT;
output [63:0] rdSrcBdata;
input  [63:0] priv_RAM_rddataA;
input  [63:0] priv_RAM_rddataB;
input  [63:0] glob_RAM_rddataA;
input  [63:0] glob_RAM_rddataB;
input  [63:0] Table_data;
input  break_q0;  
input  [63:0] rddataA_integer;                   
input  [63:0] rddataB_integer;
input  [63:0] MON_SrcA_data;         //from monitor/break/debug block 
output [63:0] mon_srcA_data_capture;
output [65:0] C_reg;
input  [1:0] exc_codeA;
input  [1:0] exc_codeB;
input [63:0] float_rddataA;
input [63:0] float_rddataB;
input [1:0] thread_q1;
input [1:0] RM_q1; 
input [15:0] pc_q1;
input fp_ready_q1;
input fp_ready_q2;
output writeAbort;
output RM_Attribute_on;
output Away;           
output [1:0] RM_Attribute;        
output int_in_service;

parameter           BTBS_ = 16'hFFA0;   // bit test and branch if set
parameter           BTBC_ = 16'hFF98;   // bit test and branch if clear
parameter           BRAL_ = 16'hFFF8;   // branch relative long
parameter           JMPA_ = 16'hFFA8;   // jump absolute long

parameter      BRAL_ADDRS = 18'h0FFF8;   // branch relative long
parameter      JMPA_ADDRS = 18'h0FFA8;   // jump absolute long
parameter      BTBS_ADDRS = 18'h0FFA0;   // bit test and branch if set
parameter      BTBC_ADDRS = 18'h0FF98;   // bit test and branch if clear

parameter  GLOB_RAM_ADDRS = 18'b01_0xxx_xxxx_xxxx_xxxx; //globabl RAM address (in bytes)
parameter        SP_ADDRS = 18'h0FFE8;
parameter       AR6_ADDRS = 18'h0FFE0;
parameter       AR5_ADDRS = 18'h0FFD8;
parameter       AR4_ADDRS = 18'h0FFD0;
parameter       AR3_ADDRS = 18'h0FFC8;
parameter       AR2_ADDRS = 18'h0FFC0;
parameter       AR1_ADDRS = 18'h0FFB8;
parameter       AR0_ADDRS = 18'h0FFB0;
parameter        PC_ADDRS = 18'h0FFA8;
parameter   PC_COPY_ADDRS = 18'h0FF90;
parameter        ST_ADDRS = 18'h0FF88;
parameter    REPEAT_ADDRS = 18'h0FF80;
parameter    LPCNT1_ADDRS = 18'h0FF78;
parameter    LPCNT0_ADDRS = 18'h0FF70;
parameter     TIMER_ADDRS = 18'h0FF68;
parameter      CREG_ADDRS = 18'h0FF60;
parameter     CAPT3_ADDRS = 18'h0FF58;
parameter     CAPT2_ADDRS = 18'h0FF50;
parameter     CAPT1_ADDRS = 18'h0FF48;
parameter     CAPT0_ADDRS = 18'h0FF40;
parameter     SCHED_ADDRS = 18'h0FF38;
parameter  SCHEDCMP_ADDRS = 18'h0FF30;
parameter     CLASS_ADDRS = 18'h0FF08;
parameter  SAVFLAGS_ADDRS = 18'h0FF00;
parameter    RNDDIR_ADDRS = 18'h0FE18;
parameter     RADIX_ADDRS = 18'h0FE10;
parameter  SAVMODES_ADDRS = 18'h0FE08;            //use direct addressing 
  
parameter       MON_ADDRS = 18'h0FE00;
parameter     FLOAT_ADDRS = 18'b00_1110_xxxx_xxxxxxxx;  //floating-point operator block
parameter    INTEGR_ADDRS = 18'b00_1101_xxxxxxxxxxxx;   // integer and logic operator block
parameter  PRIV_RAM_ADDRS = 18'b00_0xxx_xxxx_xxxx_xxxx; //first 32k bytes (since data memory is byte-addressable and smallest RAM for this in Kintex 7 is 2k x 64 bits using two blocks next to each other

parameter  NMI_VECTOR_ADDRS        =  16'hFEF8;
parameter  IRQ_VECTOR_ADDRS        =  16'hFEF0;
parameter  invalid_VECTOR_ADDRS    =  16'hFEE8;
parameter  divby0_VECTOR_ADDRS     =  16'hFEE0;
parameter  overflow_VECTOR_ADDRS   =  16'hFED8;
parameter  underflow_VECTOR_ADDRS  =  16'hFED0;
parameter  inexact_VECTOR_ADDRS    =  16'hFEC8;

parameter FTOI = 5'b1100_1;


reg [63:0] rdSrcAdata;
reg [63:0] rdSrcBdata;

reg [65:0] C_reg;
reg [19:0] timer;
reg [19:0] timercmpr;

reg [11:0] LPCNT1;
reg [11:0] LPCNT0;

reg [3:0] sModes;
reg [2:0] roundDirection;
reg [4:0] flags;

reg [15:0] NMI_VECTOR;      
reg [15:0] IRQ_VECTOR;      
reg [15:0] invalid_VECTOR;  
reg [15:0] divby0_VECTOR;   
reg [15:0] overflow_VECTOR; 
reg [15:0] underflow_VECTOR;
reg [15:0] inexact_VECTOR;  


reg [63:0] mon_srcA_data_capture;    //write-only and not qualified with wrcycl

wire [63:0] rdSrcAdataT;

wire [11:0] LPCNT1_dec;
wire [11:0] LPCNT0_dec;

wire LPCNT1_nz; 
wire LPCNT0_nz;

wire [10:0] REPEAT; 

wire [63:0] capt_dataA;
wire [63:0] capt_dataB;
wire RPT_not_z;
wire discont_out;

wire [15:0] PC;    
wire [15:0] PC_COPY;
wire        done;  
wire        IRQ_IE;  
wire [63:0] STATUS;
wire [15:0] vector;    

wire [17:0] SP;
wire [17:0] AR6;
wire [17:0] AR5;
wire [17:0] AR4;
wire [17:0] AR3;
wire [17:0] AR2;
wire [17:0] AR1;
wire [17:0] AR0;


wire NMI_ack;
wire EXC_ack;
wire IRQ_ack;
wire EXC_in_service;   
wire invalid_in_service;   
wire divby0_in_service;   
wire overflow_in_service;   
wire underflow_in_service;   
wire inexact_in_service;  

wire TrapInvalid_q1;
wire TrapDivX0_q1;
wire TrapOverflow_q1;
wire TrapUnderflow_q1;
wire TrapInexact_q1;

wire V;
wire N;
wire C;
wire Z;

wire [3:0] class;

wire [63:0] rddataA_integer;             
wire [63:0] rddataB_integer; 
wire ready_integer; 

wire writeAbort;

wire RM_Attribute_on;
wire Away;           
wire [1:0] RM_Attribute;

assign RM_Attribute_on = STATUS[63];
assign Away = STATUS[62];
assign RM_Attribute = STATUS[61:60];
 
assign LPCNT1_dec = LPCNT1 - 1'b1;
assign LPCNT0_dec = LPCNT0 - 1'b1;

assign LPCNT1_nz = |LPCNT1_dec;
assign LPCNT0_nz = |LPCNT0_dec;

assign rdSrcAdataT = (Dam_q1[1:0]==2'b10) ? Table_data : rdSrcAdata;

wire enAltImmInexactHandl  ;
wire enAltImmUnderflowHandl;
wire enAltImmOverflowHandl ;
wire enAltImmDivByZeroHandl;
wire enAltImmInvalidHandl  ; 

exc_capture exc_capt(     // quasi-trace buffer for capturing floating-point exceptions
    .CLK            (CLK        ),
    .RESET          (done   ),
    .srcA_q1        (SrcA_addrs_q1[17:0]    ),
    .srcB_q1        (SrcB_addrs_q1[17:0]    ),
    .addrsMode_q1   (Dam_q1[1:0]  ),
    .Size_SrcA_q1   (Size_SrcA_q1 ),
    .Size_SrcB_q1   (Size_SrcB_q1 ),
    .dest_q2        (Dest_addrs_q2[17:0] ),
    .pc_q1          (pc_q1      ),
    .rdSrcAdata     (float_rddataA[63:0]),
    .rdSrcBdata     (float_rddataB[63:0]),
    .exc_codeA      (exc_codeA  ),
    .exc_codeB      (exc_codeB  ),
    .rdenA          (~Dam_q0[1] && (SrcA_addrs_q0[17:5]==CAPT3_ADDRS[17:5])),
    .rdenB          (~Dam_q0[0] && (SrcB_addrs_q0[17:5]==CAPT3_ADDRS[17:5])),
    .round_mode_q1  (RM_q1           ),
    .status_RM      (STATUS[63:60]   ),
    .fp_ready_q1    (fp_ready_q1     ),
    .enAltImmInexactHandl  (enAltImmInexactHandl  ),
    .enAltImmUnderflowHandl(enAltImmUnderflowHandl),
    .enAltImmOverflowHandl (enAltImmOverflowHandl ),
    .enAltImmDivByZeroHandl(enAltImmDivByZeroHandl),
    .enAltImmInvalidHandl  (enAltImmInvalidHandl  ),
    .invalid_in_service  (invalid_in_service  ),
    .divby0_in_service   (divby0_in_service   ),
    .overflow_in_service (overflow_in_service ),
    .underflow_in_service(underflow_in_service),
    .inexact_in_service  (inexact_in_service  ),
    .TrapInexact_q1    (TrapInexact_q1   ),
    .TrapUnderflow_q1  (TrapUnderflow_q1 ),
    .TrapOverflow_q1   (TrapOverflow_q1  ),
    .TrapDivX0_q1      (TrapDivX0_q1     ),
    .TrapInvalid_q1    (TrapInvalid_q1   ),
    .capt_dataA     (capt_dataA      ),
    .capt_dataB     (capt_dataB      ),
    .writeAbort     (writeAbort      ),
    .thread_q1_sel  (thread_q1_sel   ),
    .thread_q1      (thread_q1       )
    );                                      

PROG_ADDRS prog_addrs (
    .CLK           (CLK         ),
    .RESET         (RESET       ),
    .newthreadq_sel(newthreadq_sel),
    .thread_q2_sel (thread_q2_sel ),
    .Ind_Dest_q2   (Ind_Dest_q2 ),
    .Ind_SrcB_q2   (Ind_SrcB_q2 ),
    .Size_SrcB_q2  (Size_SrcB_q2),
    .Sext_SrcB_q2  (Sext_SrcB_q2),
    .OPdest_q2     (OPdest_q2   ),
    .wrsrcAdata    (wrsrcAdata[63:0]),
    .ld_vector     (ld_vector   ),
    .vector        (vector      ),
    .rewind_PC     (rewind_PC   ),
    .wrcycl        (wrcycl      ),
    .discont_out   (discont_out ),
    .OPsrcB_q2     (OPsrcB_q2[15:0]),
    .RPT_not_z     (RPT_not_z   ),
    .next_PC       (next_PC     ),
    .PC            (PC          ),
    .PC_COPY       (PC_COPY     ),
    .break_q0      (break_q0    ),
    .int_in_service(int_in_service)
    );

DATA_ADDRS data_addrs(
    .CLK           (CLK             ),          
    .RESET         (RESET           ),          
    .newthreadq_sel(newthreadq_sel  ),          
    .thread_q2_sel (thread_q2_sel   ),          
    .wrcycl        (wrcycl          ),          
    .wrsrcAdata    (wrsrcAdata[17:0]),
    .Dam_q0        (Dam_q0[1:0]     ),          
    .Dam_q2        (Dam_q2[1:0]     ),          
    .Ind_Dest_q0   (Ind_Dest_q0     ),          
    .Ind_SrcA_q0   (Ind_SrcA_q0     ),                                                  
    .Ind_SrcB_q0   (Ind_SrcB_q0     ),                                                  
    .Imod_Dest_q2  (Imod_Dest_q2    ),                                                  
    .Imod_SrcA_q0  (Imod_SrcA_q0    ),                                                   
    .Imod_SrcB_q0  (Imod_SrcB_q0    ),                                                   
    .OPdest_q0     (OPdest_q0       ),                                                   
    .OPdest_q2     (OPdest_q2       ),          
    .OPsrcA_q0     (OPsrcA_q0       ),          
    .OPsrcB_q0     (OPsrcB_q0       ),          
    .OPsrc32_q0    (OPsrc32_q0      ),  
    .Ind_Dest_q2   (Ind_Dest_q2     ),        
    .Dest_addrs_q2 (Dest_addrs_q2   ),          
    .SrcA_addrs_q0 (SrcA_addrs_q0   ),          
    .SrcB_addrs_q0 (SrcB_addrs_q0   ),           
    . AR0          ( AR0            ),
    . AR1          ( AR1            ),
    . AR2          ( AR2            ),
    . AR3          ( AR3            ),
    . AR4          ( AR4            ),
    . AR5          ( AR5            ),
    . AR6          ( AR6            ),
    . SP           ( SP             )     
    );                            

wire rd_float_q1_selA; 
wire rd_float_q1_selB; 
wire rd_integr_q1_selA;
wire rd_integr_q1_selB;

assign rd_float_q1_selA  = (SrcA_addrs_q1[17:12]==6'b001110) && ~((Dam_q1[1:0]==2'b10) || ((Dam_q1[1:0]==2'b11) && (Size_SrcA_q1[1:0]==2'b11))) && thread_q1_sel; //don't enable if table-read or 32-bit immediate
assign rd_float_q1_selB  = (SrcA_addrs_q1[17:12]==6'b001110) &&  ~(Dam_q1[1:0]==2'bx1) && thread_q1_sel; //don't enable if any kind of immediate
assign rd_integr_q1_selA = (SrcA_addrs_q1[17:12]==6'b001101) && ~((Dam_q1[1:0]==2'b10) || ((Dam_q1[1:0]==2'b11) && (Size_SrcA_q1[1:0]==2'b11))) && thread_q1_sel; //don't enable if table-read or 32-bit immediate
assign rd_integr_q1_selB = (SrcA_addrs_q1[17:12]==6'b001101) &&  ~(Dam_q1[1:0]==2'bx1) && thread_q1_sel; //don't enable if any kind of immediate

                                  
STATUS_REG status(
     .CLK              (CLK              ),
     .RESET            (RESET            ),
     .wrcycl           (wrcycl           ),
     .thread_q2_sel    (thread_q2_sel    ),
     .OPdest_q2        (OPdest_q2        ),
     .Ind_Dest_q2      (Ind_Dest_q2      ),
     .Sext_SrcA_q2     (Sext_SrcA_q2     ),
     .Sext_SrcB_q2     (Sext_SrcB_q2     ),     
     .Size_SrcA_q2     (Size_SrcA_q2     ),
     .Size_SrcB_q2     (Size_SrcB_q2     ),
     .Size_Dest_q2     (Size_Dest_q2     ),
     .wrsrcAdata       (wrsrcAdata       ),
     .wrsrcBdata       (wrsrcBdata       ),
     .V_q2             (V_q2             ),
     .N_q2             (N_q2             ),            
     .C_q2             (C_q2             ),
     .Z_q2             (Z_q2             ),
     .V                (V                ),
     .N                (N                ),
     .C                (C                ),
     .Z                (Z                ),
     .IRQ              (IRQ              ),
     .done             (done             ),
     .enAltImmInexactHandl  (enAltImmInexactHandl  ),
     .enAltImmUnderflowHandl(enAltImmUnderflowHandl),
     .enAltImmOverflowHandl (enAltImmOverflowHandl ),
     .enAltImmDivByZeroHandl(enAltImmDivByZeroHandl),
     .enAltImmInvalidHandl  (enAltImmInvalidHandl  ),
     .IRQ_IE           (IRQ_IE           ),
     .STATUS           (STATUS           ),
     .class            (class            ),
     .exc_codeA        (exc_codeA        ),
     .exc_codeB        (exc_codeB        ),
     .rd_float_q1_selA (rd_float_q1_selA ),
     .rd_float_q1_selB (rd_float_q1_selB ),
     .rd_integr_q1_selA(rd_integr_q1_selA),
     .rd_integr_q1_selB(rd_integr_q1_selB),
     .fp_ready_q2      (fp_ready_q2      )
     );

    
int_cntrl int_cntrl(
    .CLK                  (CLK          ),
    .RESET                (RESET        ),
    .PC                   (PC[15:0]     ),
    .thread_q0_sel        (newthreadq_sel),
    .thread_q1_sel        (thread_q1_sel),
    .thread_q2_sel        (thread_q2_sel),
    .OPsrcA_q2            (OPsrcA_q2    ),
    .OPdest_q2            (OPdest_q2    ),
    .Ind_Dest_q2          (Ind_Dest_q2  ),
    .Ind_SrcA_q2          (Ind_SrcA_q2  ),
    .Sext_Dest_q2         (Sext_Dest_q2 ),
    .RPT_not_z            (RPT_not_z    ),
    .NMI                  ((timer==timercmpr) && ~done),
    .inexact_exc          (TrapInexact_q1),
    .underflow_exc        (TrapUnderflow_q1 ),
    .overflow_exc         (TrapOverflow_q1 ),
    .divby0_exc           (TrapDivX0_q1 ),
    .invalid_exc          (TrapInvalid_q1  ),
    .IRQ                  (IRQ          ),
    .IRQ_IE               (IRQ_IE       ),
    .vector               (vector       ),
    .ld_vector            (ld_vector    ),
    .NMI_ack              (NMI_ack      ),
    .EXC_ack              (EXC_ack      ),
    .IRQ_ack              (IRQ_ack      ),
    .EXC_in_service       (EXC_in_service      ),
    .invalid_in_service   (invalid_in_service  ),
    .divby0_in_service    (divby0_in_service   ),
    .overflow_in_service  (overflow_in_service ),
    .underflow_in_service (underflow_in_service),
    .inexact_in_service   (inexact_in_service  ),
    .wrcycl               (wrcycl              ),
    .int_in_service       (int_in_service      ),
    .NMI_VECTOR           (NMI_VECTOR          ),
    .IRQ_VECTOR           (IRQ_VECTOR          ),
    .invalid_VECTOR       (invalid_VECTOR      ),
    .divby0_VECTOR        (divby0_VECTOR       ),
    .overflow_VECTOR      (overflow_VECTOR     ),
    .underflow_VECTOR     (underflow_VECTOR    ),
    .inexact_VECTOR       (inexact_VECTOR      )
    );   
    
REPEAT_reg repeat_reg(
    .CLK           (CLK          ),
    .RESET         (RESET        ),
    .thread_q0_sel (newthreadq_sel),
    .Ind_Dest_q0   (Ind_Dest_q0  ),
    .Ind_SrcA_q0   (Ind_SrcA_q0  ),
    .Ind_SrcB_q0   (Ind_SrcB_q0  ),
    .Imod_Dest_q0  (Imod_Dest_q0 ),
    .Imod_SrcA_q0  (Imod_SrcA_q0 ),
    .Imod_SrcB_q0  (Imod_SrcB_q0 ),
    .OPdest_q0     (OPdest_q0    ),
    .OPsrcA_q0     (OPsrcA_q0    ),
    .OPsrcB_q0     (OPsrcB_q0    ),
    .RPT_not_z     (RPT_not_z    ),
    .break_q0      (break_q0     ),
    .int_in_service(int_in_service),
    .Dam_q0        (Dam_q0[1:0]  ),
    .AR0           (AR0[10:0]    ),
    .AR1           (AR1[10:0]    ),
    .AR2           (AR2[10:0]    ),
    .AR3           (AR3[10:0]    ),
    .AR4           (AR4[10:0]    ),
    .AR5           (AR5[10:0]    ),
    .AR6           (AR6[10:0]    ),
    .REPEAT        (REPEAT       )
);

//A-side reads
always @(*) begin    
    if (thread_q1_sel) begin
           casex (SrcA_addrs_q1)
         GLOB_RAM_ADDRS : rdSrcAdata = glob_RAM_rddataA[63:0]; //addresses are in bytes
               SP_ADDRS : rdSrcAdata = {46'h0000_0000_0000, SP[17:0]};                      
              AR6_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR6[17:0]};                      
              AR5_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR5[17:0]};
              AR4_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR4[17:0]};
              AR3_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR3[17:0]};                      
              AR2_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR2[17:0]};                      
              AR1_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR1[17:0]};
              AR0_ADDRS : rdSrcAdata = {46'h0000_0000_0000, AR0[17:0]};
               PC_ADDRS : rdSrcAdata = {48'h0000_0000_0000, PC[15:0]};
          PC_COPY_ADDRS : rdSrcAdata = {48'h0000_0000_0000, PC_COPY[15:0]};
               ST_ADDRS : rdSrcAdata = STATUS[63:0];
           REPEAT_ADDRS : rdSrcAdata = {53'h0000_0000_0000_00, REPEAT[10:0]};  //this is so REPEAT is visible to debugger
           LPCNT1_ADDRS : rdSrcAdata = {47'h0000_0000_0000, LPCNT1_nz, 4'b0000, LPCNT1[11:0]};
           LPCNT0_ADDRS : rdSrcAdata = {47'h0000_0000_0000, LPCNT0_nz, 4'b0000, LPCNT0[11:0]};
            TIMER_ADDRS : rdSrcAdata = {44'h0000_000, timer[19:0]};           //20-bit timer                    
             CREG_ADDRS : rdSrcAdata = C_reg[63:0];     //C_reg is 64-bits  plus 2 size bits 
            CLASS_ADDRS : rdSrcAdata = {60'b0, class[3:0]};
         SAVFLAGS_ADDRS : rdSrcAdata = {59'b0, flags[4:0]};
           RNDDIR_ADDRS : rdSrcAdata = {61'b0, roundDirection[2:0]};
            RADIX_ADDRS : rdSrcAdata = {62'b0, 2'b10};
         SAVMODES_ADDRS : rdSrcAdata = {60'b0, sModes[3:0]};
              MON_ADDRS : rdSrcAdata = MON_SrcA_data[63:0];  //this data comes from the monitor/debugger/break block 
                                              
            CAPT3_ADDRS,
            CAPT2_ADDRS,
            CAPT1_ADDRS,
            CAPT0_ADDRS : rdSrcAdata = capt_dataA;           //capture registers are 64-bits  
            
            FLOAT_ADDRS : rdSrcAdata = float_rddataA[63:0];
           INTEGR_ADDRS : rdSrcAdata = rddataA_integer[63:0];
         PRIV_RAM_ADDRS : rdSrcAdata =  priv_RAM_rddataA[63:0];        //lowest 8k bytes of memory is RAM space               
               default  : rdSrcAdata = 64'h0000_0000_0000_0000;  
           endcase
    end                                                                              
    else rdSrcAdata = 64'h0000_0000_0000_0000;
end                                                                          

//B-side reads
always @(*) begin    //addresses are in bytes
    if (thread_q1_sel) begin
           casex (SrcB_addrs_q1)
         GLOB_RAM_ADDRS : rdSrcBdata = glob_RAM_rddataB[63:0];
               SP_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, SP[17:0]};                      
              AR6_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR6[17:0]};                      
              AR5_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR5[17:0]};
              AR4_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR4[17:0]};
              AR3_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR3[17:0]};                      
              AR2_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR2[17:0]};                      
              AR1_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR1[17:0]};
              AR0_ADDRS : rdSrcBdata =  {46'h0000_0000_0000, AR0[17:0]};
               PC_ADDRS : rdSrcBdata =  {48'h0000_0000_0000, PC[15:0]};
          PC_COPY_ADDRS : rdSrcBdata =  {48'h0000_0000_0000, PC_COPY};
               ST_ADDRS : rdSrcBdata =  STATUS[63:0];
           LPCNT1_ADDRS : rdSrcBdata =  {47'h0000_0000_0000, LPCNT1_nz, 4'b0000, LPCNT1[11:0]};
           LPCNT0_ADDRS : rdSrcBdata =  {47'h0000_0000_0000, LPCNT0_nz, 4'b0000, LPCNT0[11:0]};
            TIMER_ADDRS : rdSrcBdata =  {44'h0000_000, timer[19:0]};           //20-bit timer                    
             CREG_ADDRS : rdSrcBdata =  C_reg[63:0];     //C_reg is 64-bits plus 2 size bits 
             
            CLASS_ADDRS : rdSrcBdata = {60'b0, class[3:0]};
         SAVFLAGS_ADDRS : rdSrcBdata = {59'b0, flags[4:0]};
           RNDDIR_ADDRS : rdSrcBdata = {61'b0, roundDirection[2:0]};
            RADIX_ADDRS : rdSrcBdata = {62'b0, 2'b10};
         SAVMODES_ADDRS : rdSrcBdata = {60'b0, sModes[3:0]};
              MON_ADDRS : rdSrcBdata = MON_SrcA_data[63:0];  //this data comes from the monitor/debugger/break block 
                                      
            CAPT3_ADDRS,
            CAPT2_ADDRS,
            CAPT1_ADDRS,
            CAPT0_ADDRS : rdSrcBdata = capt_dataB[63:0];           //capture registers are 64-bits
            
            FLOAT_ADDRS : rdSrcBdata = float_rddataB[63:0];
           INTEGR_ADDRS : rdSrcBdata = rddataB_integer[63:0];
         PRIV_RAM_ADDRS : rdSrcBdata = priv_RAM_rddataB[63:0];        //lowest 8k bytes of memory is private RAM space               
               default  : rdSrcBdata = 64'h0000_0000_0000_0000;            
           endcase
    end
    else rdSrcBdata = 64'h0000_0000_0000_0000;
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) mon_srcA_data_capture <= 64'h0000_0000_0000_0000;
    else if (Dest_addrs_q2=={2'b00, MON_ADDRS[15:0]} && ~|Dam_q2[1:0] && ~Ind_Dest_q2 && thread_q2_sel) mon_srcA_data_capture <= wrsrcAdata;
end    

//get Rounding Direction register simply makes a copy of status register bits [61:60] , the round mode bits
always @(posedge CLK or posedge RESET) begin
    if (RESET) roundDirection <= 3'b000;
    else if (Dest_addrs_q2=={2'b00, RNDDIR_ADDRS[15:0]} && ~|Dam_q2[1:0] && ~Ind_Dest_q2 && thread_q2_sel) roundDirection <= {wrsrcAdata[63], wrsrcAdata[63], wrsrcAdata[63]} & wrsrcAdata[62:60];
end    

//save Modes register simply makes a copy of status register bits [63:60] , the round mode bits
always @(posedge CLK or posedge RESET) begin
    if (RESET) sModes <= 4'h0;
    else if (Dest_addrs_q2=={2'b00, SAVMODES_ADDRS[15:0]} && ~|Dam_q2[1:0] && ~Ind_Dest_q2 && thread_q2_sel) sModes <= wrsrcAdata[63:60];
end    

//save flags register simply makes a copy of the exception bits in the status register   
always @(posedge CLK or posedge RESET) begin
    if (RESET) flags <= 5'b00000;
    else if (Dest_addrs_q2=={2'b00, SAVFLAGS_ADDRS[15:0]} && ~|Dam_q2[1:0] && ~Ind_Dest_q2 && thread_q2_sel) flags <= wrsrcAdata[10:6];
end    

// C_register
always @(posedge CLK or posedge RESET) begin
    if (RESET) C_reg <= 66'h0_0000_0000_0000_0000;
    else if ((OPdest_q2==CREG_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) C_reg <= {Size_Dest_q2, wrsrcAdata};
end

// timer--counts number of instructions this thread executes and not clocks
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        timer <= 20'h0_0000;
        timercmpr <= 20'h0_1000;     //default time-out value
    end    
    else if ((OPdest_q2==TIMER_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) begin
        timer <= 20'h0_0000;
        timercmpr <= wrsrcAdata[19:0];
    end    
    else if (~done && ~(timer==timercmpr) && newthreadq_sel) timer <= timer + 1'b1;                   
end

//loop counters
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        LPCNT1 <= 12'h000;
        LPCNT0 <= 12'h000;
    end
    else begin
        if ((OPdest_q2==LPCNT0_ADDRS[15:0]) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) LPCNT0 <= wrsrcAdata[11:0];
        else if ((OPdest_q2==BTBS_) && ~Ind_Dest_q2 && (OPsrcA_q2==LPCNT0_ADDRS[15:0]) && thread_q2_sel && LPCNT0_nz) LPCNT0 <= LPCNT0_dec;
        
        if ((OPdest_q2==LPCNT1_ADDRS[15:0]) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) LPCNT1 <= wrsrcAdata[11:0];
        else if ((OPdest_q2==BTBS_) && ~Ind_Dest_q2 && (OPsrcA_q2==LPCNT1_ADDRS[15:0]) && thread_q2_sel && LPCNT1_nz) LPCNT1 <= LPCNT1_dec;
   end     
end
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        NMI_VECTOR       <= 16'h0000;
        IRQ_VECTOR       <= 16'h0000; 
        invalid_VECTOR   <= 16'h0000; 
        divby0_VECTOR    <= 16'h0000; 
        overflow_VECTOR  <= 16'h0000; 
        underflow_VECTOR <= 16'h0000;
        inexact_VECTOR   <= 16'h0000; 
    end
    else begin
        if ((OPdest_q2==NMI_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) NMI_VECTOR <= wrsrcAdata[15:0];
        if ((OPdest_q2==IRQ_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) IRQ_VECTOR <= wrsrcAdata[15:0];
        if ((OPdest_q2==invalid_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) invalid_VECTOR <= wrsrcAdata[15:0];
        if ((OPdest_q2==divby0_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) divby0_VECTOR <= wrsrcAdata[15:0];
        if ((OPdest_q2==overflow_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) overflow_VECTOR <= wrsrcAdata[15:0];
        if ((OPdest_q2==underflow_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) underflow_VECTOR <= wrsrcAdata[15:0];
        if ((OPdest_q2==inexact_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && thread_q2_sel) inexact_VECTOR <= wrsrcAdata[15:0];
   end 
end
   
endmodule
