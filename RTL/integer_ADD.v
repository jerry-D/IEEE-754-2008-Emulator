 // integer_ADD.v
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


  module integer_ADD(
      CLK,
      RESET,
      thread_q1,
      Sext_Dest_q2, // 1=ADDC, 0=ADD
      Sext_SrcA_q2,
      Sext_SrcB_q2,
      wren,
      wraddrs,     //includes thread#
      oprndA,
      oprndB,
      tr0_C,
      tr1_C,
      tr2_C,
      tr3_C,
      rdenA,
      rdaddrsA,    //includes thread#
      rddataA,
      rdenB,
      rdaddrsB,    //includes thread#
      rddataB,
      ready
      );

input CLK;
input RESET;
input [1:0] thread_q1;
input Sext_Dest_q2;
input Sext_SrcA_q2;
input Sext_SrcB_q2;
input wren;
input [5:0] wraddrs;
input [63:0] oprndA;
input [63:0] oprndB;
input tr0_C;
input tr1_C;
input tr2_C;
input tr3_C;
input rdenA;
input [5:0] rdaddrsA;
output [67:0] rddataA;
input rdenB;
input [5:0] rdaddrsB;
output [67:0] rddataB;
output ready;

reg readyA;
reg readyB;
reg [63:0] semaphor;
reg [6:0] delay0;
reg signed [64:0] oprndAq;
reg signed [64:0] oprndBq;
reg SextResult;
reg Sext_Dest_q3;
reg Cin;

wire signed [64:0] ADD_result;
wire ready;
wire wrenq;
wire [5:0] wraddrsq;

wire [67:0] rddataA;
wire [67:0] rddataB;
wire z_flag;
wire n_flag;
wire c_flag;
wire v_flag;
wire c_flag_withCarry;
wire v_flag_withCarry;

wire c_flag_withOutCarry;
wire v_flag_withOutCarry;


assign ready = readyA && readyB;  
assign wrenq = delay0[6];
assign wraddrsq = delay0[5:0]; 
assign ADD_result = oprndAq + oprndBq + (Cin && Sext_Dest_q3);
assign z_flag = ~|ADD_result;
assign n_flag = ADD_result[64] && SextResult;
assign c_flag_withCarry = (~oprndAq[64] && oprndBq[64]) || (oprndBq[64] && ADD_result[64]) || (~oprndAq[64] && ADD_result[64]);
assign v_flag_withCarry = (oprndAq[64] &&  ~oprndBq[64] && ~ADD_result[64]) || (~oprndAq[64] &&  oprndBq[64] && ADD_result[64]);

assign c_flag_withOutCarry = (oprndAq[64] && oprndBq[64]) || (oprndBq[64] && ~ADD_result[64]) || (oprndAq[64] && ~ADD_result[64]);
assign v_flag_withOutCarry = (oprndAq[64] &&  oprndBq[64] && ~ADD_result[64]) || (~oprndAq[64] && ~oprndBq[64] && ADD_result[64]);

assign c_flag = Sext_Dest_q3 ? c_flag_withCarry : c_flag_withOutCarry;
assign v_flag = Sext_Dest_q3 ? v_flag_withCarry : v_flag_withOutCarry;

RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(68))
    ram32_integer_ADD(
    .CLK        (CLK      ),
    .wren       (wrenq    ),
    .wraddrs    (wraddrsq ),
    .wrdata     ({c_flag, v_flag, n_flag, z_flag, ADD_result[63:0]}),
    .rdenA      (rdenA    ),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (rddataA  ),
    .rdenB      (rdenB    ),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (rddataB  ));
    
always @(*)
     case(thread_q1)
        2'b00 : Cin = tr0_C; 
        2'b01 : Cin = tr1_C; 
        2'b10 : Cin = tr2_C; 
        2'b11 : Cin = tr3_C;
     endcase   

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        oprndAq <= 65'h0000_0000_0000_0000;
        oprndBq <= 65'h0000_0000_0000_0000;
        SextResult <= 1'b0;
        Sext_Dest_q3 <= 1'b0;
    end
    else begin
        if (wren) begin
           Sext_Dest_q3 <= Sext_Dest_q2;
           SextResult <= (Sext_SrcA_q2 || Sext_SrcB_q2);
           oprndAq <= {(Sext_SrcA_q2 && oprndA[63]), oprndA[63:0]};           
           oprndBq <= {(Sext_SrcB_q2 && oprndB[63]), oprndB[63:0]};
        end    
        else begin
           Sext_Dest_q3 <= 1'b0;
           SextResult <= 1'b0;
           oprndAq <= 65'h0000_0000_0000_0000;
           oprndBq <= 65'h0000_0000_0000_0000;
        end    
    end    
end            
    
always@(posedge CLK or posedge RESET) begin
    if (RESET) begin
        delay0  <= 7'h00;
    end    
    else begin
        delay0  <= {wren, wraddrs};
    end 
end        

always @(posedge CLK or posedge RESET) begin
    if (RESET) semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (wren) semaphor[wraddrs] <= 1'b0;
        if (wrenq) semaphor[wraddrsq] <= 1'b1;
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