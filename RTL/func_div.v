// func_div.v
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


module func_div (
    RESET,
    CLK,
    NaN_del,
    wren,
    round_mode_del,
    Away_del,
    A_sign_del,
    A_is_zero_del,
    A_invalid_del,
    A_inexact_del,
    A_is_infinite_del,
    B_sign_del,
    B_is_zero_del,
    B_invalid_del,
    B_inexact_del,
    B_is_infinite_del,    
    wraddrs,
    wraddrs_del,
    wrdataA,
    wrdataB,
    rdenA,
    rdaddrsA,
    rddataA,
    rdenB,
    rdaddrsB,
    rddataB,
    ready  );

input RESET, CLK, wren, rdenA, rdenB;
input [9:0] NaN_del;
input [5:0] wraddrs, wraddrs_del, rdaddrsA, rdaddrsB;
input [18:0] wrdataA, wrdataB;
input A_sign_del;
input A_is_zero_del;
input A_invalid_del;
input A_inexact_del;
input A_is_infinite_del;
input B_sign_del;
input B_is_zero_del;
input B_invalid_del;
input B_inexact_del;
input B_is_infinite_del;
input Away_del;

input [1:0] round_mode_del;

output [17:0] rddataA, rddataB;
output ready;


// invalid operation codes for NaN diagnostic payload generation
parameter sig_NaN      = 3'b000;  // singnaling NaN is an operand--if possible, an incoming sNaN should have the last 3 bits equal to this code
parameter mult_oob     = 3'b001;  // multiply operands out of bounds, multiplication(0, INF) or multiplication(?INF, 0)
parameter fsd_mult_oob = 3'b010;  // fused multiply operands out of bounds
parameter add_oob      = 3'b011;  // add or subract or fusedmultadd operands out of bounds
parameter div_oob      = 3'b100;  // division operands out of bounds, division(0, 0) or division(?INF, INF) 
parameter rem_oob      = 3'b101;  // remainder operands out of bounds, remainder(x, y), when y is zero or x is infinite (and neither is NaN)
parameter sqrt_oob     = 3'b110;  // square-root or log operand out of bounds, operand is less than zero
parameter quantize     = 3'b111;  

//FloPoCo exception codes
parameter zero = 2'b00;
parameter infinity = 2'b10;
parameter NaN = 2'b11;
parameter normal = 2'b01;
                       
reg [63:0] semaphor;  // one for each memory location   4 threads x 16 results each

reg readyA;
reg readyB;

reg wren_del_0,  
    wren_del_1, 
    wren_del_2,
    wren_del_3,
    wren_del_4,
    wren_del_5;
    
wire ready;

wire [17:0] rddataA, rddataB; 

wire invalid;
wire div_by_0;
wire guard; 
wire round; 
wire sticky;
wire [18:0] R610;
wire [17:0] R18;


assign invalid = ((A_is_zero_del && B_is_zero_del)  ||
                  (A_is_infinite_del && B_is_infinite_del)) &&
                   wren_del_4 ;

assign div_by_0 = ~invalid && B_is_zero_del && wren_del_4 ;                  

assign ready = readyA && readyB;
      
      
FPDiv610 FPDiv610(
    .clk (CLK ), 
    .rst (RESET ),
    .X   (wrdataA),
    .Y   (wrdataB),  
    .R   (R610 ),            
    .IEEEg_d1 (guard ),      
    .IEEEr_d1 (round ),      
    .IEEEs_d1 (sticky ),     
    .roundit (1'b0)          
    );
      
FP610_To_IEEE754_510_filtered FP610toIEEE510(
    .CLK               (CLK          ),
    .RESET             (RESET        ),
    .wren              (wren_del_4   ),     
    .round_mode        (round_mode_del),    
    .Away              (Away_del     ),
    .trunk_invalid     (invalid      ),
    .NaN_in            (NaN_del      ),     
    .invalid_code      (div_oob      ),     
    .operator_overflow (1'b0         ),  
    .operator_underflow(1'b0         ),    
    .div_by_0_del      (div_by_0     ),     
    .A_invalid_del     (A_invalid_del),     
    .B_invalid_del     (B_invalid_del),     
    .A_inexact_del     (A_inexact_del),     
    .B_inexact_del     (B_inexact_del),     
    .X                 (div_by_0 ? {infinity, (A_sign_del ^ B_sign_del), R610[15:0]} : R610[18:0]),       
    .Rq                (R18          ),        
    .G_in              (guard        ),        
    .R_in              (round        ),        
    .S_in              (sticky       )         
    );                       


//RAM64x34tp ram64(
RAM_func #(.ADDRS_WIDTH(6), .DATA_WIDTH(18))
    ram64_divclk(
    .CLK        (CLK      ),
    .wren       (wren_del_5 ),
    .wraddrs    (wraddrs_del),
    .wrdata     (R18),  
    .rdenA      (rdenA   ),
    .rdaddrsA   (rdaddrsA),
    .rddataA    (rddataA ),
    .rdenB      (rdenB   ),
    .rdaddrsB   (rdaddrsB),
    .rddataB    (rddataB )
    );
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        wren_del_0 <= 1'b0;
        wren_del_1 <= 1'b0;
        wren_del_2 <= 1'b0;
        wren_del_3 <= 1'b0;
        wren_del_4 <= 1'b0;
        wren_del_5 <= 1'b0;
    end
    else begin
        wren_del_0 <= wren;
        wren_del_1 <= wren_del_0;
        wren_del_2 <= wren_del_1;
        wren_del_3 <= wren_del_2;
        wren_del_4 <= wren_del_3;
        wren_del_5 <= wren_del_4;
    end
end   

always @(posedge CLK or posedge RESET) begin
    if (RESET) semaphor <= 64'hFFFF_FFFF_FFFF_FFFF;
    else begin
        if (wren) semaphor[wraddrs] <= 1'b0;
        if (wren_del_5) semaphor[wraddrs_del] <= 1'b1;
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
