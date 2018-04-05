-- FP610_To_FXP.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ ./flopoco -name=FP610_To_FXP -frequency=120 -useHardMult=no FP2Fix 6 10 1 16 0 0
-- Updating entity name to: FP610_To_FXP
-- 
-- Final report:
-- |---Entity FP2Fix_6_10_0_16_S_NTExponent_difference
-- |      Not pipelined
-- |---Entity LeftShifter_11_by_max_19_uid10
-- |      Not pipelined
-- |---Entity FP2Fix_6_10_0_16_S_NTMantSum
-- |      Not pipelined
-- Entity FP610_To_FXP
--    Not pipelined
-- Output file: flopoco.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ cat flopoco.vhdl
--------------------------------------------------------------------------------
--                  FP2Fix_6_10_0_16_S_NTExponent_difference
--                           (IntAdder_6_f120_uid3)
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

entity FP2Fix_6_10_0_16_S_NTExponent_difference is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(5 downto 0);
          Y : in  std_logic_vector(5 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(5 downto 0)   );
end entity;

architecture arch of FP2Fix_6_10_0_16_S_NTExponent_difference is
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
--                       LeftShifter_11_by_max_19_uid10
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

entity LeftShifter_11_by_max_19_uid10 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(10 downto 0);
          S : in  std_logic_vector(4 downto 0);
          R : out  std_logic_vector(29 downto 0)   );
end entity;

architecture arch of LeftShifter_11_by_max_19_uid10 is
signal level0 :  std_logic_vector(10 downto 0);
signal ps :  std_logic_vector(4 downto 0);
signal level1 :  std_logic_vector(11 downto 0);
signal level2 :  std_logic_vector(13 downto 0);
signal level3 :  std_logic_vector(17 downto 0);
signal level4 :  std_logic_vector(25 downto 0);
signal level5 :  std_logic_vector(41 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   level0<= X;
   ps<= S;
   level1<= level0 & (0 downto 0 => '0') when ps(0)= '1' else     (0 downto 0 => '0') & level0;
   level2<= level1 & (1 downto 0 => '0') when ps(1)= '1' else     (1 downto 0 => '0') & level1;
   level3<= level2 & (3 downto 0 => '0') when ps(2)= '1' else     (3 downto 0 => '0') & level2;
   level4<= level3 & (7 downto 0 => '0') when ps(3)= '1' else     (7 downto 0 => '0') & level3;
   level5<= level4 & (15 downto 0 => '0') when ps(4)= '1' else     (15 downto 0 => '0') & level4;
   R <= level5(29 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                        FP2Fix_6_10_0_16_S_NTMantSum
--                          (IntAdder_18_f120_uid13)
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

entity FP2Fix_6_10_0_16_S_NTMantSum is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(17 downto 0);
          Y : in  std_logic_vector(17 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(17 downto 0)   );
end entity;

architecture arch of FP2Fix_6_10_0_16_S_NTMantSum is
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
--                                FP610_To_FXP
--                          (FP2Fix_6_10_0_16_S_NT)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Fabrizio Ferrandi (2012)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FP610_To_FXP is
   port ( clk, rst : in std_logic;
          I : in  std_logic_vector(6+10+2 downto 0);
          O : out  std_logic_vector(16 downto 0)   );
end entity;

architecture arch of FP610_To_FXP is
   component FP2Fix_6_10_0_16_S_NTExponent_difference is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(5 downto 0);
             Y : in  std_logic_vector(5 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(5 downto 0)   );
   end component;

   component FP2Fix_6_10_0_16_S_NTMantSum is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(17 downto 0);
             Y : in  std_logic_vector(17 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(17 downto 0)   );
   end component;

   component LeftShifter_11_by_max_19_uid10 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(10 downto 0);
             S : in  std_logic_vector(4 downto 0);
             R : out  std_logic_vector(29 downto 0)   );
   end component;

signal eA0 :  std_logic_vector(5 downto 0);
signal fA0 :  std_logic_vector(10 downto 0);
signal bias :  std_logic_vector(5 downto 0);
signal eA1 :  std_logic_vector(5 downto 0);
signal shiftedby :  std_logic_vector(4 downto 0);
signal fA1 :  std_logic_vector(29 downto 0);
signal fA2a :  std_logic_vector(17 downto 0);
signal notallzero :  std_logic;
signal round :  std_logic;
signal fA2b :  std_logic_vector(17 downto 0);
signal fA3 :  std_logic_vector(17 downto 0);
signal fA3b :  std_logic_vector(17 downto 0);
signal fA4 :  std_logic_vector(16 downto 0);
signal overFl0 :  std_logic;
signal overFl1 :  std_logic;
signal eTest :  std_logic;
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   eA0 <= I(15 downto 10);
   fA0 <= "1" & I(9 downto 0);
   bias <= not conv_std_logic_vector(30, 6);
   Exponent_difference: FP2Fix_6_10_0_16_S_NTExponent_difference  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => '1',
                 R => eA1,
                 X => bias,
                 Y => eA0);
   ---------------- cycle 0----------------
   shiftedby <= eA1(4 downto 0) when eA1(5) = '0' else (4 downto 0 => '0');
   FXP_shifter: LeftShifter_11_by_max_19_uid10  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 R => fA1,
                 S => shiftedby,
                 X => fA0);
   fA2a<= '0' & fA1(27 downto 11);
   notallzero <= '0' when fA1(9 downto 0) = (9 downto 0 => '0') else '1';
   round <= (fA1(10) and I(16)) or (fA1(10) and notallzero and not I(16));
   fA2b<= '0' & (16 downto 1 => '0') & round;
   MantSum: FP2Fix_6_10_0_16_S_NTMantSum  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => '0',
                 R => fA3,
                 X => fA2a,
                 Y => fA2b);
   ---------------- cycle 0----------------
   fA3b<= -signed(fA3);
   fA4<= fA3(16 downto 0) when I(16) = '0' else fA3b(16 downto 0);
   overFl0<= '1' when I(15 downto 10) > conv_std_logic_vector(47,6) else I(18);
   overFl1 <= fA3(17);
   eTest <= (overFl0 or overFl1);
   O <= fA4 when eTest = '0' else
      I(16) & (15 downto 0 => not I(16));
end architecture;
