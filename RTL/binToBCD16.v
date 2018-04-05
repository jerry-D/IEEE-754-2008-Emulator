//binToBCD16.v
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

module binToBCD16 (
    RESET,
    CLK,
    binIn,
    decDigit4,
    decDigit3,
    decDigit2,
    decDigit1,
    decDigit0
    );
input RESET, CLK;
input [15:0] binIn;

output [3:0] decDigit4;
output [3:0] decDigit3;
output [3:0] decDigit2;
output [3:0] decDigit1;
output [3:0] decDigit0;

reg [18:0] shftadd8xq;
reg [19:0] DecOut_del_0;
reg [19:0] DecOut_del_1;

wire [3:0] ones;
wire [3:0] tens;
wire [3:0] hundreds;
wire [3:0] thousands;
wire [3:0] tenthousands;

wire [3:0] decDigit4;
wire [3:0] decDigit3;
wire [3:0] decDigit2;
wire [3:0] decDigit1;
wire [3:0] decDigit0;

wire [19:0] DecOut;

wire [3:0] shftadd0_out;
wire [3:0] shftadd1_out;
wire [3:0] shftadd2_out;


wire [3:0] shftadd31_out;
wire [3:0] shftadd30_out;

wire [3:0] shftadd41_out;
wire [3:0] shftadd40_out;

wire [3:0] shftadd51_out;
wire [3:0] shftadd50_out;

wire [3:0] shftadd62_out;
wire [3:0] shftadd61_out;
wire [3:0] shftadd60_out;

wire [3:0] shftadd72_out;
wire [3:0] shftadd71_out;
wire [3:0] shftadd70_out;

wire [3:0] shftadd82_out;
wire [3:0] shftadd81_out;
wire [3:0] shftadd80_out;

wire [3:0] shftadd93_out;
wire [3:0] shftadd92_out;
wire [3:0] shftadd91_out;
wire [3:0] shftadd90_out;

wire [3:0] shftadd103_out;
wire [3:0] shftadd102_out;
wire [3:0] shftadd101_out;
wire [3:0] shftadd100_out;

wire [3:0] shftadd113_out;
wire [3:0] shftadd112_out;
wire [3:0] shftadd111_out;
wire [3:0] shftadd110_out;

wire [3:0] shftadd124_out;
wire [3:0] shftadd123_out;
wire [3:0] shftadd122_out;
wire [3:0] shftadd121_out;
wire [3:0] shftadd120_out;

