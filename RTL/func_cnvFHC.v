// func_cnvFHC.v
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

module func_cnvFHC (
    RESET,
    CLK,
    wren,
    thread_q1,
    wraddrs,
    oprndA,
    oprndB,
    tr0_C,
    tr0_V,
    tr0_N,
    tr0_Z,
    tr1_C,
    tr1_V,
    tr1_N,
    tr1_Z,
    tr2_C,
    tr2_V,
    tr2_N,
    tr2_Z,
    tr3_C,
    tr3_V,
    tr3_N,
    tr3_Z,
    rdenA,
    rdaddrsA,
    rddataA,
    rdenB,
    rdaddrsB,
    rddataB,
    ready
    );

input RESET, CLK, wren, rdenA, rdenB;
input [5:0] wraddrs, rdaddrsA, rdaddrsB;   // {thread, addrs}
input [1:0] thread_q1;
input [63:0] oprndA;
input [63:0] oprndB;


output [67:0] rddataA, rddataB;
output ready;

input tr0_C;
input tr0_V;
input tr0_N;
input tr0_Z;
input tr1_C;
input tr1_V;
input tr1_N;
input tr1_Z;
input tr2_C;
input tr2_V;
input tr2_N;
input tr2_Z;
input tr3_C;
input tr3_V;
input tr3_N;
input tr3_Z;
                       
reg [63:0] semaphor;  // one for each memory location
reg readyA;
reg readyB;

reg [6:0] delay0;

reg [63:0] oprndAq;
reg [63:0] oprndBq;

reg Cin;
reg Vin;
reg Nin;
reg Zin;

wire wrenq;
wire [5:0] wraddrsq;
wire [1:0] thread_q2;

wire ready;

wire [67:0] rddataA, rddataB; 
wire [63:0] rddataAq, rddataBq; 

wire [63:0] R;

assign wrenq = delay0[6];
assign wraddrsq = delay0[5:0];
assign thread_q2 = wraddrsq[5:4]; 

assign rddataA = {Cin, Vin, Nin, Zin, rddataAq};    
assign rddataB = {Cin, Vin, Nin, Zin, rddataBq};    

assign ready = readyA && readyB;

cnvFHC cnvFHC_15(
    .charIn (oprndBq[63:56]),
    .nybleOut (R[63:60])
    );

cnvFHC cnvFHC_14(
    .charIn (oprndBq[55:48]),
    .nybleOut (R[59:56])
    );

cnvFHC cnvFHC_13(
    .charIn (oprndBq[47:40]),
    .nybleOut (R[55:52])
    );

cnvFHC cnvFHC_12(
    .charIn (oprndBq[39:32]),
    .nybleOut (R[51:48])
    );

cnvFHC cnvFHC_11(
    .charIn (oprndBq[31:24]),
    .nybleOut (R[47:44])
    );

cnvFHC cnvFHC_10(
    .charIn (oprndBq[23:16]),
    .nybleOut (R[43:40])
    );

cnvFHC cnvFHC_9(
    .charIn (oprndBq[15:8]),
    .nybleOut (R[39:36])
    );

cnvFHC cnvFHC_8(
    .charIn (oprndBq[7:0]),
    .nybleOut (R[35:32])
    );



cnvFHC cnvFHC_7(
    .charIn (oprndAq[63:56]),
    .nybleOut (R[31:28])
    );

cnvFHC cnvFHC_6(
    .charIn (oprndAq[55:48]),
    .nybleOut (R[27:24])
    );

cnvFHC cnvFHC_5(
    .charIn (oprndAq[47:40]),
    .nybleOut (R[23:20])
    );

cnvFHC cnvFHC_4(
    .charIn (oprndAq[39:32]),
    .nybleOut (R[19:16])
    );

cnvFHC cnvFHC_3(
    .charIn (oprndAq[31:24]),
    .nybleOut (R[15:12])
    );

cnvFHC cnvFHC_2(
    .charIn (oprndAq[23:16]),
    .nybleOut (R[11:8])
    );

cnvFHC cnvFHC_1(
    .charIn (oprndAq[15:8]),
    .nybleOut (R[7:4])
    );

cnvFHC cnvFHC_0(
    .charIn (oprndAq[7:0]),
    .nybleOut (R[3:0])
    );


//RAM64x34tp ram64(
RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(64))
    ram64_cnvFHC(
    .CLK        (CLK     ),
    .wren       (wrenq ),
    .wraddrs    (wraddrsq ),   
    .wrdata     (R ), 
    .rdenA      (rdenA   ),   
    .rdaddrsA   (rdaddrsA),
    .rddataA    (rddataAq ),
    .rdenB      (rdenB   ),
    .rdaddrsB   (rdaddrsB),
    .rddataB    (rddataBq )
    );

always @(*)
    case (thread_q1)
       2'b00 : begin
                Cin = tr0_C;
                Vin = tr0_V;
                Nin = tr0_N;
                Zin = tr0_Z;
               end 
       2'b01 : begin
                Cin = tr1_C;
                Vin = tr1_V;
                Nin = tr1_N;
                Zin = tr1_Z;
               end 
       2'b10 : begin
                Cin = tr2_C;
                Vin = tr2_V;
                Nin = tr2_N;
                Zin = tr2_Z;
               end 
       2'b11 : begin
                Cin = tr3_C;
                Vin = tr3_V;
                Nin = tr3_N;
                Zin = tr3_Z;
               end 
    endcase


always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        oprndAq <= 64'h0000_0000_0000_0000;
        oprndBq <= 64'h0000_0000_0000_0000;
//        Cin <= 1'b0;
//        Vin <= 1'b0;
//        Nin <= 1'b0;
//        Zin <= 1'b0;
     end
    else begin
        if (wren) begin
           oprndAq <= oprndA;           
           oprndBq <= oprndB;           
        end    
        else begin
           oprndAq <= 64'h0000_0000_0000_0000;
           oprndBq <= 64'h0000_0000_0000_0000;
        end 
/*           
        case (thread_q2)
           2'b00 : begin
                    Cin <= tr0_C;
                    Vin <= tr0_V;
                    Nin <= tr0_N;
                    Zin <= tr0_Z;
                   end 
           2'b01 : begin
                    Cin <= tr1_C;
                    Vin <= tr1_V;
                    Nin <= tr1_N;
                    Zin <= tr1_Z;
                   end 
           2'b10 : begin
                    Cin <= tr2_C;
                    Vin <= tr2_V;
                    Nin <= tr2_N;
                    Zin <= tr2_Z;
                   end 
           2'b11 : begin
                    Cin <= tr3_C;
                    Vin <= tr3_V;
                    Nin <= tr3_N;
                    Zin <= tr3_Z;
                   end 
        endcase
*/        
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
