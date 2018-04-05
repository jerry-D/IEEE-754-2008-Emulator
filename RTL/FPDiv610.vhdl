-- FPDiv610.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ ./flopoco -name=FPDiv610 -frequency=120 -useHardMult=no FPDiv 6 10
-- Updating entity name to: FPDiv610
-- 
-- Final report:
-- Entity FPDiv610
--    Pipeline depth = 5
-- Output file: flopoco.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ cat flopoco.vhdl
--------------------------------------------------------------------------------
--                                  FPDiv610
--                                (FPDiv_6_10)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors:
--------------------------------------------------------------------------------
-- Pipeline depth: 5 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPDiv610 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(6+10+2 downto 0);
          Y : in  std_logic_vector(6+10+2 downto 0);
          R : out  std_logic_vector(6+10+2 downto 0);   
   IEEEg_d1 : out std_logic;
   IEEEr_d1 : out std_logic;
   IEEEs_d1 : out std_logic;
    roundit : in std_logic  );
end entity;

architecture arch of FPDiv610 is
signal fX :  std_logic_vector(10 downto 0);
signal fY, fY_d1, fY_d2 :  std_logic_vector(10 downto 0);
signal expR0, expR0_d1, expR0_d2, expR0_d3, expR0_d4 :  std_logic_vector(7 downto 0);
signal sR, sR_d1, sR_d2, sR_d3, sR_d4, sR_d5 :  std_logic;
signal exnXY :  std_logic_vector(3 downto 0);
signal exnR0, exnR0_d1, exnR0_d2, exnR0_d3, exnR0_d4, exnR0_d5 :  std_logic_vector(1 downto 0);
signal fYTimes3, fYTimes3_d1, fYTimes3_d2 :  std_logic_vector(12 downto 0);
signal w7, w7_d1 :  std_logic_vector(12 downto 0);
signal sel7 :  std_logic_vector(4 downto 0);
signal q7, q7_d1, q7_d2 :  std_logic_vector(2 downto 0);
signal q7D :  std_logic_vector(13 downto 0);
signal w7pad :  std_logic_vector(13 downto 0);
signal w6full :  std_logic_vector(13 downto 0);
signal w6 :  std_logic_vector(12 downto 0);
signal sel6 :  std_logic_vector(4 downto 0);
signal q6, q6_d1, q6_d2 :  std_logic_vector(2 downto 0);
signal q6D :  std_logic_vector(13 downto 0);
signal w6pad :  std_logic_vector(13 downto 0);
signal w5full :  std_logic_vector(13 downto 0);
signal w5 :  std_logic_vector(12 downto 0);
signal sel5 :  std_logic_vector(4 downto 0);
signal q5, q5_d1, q5_d2 :  std_logic_vector(2 downto 0);
signal q5D :  std_logic_vector(13 downto 0);
signal w5pad :  std_logic_vector(13 downto 0);
signal w4full :  std_logic_vector(13 downto 0);
signal w4, w4_d1 :  std_logic_vector(12 downto 0);
signal sel4 :  std_logic_vector(4 downto 0);
signal q4, q4_d1 :  std_logic_vector(2 downto 0);
signal q4D :  std_logic_vector(13 downto 0);
signal w4pad :  std_logic_vector(13 downto 0);
signal w3full :  std_logic_vector(13 downto 0);
signal w3 :  std_logic_vector(12 downto 0);
signal sel3 :  std_logic_vector(4 downto 0);
signal q3, q3_d1 :  std_logic_vector(2 downto 0);
signal q3D :  std_logic_vector(13 downto 0);
signal w3pad :  std_logic_vector(13 downto 0);
signal w2full :  std_logic_vector(13 downto 0);
signal w2 :  std_logic_vector(12 downto 0);
signal sel2 :  std_logic_vector(4 downto 0);
signal q2, q2_d1 :  std_logic_vector(2 downto 0);
signal q2D :  std_logic_vector(13 downto 0);
signal w2pad :  std_logic_vector(13 downto 0);
signal w1full :  std_logic_vector(13 downto 0);
signal w1 :  std_logic_vector(12 downto 0);
signal sel1 :  std_logic_vector(4 downto 0);
signal q1, q1_d1 :  std_logic_vector(2 downto 0);
signal q1D :  std_logic_vector(13 downto 0);
signal w1pad :  std_logic_vector(13 downto 0);
signal w0full :  std_logic_vector(13 downto 0);
signal w0, w0_d1 :  std_logic_vector(12 downto 0);
signal q0 :  std_logic_vector(2 downto 0);
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
signal qP :  std_logic_vector(15 downto 0);
signal qM :  std_logic_vector(15 downto 0);
signal fR0, fR0_d1 :  std_logic_vector(15 downto 0);
signal fR :  std_logic_vector(13 downto 0);
signal fRn1, fRn1_d1 :  std_logic_vector(11 downto 0);
signal expR1, expR1_d1 :  std_logic_vector(7 downto 0);
signal round, round_d1 :  std_logic;
--signal roundit, round_d1 :  std_logic;   -- mod by JDH 12/7/2017
signal expfrac :  std_logic_vector(17 downto 0);
signal expfracR :  std_logic_vector(17 downto 0);
signal exnR :  std_logic_vector(1 downto 0);
signal exnRfinal :  std_logic_vector(1 downto 0);
signal IEEEg, IEEEr, IEEEs : std_logic;    -- mod by JDH 12/7/2017
--signal IEEEg_d1, IEEEr_d1, IEEEs_d1 : std_logic;    -- mod by JDH 12/7/2017
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            fY_d1 <=  fY;
            fY_d2 <=  fY_d1;
            expR0_d1 <=  expR0;
            expR0_d2 <=  expR0_d1;
            expR0_d3 <=  expR0_d2;
            expR0_d4 <=  expR0_d3;
            sR_d1 <=  sR;
            sR_d2 <=  sR_d1;
            sR_d3 <=  sR_d2;
            sR_d4 <=  sR_d3;
            sR_d5 <=  sR_d4;
            exnR0_d1 <=  exnR0;
            exnR0_d2 <=  exnR0_d1;
            exnR0_d3 <=  exnR0_d2;
            exnR0_d4 <=  exnR0_d3;
            exnR0_d5 <=  exnR0_d4;
            fYTimes3_d1 <=  fYTimes3;
            fYTimes3_d2 <=  fYTimes3_d1;
            w7_d1 <=  w7;
            q7_d1 <=  q7;
            q7_d2 <=  q7_d1;
            q6_d1 <=  q6;
            q6_d2 <=  q6_d1;
            q5_d1 <=  q5;
            q5_d2 <=  q5_d1;
            w4_d1 <=  w4;
            q4_d1 <=  q4;
            q3_d1 <=  q3;
            q2_d1 <=  q2;
            q1_d1 <=  q1;
            w0_d1 <=  w0;
            fR0_d1 <=  fR0;
            fRn1_d1 <=  fRn1;
            expR1_d1 <=  expR1;
