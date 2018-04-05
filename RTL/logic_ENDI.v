 // logic_ENDI.v
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

  module logic_ENDI(
      CLK,
      RESET,
      wren,
      thread_q1,
      Size_Dest_q1,
      wraddrs,     //includes thread#
      oprndA,
      oprndB,
      tr0_C,
      tr0_V,
      tr1_C,
      tr1_V,
      tr2_C,
      tr2_V,
      tr3_C,
      tr3_V,
      rdenA,
      Size_SrcA_q1,
      rdaddrsA,    //includes thread#
      rddataA,
      rdenB,
      Size_SrcB_q1,
      rdaddrsB,    //includes thread#
      rddataB,
      ready
      );

input CLK;
input RESET;
input wren;
input [1:0] thread_q1;
input [1:0] Size_Dest_q1;
input [5:0] wraddrs;
input [63:0] oprndA;
input [63:0] oprndB;
input tr0_C;
input tr0_V;
input tr1_C;
input tr1_V;
input tr2_C;
input tr2_V;
input tr3_C;
input tr3_V;
input rdenA;
input [1:0] Size_SrcA_q1;
input [5:0] rdaddrsA;
output [67:0] rddataA;
input rdenB;
input [1:0] Size_SrcB_q1;
input [5:0] rdaddrsB;
output [67:0] rddataB;
output ready;

reg readyA;
reg readyB;
reg [63:0] semaphor;
reg [6:0] delay0;
reg Cin; 
reg Vin; 

reg [63:0] oprndAq;
reg [63:0] oprndBq;
reg [63:0] ENDI;
reg [3:0] ENDI_SELq0;
reg [3:0] ENDI_SELq1;

wire n_flag;
wire z_flag;
wire ready;
wire wrenq;
wire [5:0] wraddrsq;

wire [67:0] rddataA;
wire [67:0] rddataB;
wire [65:0] rddataAq;
wire [65:0] rddataBq;
wire [3:0] ENDI_SEL;

assign ENDI_SEL = {Size_Dest_q1, Size_SrcA_q1}; 

assign n_flag = ENDI[63];
assign z_flag = ~|ENDI;
assign ready = readyA & readyB;  
assign wrenq = delay0[6];
assign wraddrsq = delay0[5:0];

assign rddataA = {Cin, Vin, rddataAq};     
assign rddataB = {Cin, Vin, rddataBq};     

RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(66))
    ram32_logic_ENDI(
    .CLK        (CLK      ),
    .wren       (wrenq    ),
    .wraddrs    (wraddrsq ),
    .wrdata     ({n_flag, z_flag, ENDI}),
    .rdenA      (rdenA    ),
    .rdaddrsA   (rdaddrsA ),
    .rddataA    (rddataAq  ),
    .rdenB      (rdenB    ),
    .rdaddrsB   (rdaddrsB ),
    .rddataB    (rddataBq  ));

always @(*)
    if (wrenq) 
        case(ENDI_SELq1)
           4'b0101 : ENDI = {48'h0000_0000_0000, oprndAq[7:0], oprndAq[15:8]};  //upper and lower bytes of single half-word (16 bits)
           4'b1001 : ENDI = {32'h0000_0000, oprndBq[7:0], oprndBq[15:8], oprndAq[7:0], oprndAq[15:8]}; 
           4'b1010 : ENDI = {32'h0000_0000, oprndAq[7:0], oprndAq[15:8], oprndAq[23:16], oprndAq[31:24]};
           4'b1101 : ENDI = {32'h0000_0000, oprndBq[7:0], oprndBq[15:8], oprndAq[7:0], oprndAq[15:8]}; 
           4'b1110 : ENDI = {oprndBq[7:0], oprndBq[15:8], oprndBq[23:16], oprndBq[31:24]   ,oprndAq[7:0], oprndAq[15:8],  oprndAq[23:16], oprndAq[31:24]};
           4'b1111 : ENDI = {oprndAq[7:0], oprndAq[15:8], oprndAq[23:16], oprndAq[31:24], oprndAq[39:32], oprndAq[47:40], oprndAq[55:48], oprndAq[63:56]};
           default : ENDI = 64'hFFFF_FFFF_FFFF_FFFF;
        endcase    
    else  ENDI = 64'hFFFF_FFFF_FFFF_FFFF;

always @(*)
    case (thread_q1)
       2'b00 : begin
                Cin = tr0_C;
                Vin = tr0_V;
               end 
       2'b01 : begin
                Cin = tr1_C;
                Vin = tr1_V;
               end 
       2'b10 : begin
                Cin = tr2_C;
                Vin = tr2_V;
               end 
       2'b11 : begin
                Cin = tr3_C;
                Vin = tr3_V;
               end 
    endcase
    

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        oprndAq <= 64'h0000_0000_0000_0000;
        oprndBq <= 64'h0000_0000_0000_0000;
        ENDI_SELq0 <= 4'b0;
        ENDI_SELq1 <= 4'b0;
     end
    else begin
        ENDI_SELq0 <= ENDI_SEL;
        ENDI_SELq1 <= ENDI_SELq0;
        if (wren) begin
        
           oprndAq <= oprndA;           
           oprndBq <= oprndB;  
        end    
        else begin
           oprndAq <= 64'h0000_0000_0000_0000;
           oprndBq <= 64'h0000_0000_0000_0000;
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