bindec3 shftadd0(.bin_in ({1'b0, binIn[15:13]}), .dec_out(shftadd0_out));

bindec3 shftadd1(.bin_in ({shftadd0_out[2:0], binIn[12]}), .dec_out(shftadd1_out));
    
bindec3 shftadd2(.bin_in ({shftadd1_out[2:0], binIn[11]}), .dec_out(shftadd2_out));

bindec3 shftadd31(.bin_in ({1'b0, shftadd0_out[3], shftadd1_out[3], shftadd2_out[3]}), .dec_out(shftadd31_out));

bindec3 shftadd30(.bin_in ({shftadd2_out[2:0], binIn[10]}), .dec_out(shftadd30_out));

bindec3 shftadd41(.bin_in ({shftadd31_out[2:0], shftadd30_out[3]}), .dec_out(shftadd41_out));
bindec3 shftadd40(.bin_in ({shftadd30_out[2:0], binIn[9]}), .dec_out(shftadd40_out));

bindec3 shftadd51(.bin_in ({shftadd41_out[2:0], shftadd40_out[3]}), .dec_out(shftadd51_out));
bindec3 shftadd50(.bin_in ({shftadd40_out[2:0], binIn[8]}), .dec_out(shftadd50_out));


bindec3 shftadd62(.bin_in ({1'b0, shftadd31_out[3], shftadd41_out[3], shftadd51_out[3]}), .dec_out(shftadd62_out));
bindec3 shftadd61(.bin_in ({shftadd51_out[2:0], shftadd50_out[3]}), .dec_out(shftadd61_out));
bindec3 shftadd60(.bin_in ({shftadd50_out[2:0], binIn[7]}), .dec_out(shftadd60_out));

bindec3 shftadd72(.bin_in ({shftadd62_out[2:0], shftadd61_out[3]}), .dec_out(shftadd72_out));
bindec3 shftadd71(.bin_in ({shftadd61_out[2:0], shftadd60_out[3]}), .dec_out(shftadd71_out));
bindec3 shftadd70(.bin_in ({shftadd60_out[2:0], binIn[6]}), .dec_out(shftadd70_out));

bindec3 shftadd82(.bin_in ({shftadd72_out[2:0], shftadd71_out[3]}), .dec_out(shftadd82_out));
bindec3 shftadd81(.bin_in ({shftadd71_out[2:0], shftadd70_out[3]}), .dec_out(shftadd81_out));
bindec3 shftadd80(.bin_in ({shftadd70_out[2:0], binIn[5]}  ), .dec_out(shftadd80_out));

//------------------------------------------- register here ----------------------------------

bindec3 shftadd93(.bin_in ({1'b0, shftadd8xq[18:16]}), .dec_out(shftadd93_out));
bindec3 shftadd92(.bin_in (shftadd8xq[15:12]), .dec_out(shftadd92_out));
bindec3 shftadd91(.bin_in (shftadd8xq[11:8]), .dec_out(shftadd91_out));
bindec3 shftadd90(.bin_in (shftadd8xq[7:4]), .dec_out(shftadd90_out));

bindec3 shftadd103(.bin_in ({shftadd93_out[2:0], shftadd92_out[3]}), .dec_out(shftadd103_out));
bindec3 shftadd102(.bin_in ({shftadd92_out[2:0], shftadd91_out[3]}), .dec_out(shftadd102_out));
bindec3 shftadd101(.bin_in ({shftadd91_out[2:0], shftadd90_out[3]}  ), .dec_out(shftadd101_out));
bindec3 shftadd100(.bin_in ({shftadd90_out[2:0], shftadd8xq[3]}), .dec_out(shftadd100_out));

bindec3 shftadd113(.bin_in ({shftadd103_out[2:0], shftadd102_out[3]}), .dec_out(shftadd113_out));
bindec3 shftadd112(.bin_in ({shftadd102_out[2:0], shftadd101_out[3]}), .dec_out(shftadd112_out));
bindec3 shftadd111(.bin_in ({shftadd101_out[2:0], shftadd100_out[3]}  ), .dec_out(shftadd111_out));
bindec3 shftadd110(.bin_in ({shftadd100_out[2:0], shftadd8xq[2]}), .dec_out(shftadd110_out));

bindec3 shftadd124(.bin_in ({1'b0, shftadd93_out[3], shftadd103_out[3], shftadd113_out[3]}), .dec_out(shftadd124_out));
bindec3 shftadd123(.bin_in ({shftadd113_out[2:0], shftadd112_out[3]}), .dec_out(shftadd123_out));
bindec3 shftadd122(.bin_in ({shftadd112_out[2:0], shftadd111_out[3]}), .dec_out(shftadd122_out));
bindec3 shftadd121(.bin_in ({shftadd111_out[2:0], shftadd110_out[3]}  ), .dec_out(shftadd121_out));
bindec3 shftadd120(.bin_in ({shftadd110_out[2:0], shftadd8xq[1]}), .dec_out(shftadd120_out));


always @(posedge CLK or posedge RESET) 
    if (RESET) begin
        shftadd8xq <= 1'b0;
        DecOut_del_0 <= 20'b0;
        DecOut_del_1 <= 20'b0;
    end
    else begin
        shftadd8xq[18:0] <= {shftadd62_out[3], shftadd72_out[3], shftadd82_out[3:0], shftadd81_out[3:0], shftadd80_out[3:0], binIn[4:0]}; 
        //these two delays are included here to maintain coherency with fraction BCD circuit, which is 3 stages deep
        DecOut_del_0 <= DecOut;
        DecOut_del_1 <= DecOut_del_0;
    end


assign tenthousands = {shftadd124_out[2:0], shftadd123_out[3]};
assign thousands = {shftadd123_out[2:0], shftadd122_out[3]};
assign hundreds = {shftadd122_out[2:0], shftadd121_out[3]};
assign tens = {shftadd121_out[2:0], shftadd120_out[3]}; 
assign ones = {shftadd120_out[2:0], shftadd8xq[0]};
assign DecOut = {tenthousands, thousands, hundreds, tens, ones};

assign decDigit4 = DecOut_del_1[19:16];
assign decDigit3 = DecOut_del_1[15:12];
assign decDigit2 = DecOut_del_1[11:8];
assign decDigit1 = DecOut_del_1[7:4];
assign decDigit0 = DecOut_del_1[3:0];

endmodule    