--            round_d1 <=  round;
            round_d1 <=  roundit;  -- mod by JDH 12/7/2017
            IEEEg_d1 <= IEEEg; 
            IEEEr_d1 <= IEEEr;
            IEEEs_d1 <= IEEEs; 
         end if;
      end process;
   fX <= "1" & X(9 downto 0);
   fY <= "1" & Y(9 downto 0);
   -- exponent difference, sign and exception combination computed early, to have less bits to pipeline
   expR0 <= ("00" & X(15 downto 10)) - ("00" & Y(15 downto 10));
   sR <= X(16) xor Y(16);
   -- early exception handling
   exnXY <= X(18 downto 17) & Y(18 downto 17);
   with exnXY select
      exnR0 <=
         "01"  when "0101",                   -- normal
         "00"  when "0001" | "0010" | "0110", -- zero
         "10"  when "0100" | "1000" | "1001", -- overflow
         "11"  when others;                   -- NaN
    -- compute 3Y
   fYTimes3 <= ("00" & fY) + ("0" & fY & "0");
   w7 <=  "00" & fX;
   ----------------Synchro barrier, entering cycle 1----------------
   sel7 <= w7_d1(12 downto 9) & fY_d1(9);
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
         "000" & fY_d1            when "001" | "111",
         "00" & fY_d1 & "0"     when "010" | "110",
         "0" & fYTimes3_d1             when "011" | "101",
         (13 downto 0 => '0') when others;

   w7pad <= w7_d1 & "0";
   with q7(2) select
   w6full<= w7pad - q7D when '0',
         w7pad + q7D when others;

   w6 <= w6full(11 downto 0) & "0";
   sel6 <= w6(12 downto 9) & fY_d1(9);
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
         "000" & fY_d1            when "001" | "111",
         "00" & fY_d1 & "0"     when "010" | "110",
         "0" & fYTimes3_d1             when "011" | "101",
         (13 downto 0 => '0') when others;

   w6pad <= w6 & "0";
   with q6(2) select
   w5full<= w6pad - q6D when '0',
         w6pad + q6D when others;

   w5 <= w5full(11 downto 0) & "0";
   sel5 <= w5(12 downto 9) & fY_d1(9);
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
         "000" & fY_d1            when "001" | "111",
         "00" & fY_d1 & "0"     when "010" | "110",
         "0" & fYTimes3_d1             when "011" | "101",
         (13 downto 0 => '0') when others;

   w5pad <= w5 & "0";
   with q5(2) select
   w4full<= w5pad - q5D when '0',
         w5pad + q5D when others;

   w4 <= w4full(11 downto 0) & "0";
   ----------------Synchro barrier, entering cycle 2----------------
   sel4 <= w4_d1(12 downto 9) & fY_d2(9);
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
         "000" & fY_d2            when "001" | "111",
         "00" & fY_d2 & "0"     when "010" | "110",
         "0" & fYTimes3_d2             when "011" | "101",
         (13 downto 0 => '0') when others;

   w4pad <= w4_d1 & "0";
   with q4(2) select
   w3full<= w4pad - q4D when '0',
         w4pad + q4D when others;

   w3 <= w3full(11 downto 0) & "0";
   sel3 <= w3(12 downto 9) & fY_d2(9);
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
         "000" & fY_d2            when "001" | "111",
         "00" & fY_d2 & "0"     when "010" | "110",
         "0" & fYTimes3_d2             when "011" | "101",
         (13 downto 0 => '0') when others;

   w3pad <= w3 & "0";
   with q3(2) select
   w2full<= w3pad - q3D when '0',
         w3pad + q3D when others;

   w2 <= w2full(11 downto 0) & "0";
   sel2 <= w2(12 downto 9) & fY_d2(9);
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
         "000" & fY_d2            when "001" | "111",
         "00" & fY_d2 & "0"     when "010" | "110",
         "0" & fYTimes3_d2             when "011" | "101",
         (13 downto 0 => '0') when others;

   w2pad <= w2 & "0";
   with q2(2) select
   w1full<= w2pad - q2D when '0',
         w2pad + q2D when others;

   w1 <= w1full(11 downto 0) & "0";
   sel1 <= w1(12 downto 9) & fY_d2(9);
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
         "000" & fY_d2            when "001" | "111",
         "00" & fY_d2 & "0"     when "010" | "110",
         "0" & fYTimes3_d2             when "011" | "101",
         (13 downto 0 => '0') when others;

   w1pad <= w1 & "0";
   with q1(2) select
   w0full<= w1pad - q1D when '0',
         w1pad + q1D when others;

   w0 <= w0full(11 downto 0) & "0";
   ----------------Synchro barrier, entering cycle 3----------------
   q0(2 downto 0) <= "000" when  w0_d1 = (12 downto 0 => '0')
                else w0_d1(12) & "10";
   qP7 <=      q7_d2(1 downto 0);
   qM7 <=      q7_d2(2) & "0";
   qP6 <=      q6_d2(1 downto 0);
   qM6 <=      q6_d2(2) & "0";
   qP5 <=      q5_d2(1 downto 0);
   qM5 <=      q5_d2(2) & "0";
   qP4 <=      q4_d1(1 downto 0);
   qM4 <=      q4_d1(2) & "0";
   qP3 <=      q3_d1(1 downto 0);
   qM3 <=      q3_d1(2) & "0";
   qP2 <=      q2_d1(1 downto 0);
   qM2 <=      q2_d1(2) & "0";
   qP1 <=      q1_d1(1 downto 0);
   qM1 <=      q1_d1(2) & "0";
   qP0 <= q0(1 downto 0);
   qM0 <= q0(2)  & "0";
   qP <= qP7 & qP6 & qP5 & qP4 & qP3 & qP2 & qP1 & qP0;
   qM <= qM7(0) & qM6 & qM5 & qM4 & qM3 & qM2 & qM1 & qM0 & "0";
   fR0 <= qP - qM;
   ----------------Synchro barrier, entering cycle 4----------------
   fR <= fR0_d1(15 downto 3)  & (fR0_d1(2) or fR0_d1(1));  -- even wF, fixing the round bit   
   -- normalisation
   with fR(13) select
      fRn1 <= fR(12 downto 2) & (fR(1) or fR(0)) when '1',         
              fR(11 downto 0)                    when others;      
   expR1 <= expR0_d4 + ("000" & (4 downto 1 => '1') & fR(13)); -- add back bias
   
   --::::::::::::::::::::::::::::::::::::::this part added to support directed rounding externally::::::::::::::::::::::::  
   --round <= fRn1(1) and (fRn1(2) or fRn1(0)); -- fRn1(0) is the sticky bit       -- mod by JDH 12/7/2017
--    with fR(13) select lsb   <= fR0_d1(5) when '1' fR0_d1(4) when others;          -- lsb
    with fR(13) select IEEEg <= fR0_d1(4) when '1', fR0_d1(3) when others;          -- guard bit
    with fR(13) select IEEEr <= fR0_d1(3) when '1', fR0_d1(2) when others;          -- round bit
    with fR(13) select IEEEs <= (fR0_d1(2) or fR0_d1(1) or fR0_d1(0)) when '1', (fR0_d1(1) or fR0_d1(0)) when others;  -- sticky bit
  --:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
  
   ----------------Synchro barrier, entering cycle 5----------------
   -- final rounding
   expfrac <= expR1_d1 & fRn1_d1(11 downto 2) ;
   expfracR <= expfrac + ((17 downto 1 => '0') & round_d1);
   exnR <=      "00"  when expfracR(17) = '1'   -- underflow
           else "10"  when  expfracR(17 downto 16) =  "01" -- overflow
           else "01";      -- 00, normal case
   with exnR0_d5 select
      exnRfinal <=
         exnR   when "01", -- normal
         exnR0_d5  when others;
   R <= exnRfinal & sR_d5 & expfracR(15 downto 0);
end architecture;
