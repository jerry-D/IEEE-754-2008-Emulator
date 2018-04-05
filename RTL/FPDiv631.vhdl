-- FPDiv631.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ ./flopoco -name=FPDiv631 -frequency=175 -useHardMult=no FPDiv 6 31
-- Updating entity name to: FPDiv631
-- 
-- Final report:
-- Entity FPDiv631
--    Pipeline depth = 9
-- Output file: flopoco.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ cat flopoco.vhdl
--------------------------------------------------------------------------------
--                                  FPDiv631
--                                (FPDiv_6_31)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors:
--------------------------------------------------------------------------------
-- Pipeline depth: 9 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPDiv631 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(6+31+2 downto 0);
          Y : in  std_logic_vector(6+31+2 downto 0);
          R : out  std_logic_vector(6+31+2 downto 0)   );
end entity;

architecture arch of FPDiv631 is
signal fX :  std_logic_vector(31 downto 0);
signal fY, fY_d1, fY_d2, fY_d3, fY_d4, fY_d5, fY_d6 :  std_logic_vector(31 downto 0);
signal expR0, expR0_d1, expR0_d2, expR0_d3, expR0_d4, expR0_d5, expR0_d6, expR0_d7, expR0_d8 :  std_logic_vector(7 downto 0);
signal sR, sR_d1, sR_d2, sR_d3, sR_d4, sR_d5, sR_d6, sR_d7, sR_d8, sR_d9 :  std_logic;
signal exnXY :  std_logic_vector(3 downto 0);
signal exnR0, exnR0_d1, exnR0_d2, exnR0_d3, exnR0_d4, exnR0_d5, exnR0_d6, exnR0_d7, exnR0_d8, exnR0_d9 :  std_logic_vector(1 downto 0);
signal fYTimes3, fYTimes3_d1, fYTimes3_d2, fYTimes3_d3, fYTimes3_d4, fYTimes3_d5, fYTimes3_d6 :  std_logic_vector(33 downto 0);
signal w17, w17_d1 :  std_logic_vector(33 downto 0);
signal sel17 :  std_logic_vector(4 downto 0);
signal q17, q17_d1, q17_d2, q17_d3, q17_d4, q17_d5, q17_d6 :  std_logic_vector(2 downto 0);
signal q17D :  std_logic_vector(34 downto 0);
signal w17pad :  std_logic_vector(34 downto 0);
signal w16full :  std_logic_vector(34 downto 0);
signal w16 :  std_logic_vector(33 downto 0);
signal sel16 :  std_logic_vector(4 downto 0);
signal q16, q16_d1, q16_d2, q16_d3, q16_d4, q16_d5, q16_d6 :  std_logic_vector(2 downto 0);
signal q16D :  std_logic_vector(34 downto 0);
signal w16pad :  std_logic_vector(34 downto 0);
signal w15full :  std_logic_vector(34 downto 0);
signal w15, w15_d1 :  std_logic_vector(33 downto 0);
signal sel15 :  std_logic_vector(4 downto 0);
signal q15, q15_d1, q15_d2, q15_d3, q15_d4, q15_d5 :  std_logic_vector(2 downto 0);
signal q15D :  std_logic_vector(34 downto 0);
signal w15pad :  std_logic_vector(34 downto 0);
signal w14full :  std_logic_vector(34 downto 0);
signal w14 :  std_logic_vector(33 downto 0);
signal sel14 :  std_logic_vector(4 downto 0);
signal q14, q14_d1, q14_d2, q14_d3, q14_d4, q14_d5 :  std_logic_vector(2 downto 0);
signal q14D :  std_logic_vector(34 downto 0);
signal w14pad :  std_logic_vector(34 downto 0);
signal w13full :  std_logic_vector(34 downto 0);
signal w13 :  std_logic_vector(33 downto 0);
signal sel13 :  std_logic_vector(4 downto 0);
signal q13, q13_d1, q13_d2, q13_d3, q13_d4, q13_d5 :  std_logic_vector(2 downto 0);
signal q13D :  std_logic_vector(34 downto 0);
signal w13pad :  std_logic_vector(34 downto 0);
signal w12full :  std_logic_vector(34 downto 0);
signal w12, w12_d1 :  std_logic_vector(33 downto 0);
signal sel12 :  std_logic_vector(4 downto 0);
signal q12, q12_d1, q12_d2, q12_d3, q12_d4 :  std_logic_vector(2 downto 0);
signal q12D :  std_logic_vector(34 downto 0);
signal w12pad :  std_logic_vector(34 downto 0);
signal w11full :  std_logic_vector(34 downto 0);
signal w11 :  std_logic_vector(33 downto 0);
signal sel11 :  std_logic_vector(4 downto 0);
signal q11, q11_d1, q11_d2, q11_d3, q11_d4 :  std_logic_vector(2 downto 0);
signal q11D :  std_logic_vector(34 downto 0);
signal w11pad :  std_logic_vector(34 downto 0);
signal w10full :  std_logic_vector(34 downto 0);
signal w10 :  std_logic_vector(33 downto 0);
signal sel10 :  std_logic_vector(4 downto 0);
signal q10, q10_d1, q10_d2, q10_d3, q10_d4 :  std_logic_vector(2 downto 0);
signal q10D :  std_logic_vector(34 downto 0);
signal w10pad :  std_logic_vector(34 downto 0);
signal w9full :  std_logic_vector(34 downto 0);
signal w9, w9_d1 :  std_logic_vector(33 downto 0);
signal sel9 :  std_logic_vector(4 downto 0);
signal q9, q9_d1, q9_d2, q9_d3 :  std_logic_vector(2 downto 0);
signal q9D :  std_logic_vector(34 downto 0);
signal w9pad :  std_logic_vector(34 downto 0);
signal w8full :  std_logic_vector(34 downto 0);
signal w8 :  std_logic_vector(33 downto 0);
signal sel8 :  std_logic_vector(4 downto 0);
signal q8, q8_d1, q8_d2, q8_d3 :  std_logic_vector(2 downto 0);
signal q8D :  std_logic_vector(34 downto 0);
signal w8pad :  std_logic_vector(34 downto 0);
signal w7full :  std_logic_vector(34 downto 0);
signal w7 :  std_logic_vector(33 downto 0);
signal sel7 :  std_logic_vector(4 downto 0);
signal q7, q7_d1, q7_d2, q7_d3 :  std_logic_vector(2 downto 0);
signal q7D :  std_logic_vector(34 downto 0);
signal w7pad :  std_logic_vector(34 downto 0);
signal w6full :  std_logic_vector(34 downto 0);
signal w6, w6_d1 :  std_logic_vector(33 downto 0);
signal sel6 :  std_logic_vector(4 downto 0);
signal q6, q6_d1, q6_d2 :  std_logic_vector(2 downto 0);
signal q6D :  std_logic_vector(34 downto 0);
signal w6pad :  std_logic_vector(34 downto 0);
signal w5full :  std_logic_vector(34 downto 0);
signal w5 :  std_logic_vector(33 downto 0);
signal sel5 :  std_logic_vector(4 downto 0);
signal q5, q5_d1, q5_d2 :  std_logic_vector(2 downto 0);
signal q5D :  std_logic_vector(34 downto 0);
signal w5pad :  std_logic_vector(34 downto 0);
signal w4full :  std_logic_vector(34 downto 0);
signal w4 :  std_logic_vector(33 downto 0);
signal sel4 :  std_logic_vector(4 downto 0);
signal q4, q4_d1, q4_d2 :  std_logic_vector(2 downto 0);
signal q4D :  std_logic_vector(34 downto 0);
signal w4pad :  std_logic_vector(34 downto 0);
signal w3full :  std_logic_vector(34 downto 0);
signal w3, w3_d1 :  std_logic_vector(33 downto 0);
signal sel3 :  std_logic_vector(4 downto 0);
signal q3, q3_d1 :  std_logic_vector(2 downto 0);
signal q3D :  std_logic_vector(34 downto 0);
signal w3pad :  std_logic_vector(34 downto 0);
signal w2full :  std_logic_vector(34 downto 0);
signal w2 :  std_logic_vector(33 downto 0);
signal sel2 :  std_logic_vector(4 downto 0);
signal q2, q2_d1 :  std_logic_vector(2 downto 0);
signal q2D :  std_logic_vector(34 downto 0);
signal w2pad :  std_logic_vector(34 downto 0);
signal w1full :  std_logic_vector(34 downto 0);
signal w1 :  std_logic_vector(33 downto 0);
signal sel1 :  std_logic_vector(4 downto 0);
signal q1, q1_d1 :  std_logic_vector(2 downto 0);
signal q1D :  std_logic_vector(34 downto 0);
signal w1pad :  std_logic_vector(34 downto 0);
signal w0full :  std_logic_vector(34 downto 0);
signal w0, w0_d1 :  std_logic_vector(33 downto 0);
signal q0 :  std_logic_vector(2 downto 0);
signal qP17 :  std_logic_vector(1 downto 0);
signal qM17 :  std_logic_vector(1 downto 0);
signal qP16 :  std_logic_vector(1 downto 0);
signal qM16 :  std_logic_vector(1 downto 0);
signal qP15 :  std_logic_vector(1 downto 0);
signal qM15 :  std_logic_vector(1 downto 0);
signal qP14 :  std_logic_vector(1 downto 0);
signal qM14 :  std_logic_vector(1 downto 0);
signal qP13 :  std_logic_vector(1 downto 0);
signal qM13 :  std_logic_vector(1 downto 0);
signal qP12 :  std_logic_vector(1 downto 0);
signal qM12 :  std_logic_vector(1 downto 0);
signal qP11 :  std_logic_vector(1 downto 0);
signal qM11 :  std_logic_vector(1 downto 0);
signal qP10 :  std_logic_vector(1 downto 0);
signal qM10 :  std_logic_vector(1 downto 0);
signal qP9 :  std_logic_vector(1 downto 0);
signal qM9 :  std_logic_vector(1 downto 0);
signal qP8 :  std_logic_vector(1 downto 0);
signal qM8 :  std_logic_vector(1 downto 0);
signal qP7 :  std_logic_vector(1 downto 0);
signal qM7 :  std_logic_vector(1 downto 0);
signal qP6 :  std_logic_vector(1 downto 0);
signal qM6 :  std_logic_vector(1 downto 0);
signal qP5 :  std_logic_vector(1 downto 0);
signal qM5 :  std_logic_vector(1 downto 0);
signal qP4 :  std_logic_vector(1 downto 0);
signal qM4 :  std_logic_vector(1 downto 0);
signal qP3 :  std_logic_vector(1 downto 0);
signal qM3 :  std_logic_vector(1 downto 0);
signal qP2 :  std_logic_vector(1 downto 0);
signal qM2 :  std_logic_vector(1 downto 0);
signal qP1 :  std_logic_vector(1 downto 0);
signal qM1 :  std_logic_vector(1 downto 0);
signal qP0 :  std_logic_vector(1 downto 0);
signal qM0 :  std_logic_vector(1 downto 0);
signal qP :  std_logic_vector(35 downto 0);
signal qM :  std_logic_vector(35 downto 0);
signal fR0, fR0_d1 :  std_logic_vector(35 downto 0);
signal fR :  std_logic_vector(34 downto 0);
signal fRn1, fRn1_d1 :  std_logic_vector(32 downto 0);
signal expR1, expR1_d1 :  std_logic_vector(7 downto 0);
signal round, round_d1 :  std_logic;
signal expfrac :  std_logic_vector(38 downto 0);
signal expfracR :  std_logic_vector(38 downto 0);
signal exnR :  std_logic_vector(1 downto 0);
signal exnRfinal :  std_logic_vector(1 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            fY_d1 <=  fY;
            fY_d2 <=  fY_d1;
            fY_d3 <=  fY_d2;
            fY_d4 <=  fY_d3;
            fY_d5 <=  fY_d4;
            fY_d6 <=  fY_d5;
            expR0_d1 <=  expR0;
            expR0_d2 <=  expR0_d1;
            expR0_d3 <=  expR0_d2;
            expR0_d4 <=  expR0_d3;
            expR0_d5 <=  expR0_d4;
            expR0_d6 <=  expR0_d5;
            expR0_d7 <=  expR0_d6;
            expR0_d8 <=  expR0_d7;
            sR_d1 <=  sR;
            sR_d2 <=  sR_d1;
            sR_d3 <=  sR_d2;
            sR_d4 <=  sR_d3;
            sR_d5 <=  sR_d4;
            sR_d6 <=  sR_d5;
            sR_d7 <=  sR_d6;
            sR_d8 <=  sR_d7;
            sR_d9 <=  sR_d8;
            exnR0_d1 <=  exnR0;
            exnR0_d2 <=  exnR0_d1;
            exnR0_d3 <=  exnR0_d2;
            exnR0_d4 <=  exnR0_d3;
            exnR0_d5 <=  exnR0_d4;
            exnR0_d6 <=  exnR0_d5;
            exnR0_d7 <=  exnR0_d6;
            exnR0_d8 <=  exnR0_d7;
            exnR0_d9 <=  exnR0_d8;
            fYTimes3_d1 <=  fYTimes3;
            fYTimes3_d2 <=  fYTimes3_d1;
            fYTimes3_d3 <=  fYTimes3_d2;
            fYTimes3_d4 <=  fYTimes3_d3;
            fYTimes3_d5 <=  fYTimes3_d4;
            fYTimes3_d6 <=  fYTimes3_d5;
            w17_d1 <=  w17;
            q17_d1 <=  q17;
            q17_d2 <=  q17_d1;
            q17_d3 <=  q17_d2;
            q17_d4 <=  q17_d3;
            q17_d5 <=  q17_d4;
            q17_d6 <=  q17_d5;
            q16_d1 <=  q16;
            q16_d2 <=  q16_d1;
            q16_d3 <=  q16_d2;
            q16_d4 <=  q16_d3;
            q16_d5 <=  q16_d4;
            q16_d6 <=  q16_d5;
            w15_d1 <=  w15;
            q15_d1 <=  q15;
            q15_d2 <=  q15_d1;
            q15_d3 <=  q15_d2;
            q15_d4 <=  q15_d3;
            q15_d5 <=  q15_d4;
            q14_d1 <=  q14;
            q14_d2 <=  q14_d1;
            q14_d3 <=  q14_d2;
            q14_d4 <=  q14_d3;
            q14_d5 <=  q14_d4;
            q13_d1 <=  q13;
            q13_d2 <=  q13_d1;
            q13_d3 <=  q13_d2;
            q13_d4 <=  q13_d3;
            q13_d5 <=  q13_d4;
            w12_d1 <=  w12;
            q12_d1 <=  q12;
            q12_d2 <=  q12_d1;
            q12_d3 <=  q12_d2;
            q12_d4 <=  q12_d3;
            q11_d1 <=  q11;
            q11_d2 <=  q11_d1;
            q11_d3 <=  q11_d2;
            q11_d4 <=  q11_d3;
            q10_d1 <=  q10;
            q10_d2 <=  q10_d1;
            q10_d3 <=  q10_d2;
            q10_d4 <=  q10_d3;
            w9_d1 <=  w9;
            q9_d1 <=  q9;
            q9_d2 <=  q9_d1;
            q9_d3 <=  q9_d2;
            q8_d1 <=  q8;
            q8_d2 <=  q8_d1;
            q8_d3 <=  q8_d2;
            q7_d1 <=  q7;
            q7_d2 <=  q7_d1;
            q7_d3 <=  q7_d2;
            w6_d1 <=  w6;
            q6_d1 <=  q6;
            q6_d2 <=  q6_d1;
            q5_d1 <=  q5;
            q5_d2 <=  q5_d1;
            q4_d1 <=  q4;
            q4_d2 <=  q4_d1;
            w3_d1 <=  w3;
            q3_d1 <=  q3;
            q2_d1 <=  q2;
            q1_d1 <=  q1;
            w0_d1 <=  w0;
            fR0_d1 <=  fR0;
            fRn1_d1 <=  fRn1;
            expR1_d1 <=  expR1;
            round_d1 <=  round;
         end if;
      end process;
   fX <= "1" & X(30 downto 0);
   fY <= "1" & Y(30 downto 0);
   -- exponent difference, sign and exception combination computed early, to have less bits to pipeline
   expR0 <= ("00" & X(36 downto 31)) - ("00" & Y(36 downto 31));
   sR <= X(37) xor Y(37);
   -- early exception handling
   exnXY <= X(39 downto 38) & Y(39 downto 38);
   with exnXY select
      exnR0 <=
         "01"  when "0101",                   -- normal
         "00"  when "0001" | "0010" | "0110", -- zero
         "10"  when "0100" | "1000" | "1001", -- overflow
         "11"  when others;                   -- NaN
    -- compute 3Y
   fYTimes3 <= ("00" & fY) + ("0" & fY & "0");
   w17 <=  "00" & fX;
   ----------------Synchro barrier, entering cycle 1----------------
   sel17 <= w17_d1(33 downto 30) & fY_d1(30);
   with sel17 select
   q17 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q17 select
      q17D <=
         "000" & fY_d1            when "001" | "111",
         "00" & fY_d1 & "0"     when "010" | "110",
         "0" & fYTimes3_d1             when "011" | "101",
         (34 downto 0 => '0') when others;

   w17pad <= w17_d1 & "0";
   with q17(2) select
   w16full<= w17pad - q17D when '0',
         w17pad + q17D when others;

   w16 <= w16full(32 downto 0) & "0";
   sel16 <= w16(33 downto 30) & fY_d1(30);
   with sel16 select
   q16 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q16 select
      q16D <=
         "000" & fY_d1            when "001" | "111",
         "00" & fY_d1 & "0"     when "010" | "110",
         "0" & fYTimes3_d1             when "011" | "101",
         (34 downto 0 => '0') when others;

   w16pad <= w16 & "0";
   with q16(2) select
   w15full<= w16pad - q16D when '0',
         w16pad + q16D when others;

   w15 <= w15full(32 downto 0) & "0";
   ----------------Synchro barrier, entering cycle 2----------------
   sel15 <= w15_d1(33 downto 30) & fY_d2(30);
   with sel15 select
   q15 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q15 select
      q15D <=
         "000" & fY_d2            when "001" | "111",
         "00" & fY_d2 & "0"     when "010" | "110",
         "0" & fYTimes3_d2             when "011" | "101",
         (34 downto 0 => '0') when others;

   w15pad <= w15_d1 & "0";
   with q15(2) select
   w14full<= w15pad - q15D when '0',
         w15pad + q15D when others;

   w14 <= w14full(32 downto 0) & "0";
   sel14 <= w14(33 downto 30) & fY_d2(30);
   with sel14 select
   q14 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q14 select
      q14D <=
         "000" & fY_d2            when "001" | "111",
         "00" & fY_d2 & "0"     when "010" | "110",
         "0" & fYTimes3_d2             when "011" | "101",
         (34 downto 0 => '0') when others;

   w14pad <= w14 & "0";
   with q14(2) select
   w13full<= w14pad - q14D when '0',
         w14pad + q14D when others;

   w13 <= w13full(32 downto 0) & "0";
   sel13 <= w13(33 downto 30) & fY_d2(30);
   with sel13 select
   q13 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q13 select
      q13D <=
         "000" & fY_d2            when "001" | "111",
         "00" & fY_d2 & "0"     when "010" | "110",
         "0" & fYTimes3_d2             when "011" | "101",
         (34 downto 0 => '0') when others;

   w13pad <= w13 & "0";
   with q13(2) select
   w12full<= w13pad - q13D when '0',
         w13pad + q13D when others;

   w12 <= w12full(32 downto 0) & "0";
   ----------------Synchro barrier, entering cycle 3----------------
   sel12 <= w12_d1(33 downto 30) & fY_d3(30);
   with sel12 select
   q12 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q12 select
      q12D <=
         "000" & fY_d3            when "001" | "111",
         "00" & fY_d3 & "0"     when "010" | "110",
         "0" & fYTimes3_d3             when "011" | "101",
         (34 downto 0 => '0') when others;

   w12pad <= w12_d1 & "0";
   with q12(2) select
   w11full<= w12pad - q12D when '0',
         w12pad + q12D when others;

   w11 <= w11full(32 downto 0) & "0";
   sel11 <= w11(33 downto 30) & fY_d3(30);
   with sel11 select
   q11 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q11 select
      q11D <=
         "000" & fY_d3            when "001" | "111",
         "00" & fY_d3 & "0"     when "010" | "110",
         "0" & fYTimes3_d3             when "011" | "101",
         (34 downto 0 => '0') when others;

   w11pad <= w11 & "0";
   with q11(2) select
   w10full<= w11pad - q11D when '0',
         w11pad + q11D when others;

   w10 <= w10full(32 downto 0) & "0";
   sel10 <= w10(33 downto 30) & fY_d3(30);
   with sel10 select
   q10 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q10 select
      q10D <=
         "000" & fY_d3            when "001" | "111",
         "00" & fY_d3 & "0"     when "010" | "110",
         "0" & fYTimes3_d3             when "011" | "101",
         (34 downto 0 => '0') when others;

   w10pad <= w10 & "0";
   with q10(2) select
   w9full<= w10pad - q10D when '0',
         w10pad + q10D when others;

   w9 <= w9full(32 downto 0) & "0";
   ----------------Synchro barrier, entering cycle 4----------------
   sel9 <= w9_d1(33 downto 30) & fY_d4(30);
   with sel9 select
   q9 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q9 select
      q9D <=
         "000" & fY_d4            when "001" | "111",
         "00" & fY_d4 & "0"     when "010" | "110",
         "0" & fYTimes3_d4             when "011" | "101",
         (34 downto 0 => '0') when others;

   w9pad <= w9_d1 & "0";
   with q9(2) select
   w8full<= w9pad - q9D when '0',
         w9pad + q9D when others;

   w8 <= w8full(32 downto 0) & "0";
   sel8 <= w8(33 downto 30) & fY_d4(30);
   with sel8 select
   q8 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q8 select
      q8D <=
         "000" & fY_d4            when "001" | "111",
         "00" & fY_d4 & "0"     when "010" | "110",
         "0" & fYTimes3_d4             when "011" | "101",
         (34 downto 0 => '0') when others;

   w8pad <= w8 & "0";
   with q8(2) select
   w7full<= w8pad - q8D when '0',
         w8pad + q8D when others;

   w7 <= w7full(32 downto 0) & "0";
   sel7 <= w7(33 downto 30) & fY_d4(30);
   with sel7 select
   q7 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q7 select
      q7D <=
         "000" & fY_d4            when "001" | "111",
         "00" & fY_d4 & "0"     when "010" | "110",
         "0" & fYTimes3_d4             when "011" | "101",
         (34 downto 0 => '0') when others;

   w7pad <= w7 & "0";
   with q7(2) select
   w6full<= w7pad - q7D when '0',
         w7pad + q7D when others;

   w6 <= w6full(32 downto 0) & "0";
   ----------------Synchro barrier, entering cycle 5----------------
   sel6 <= w6_d1(33 downto 30) & fY_d5(30);
   with sel6 select
   q6 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q6 select
      q6D <=
         "000" & fY_d5            when "001" | "111",
         "00" & fY_d5 & "0"     when "010" | "110",
         "0" & fYTimes3_d5             when "011" | "101",
         (34 downto 0 => '0') when others;

   w6pad <= w6_d1 & "0";
   with q6(2) select
   w5full<= w6pad - q6D when '0',
         w6pad + q6D when others;

   w5 <= w5full(32 downto 0) & "0";
   sel5 <= w5(33 downto 30) & fY_d5(30);
   with sel5 select
   q5 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q5 select
      q5D <=
         "000" & fY_d5            when "001" | "111",
         "00" & fY_d5 & "0"     when "010" | "110",
         "0" & fYTimes3_d5             when "011" | "101",
         (34 downto 0 => '0') when others;

   w5pad <= w5 & "0";
   with q5(2) select
   w4full<= w5pad - q5D when '0',
         w5pad + q5D when others;

   w4 <= w4full(32 downto 0) & "0";
   sel4 <= w4(33 downto 30) & fY_d5(30);
   with sel4 select
   q4 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q4 select
      q4D <=
         "000" & fY_d5            when "001" | "111",
         "00" & fY_d5 & "0"     when "010" | "110",
         "0" & fYTimes3_d5             when "011" | "101",
         (34 downto 0 => '0') when others;

   w4pad <= w4 & "0";
   with q4(2) select
   w3full<= w4pad - q4D when '0',
         w4pad + q4D when others;

   w3 <= w3full(32 downto 0) & "0";
   ----------------Synchro barrier, entering cycle 6----------------
   sel3 <= w3_d1(33 downto 30) & fY_d6(30);
   with sel3 select
   q3 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q3 select
      q3D <=
         "000" & fY_d6            when "001" | "111",
         "00" & fY_d6 & "0"     when "010" | "110",
         "0" & fYTimes3_d6             when "011" | "101",
         (34 downto 0 => '0') when others;

   w3pad <= w3_d1 & "0";
   with q3(2) select
   w2full<= w3pad - q3D when '0',
         w3pad + q3D when others;

   w2 <= w2full(32 downto 0) & "0";
   sel2 <= w2(33 downto 30) & fY_d6(30);
   with sel2 select
   q2 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q2 select
      q2D <=
         "000" & fY_d6            when "001" | "111",
         "00" & fY_d6 & "0"     when "010" | "110",
         "0" & fYTimes3_d6             when "011" | "101",
         (34 downto 0 => '0') when others;

   w2pad <= w2 & "0";
   with q2(2) select
   w1full<= w2pad - q2D when '0',
         w2pad + q2D when others;

   w1 <= w1full(32 downto 0) & "0";
   sel1 <= w1(33 downto 30) & fY_d6(30);
   with sel1 select
   q1 <=
      "001" when "00010" | "00011",
      "010" when "00100" | "00101" | "00111",
      "011" when "00110" | "01000" | "01001" | "01010" | "01011" | "01101" | "01111",
      "101" when "11000" | "10110" | "10111" | "10100" | "10101" | "10011" | "10001",
      "110" when "11010" | "11011" | "11001",
      "111" when "11100" | "11101",
      "000" when others;

   with q1 select
      q1D <=
         "000" & fY_d6            when "001" | "111",
         "00" & fY_d6 & "0"     when "010" | "110",
         "0" & fYTimes3_d6             when "011" | "101",
         (34 downto 0 => '0') when others;

   w1pad <= w1 & "0";
   with q1(2) select
   w0full<= w1pad - q1D when '0',
         w1pad + q1D when others;

   w0 <= w0full(32 downto 0) & "0";
   ----------------Synchro barrier, entering cycle 7----------------
   q0(2 downto 0) <= "000" when  w0_d1 = (33 downto 0 => '0')
                else w0_d1(33) & "10";
   qP17 <=      q17_d6(1 downto 0);
   qM17 <=      q17_d6(2) & "0";
   qP16 <=      q16_d6(1 downto 0);
   qM16 <=      q16_d6(2) & "0";
   qP15 <=      q15_d5(1 downto 0);
   qM15 <=      q15_d5(2) & "0";
   qP14 <=      q14_d5(1 downto 0);
   qM14 <=      q14_d5(2) & "0";
   qP13 <=      q13_d5(1 downto 0);
   qM13 <=      q13_d5(2) & "0";
   qP12 <=      q12_d4(1 downto 0);
   qM12 <=      q12_d4(2) & "0";
   qP11 <=      q11_d4(1 downto 0);
   qM11 <=      q11_d4(2) & "0";
   qP10 <=      q10_d4(1 downto 0);
   qM10 <=      q10_d4(2) & "0";
   qP9 <=      q9_d3(1 downto 0);
   qM9 <=      q9_d3(2) & "0";
   qP8 <=      q8_d3(1 downto 0);
   qM8 <=      q8_d3(2) & "0";
   qP7 <=      q7_d3(1 downto 0);
   qM7 <=      q7_d3(2) & "0";
   qP6 <=      q6_d2(1 downto 0);
   qM6 <=      q6_d2(2) & "0";
   qP5 <=      q5_d2(1 downto 0);
   qM5 <=      q5_d2(2) & "0";
   qP4 <=      q4_d2(1 downto 0);
   qM4 <=      q4_d2(2) & "0";
   qP3 <=      q3_d1(1 downto 0);
   qM3 <=      q3_d1(2) & "0";
   qP2 <=      q2_d1(1 downto 0);
   qM2 <=      q2_d1(2) & "0";
   qP1 <=      q1_d1(1 downto 0);
   qM1 <=      q1_d1(2) & "0";
   qP0 <= q0(1 downto 0);
   qM0 <= q0(2)  & "0";
   qP <= qP17 & qP16 & qP15 & qP14 & qP13 & qP12 & qP11 & qP10 & qP9 & qP8 & qP7 & qP6 & qP5 & qP4 & qP3 & qP2 & qP1 & qP0;
   qM <= qM17(0) & qM16 & qM15 & qM14 & qM13 & qM12 & qM11 & qM10 & qM9 & qM8 & qM7 & qM6 & qM5 & qM4 & qM3 & qM2 & qM1 & qM0 & "0";
   fR0 <= qP - qM;
   ----------------Synchro barrier, entering cycle 8----------------
   fR <= fR0_d1(35 downto 1);  -- odd wF
   -- normalisation
   with fR(34) select
      fRn1 <= fR(33 downto 2) & (fR(1) or fR(0)) when '1',
              fR(32 downto 0)                    when others;
   expR1 <= expR0_d8 + ("000" & (4 downto 1 => '1') & fR(34)); -- add back bias
   round <= fRn1(1) and (fRn1(2) or fRn1(0)); -- fRn1(0) is the sticky bit
   ----------------Synchro barrier, entering cycle 9----------------
   -- final rounding
   expfrac <= expR1_d1 & fRn1_d1(32 downto 2) ;
   expfracR <= expfrac + ((38 downto 1 => '0') & round_d1);
   exnR <=      "00"  when expfracR(38) = '1'   -- underflow
           else "10"  when  expfracR(38 downto 37) =  "01" -- overflow
           else "01";      -- 00, normal case
   with exnR0_d9 select
      exnRfinal <=
         exnR   when "01", -- normal
         exnR0_d9  when others;
   R <= exnRfinal & sR_d9 & expfracR(36 downto 0);
end architecture;
