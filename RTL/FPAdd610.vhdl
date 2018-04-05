-- FPAdd610.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ ./flopoco -name=FPAdd610 -frequency=120 -useHardMult=no FPAdd 6 10
-- Updating entity name to: FPAdd610
-- 
-- Final report:
-- |---Entity FPAdd_6_10_uid2_RightShifter
-- |      Not pipelined
-- |---Entity IntAdder_14_f120_uid7
-- |      Not pipelined
-- |---Entity LZCShifter_15_to_15_counting_16_uid14
-- |      Pipeline depth = 1
-- |---Entity IntAdder_19_f120_uid17
-- |      Not pipelined
-- Entity FAdd610
--    Pipeline depth = 2
-- Output file: flopoco.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ cat flopoco.vhdl
--------------------------------------------------------------------------------
--                        FPAdd_6_10_uid2_RightShifter
--                      (RightShifter_11_by_max_13_uid4)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2011)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPAdd_6_10_uid2_RightShifter is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(10 downto 0);
          S : in  std_logic_vector(3 downto 0);
          R : out  std_logic_vector(23 downto 0)   );
end entity;

architecture arch of FPAdd_6_10_uid2_RightShifter is
signal level0 :  std_logic_vector(10 downto 0);
signal ps :  std_logic_vector(3 downto 0);
signal level1 :  std_logic_vector(11 downto 0);
signal level2 :  std_logic_vector(13 downto 0);
signal level3 :  std_logic_vector(17 downto 0);
signal level4 :  std_logic_vector(25 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   level0<= X;
   ps<= S;
   level1<=  (0 downto 0 => '0') & level0 when ps(0) = '1' else    level0 & (0 downto 0 => '0');
   level2<=  (1 downto 0 => '0') & level1 when ps(1) = '1' else    level1 & (1 downto 0 => '0');
   level3<=  (3 downto 0 => '0') & level2 when ps(2) = '1' else    level2 & (3 downto 0 => '0');
   level4<=  (7 downto 0 => '0') & level3 when ps(3) = '1' else    level3 & (7 downto 0 => '0');
   R <= level4(25 downto 2);
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_14_f120_uid7
--                    (IntAdderAlternative_14_f120_uid11)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_14_f120_uid7 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(13 downto 0);
          Y : in  std_logic_vector(13 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(13 downto 0)   );
end entity;

architecture arch of IntAdder_14_f120_uid7 is
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   --Alternative
    R <= X + Y + Cin;
end architecture;

--------------------------------------------------------------------------------
--                   LZCShifter_15_to_15_counting_16_uid14
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Florent de Dinechin, Bogdan Pasca (2007)
--------------------------------------------------------------------------------
-- Pipeline depth: 1 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LZCShifter_15_to_15_counting_16_uid14 is
   port ( clk, rst : in std_logic;
          I : in  std_logic_vector(14 downto 0);
          Count : out  std_logic_vector(3 downto 0);
          O : out  std_logic_vector(14 downto 0)   );
end entity;

architecture arch of LZCShifter_15_to_15_counting_16_uid14 is
signal level4 :  std_logic_vector(14 downto 0);
signal count3, count3_d1 :  std_logic;
signal level3 :  std_logic_vector(14 downto 0);
signal count2, count2_d1 :  std_logic;
signal level2 :  std_logic_vector(14 downto 0);
signal count1, count1_d1 :  std_logic;
signal level1, level1_d1 :  std_logic_vector(14 downto 0);
signal count0, count0_d1 :  std_logic;
signal level0 :  std_logic_vector(14 downto 0);
signal sCount :  std_logic_vector(3 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            count3_d1 <=  count3;
            count2_d1 <=  count2;
            count1_d1 <=  count1;
            level1_d1 <=  level1;
            count0_d1 <=  count0;
         end if;
      end process;
   level4 <= I ;
   count3<= '1' when level4(14 downto 7) = (14 downto 7=>'0') else '0';
   level3<= level4(14 downto 0) when count3='0' else level4(6 downto 0) & (7 downto 0 => '0');

   count2<= '1' when level3(14 downto 11) = (14 downto 11=>'0') else '0';
   level2<= level3(14 downto 0) when count2='0' else level3(10 downto 0) & (3 downto 0 => '0');

   count1<= '1' when level2(14 downto 13) = (14 downto 13=>'0') else '0';
   level1<= level2(14 downto 0) when count1='0' else level2(12 downto 0) & (1 downto 0 => '0');

   count0<= '1' when level1(14 downto 14) = (14 downto 14=>'0') else '0';
   ----------------Synchro barrier, entering cycle 1----------------
   level0<= level1_d1(14 downto 0) when count0_d1='0' else level1_d1(13 downto 0) & (0 downto 0 => '0');

   O <= level0;
   sCount <= count3_d1 & count2_d1 & count1_d1 & count0_d1;
   Count <= sCount;
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_19_f120_uid17
--                    (IntAdderAlternative_19_f120_uid21)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_19_f120_uid17 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(18 downto 0);
          Y : in  std_logic_vector(18 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(18 downto 0)   );
end entity;

architecture arch of IntAdder_19_f120_uid17 is
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   --Alternative
    R <= X + Y + Cin;
end architecture;

--------------------------------------------------------------------------------
--                                FPAdd610
--                             (FPAdd_6_10_uid2)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Pasca, Florent de Dinechin (2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPAdd610 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(6+10+2 downto 0);
          Y : in  std_logic_vector(6+10+2 downto 0);
          R : out std_logic_vector(6+10+2 downto 0);
        grd : out std_logic;    --mod by JDH 12/7/2017
        rnd : out std_logic;
        stk : out std_logic;                 
 addToRoundBit : in std_logic );
end entity;

architecture arch of FPAdd610 is
   component FPAdd_6_10_uid2_RightShifter is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(10 downto 0);
             S : in  std_logic_vector(3 downto 0);
             R : out  std_logic_vector(23 downto 0)   );
   end component;

   component IntAdder_14_f120_uid7 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(13 downto 0);
             Y : in  std_logic_vector(13 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(13 downto 0)   );
   end component;

   component IntAdder_19_f120_uid17 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(18 downto 0);
             Y : in  std_logic_vector(18 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(18 downto 0)   );
   end component;

   component LZCShifter_15_to_15_counting_16_uid14 is
      port ( clk, rst : in std_logic;
             I : in  std_logic_vector(14 downto 0);
             Count : out  std_logic_vector(3 downto 0);
             O : out  std_logic_vector(14 downto 0)   );
   end component;

signal excExpFracX :  std_logic_vector(17 downto 0);
signal excExpFracY :  std_logic_vector(17 downto 0);
signal eXmeY :  std_logic_vector(6 downto 0);
signal eYmeX :  std_logic_vector(6 downto 0);
signal swap :  std_logic;
signal newX, newX_d1 :  std_logic_vector(18 downto 0);
signal newY :  std_logic_vector(18 downto 0);
signal expX, expX_d1 :  std_logic_vector(5 downto 0);
signal excX :  std_logic_vector(1 downto 0);
signal excY :  std_logic_vector(1 downto 0);
signal signX :  std_logic;
signal signY :  std_logic;
signal EffSub, EffSub_d1, EffSub_d2 :  std_logic;
signal sXsYExnXY :  std_logic_vector(5 downto 0);
signal sdExnXY :  std_logic_vector(3 downto 0);
signal fracY :  std_logic_vector(10 downto 0);
signal excRt, excRt_d1, excRt_d2 :  std_logic_vector(1 downto 0);
signal signR, signR_d1, signR_d2 :  std_logic;
signal expDiff :  std_logic_vector(6 downto 0);
signal shiftedOut :  std_logic;
signal shiftVal :  std_logic_vector(3 downto 0);
signal shiftedFracY, shiftedFracY_d1 :  std_logic_vector(23 downto 0);
signal sticky :  std_logic;
signal fracYfar :  std_logic_vector(13 downto 0);
signal EffSubVector :  std_logic_vector(13 downto 0);
signal fracYfarXorOp :  std_logic_vector(13 downto 0);
signal fracXfar :  std_logic_vector(13 downto 0);
signal cInAddFar :  std_logic;
signal fracAddResult :  std_logic_vector(13 downto 0);
signal fracGRS :  std_logic_vector(14 downto 0);
signal extendedExpInc, extendedExpInc_d1 :  std_logic_vector(7 downto 0);
signal nZerosNew :  std_logic_vector(3 downto 0);
signal shiftedFrac :  std_logic_vector(14 downto 0);
signal updatedExp :  std_logic_vector(7 downto 0);
signal eqdiffsign :  std_logic;
signal expFrac :  std_logic_vector(18 downto 0);
--signal stk :  std_logic;
--signal rnd :  std_logic;
--signal grd :  std_logic;
signal lsb :  std_logic;
--signal addToRoundBit :  std_logic;
signal RoundedExpFrac :  std_logic_vector(18 downto 0);
signal upExc :  std_logic_vector(1 downto 0);
signal fracR :  std_logic_vector(9 downto 0);
signal expR :  std_logic_vector(5 downto 0);
signal exExpExc :  std_logic_vector(3 downto 0);
signal excRt2 :  std_logic_vector(1 downto 0);
signal excR :  std_logic_vector(1 downto 0);
signal signR2 :  std_logic;
signal computedR :  std_logic_vector(18 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            newX_d1 <=  newX;
            expX_d1 <=  expX;
            EffSub_d1 <=  EffSub;
            EffSub_d2 <=  EffSub_d1;
            excRt_d1 <=  excRt;
            excRt_d2 <=  excRt_d1;
            signR_d1 <=  signR;
            signR_d2 <=  signR_d1;
            shiftedFracY_d1 <=  shiftedFracY;
            extendedExpInc_d1 <=  extendedExpInc;
         end if;
      end process;
-- Exponent difference and swap  --
   excExpFracX <= X(18 downto 17) & X(15 downto 0);
   excExpFracY <= Y(18 downto 17) & Y(15 downto 0);
   eXmeY <= ("0" & X(15 downto 10)) - ("0" & Y(15 downto 10));
   eYmeX <= ("0" & Y(15 downto 10)) - ("0" & X(15 downto 10));
   swap <= '0' when excExpFracX >= excExpFracY else '1';
   newX <= X when swap = '0' else Y;
   newY <= Y when swap = '0' else X;
   expX<= newX(15 downto 10);
   excX<= newX(18 downto 17);
   excY<= newY(18 downto 17);
   signX<= newX(16);
   signY<= newY(16);
   EffSub <= signX xor signY;
   sXsYExnXY <= signX & signY & excX & excY;
   sdExnXY <= excX & excY;
   fracY <= "00000000000" when excY="00" else ('1' & newY(9 downto 0));
   with sXsYExnXY select
   excRt <= "00" when "000000"|"010000"|"100000"|"110000",
      "01" when "000101"|"010101"|"100101"|"110101"|"000100"|"010100"|"100100"|"110100"|"000001"|"010001"|"100001"|"110001",
      "10" when "111010"|"001010"|"001000"|"011000"|"101000"|"111000"|"000010"|"010010"|"100010"|"110010"|"001001"|"011001"|"101001"|"111001"|"000110"|"010110"|"100110"|"110110",
      "11" when others;
   signR<= '0' when (sXsYExnXY="100000" or sXsYExnXY="010000") else signX;
   ---------------- cycle 0----------------
   expDiff <= eXmeY when swap = '0' else eYmeX;
   shiftedOut <= '1' when (expDiff >= 12) else '0';
   shiftVal <= expDiff(3 downto 0) when shiftedOut='0' else CONV_STD_LOGIC_VECTOR(13,4) ;
   RightShifterComponent: FPAdd_6_10_uid2_RightShifter  -- pipelineDepth=0 maxInDelay=3.21688e-09
      port map ( clk  => clk,
                 rst  => rst,
                 R => shiftedFracY,
                 S => shiftVal,
                 X => fracY);
   ----------------Synchro barrier, entering cycle 1----------------
   sticky <= '0' when (shiftedFracY_d1(10 downto 0)=CONV_STD_LOGIC_VECTOR(0,10)) else '1';
   ---------------- cycle 0----------------
   ----------------Synchro barrier, entering cycle 1----------------
   fracYfar <= "0" & shiftedFracY_d1(23 downto 11);
   EffSubVector <= (13 downto 0 => EffSub_d1);
   fracYfarXorOp <= fracYfar xor EffSubVector;
   fracXfar <= "01" & (newX_d1(9 downto 0)) & "00";
   cInAddFar <= EffSub_d1 and not sticky;
   fracAdder: IntAdder_14_f120_uid7  -- pipelineDepth=0 maxInDelay=1.41244e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => cInAddFar,
                 R => fracAddResult,
                 X => fracXfar,
                 Y => fracYfarXorOp);
   fracGRS<= fracAddResult & sticky;
   extendedExpInc<= ("00" & expX_d1) + '1';
   LZC_component: LZCShifter_15_to_15_counting_16_uid14  -- pipelineDepth=1 maxInDelay=2.40244e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Count => nZerosNew,
                 I => fracGRS,
                 O => shiftedFrac);
   ----------------Synchro barrier, entering cycle 2----------------
   updatedExp <= extendedExpInc_d1 - ("0000" & nZerosNew);
   eqdiffsign <= '1' when nZerosNew="1111" else '0';
   expFrac<= updatedExp & shiftedFrac(13 downto 3);
   ---------------- cycle 2----------------
   stk<= shiftedFrac(1) or shiftedFrac(0);
   rnd<= shiftedFrac(2);
   grd<= shiftedFrac(3);
--   lsb<= shiftedFrac(4);
   --addToRoundBit<= '0' when (lsb='0' and grd='1' and rnd='0' and stk='0')  else '1';  --mod by JDH 12/7/2017
   roundingAdder: IntAdder_19_f120_uid17  -- pipelineDepth=0 maxInDelay=1.29672e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => addToRoundBit,
                 R => RoundedExpFrac,
                 X => expFrac,
                 Y => "0000000000000000000");
   ---------------- cycle 2----------------
   upExc <= RoundedExpFrac(18 downto 17);
   fracR <= RoundedExpFrac(10 downto 1);
   expR <= RoundedExpFrac(16 downto 11);
   exExpExc <= upExc & excRt_d2;
   with (exExpExc) select
   excRt2<= "00" when "0000"|"0100"|"1000"|"1100"|"1001"|"1101",
      "01" when "0001",
      "10" when "0010"|"0110"|"1010"|"1110"|"0101",
      "11" when others;
   excR <= "00" when (eqdiffsign='1' and EffSub_d2='1') else excRt2;
   signR2 <= '0' when (eqdiffsign='1' and EffSub_d2='1') else signR_d2;
   computedR <= excR & signR2 & expR & fracR;
   R <= computedR;
end architecture;
