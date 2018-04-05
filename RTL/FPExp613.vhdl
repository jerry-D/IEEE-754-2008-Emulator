-- FPExp613.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ ./flopoco -name=FPExp613 -frequency=120 -useHardMult=no FPExp 6 13
-- Warning: the given expression is not a constant but an expression to evaluate. A faithful evaluation to 10000 bits will be used.
-- Warning: the given expression is not a constant but an expression to evaluate. A faithful evaluation to 10000 bits will be used.
-- Updating entity name to: FPExp613
-- 
-- Final report:
-- Entity SmallMultTableP3x3r6XuYu
--    Not pipelined
-- Entity Compressor_6_3
--    Not pipelined
-- Entity Compressor_14_3
--    Not pipelined
-- Entity Compressor_4_3
--    Not pipelined
-- Entity Compressor_23_3
--    Not pipelined
-- Entity Compressor_3_2
--    Not pipelined
-- |---Entity LeftShifter_14_by_max_21_uid3
-- |      Not pipelined
-- |   |---Entity FixRealKCM_M3_4_0_1_log_2_unsigned_Table_1
-- |   |      Not pipelined
-- |   |---Entity FixRealKCM_M3_4_0_1_log_2_unsigned_Table_0
-- |   |      Not pipelined
-- |   |---Entity IntAdder_10_f120_uid11
-- |   |      Not pipelined
-- |---Entity FixRealKCM_M3_4_0_1_log_2_unsigned
-- |      Not pipelined
-- |   |---Entity FixRealKCM_0_5_M16_log_2_unsigned_Table_0
-- |   |      Not pipelined
-- |---Entity FixRealKCM_0_5_M16_log_2_unsigned
-- |      Not pipelined
-- |---Entity IntAdder_16_f126_uid23
-- |      Not pipelined
-- |---Entity MagicSPExpTable
-- |      Not pipelined
-- |---Entity IntAdder_8_f120_uid32
-- |      Not pipelined
-- |   |---Entity IntAdder_12_f120_uid73
-- |   |      Not pipelined
-- |---Entity IntMultiplier_UsingDSP_7_8_9_unsigned_uid39
-- |      Not pipelined
-- |---Entity IntAdder_17_f120_uid81
-- |      Not pipelined
-- |---Entity IntAdder_21_f120_uid88
-- |      Not pipelined
-- Entity FPExp613
--    Pipeline depth = 2
-- Output file: flopoco.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ cat flopoco.vhdl
--------------------------------------------------------------------------------
--                          SmallMultTableP3x3r6XuYu
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Florent de Dinechin (2007-2012)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
entity SmallMultTableP3x3r6XuYu is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(5 downto 0);
          Y : out  std_logic_vector(5 downto 0)   );
end entity;

architecture arch of SmallMultTableP3x3r6XuYu is
begin
  with X select  Y <=
   "000000" when "000000",
   "000000" when "000001",
   "000000" when "000010",
   "000000" when "000011",
   "000000" when "000100",
   "000000" when "000101",
   "000000" when "000110",
   "000000" when "000111",
   "000000" when "001000",
   "000001" when "001001",
   "000010" when "001010",
   "000011" when "001011",
   "000100" when "001100",
   "000101" when "001101",
   "000110" when "001110",
   "000111" when "001111",
   "000000" when "010000",
   "000010" when "010001",
   "000100" when "010010",
   "000110" when "010011",
   "001000" when "010100",
   "001010" when "010101",
   "001100" when "010110",
   "001110" when "010111",
   "000000" when "011000",
   "000011" when "011001",
   "000110" when "011010",
   "001001" when "011011",
   "001100" when "011100",
   "001111" when "011101",
   "010010" when "011110",
   "010101" when "011111",
   "000000" when "100000",
   "000100" when "100001",
   "001000" when "100010",
   "001100" when "100011",
   "010000" when "100100",
   "010100" when "100101",
   "011000" when "100110",
   "011100" when "100111",
   "000000" when "101000",
   "000101" when "101001",
   "001010" when "101010",
   "001111" when "101011",
   "010100" when "101100",
   "011001" when "101101",
   "011110" when "101110",
   "100011" when "101111",
   "000000" when "110000",
   "000110" when "110001",
   "001100" when "110010",
   "010010" when "110011",
   "011000" when "110100",
   "011110" when "110101",
   "100100" when "110110",
   "101010" when "110111",
   "000000" when "111000",
   "000111" when "111001",
   "001110" when "111010",
   "010101" when "111011",
   "011100" when "111100",
   "100011" when "111101",
   "101010" when "111110",
   "110001" when "111111",
   "------" when others;
end architecture;

--------------------------------------------------------------------------------
--                               Compressor_6_3
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Popa, Illyes Kinga, 2012
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Compressor_6_3 is
   port ( X0 : in  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(2 downto 0)   );
end entity;

architecture arch of Compressor_6_3 is
signal X :  std_logic_vector(5 downto 0);
begin
   X <=X0 ;
   with X select R <=
      "000" when "000000",
      "001" when "000001",
      "001" when "000010",
      "010" when "000011",
      "001" when "000100",
      "010" when "000101",
      "010" when "000110",
      "011" when "000111",
      "001" when "001000",
      "010" when "001001",
      "010" when "001010",
      "011" when "001011",
      "010" when "001100",
      "011" when "001101",
      "011" when "001110",
      "100" when "001111",
      "001" when "010000",
      "010" when "010001",
      "010" when "010010",
      "011" when "010011",
      "010" when "010100",
      "011" when "010101",
      "011" when "010110",
      "100" when "010111",
      "010" when "011000",
      "011" when "011001",
      "011" when "011010",
      "100" when "011011",
      "011" when "011100",
      "100" when "011101",
      "100" when "011110",
      "101" when "011111",
      "001" when "100000",
      "010" when "100001",
      "010" when "100010",
      "011" when "100011",
      "010" when "100100",
      "011" when "100101",
      "011" when "100110",
      "100" when "100111",
      "010" when "101000",
      "011" when "101001",
      "011" when "101010",
      "100" when "101011",
      "011" when "101100",
      "100" when "101101",
      "100" when "101110",
      "101" when "101111",
      "010" when "110000",
      "011" when "110001",
      "011" when "110010",
      "100" when "110011",
      "011" when "110100",
      "100" when "110101",
      "100" when "110110",
      "101" when "110111",
      "011" when "111000",
      "100" when "111001",
      "100" when "111010",
      "101" when "111011",
      "100" when "111100",
      "101" when "111101",
      "101" when "111110",
      "110" when "111111",
      "---" when others;

end architecture;

--------------------------------------------------------------------------------
--                              Compressor_14_3
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Popa, Illyes Kinga, 2012
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Compressor_14_3 is
   port ( X0 : in  std_logic_vector(3 downto 0);
          X1 : in  std_logic_vector(0 downto 0);
          R : out  std_logic_vector(2 downto 0)   );
end entity;

architecture arch of Compressor_14_3 is
signal X :  std_logic_vector(4 downto 0);
begin
   X <=X1 & X0 ;
   with X select R <=
      "000" when "00000",
      "001" when "00001",
      "001" when "00010",
      "010" when "00011",
      "001" when "00100",
      "010" when "00101",
      "010" when "00110",
      "011" when "00111",
      "001" when "01000",
      "010" when "01001",
      "010" when "01010",
      "011" when "01011",
      "010" when "01100",
      "011" when "01101",
      "011" when "01110",
      "100" when "01111",
      "010" when "10000",
      "011" when "10001",
      "011" when "10010",
      "100" when "10011",
      "011" when "10100",
      "100" when "10101",
      "100" when "10110",
      "101" when "10111",
      "011" when "11000",
      "100" when "11001",
      "100" when "11010",
      "101" when "11011",
      "100" when "11100",
      "101" when "11101",
      "101" when "11110",
      "110" when "11111",
      "---" when others;

end architecture;

--------------------------------------------------------------------------------
--                               Compressor_4_3
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Popa, Illyes Kinga, 2012
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Compressor_4_3 is
   port ( X0 : in  std_logic_vector(3 downto 0);
          R : out  std_logic_vector(2 downto 0)   );
end entity;

architecture arch of Compressor_4_3 is
signal X :  std_logic_vector(3 downto 0);
begin
   X <=X0 ;
   with X select R <=
      "000" when "0000",
      "001" when "0001",
      "001" when "0010",
      "010" when "0011",
      "001" when "0100",
      "010" when "0101",
      "010" when "0110",
      "011" when "0111",
      "001" when "1000",
      "010" when "1001",
      "010" when "1010",
      "011" when "1011",
      "010" when "1100",
      "011" when "1101",
      "011" when "1110",
      "100" when "1111",
      "---" when others;

end architecture;

--------------------------------------------------------------------------------
--                              Compressor_23_3
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Popa, Illyes Kinga, 2012
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Compressor_23_3 is
   port ( X0 : in  std_logic_vector(2 downto 0);
          X1 : in  std_logic_vector(1 downto 0);
          R : out  std_logic_vector(2 downto 0)   );
end entity;

architecture arch of Compressor_23_3 is
signal X :  std_logic_vector(4 downto 0);
begin
   X <=X1 & X0 ;
   with X select R <=
      "000" when "00000",
      "001" when "00001",
      "001" when "00010",
      "010" when "00011",
      "001" when "00100",
      "010" when "00101",
      "010" when "00110",
      "011" when "00111",
      "010" when "01000",
      "011" when "01001",
      "011" when "01010",
      "100" when "01011",
      "011" when "01100",
      "100" when "01101",
      "100" when "01110",
      "101" when "01111",
      "010" when "10000",
      "011" when "10001",
      "011" when "10010",
      "100" when "10011",
      "011" when "10100",
      "100" when "10101",
      "100" when "10110",
      "101" when "10111",
      "100" when "11000",
      "101" when "11001",
      "101" when "11010",
      "110" when "11011",
      "101" when "11100",
      "110" when "11101",
      "110" when "11110",
      "111" when "11111",
      "---" when others;

end architecture;

--------------------------------------------------------------------------------
--                               Compressor_3_2
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Popa, Illyes Kinga, 2012
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Compressor_3_2 is
   port ( X0 : in  std_logic_vector(2 downto 0);
          R : out  std_logic_vector(1 downto 0)   );
end entity;

architecture arch of Compressor_3_2 is
signal X :  std_logic_vector(2 downto 0);
begin
   X <=X0 ;
   with X select R <=
      "00" when "000",
      "01" when "001",
      "01" when "010",
      "10" when "011",
      "01" when "100",
      "10" when "101",
      "10" when "110",
      "11" when "111",
      "--" when others;

end architecture;

--------------------------------------------------------------------------------
--                       LeftShifter_14_by_max_21_uid3
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

entity LeftShifter_14_by_max_21_uid3 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(13 downto 0);
          S : in  std_logic_vector(4 downto 0);
          R : out  std_logic_vector(34 downto 0)   );
end entity;

architecture arch of LeftShifter_14_by_max_21_uid3 is
signal level0 :  std_logic_vector(13 downto 0);
signal ps :  std_logic_vector(4 downto 0);
signal level1 :  std_logic_vector(14 downto 0);
signal level2 :  std_logic_vector(16 downto 0);
signal level3 :  std_logic_vector(20 downto 0);
signal level4 :  std_logic_vector(28 downto 0);
signal level5 :  std_logic_vector(44 downto 0);
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
   R <= level5(34 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                 FixRealKCM_M3_4_0_1_log_2_unsigned_Table_1
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Florent de Dinechin (2007-2012)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
entity FixRealKCM_M3_4_0_1_log_2_unsigned_Table_1 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(1 downto 0);
          Y : out  std_logic_vector(9 downto 0)   );
end entity;

architecture arch of FixRealKCM_M3_4_0_1_log_2_unsigned_Table_1 is
begin
  with X select  Y <=
   "0000001000" when "00",
   "0011000001" when "01",
   "0101111001" when "10",
   "1000110010" when "11",
   "----------" when others;
end architecture;

--------------------------------------------------------------------------------
--                 FixRealKCM_M3_4_0_1_log_2_unsigned_Table_0
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Florent de Dinechin (2007-2012)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
entity FixRealKCM_M3_4_0_1_log_2_unsigned_Table_0 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(5 downto 0);
          Y : out  std_logic_vector(7 downto 0)   );
end entity;

architecture arch of FixRealKCM_M3_4_0_1_log_2_unsigned_Table_0 is
begin
  with X select  Y <=
   "00000000" when "000000",
   "00000011" when "000001",
   "00000110" when "000010",
   "00001001" when "000011",
   "00001100" when "000100",
   "00001110" when "000101",
   "00010001" when "000110",
   "00010100" when "000111",
   "00010111" when "001000",
   "00011010" when "001001",
   "00011101" when "001010",
   "00100000" when "001011",
   "00100011" when "001100",
   "00100110" when "001101",
   "00101000" when "001110",
   "00101011" when "001111",
   "00101110" when "010000",
   "00110001" when "010001",
   "00110100" when "010010",
   "00110111" when "010011",
   "00111010" when "010100",
   "00111101" when "010101",
   "00111111" when "010110",
   "01000010" when "010111",
   "01000101" when "011000",
   "01001000" when "011001",
   "01001011" when "011010",
   "01001110" when "011011",
   "01010001" when "011100",
   "01010100" when "011101",
   "01010111" when "011110",
   "01011001" when "011111",
   "01011100" when "100000",
   "01011111" when "100001",
   "01100010" when "100010",
   "01100101" when "100011",
   "01101000" when "100100",
   "01101011" when "100101",
   "01101110" when "100110",
   "01110001" when "100111",
   "01110011" when "101000",
   "01110110" when "101001",
   "01111001" when "101010",
   "01111100" when "101011",
   "01111111" when "101100",
   "10000010" when "101101",
   "10000101" when "101110",
   "10001000" when "101111",
   "10001010" when "110000",
   "10001101" when "110001",
   "10010000" when "110010",
   "10010011" when "110011",
   "10010110" when "110100",
   "10011001" when "110101",
   "10011100" when "110110",
   "10011111" when "110111",
   "10100010" when "111000",
   "10100100" when "111001",
   "10100111" when "111010",
   "10101010" when "111011",
   "10101101" when "111100",
   "10110000" when "111101",
   "10110011" when "111110",
   "10110110" when "111111",
   "--------" when others;
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_10_f120_uid11
--                    (IntAdderAlternative_10_f120_uid15)
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

entity IntAdder_10_f120_uid11 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(9 downto 0);
          Y : in  std_logic_vector(9 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(9 downto 0)   );
end entity;

architecture arch of IntAdder_10_f120_uid11 is
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
--                     FixRealKCM_M3_4_0_1_log_2_unsigned
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors:
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FixRealKCM_M3_4_0_1_log_2_unsigned is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(7 downto 0);
          R : out  std_logic_vector(5 downto 0)   );
end entity;

architecture arch of FixRealKCM_M3_4_0_1_log_2_unsigned is
   component FixRealKCM_M3_4_0_1_log_2_unsigned_Table_0 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(5 downto 0);
             Y : out  std_logic_vector(7 downto 0)   );
   end component;

   component FixRealKCM_M3_4_0_1_log_2_unsigned_Table_1 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(1 downto 0);
             Y : out  std_logic_vector(9 downto 0)   );
   end component;

   component IntAdder_10_f120_uid11 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(9 downto 0);
             Y : in  std_logic_vector(9 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(9 downto 0)   );
   end component;

signal d1 :  std_logic_vector(1 downto 0);
signal d0 :  std_logic_vector(5 downto 0);
signal pp0 :  std_logic_vector(7 downto 0);
signal pp1 :  std_logic_vector(9 downto 0);
signal addOp0 :  std_logic_vector(9 downto 0);
signal OutRes :  std_logic_vector(9 downto 0);
attribute rom_extract: string;
attribute rom_style: string;
attribute rom_extract of FixRealKCM_M3_4_0_1_log_2_unsigned_Table_0: component is "yes";
attribute rom_extract of FixRealKCM_M3_4_0_1_log_2_unsigned_Table_1: component is "yes";
attribute rom_style of FixRealKCM_M3_4_0_1_log_2_unsigned_Table_0: component is "distributed";
attribute rom_style of FixRealKCM_M3_4_0_1_log_2_unsigned_Table_1: component is "distributed";
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   d1 <= X(7 downto 6);
   d0 <= X(5 downto 0);
   KCMTable_0: FixRealKCM_M3_4_0_1_log_2_unsigned_Table_0  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => d0,
                 Y => pp0);
   KCMTable_1: FixRealKCM_M3_4_0_1_log_2_unsigned_Table_1  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => d1,
                 Y => pp1);
   addOp0 <= (9 downto 8 => '0') & pp0;
   Result_Adder: IntAdder_10_f120_uid11  -- pipelineDepth=0 maxInDelay=5.47752e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => '0',
                 R => OutRes,
                 X => addOp0,
                 Y => pp1);
   R <= OutRes(9 downto 4);
end architecture;

--------------------------------------------------------------------------------
--                 FixRealKCM_0_5_M16_log_2_unsigned_Table_0
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Florent de Dinechin (2007-2012)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
entity FixRealKCM_0_5_M16_log_2_unsigned_Table_0 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(5 downto 0);
          Y : out  std_logic_vector(21 downto 0)   );
end entity;

architecture arch of FixRealKCM_0_5_M16_log_2_unsigned_Table_0 is
begin
  with X select  Y <=
   "0000000000000000000000" when "000000",
   "0000001011000101110010" when "000001",
   "0000010110001011100100" when "000010",
   "0000100001010001010110" when "000011",
   "0000101100010111001000" when "000100",
   "0000110111011100111010" when "000101",
   "0001000010100010101101" when "000110",
   "0001001101101000011111" when "000111",
   "0001011000101110010001" when "001000",
   "0001100011110100000011" when "001001",
   "0001101110111001110101" when "001010",
   "0001111001111111100111" when "001011",
   "0010000101000101011001" when "001100",
   "0010010000001011001011" when "001101",
   "0010011011010000111101" when "001110",
   "0010100110010110101111" when "001111",
   "0010110001011100100001" when "010000",
   "0010111100100010010100" when "010001",
   "0011000111101000000110" when "010010",
   "0011010010101101111000" when "010011",
   "0011011101110011101010" when "010100",
   "0011101000111001011100" when "010101",
   "0011110011111111001110" when "010110",
   "0011111111000101000000" when "010111",
   "0100001010001010110010" when "011000",
   "0100010101010000100100" when "011001",
   "0100100000010110010110" when "011010",
   "0100101011011100001001" when "011011",
   "0100110110100001111011" when "011100",
   "0101000001100111101101" when "011101",
   "0101001100101101011111" when "011110",
   "0101010111110011010001" when "011111",
   "0101100010111001000011" when "100000",
   "0101101101111110110101" when "100001",
   "0101111001000100100111" when "100010",
   "0110000100001010011001" when "100011",
   "0110001111010000001011" when "100100",
   "0110011010010101111101" when "100101",
   "0110100101011011110000" when "100110",
   "0110110000100001100010" when "100111",
   "0110111011100111010100" when "101000",
   "0111000110101101000110" when "101001",
   "0111010001110010111000" when "101010",
   "0111011100111000101010" when "101011",
   "0111100111111110011100" when "101100",
   "0111110011000100001110" when "101101",
   "0111111110001010000000" when "101110",
   "1000001001001111110010" when "101111",
   "1000010100010101100100" when "110000",
   "1000011111011011010111" when "110001",
   "1000101010100001001001" when "110010",
   "1000110101100110111011" when "110011",
   "1001000000101100101101" when "110100",
   "1001001011110010011111" when "110101",
   "1001010110111000010001" when "110110",
   "1001100001111110000011" when "110111",
   "1001101101000011110101" when "111000",
   "1001111000001001100111" when "111001",
   "1010000011001111011001" when "111010",
   "1010001110010101001100" when "111011",
   "1010011001011010111110" when "111100",
   "1010100100100000110000" when "111101",
   "1010101111100110100010" when "111110",
   "1010111010101100010100" when "111111",
   "----------------------" when others;
end architecture;

--------------------------------------------------------------------------------
--                     FixRealKCM_0_5_M16_log_2_unsigned
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors:
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FixRealKCM_0_5_M16_log_2_unsigned is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(21 downto 0)   );
end entity;

architecture arch of FixRealKCM_0_5_M16_log_2_unsigned is
   component FixRealKCM_0_5_M16_log_2_unsigned_Table_0 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(5 downto 0);
             Y : out  std_logic_vector(21 downto 0)   );
   end component;

signal Y :  std_logic_vector(21 downto 0);
attribute rom_extract: string;
attribute rom_style: string;
attribute rom_extract of FixRealKCM_0_5_M16_log_2_unsigned_Table_0: component is "yes";
attribute rom_style of FixRealKCM_0_5_M16_log_2_unsigned_Table_0: component is "distributed";
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   KCMTable: FixRealKCM_0_5_M16_log_2_unsigned_Table_0  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => X,
                 Y => Y);
   R <= Y;
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_16_f126_uid23
--                    (IntAdderAlternative_16_f126_uid27)
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

entity IntAdder_16_f126_uid23 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(15 downto 0);
          Y : in  std_logic_vector(15 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(15 downto 0)   );
end entity;

architecture arch of IntAdder_16_f126_uid23 is
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
--                              MagicSPExpTable
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Radu Tudoran, Florent de Dinechin (2009)
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity MagicSPExpTable is
   port ( X1 : in  std_logic_vector(8 downto 0);
          Y1 : out  std_logic_vector(24 downto 0);
          X2 : in  std_logic_vector(8 downto 0);
          Y2 : out  std_logic_vector(24 downto 0)   );
end entity;

architecture arch of MagicSPExpTable is
type ROMContent is array (0 to 511) of std_logic_vector(24 downto 0);
constant memVar: ROMContent :=    (
      "1000000000000000000000000",       "1000000001000000000000000",       "1000000010000000100000001",       "1000000011000000100000001",
      "1000000100000001000000001",       "1000000101000001100000001",       "1000000110000010100000010",       "1000000111000011000000010",
      "1000001000000100000000010",       "1000001001000101000000010",       "1000001010000110100000011",       "1000001011000111100000011",
      "1000001100001001000000011",       "1000001101001010100000011",       "1000001110001100100000100",       "1000001111001110000000100",
      "1000010000010000000000100",       "1000010001010010100000100",       "1000010010010100100000101",       "1000010011010111000000101",
      "1000010100011001100000101",       "1000010101011100000000101",       "1000010110011110100000110",       "1000010111100001100000110",
      "1000011000100100100000110",       "1000011001100111100000110",       "1000011010101011000000111",       "1000011011101110100000111",
      "1000011100110010000000111",       "1000011101110101100000111",       "1000011110111001100001000",       "1000011111111101100001000",
      "1000100001000001100001000",       "1000100010000101100001000",       "1000100011001010000001001",       "1000100100001110100001001",
      "1000100101010011000001001",       "1000100110010111100001001",       "1000100111011100100001010",       "1000101000100001100001010",
      "1000101001100110100001010",       "1000101010101100000001010",       "1000101011110001100001011",       "1000101100110111000001011",
      "1000101101111100100001011",       "1000101111000010100001011",       "1000110000001000100001100",       "1000110001001110100001100",
      "1000110010010100100001100",       "1000110011011011000001100",       "1000110100100001100001101",       "1000110101101000000001101",
      "1000110110101111000001101",       "1000110111110110000001101",       "1000111000111101000001110",       "1000111010000100000001110",
      "1000111011001011100001110",       "1000111100010011000001110",       "1000111101011010100001111",       "1000111110100010000001111",
      "1000111111101010000001111",       "1001000000110010000001111",       "1001000001111010000010000",       "1001000011000010100010000",
      "1001000100001011000010000",       "1001000101010011100010000",       "1001000110011100100010001",       "1001000111100101000010001",
      "1001001000101110000010001",       "1001001001110111100010001",       "1001001011000000100010010",       "1001001100001010000010010",
      "1001001101010011100010010",       "1001001110011101100010010",       "1001001111100111100010011",       "1001010000110001100010011",
      "1001010001111011100010011",       "1001010011000110000010011",       "1001010100010000100010100",       "1001010101011011000010100",
      "1001010110100101100010100",       "1001010111110000100010100",       "1001011000111011100010101",       "1001011010000111000010101",
      "1001011011010010000010101",       "1001011100011101100010101",       "1001011101101001100010110",       "1001011110110101000010110",
      "1001100000000001000010110",       "1001100001001101000010110",       "1001100010011001100010111",       "1001100011100101100010111",
      "1001100100110010000010111",       "1001100101111111000010111",       "1001100111001011100011000",       "1001101000011000100011000",
      "1001101001100110000011000",       "1001101010110011000011000",       "1001101100000000100011001",       "1001101101001110000011001",
      "1001101110011100000011001",       "1001101111101001100011001",       "1001110000110111100011010",       "1001110010000110000011010",
      "1001110011010100000011010",       "1001110100100010100011010",       "1001110101110001100011011",       "1001110111000000000011011",
      "1001111000001111000011011",       "1001111001011110000011011",       "1001111010101101100011100",       "1001111011111101000011100",
      "1001111101001100100011100",       "1001111110011100000011100",       "1001111111101100000011101",       "1010000000111100000011101",
      "1010000010001100100011101",       "1010000011011100100011101",       "1010000100101101000011110",       "1010000101111110000011110",
      "1010000111001110100011110",       "1010001000011111100011110",       "1010001001110001000011111",       "1010001011000010000011111",
      "1010001100010011100011111",       "1010001101100101000011111",       "1010001110110111000100000",       "1010010000001001000100000",
      "1010010001011011000100000",       "1010010010101101000100000",       "1010010011111111100100001",       "1010010101010010000100001",
      "1010010110100101000100001",       "1010010111111000000100001",       "1010011001001011000100010",       "1010011010011110000100010",
      "1010011011110001100100010",       "1010011101000101000100010",       "1010011110011001000100011",       "1010011111101100100100011",
      "1010100001000000100100011",       "1010100010010101000100011",       "1010100011101001100100100",       "1010100100111110000100100",
      "1010100110010010100100100",       "1010100111100111100100100",       "1010101000111100100100101",       "1010101010010001100100101",
      "1010101011100111000100101",       "1010101100111100100100101",       "1010101110010010100100110",       "1010101111101000000100110",
      "1010110000111110000100110",       "1010110010010100100100110",       "1010110011101010100100111",       "1010110101000001100100111",
      "1010110110011000000100111",       "1010110111101111000100111",       "1010111001000110000101000",       "1010111010011101000101000",
      "1010111011110100100101000",       "1010111101001100000101000",       "1010111110100100000101001",       "1010111111111011100101001",
      "1011000001010100000101001",       "1011000010101100000101001",       "1011000100000100100101010",       "1011000101011101000101010",
      "1011000110110110000101010",       "1011001000001111000101010",       "1011001001101000000101011",       "1011001011000001000101011",
      "1011001100011010100101011",       "1011001101110100100101011",       "1011001111001110000101100",       "1011010000101000000101100",
      "1011010010000010100101100",       "1011010011011100100101100",       "1011010100110111000101101",       "1011010110010010000101101",
      "1011010111101100100101101",       "1011011001001000000101101",       "1011011010100011000101110",       "1011011011111110100101110",
      "1011011101011010000101110",       "1011011110110110000101110",       "1011100000010001100101111",       "1011100001101110000101111",
      "1011100011001010000101111",       "1011100100100110100101111",       "1011100110000011100110000",       "1011100111100000000110000",
      "1011101000111101000110000",       "1011101010011010100110000",       "1011101011111000000110001",       "1011101101010101100110001",
      "1011101110110011000110001",       "1011110000010001000110001",       "1011110001101111000110010",       "1011110011001101100110010",
      "1011110100101100000110010",       "1011110110001010100110010",       "1011110111101001100110011",       "1011111001001000100110011",
      "1011111010101000000110011",       "1011111100000111000110011",       "1011111101100111000110100",       "1011111111000110100110100",
      "1100000000100110100110100",       "1100000010000111000110100",       "1100000011100111000110101",       "1100000101000111100110101",
      "1100000110101000100110101",       "1100001000001001100110101",       "1100001001101010100110110",       "1100001011001011100110110",
      "1100001100101101000110110",       "1100001110001111000110110",       "1100001111110001000110111",       "1100010001010011000110111",
      "1100010010110101000110111",       "1100010100010111100110111",       "1100010101111010000111000",       "1100010111011101000111000",
      "1100011001000000000111000",       "1100011010100011100111000",       "1100011100000110100111001",       "1100011101101010100111001",
      "1100011111001110000111001",       "1100100000110010000111001",       "1100100010010110100111010",       "1100100011111010100111010",
      "1100100101011111100111010",       "1100100111000100000111010",       "1100101000101001000111011",       "1100101010001110000111011",
      "1100101011110011100111011",       "1100101101011001000111011",       "1100101110111111000111100",       "1100110000100101000111100",
      "1100110010001011000111100",       "1100110011110001100111100",       "1100110101011000000111101",       "1100110110111111000111101",
      "1100111000100110000111101",       "1100111010001101000111101",       "1100111011110100100111110",       "1100111101011100000111110",
      "1100111111000011100111110",       "1101000000101011100111110",       "1101000010010100000111111",       "1101000011111100100111111",
      "1101000101100101000111111",       "1101000111001101100111111",       "1101001000110110101000000",       "1101001010100000001000000",
      "0100110110100011001000000",       "0100110111001001101000000",       "0100110111110000101000001",       "0100111000010111101000001",
      "0100111000111110101000001",       "0100111001100110001000001",       "0100111010001101001000010",       "0100111010110100101000010",
      "0100111011011100001000010",       "0100111100000011001000010",       "0100111100101011001000011",       "0100111101010010101000011",
      "0100111101111010001000011",       "0100111110100010001000011",       "0100111111001001101000100",       "0100111111110001101000100",
      "0101000000011001101000100",       "0101000001000010001000100",       "0101000001101010001000101",       "0101000010010010001000101",
      "0101000010111010101000101",       "0101000011100011001000101",       "0101000100001011101000110",       "0101000100110100001000110",
      "0101000101011100101000110",       "0101000110000101101000110",       "0101000110101110001000111",       "0101000111010111001000111",
      "0101001000000000001000111",       "0101001000101001001000111",       "0101001001010010001001000",       "0101001001111011101001000",
      "0101001010100100101001000",       "0101001011001110001001000",       "0101001011110111101001001",       "0101001100100001001001001",
      "0101001101001010101001001",       "0101001101110100001001001",       "0101001110011110001001010",       "0101001111001000001001010",
      "0101001111110010001001010",       "0101010000011100001001010",       "0101010001000110001001011",       "0101010001110000001001011",
      "0101010010011010101001011",       "0101010011000100101001011",       "0101010011101111001001100",       "0101010100011001101001100",
      "0101010101000100001001100",       "0101010101101111001001100",       "0101010110011001101001101",       "0101010111000100101001101",
      "0101010111101111101001101",       "0101011000011010101001101",       "0101011001000101101001110",       "0101011001110000101001110",
      "0101011010011100001001110",       "0101011011000111101001110",       "0101011011110010101001111",       "0101011100011110001001111",
      "0101011101001010001001111",       "0101011101110101101001111",       "0101011110100001101010000",       "0101011111001101001010000",
      "0101011111111001001010000",       "0101100000100101001010000",       "0101100001010001001010001",       "0101100001111101101010001",
      "0101100010101001101010001",       "0101100011010110001010001",       "0101100100000010101010010",       "0101100100101111001010010",
      "0101100101011100001010010",       "0101100110001000101010010",       "0101100110110101101010011",       "0101100111100010001010011",
      "0101101000001111001010011",       "0101101000111100001010011",       "0101101001101001101010100",       "0101101010010110101010100",
      "0101101011000100001010100",       "0101101011110001101010100",       "0101101100011111001010101",       "0101101101001100101010101",
      "0101101101111010001010101",       "0101101110101000001010101",       "0101101111010110001010110",       "0101110000000100001010110",
      "0101110000110010001010110",       "0101110001100000001010110",       "0101110010001110101010111",       "0101110010111100101010111",
      "0101110011101011001010111",       "0101110100011001101010111",       "0101110101001000001011000",       "0101110101110111001011000",
      "0101110110100101101011000",       "0101110111010100101011000",       "0101111000000011101011001",       "0101111000110010101011001",
      "0101111001100001101011001",       "0101111010010001001011001",       "0101111011000000001011010",       "0101111011101111101011010",
      "0101111100011111001011010",       "0101111101001110101011010",       "0101111101111110101011011",       "0101111110101110001011011",
      "0101111111011110001011011",       "0110000000001110001011011",       "0110000000111110001011100",       "0110000001101110101011100",
      "0110000010011110101011100",       "0110000011001111001011100",       "0110000011111111101011101",       "0110000100110000001011101",
      "0110000101100000101011101",       "0110000110010001101011101",       "0110000111000010001011110",       "0110000111110011001011110",
      "0110001000100100001011110",       "0110001001010101001011110",       "0110001010000110101011111",       "0110001010110111101011111",
      "0110001011101001001011111",       "0110001100011010101011111",       "0110001101001100101100000",       "0110001101111110001100000",
      "0110001110101111101100000",       "0110001111100001101100000",       "0110010000010011101100001",       "0110010001000101101100001",
      "0110010001111000001100001",       "0110010010101010001100001",       "0110010011011100101100010",       "0110010100001111001100010",
      "0110010101000001101100010",       "0110010101110100101100010",       "0110010110100111001100011",       "0110010111011010001100011",
      "0110011000001101001100011",       "0110011001000000001100011",       "0110011001110011001100100",       "0110011010100110101100100",
      "0110011011011010001100100",       "0110011100001101101100100",       "0110011101000001001100101",       "0110011101110100101100101",
      "0110011110101000101100101",       "0110011111011100001100101",       "0110100000010000001100110",       "0110100001000100101100110",
      "0110100001111000101100110",       "0110100010101100101100110",       "0110100011100001001100111",       "0110100100010101101100111",
      "0110100101001010001100111",       "0110100101111111001100111",       "0110100110110011101101000",       "0110100111101000101101000",
      "0110101000011101101101000",       "0110101001010010101101000",       "0110101010001000001101001",       "0110101010111101101101001",
      "0110101011110010101101001",       "0110101100101000001101001",       "0110101101011110001101010",       "0110101110010011101101010",
      "0110101111001001101101010",       "0110101111111111101101010",       "0110110000110101101101011",       "0110110001101011101101011",
      "0110110010100010001101011",       "0110110011011000001101011",       "0110110100001110101101100",       "0110110101000101101101100",
      "0110110101111100001101100",       "0110110110110011001101100",       "0110110111101001101101101",       "0110111000100000101101101",
      "0110111001011000001101101",       "0110111010001111001101101",       "0110111011000110101101110",       "0110111011111110001101110",
      "0110111100110101101101110",       "0110111101101101001101110",       "0110111110100101001101111",       "0110111111011100101101111",
      "0111000000010100101101111",       "0111000001001100101101111",       "0111000010000101001110000",       "0111000010111101001110000",
      "0111000011110101101110000",       "0111000100101110001110000",       "0111000101100111001110001",       "0111000110011111101110001",
      "0111000111011000101110001",       "0111001000010001101110001",       "0111001001001010101110010",       "0111001010000011101110010",
      "0111001010111101001110010",       "0111001011110110101110010",       "0111001100110000001110011",       "0111001101101001101110011",
      "0111001110100011101110011",       "0111001111011101101110011",       "0111010000010111101110100",       "0111010001010001101110100",
      "0111010010001011101110100",       "0111010011000110001110100",       "0111010100000000101110101",       "0111010100111011001110101",
      "0111010101110101101110101",       "0111010110110000101110101",       "0111010111101011101110110",       "0111011000100110101110110",
      "0111011001100001101110110",       "0111011010011100101110110",       "0111011011011000001110111",       "0111011100010011101110111",
      "0111011101001111001110111",       "0111011110001011001110111",       "0111011111000110101111000",       "0111100000000010101111000",
      "0111100000111110101111000",       "0111100001111011001111000",       "0111100010110111001111001",       "0111100011110011101111001",
      "0111100100110000001111001",       "0111100101101101001111001",       "0111100110101001101111010",       "0111100111100110101111010",
      "0111101000100011101111010",       "0111101001100000101111010",       "0111101010011110001111011",       "0111101011011011001111011",
      "0111101100011000101111011",       "0111101101010110101111011",       "0111101110010100001111100",       "0111101111010010001111100",
      "0111110000010000001111100",       "0111110001001110001111100",       "0111110010001100001111101",       "0111110011001010101111101",
      "0111110100001001001111101",       "0111110101000111101111101",       "0111110110000110001111110",       "0111110111000101001111110",
      "0111111000000100001111110",       "0111111001000011001111110",       "0111111010000010001111111",       "0111111011000001101111111",
      "0111111100000001001111111",       "0111111101000000101111111",       "0111111110000000010000000",       "0111111111000000010000000"
)
;
begin
          Y1 <= memVar(conv_integer(X1));
          Y2 <= memVar(conv_integer(X2));
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_8_f120_uid32
--                     (IntAdderAlternative_8_f120_uid36)
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

entity IntAdder_8_f120_uid32 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(7 downto 0);
          Y : in  std_logic_vector(7 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(7 downto 0)   );
end entity;

architecture arch of IntAdder_8_f120_uid32 is
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
--                           IntAdder_12_f120_uid73
--                    (IntAdderAlternative_12_f120_uid77)
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

entity IntAdder_12_f120_uid73 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(11 downto 0);
          Y : in  std_logic_vector(11 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(11 downto 0)   );
end entity;

architecture arch of IntAdder_12_f120_uid73 is
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
--                IntMultiplier_UsingDSP_7_8_9_unsigned_uid39
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Florent de Dinechin, Kinga Illyes, Bogdan Popa, Bogdan Pasca, 2012
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
library work;

entity IntMultiplier_UsingDSP_7_8_9_unsigned_uid39 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(6 downto 0);
          Y : in  std_logic_vector(7 downto 0);
          R : out  std_logic_vector(8 downto 0)   );
end entity;

architecture arch of IntMultiplier_UsingDSP_7_8_9_unsigned_uid39 is
   component Compressor_14_3 is
      port ( X0 : in  std_logic_vector(3 downto 0);
             X1 : in  std_logic_vector(0 downto 0);
             R : out  std_logic_vector(2 downto 0)   );
   end component;

   component Compressor_23_3 is
      port ( X0 : in  std_logic_vector(2 downto 0);
             X1 : in  std_logic_vector(1 downto 0);
             R : out  std_logic_vector(2 downto 0)   );
   end component;

   component Compressor_3_2 is
      port ( X0 : in  std_logic_vector(2 downto 0);
             R : out  std_logic_vector(1 downto 0)   );
   end component;

   component Compressor_4_3 is
      port ( X0 : in  std_logic_vector(3 downto 0);
             R : out  std_logic_vector(2 downto 0)   );
   end component;

   component Compressor_6_3 is
      port ( X0 : in  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(2 downto 0)   );
   end component;

   component IntAdder_12_f120_uid73 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(11 downto 0);
             Y : in  std_logic_vector(11 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(11 downto 0)   );
   end component;

   component SmallMultTableP3x3r6XuYu is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(5 downto 0);
             Y : out  std_logic_vector(5 downto 0)   );
   end component;

signal XX_m40 :  std_logic_vector(7 downto 0);
signal YY_m40 :  std_logic_vector(6 downto 0);
signal Xp_m40b42 :  std_logic_vector(8 downto 0);
signal Yp_m40b42 :  std_logic_vector(8 downto 0);
signal x_m40b42_0 :  std_logic_vector(2 downto 0);
signal x_m40b42_1 :  std_logic_vector(2 downto 0);
signal x_m40b42_2 :  std_logic_vector(2 downto 0);
signal y_m40b42_0 :  std_logic_vector(2 downto 0);
signal y_m40b42_1 :  std_logic_vector(2 downto 0);
signal y_m40b42_2 :  std_logic_vector(2 downto 0);
signal Y0X1_42_m40 :  std_logic_vector(5 downto 0);
signal PP42X1Y0_m40 :  std_logic_vector(5 downto 0);
signal heap_bh41_w0_0 :  std_logic;
signal heap_bh41_w1_0 :  std_logic;
signal heap_bh41_w2_0 :  std_logic;
signal Y0X2_42_m40 :  std_logic_vector(5 downto 0);
signal PP42X2Y0_m40 :  std_logic_vector(5 downto 0);
signal heap_bh41_w2_1 :  std_logic;
signal heap_bh41_w3_0 :  std_logic;
signal heap_bh41_w4_0 :  std_logic;
signal heap_bh41_w5_0 :  std_logic;
signal Y1X0_42_m40 :  std_logic_vector(5 downto 0);
signal PP42X0Y1_m40 :  std_logic_vector(5 downto 0);
signal heap_bh41_w0_1 :  std_logic;
signal heap_bh41_w1_1 :  std_logic;
signal heap_bh41_w2_2 :  std_logic;
signal Y1X1_42_m40 :  std_logic_vector(5 downto 0);
signal PP42X1Y1_m40 :  std_logic_vector(5 downto 0);
signal heap_bh41_w0_2 :  std_logic;
signal heap_bh41_w1_2 :  std_logic;
signal heap_bh41_w2_3 :  std_logic;
signal heap_bh41_w3_1 :  std_logic;
signal heap_bh41_w4_1 :  std_logic;
signal heap_bh41_w5_1 :  std_logic;
signal Y1X2_42_m40 :  std_logic_vector(5 downto 0);
signal PP42X2Y1_m40 :  std_logic_vector(5 downto 0);
signal heap_bh41_w3_2 :  std_logic;
signal heap_bh41_w4_2 :  std_logic;
signal heap_bh41_w5_2 :  std_logic;
signal heap_bh41_w6_0 :  std_logic;
signal heap_bh41_w7_0 :  std_logic;
signal heap_bh41_w8_0 :  std_logic;
signal Y2X0_42_m40 :  std_logic_vector(5 downto 0);
signal PP42X0Y2_m40 :  std_logic_vector(5 downto 0);
signal heap_bh41_w1_3 :  std_logic;
signal heap_bh41_w2_4 :  std_logic;
signal heap_bh41_w3_3 :  std_logic;
signal heap_bh41_w4_3 :  std_logic;
signal heap_bh41_w5_3 :  std_logic;
signal Y2X1_42_m40 :  std_logic_vector(5 downto 0);
signal PP42X1Y2_m40 :  std_logic_vector(5 downto 0);
signal heap_bh41_w3_4 :  std_logic;
signal heap_bh41_w4_4 :  std_logic;
signal heap_bh41_w5_4 :  std_logic;
signal heap_bh41_w6_1 :  std_logic;
signal heap_bh41_w7_1 :  std_logic;
signal heap_bh41_w8_1 :  std_logic;
signal Y2X2_42_m40 :  std_logic_vector(5 downto 0);
signal PP42X2Y2_m40 :  std_logic_vector(5 downto 0);
signal heap_bh41_w6_2 :  std_logic;
signal heap_bh41_w7_2 :  std_logic;
signal heap_bh41_w8_2 :  std_logic;
signal heap_bh41_w9_0 :  std_logic;
signal heap_bh41_w10_0 :  std_logic;
signal heap_bh41_w11_0 :  std_logic;
signal heap_bh41_w2_5 :  std_logic;
signal CompressorIn_bh41_0_0 :  std_logic_vector(5 downto 0);
signal CompressorOut_bh41_0_0 :  std_logic_vector(2 downto 0);
signal heap_bh41_w2_6 :  std_logic;
signal heap_bh41_w3_5 :  std_logic;
signal heap_bh41_w4_5 :  std_logic;
signal CompressorIn_bh41_1_1 :  std_logic_vector(3 downto 0);
signal CompressorIn_bh41_1_2 :  std_logic_vector(0 downto 0);
signal CompressorOut_bh41_1_1 :  std_logic_vector(2 downto 0);
signal heap_bh41_w3_6 :  std_logic;
signal heap_bh41_w4_6 :  std_logic;
signal heap_bh41_w5_5 :  std_logic;
signal CompressorIn_bh41_2_3 :  std_logic_vector(3 downto 0);
signal CompressorIn_bh41_2_4 :  std_logic_vector(0 downto 0);
signal CompressorOut_bh41_2_2 :  std_logic_vector(2 downto 0);
signal heap_bh41_w4_7 :  std_logic;
signal heap_bh41_w5_6 :  std_logic;
signal heap_bh41_w6_3 :  std_logic;
signal CompressorIn_bh41_3_5 :  std_logic_vector(3 downto 0);
signal CompressorIn_bh41_3_6 :  std_logic_vector(0 downto 0);
signal CompressorOut_bh41_3_3 :  std_logic_vector(2 downto 0);
signal heap_bh41_w5_7 :  std_logic;
signal heap_bh41_w6_4 :  std_logic;
signal heap_bh41_w7_3 :  std_logic;
signal CompressorIn_bh41_4_7 :  std_logic_vector(3 downto 0);
signal CompressorOut_bh41_4_4 :  std_logic_vector(2 downto 0);
signal heap_bh41_w1_4 :  std_logic;
signal heap_bh41_w2_7 :  std_logic;
signal heap_bh41_w3_7 :  std_logic;
signal CompressorIn_bh41_5_8 :  std_logic_vector(2 downto 0);
signal CompressorIn_bh41_5_9 :  std_logic_vector(1 downto 0);
signal CompressorOut_bh41_5_5 :  std_logic_vector(2 downto 0);
signal heap_bh41_w7_4 :  std_logic;
signal heap_bh41_w8_3 :  std_logic;
signal heap_bh41_w9_1 :  std_logic;
signal CompressorIn_bh41_6_10 :  std_logic_vector(2 downto 0);
signal CompressorOut_bh41_6_6 :  std_logic_vector(1 downto 0);
signal heap_bh41_w0_3 :  std_logic;
signal heap_bh41_w1_5 :  std_logic;
signal tempR_bh41_0 :  std_logic;
signal CompressorIn_bh41_7_11 :  std_logic_vector(3 downto 0);
signal CompressorIn_bh41_7_12 :  std_logic_vector(0 downto 0);
signal CompressorOut_bh41_7_7 :  std_logic_vector(2 downto 0);
signal heap_bh41_w3_8 :  std_logic;
signal heap_bh41_w4_8 :  std_logic;
signal heap_bh41_w5_8 :  std_logic;
signal CompressorIn_bh41_8_13 :  std_logic_vector(3 downto 0);
signal CompressorIn_bh41_8_14 :  std_logic_vector(0 downto 0);
signal CompressorOut_bh41_8_8 :  std_logic_vector(2 downto 0);
signal heap_bh41_w6_5 :  std_logic;
signal heap_bh41_w7_5 :  std_logic;
signal heap_bh41_w8_4 :  std_logic;
signal CompressorIn_bh41_9_15 :  std_logic_vector(2 downto 0);
signal CompressorOut_bh41_9_9 :  std_logic_vector(1 downto 0);
signal heap_bh41_w5_9 :  std_logic;
signal heap_bh41_w6_6 :  std_logic;
signal CompressorIn_bh41_10_16 :  std_logic_vector(2 downto 0);
signal CompressorIn_bh41_10_17 :  std_logic_vector(1 downto 0);
signal CompressorOut_bh41_10_10 :  std_logic_vector(2 downto 0);
signal heap_bh41_w4_9 :  std_logic;
signal heap_bh41_w5_10 :  std_logic;
signal heap_bh41_w6_7 :  std_logic;
signal CompressorIn_bh41_11_18 :  std_logic_vector(2 downto 0);
signal CompressorIn_bh41_11_19 :  std_logic_vector(1 downto 0);
signal CompressorOut_bh41_11_11 :  std_logic_vector(2 downto 0);
signal heap_bh41_w8_5 :  std_logic;
signal heap_bh41_w9_2 :  std_logic;
signal heap_bh41_w10_1 :  std_logic;
signal CompressorIn_bh41_12_20 :  std_logic_vector(2 downto 0);
signal CompressorIn_bh41_12_21 :  std_logic_vector(1 downto 0);
signal CompressorOut_bh41_12_12 :  std_logic_vector(2 downto 0);
signal heap_bh41_w6_8 :  std_logic;
signal heap_bh41_w7_6 :  std_logic;
signal heap_bh41_w8_6 :  std_logic;
signal finalAdderIn0_bh41 :  std_logic_vector(11 downto 0);
signal finalAdderIn1_bh41 :  std_logic_vector(11 downto 0);
signal finalAdderCin_bh41 :  std_logic;
signal finalAdderOut_bh41 :  std_logic_vector(11 downto 0);
signal CompressionResult41 :  std_logic_vector(12 downto 0);
attribute rom_extract: string;
attribute rom_style: string;
attribute rom_extract of SmallMultTableP3x3r6XuYu: component is "yes";
attribute rom_style of SmallMultTableP3x3r6XuYu: component is "distributed";
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   XX_m40 <= Y ;
   YY_m40 <= X ;
   -- code generated by IntMultiplier::buildHeapLogicOnly()
   -- buildheaplogiconly called for lsbX=0 lsbY=0 msbX=8 msbY=7
   Xp_m40b42 <= XX_m40(7 downto 0) & "0";
   Yp_m40b42 <= YY_m40(6 downto 0) & "00";
   x_m40b42_0 <= Xp_m40b42(2 downto 0);
   x_m40b42_1 <= Xp_m40b42(5 downto 3);
   x_m40b42_2 <= Xp_m40b42(8 downto 6);
   y_m40b42_0 <= Yp_m40b42(2 downto 0);
   y_m40b42_1 <= Yp_m40b42(5 downto 3);
   y_m40b42_2 <= Yp_m40b42(8 downto 6);
   ----------------Synchro barrier, entering cycle 0----------------
   -- Partial product row number 0
   Y0X1_42_m40 <= y_m40b42_0 & x_m40b42_1;
   PP_m40_42X1Y0_Tbl: SmallMultTableP3x3r6XuYu  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => Y0X1_42_m40,
                 Y => PP42X1Y0_m40);
   -- Adding the relevant bits to the heap of bits
   heap_bh41_w0_0 <= PP42X1Y0_m40(3); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w1_0 <= PP42X1Y0_m40(4); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w2_0 <= PP42X1Y0_m40(5); -- cycle= 0 cp= 5.4816e-10

   Y0X2_42_m40 <= y_m40b42_0 & x_m40b42_2;
   PP_m40_42X2Y0_Tbl: SmallMultTableP3x3r6XuYu  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => Y0X2_42_m40,
                 Y => PP42X2Y0_m40);
   -- Adding the relevant bits to the heap of bits
   heap_bh41_w2_1 <= PP42X2Y0_m40(2); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w3_0 <= PP42X2Y0_m40(3); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w4_0 <= PP42X2Y0_m40(4); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w5_0 <= PP42X2Y0_m40(5); -- cycle= 0 cp= 5.4816e-10

   -- Partial product row number 1
   Y1X0_42_m40 <= y_m40b42_1 & x_m40b42_0;
   PP_m40_42X0Y1_Tbl: SmallMultTableP3x3r6XuYu  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => Y1X0_42_m40,
                 Y => PP42X0Y1_m40);
   -- Adding the relevant bits to the heap of bits
   heap_bh41_w0_1 <= PP42X0Y1_m40(3); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w1_1 <= PP42X0Y1_m40(4); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w2_2 <= PP42X0Y1_m40(5); -- cycle= 0 cp= 5.4816e-10

   Y1X1_42_m40 <= y_m40b42_1 & x_m40b42_1;
   PP_m40_42X1Y1_Tbl: SmallMultTableP3x3r6XuYu  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => Y1X1_42_m40,
                 Y => PP42X1Y1_m40);
   -- Adding the relevant bits to the heap of bits
   heap_bh41_w0_2 <= PP42X1Y1_m40(0); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w1_2 <= PP42X1Y1_m40(1); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w2_3 <= PP42X1Y1_m40(2); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w3_1 <= PP42X1Y1_m40(3); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w4_1 <= PP42X1Y1_m40(4); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w5_1 <= PP42X1Y1_m40(5); -- cycle= 0 cp= 5.4816e-10

   Y1X2_42_m40 <= y_m40b42_1 & x_m40b42_2;
   PP_m40_42X2Y1_Tbl: SmallMultTableP3x3r6XuYu  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => Y1X2_42_m40,
                 Y => PP42X2Y1_m40);
   -- Adding the relevant bits to the heap of bits
   heap_bh41_w3_2 <= PP42X2Y1_m40(0); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w4_2 <= PP42X2Y1_m40(1); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w5_2 <= PP42X2Y1_m40(2); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w6_0 <= PP42X2Y1_m40(3); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w7_0 <= PP42X2Y1_m40(4); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w8_0 <= PP42X2Y1_m40(5); -- cycle= 0 cp= 5.4816e-10

   -- Partial product row number 2
   Y2X0_42_m40 <= y_m40b42_2 & x_m40b42_0;
   PP_m40_42X0Y2_Tbl: SmallMultTableP3x3r6XuYu  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => Y2X0_42_m40,
                 Y => PP42X0Y2_m40);
   -- Adding the relevant bits to the heap of bits
   heap_bh41_w1_3 <= PP42X0Y2_m40(1); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w2_4 <= PP42X0Y2_m40(2); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w3_3 <= PP42X0Y2_m40(3); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w4_3 <= PP42X0Y2_m40(4); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w5_3 <= PP42X0Y2_m40(5); -- cycle= 0 cp= 5.4816e-10

   Y2X1_42_m40 <= y_m40b42_2 & x_m40b42_1;
   PP_m40_42X1Y2_Tbl: SmallMultTableP3x3r6XuYu  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => Y2X1_42_m40,
                 Y => PP42X1Y2_m40);
   -- Adding the relevant bits to the heap of bits
   heap_bh41_w3_4 <= PP42X1Y2_m40(0); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w4_4 <= PP42X1Y2_m40(1); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w5_4 <= PP42X1Y2_m40(2); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w6_1 <= PP42X1Y2_m40(3); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w7_1 <= PP42X1Y2_m40(4); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w8_1 <= PP42X1Y2_m40(5); -- cycle= 0 cp= 5.4816e-10

   Y2X2_42_m40 <= y_m40b42_2 & x_m40b42_2;
   PP_m40_42X2Y2_Tbl: SmallMultTableP3x3r6XuYu  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => Y2X2_42_m40,
                 Y => PP42X2Y2_m40);
   -- Adding the relevant bits to the heap of bits
   heap_bh41_w6_2 <= PP42X2Y2_m40(0); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w7_2 <= PP42X2Y2_m40(1); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w8_2 <= PP42X2Y2_m40(2); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w9_0 <= PP42X2Y2_m40(3); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w10_0 <= PP42X2Y2_m40(4); -- cycle= 0 cp= 5.4816e-10
   heap_bh41_w11_0 <= PP42X2Y2_m40(5); -- cycle= 0 cp= 5.4816e-10


   -- Beginning of code generated by BitHeap::generateCompressorVHDL
   -- code generated by BitHeap::generateSupertileVHDL()
   ----------------Synchro barrier, entering cycle 0----------------

   -- Adding the constant bits
   heap_bh41_w2_5 <= '1'; -- cycle= 0 cp= 0

   ----------------Synchro barrier, entering cycle 0----------------

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_0_0 <= heap_bh41_w2_5 & heap_bh41_w2_4 & heap_bh41_w2_3 & heap_bh41_w2_2 & heap_bh41_w2_1 & heap_bh41_w2_0;
   Compressor_bh41_0: Compressor_6_3
      port map ( R => CompressorOut_bh41_0_0   ,
                 X0 => CompressorIn_bh41_0_0);
   heap_bh41_w2_6 <= CompressorOut_bh41_0_0(0); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w3_5 <= CompressorOut_bh41_0_0(1); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w4_5 <= CompressorOut_bh41_0_0(2); -- cycle= 0 cp= 1.07888e-09

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_1_1 <= heap_bh41_w3_4 & heap_bh41_w3_3 & heap_bh41_w3_2 & heap_bh41_w3_1;
   CompressorIn_bh41_1_2(0) <= heap_bh41_w4_4;
   Compressor_bh41_1: Compressor_14_3
      port map ( R => CompressorOut_bh41_1_1   ,
                 X0 => CompressorIn_bh41_1_1,
                 X1 => CompressorIn_bh41_1_2);
   heap_bh41_w3_6 <= CompressorOut_bh41_1_1(0); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w4_6 <= CompressorOut_bh41_1_1(1); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w5_5 <= CompressorOut_bh41_1_1(2); -- cycle= 0 cp= 1.07888e-09

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_2_3 <= heap_bh41_w4_3 & heap_bh41_w4_2 & heap_bh41_w4_1 & heap_bh41_w4_0;
   CompressorIn_bh41_2_4(0) <= heap_bh41_w5_4;
   Compressor_bh41_2: Compressor_14_3
      port map ( R => CompressorOut_bh41_2_2   ,
                 X0 => CompressorIn_bh41_2_3,
                 X1 => CompressorIn_bh41_2_4);
   heap_bh41_w4_7 <= CompressorOut_bh41_2_2(0); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w5_6 <= CompressorOut_bh41_2_2(1); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w6_3 <= CompressorOut_bh41_2_2(2); -- cycle= 0 cp= 1.07888e-09

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_3_5 <= heap_bh41_w5_3 & heap_bh41_w5_2 & heap_bh41_w5_1 & heap_bh41_w5_0;
   CompressorIn_bh41_3_6(0) <= heap_bh41_w6_2;
   Compressor_bh41_3: Compressor_14_3
      port map ( R => CompressorOut_bh41_3_3   ,
                 X0 => CompressorIn_bh41_3_5,
                 X1 => CompressorIn_bh41_3_6);
   heap_bh41_w5_7 <= CompressorOut_bh41_3_3(0); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w6_4 <= CompressorOut_bh41_3_3(1); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w7_3 <= CompressorOut_bh41_3_3(2); -- cycle= 0 cp= 1.07888e-09

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_4_7 <= heap_bh41_w1_3 & heap_bh41_w1_2 & heap_bh41_w1_1 & heap_bh41_w1_0;
   Compressor_bh41_4: Compressor_4_3
      port map ( R => CompressorOut_bh41_4_4   ,
                 X0 => CompressorIn_bh41_4_7);
   heap_bh41_w1_4 <= CompressorOut_bh41_4_4(0); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w2_7 <= CompressorOut_bh41_4_4(1); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w3_7 <= CompressorOut_bh41_4_4(2); -- cycle= 0 cp= 1.07888e-09

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_5_8 <= heap_bh41_w7_2 & heap_bh41_w7_1 & heap_bh41_w7_0;
   CompressorIn_bh41_5_9 <= heap_bh41_w8_2 & heap_bh41_w8_1;
   Compressor_bh41_5: Compressor_23_3
      port map ( R => CompressorOut_bh41_5_5   ,
                 X0 => CompressorIn_bh41_5_8,
                 X1 => CompressorIn_bh41_5_9);
   heap_bh41_w7_4 <= CompressorOut_bh41_5_5(0); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w8_3 <= CompressorOut_bh41_5_5(1); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w9_1 <= CompressorOut_bh41_5_5(2); -- cycle= 0 cp= 1.07888e-09

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_6_10 <= heap_bh41_w0_2 & heap_bh41_w0_1 & heap_bh41_w0_0;
   Compressor_bh41_6: Compressor_3_2
      port map ( R => CompressorOut_bh41_6_6   ,
                 X0 => CompressorIn_bh41_6_10);
   heap_bh41_w0_3 <= CompressorOut_bh41_6_6(0); -- cycle= 0 cp= 1.07888e-09
   heap_bh41_w1_5 <= CompressorOut_bh41_6_6(1); -- cycle= 0 cp= 1.07888e-09
   ----------------Synchro barrier, entering cycle 0----------------
   tempR_bh41_0 <= heap_bh41_w0_3; -- already compressed

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_7_11 <= heap_bh41_w3_0 & heap_bh41_w3_7 & heap_bh41_w3_6 & heap_bh41_w3_5;
   CompressorIn_bh41_7_12(0) <= heap_bh41_w4_7;
   Compressor_bh41_7: Compressor_14_3
      port map ( R => CompressorOut_bh41_7_7   ,
                 X0 => CompressorIn_bh41_7_11,
                 X1 => CompressorIn_bh41_7_12);
   heap_bh41_w3_8 <= CompressorOut_bh41_7_7(0); -- cycle= 0 cp= 1.6096e-09
   heap_bh41_w4_8 <= CompressorOut_bh41_7_7(1); -- cycle= 0 cp= 1.6096e-09
   heap_bh41_w5_8 <= CompressorOut_bh41_7_7(2); -- cycle= 0 cp= 1.6096e-09

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_8_13 <= heap_bh41_w6_1 & heap_bh41_w6_0 & heap_bh41_w6_4 & heap_bh41_w6_3;
   CompressorIn_bh41_8_14(0) <= heap_bh41_w7_4;
   Compressor_bh41_8: Compressor_14_3
      port map ( R => CompressorOut_bh41_8_8   ,
                 X0 => CompressorIn_bh41_8_13,
                 X1 => CompressorIn_bh41_8_14);
   heap_bh41_w6_5 <= CompressorOut_bh41_8_8(0); -- cycle= 0 cp= 1.6096e-09
   heap_bh41_w7_5 <= CompressorOut_bh41_8_8(1); -- cycle= 0 cp= 1.6096e-09
   heap_bh41_w8_4 <= CompressorOut_bh41_8_8(2); -- cycle= 0 cp= 1.6096e-09

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_9_15 <= heap_bh41_w5_7 & heap_bh41_w5_6 & heap_bh41_w5_5;
   Compressor_bh41_9: Compressor_3_2
      port map ( R => CompressorOut_bh41_9_9   ,
                 X0 => CompressorIn_bh41_9_15);
   heap_bh41_w5_9 <= CompressorOut_bh41_9_9(0); -- cycle= 0 cp= 1.6096e-09
   heap_bh41_w6_6 <= CompressorOut_bh41_9_9(1); -- cycle= 0 cp= 1.6096e-09

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_10_16 <= heap_bh41_w4_6 & heap_bh41_w4_5 & heap_bh41_w4_8;
   CompressorIn_bh41_10_17 <= heap_bh41_w5_9 & heap_bh41_w5_8;
   Compressor_bh41_10: Compressor_23_3
      port map ( R => CompressorOut_bh41_10_10   ,
                 X0 => CompressorIn_bh41_10_16,
                 X1 => CompressorIn_bh41_10_17);
   heap_bh41_w4_9 <= CompressorOut_bh41_10_10(0); -- cycle= 0 cp= 2.14032e-09
   heap_bh41_w5_10 <= CompressorOut_bh41_10_10(1); -- cycle= 0 cp= 2.14032e-09
   heap_bh41_w6_7 <= CompressorOut_bh41_10_10(2); -- cycle= 0 cp= 2.14032e-09

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_11_18 <= heap_bh41_w8_0 & heap_bh41_w8_3 & heap_bh41_w8_4;
   CompressorIn_bh41_11_19 <= heap_bh41_w9_0 & heap_bh41_w9_1;
   Compressor_bh41_11: Compressor_23_3
      port map ( R => CompressorOut_bh41_11_11   ,
                 X0 => CompressorIn_bh41_11_18,
                 X1 => CompressorIn_bh41_11_19);
   heap_bh41_w8_5 <= CompressorOut_bh41_11_11(0); -- cycle= 0 cp= 2.14032e-09
   heap_bh41_w9_2 <= CompressorOut_bh41_11_11(1); -- cycle= 0 cp= 2.14032e-09
   heap_bh41_w10_1 <= CompressorOut_bh41_11_11(2); -- cycle= 0 cp= 2.14032e-09

   ----------------Synchro barrier, entering cycle 0----------------
   CompressorIn_bh41_12_20 <= heap_bh41_w6_6 & heap_bh41_w6_5 & heap_bh41_w6_7;
   CompressorIn_bh41_12_21 <= heap_bh41_w7_3 & heap_bh41_w7_5;
   Compressor_bh41_12: Compressor_23_3
      port map ( R => CompressorOut_bh41_12_12   ,
                 X0 => CompressorIn_bh41_12_20,
                 X1 => CompressorIn_bh41_12_21);
   heap_bh41_w6_8 <= CompressorOut_bh41_12_12(0); -- cycle= 0 cp= 2.67104e-09
   heap_bh41_w7_6 <= CompressorOut_bh41_12_12(1); -- cycle= 0 cp= 2.67104e-09
   heap_bh41_w8_6 <= CompressorOut_bh41_12_12(2); -- cycle= 0 cp= 2.67104e-09
   ----------------Synchro barrier, entering cycle 0----------------
   finalAdderIn0_bh41 <= "0" & heap_bh41_w11_0 & heap_bh41_w10_0 & heap_bh41_w9_2 & heap_bh41_w8_5 & heap_bh41_w7_6 & heap_bh41_w6_8 & heap_bh41_w5_10 & heap_bh41_w4_9 & heap_bh41_w3_8 & heap_bh41_w2_7 & heap_bh41_w1_5;
   finalAdderIn1_bh41 <= "0" & '0' & heap_bh41_w10_1 & '0' & heap_bh41_w8_6 & '0' & '0' & '0' & '0' & '0' & heap_bh41_w2_6 & heap_bh41_w1_4;
   finalAdderCin_bh41 <= '0';
   Adder_final41_0: IntAdder_12_f120_uid73  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => finalAdderCin_bh41,
                 R => finalAdderOut_bh41   ,
                 X => finalAdderIn0_bh41,
                 Y => finalAdderIn1_bh41);
   -- concatenate all the compressed chunks
   CompressionResult41 <= finalAdderOut_bh41 & tempR_bh41_0;
   -- End of code generated by BitHeap::generateCompressorVHDL
   R <= CompressionResult41(11 downto 3);
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_17_f120_uid81
--                    (IntAdderAlternative_17_f120_uid85)
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

entity IntAdder_17_f120_uid81 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(16 downto 0);
          Y : in  std_logic_vector(16 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(16 downto 0)   );
end entity;

architecture arch of IntAdder_17_f120_uid81 is
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
--                           IntAdder_21_f120_uid88
--                    (IntAdderAlternative_21_f120_uid92)
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

entity IntAdder_21_f120_uid88 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(20 downto 0);
          Y : in  std_logic_vector(20 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(20 downto 0)   );
end entity;

architecture arch of IntAdder_21_f120_uid88 is
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
--                                  FPExp613
--                              (FPExp_6_13_120)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: F. de Dinechin, Bogdan Pasca (2008-2013)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPExp613 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(6+13+2 downto 0);
          R : out  std_logic_vector(6+13+2 downto 0)   );
end entity;

architecture arch of FPExp613 is
   component FixRealKCM_0_5_M16_log_2_unsigned is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(21 downto 0)   );
   end component;

   component FixRealKCM_M3_4_0_1_log_2_unsigned is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(7 downto 0);
             R : out  std_logic_vector(5 downto 0)   );
   end component;

   component IntAdder_16_f126_uid23 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(15 downto 0);
             Y : in  std_logic_vector(15 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(15 downto 0)   );
   end component;

   component IntAdder_17_f120_uid81 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(16 downto 0);
             Y : in  std_logic_vector(16 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(16 downto 0)   );
   end component;

   component IntAdder_21_f120_uid88 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(20 downto 0);
             Y : in  std_logic_vector(20 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(20 downto 0)   );
   end component;

   component IntAdder_8_f120_uid32 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(7 downto 0);
             Y : in  std_logic_vector(7 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(7 downto 0)   );
   end component;

   component IntMultiplier_UsingDSP_7_8_9_unsigned_uid39 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(6 downto 0);
             Y : in  std_logic_vector(7 downto 0);
             R : out  std_logic_vector(8 downto 0)   );
   end component;

   component LeftShifter_14_by_max_21_uid3 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(13 downto 0);
             S : in  std_logic_vector(4 downto 0);
             R : out  std_logic_vector(34 downto 0)   );
   end component;

   component MagicSPExpTable is
      port ( X1 : in  std_logic_vector(8 downto 0);
             Y1 : out  std_logic_vector(24 downto 0);
             X2 : in  std_logic_vector(8 downto 0);
             Y2 : out  std_logic_vector(24 downto 0)   );
   end component;

signal Xexn, Xexn_d1, Xexn_d2 :  std_logic_vector(1 downto 0);
signal XSign, XSign_d1, XSign_d2 :  std_logic;
signal XexpField :  std_logic_vector(5 downto 0);
signal Xfrac :  std_logic_vector(12 downto 0);
signal e0 :  std_logic_vector(7 downto 0);
signal shiftVal :  std_logic_vector(7 downto 0);
signal resultWillBeOne :  std_logic;
signal mXu :  std_logic_vector(13 downto 0);
signal oufl0, oufl0_d1, oufl0_d2 :  std_logic;
signal shiftValIn :  std_logic_vector(4 downto 0);
signal fixX0 :  std_logic_vector(34 downto 0);
signal fixX :  std_logic_vector(21 downto 0);
signal xMulIn :  std_logic_vector(7 downto 0);
signal absK :  std_logic_vector(5 downto 0);
signal minusAbsK :  std_logic_vector(6 downto 0);
signal K, K_d1, K_d2 :  std_logic_vector(6 downto 0);
signal absKLog2 :  std_logic_vector(21 downto 0);
signal subOp1 :  std_logic_vector(15 downto 0);
signal subOp2 :  std_logic_vector(15 downto 0);
signal Y :  std_logic_vector(15 downto 0);
signal Addr1 :  std_logic_vector(8 downto 0);
signal Z :  std_logic_vector(6 downto 0);
signal Addr2 :  std_logic_vector(8 downto 0);
signal expZ_output :  std_logic_vector(24 downto 0);
signal expA_output :  std_logic_vector(24 downto 0);
signal expA, expA_d1, expA_d2 :  std_logic_vector(16 downto 0);
signal expZminus1, expZminus1_d1 :  std_logic_vector(7 downto 0);
signal expArounded0 :  std_logic_vector(7 downto 0);
signal expArounded, expArounded_d1 :  std_logic_vector(6 downto 0);
signal lowerProduct, lowerProduct_d1 :  std_logic_vector(8 downto 0);
signal extendedLowerProduct :  std_logic_vector(16 downto 0);
signal expY :  std_logic_vector(16 downto 0);
signal needNoNorm :  std_logic;
signal preRoundBiasSig :  std_logic_vector(20 downto 0);
signal roundBit :  std_logic;
signal roundNormAddend :  std_logic_vector(20 downto 0);
signal roundedExpSigRes :  std_logic_vector(20 downto 0);
signal roundedExpSig :  std_logic_vector(20 downto 0);
signal ofl1 :  std_logic;
signal ofl2 :  std_logic;
signal ofl3 :  std_logic;
signal ofl :  std_logic;
signal ufl1 :  std_logic;
signal ufl2 :  std_logic;
signal ufl3 :  std_logic;
signal ufl :  std_logic;
signal Rexn :  std_logic_vector(1 downto 0);
constant g: positive := 3;
constant wE: positive := 6;
constant wF: positive := 13;
constant wFIn: positive := 13;
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            Xexn_d1 <=  Xexn;
            Xexn_d2 <=  Xexn_d1;
            XSign_d1 <=  XSign;
            XSign_d2 <=  XSign_d1;
            oufl0_d1 <=  oufl0;
            oufl0_d2 <=  oufl0_d1;
            K_d1 <=  K;
            K_d2 <=  K_d1;
            expA_d1 <=  expA;
            expA_d2 <=  expA_d1;
            expZminus1_d1 <=  expZminus1;
            expArounded_d1 <=  expArounded;
            lowerProduct_d1 <=  lowerProduct;
         end if;
      end process;
   Xexn <= X(wE+wFIn+2 downto wE+wFIn+1);
   XSign <= X(wE+wFIn);
   XexpField <= X(wE+wFIn-1 downto wFIn);
   Xfrac <= X(wFIn-1 downto 0);
   e0 <= conv_std_logic_vector(15, wE+2);  -- bias - (wF+g)
   shiftVal <= ("00" & XexpField) - e0; -- for a left shift
   -- underflow when input is shifted to zero (shiftval<0), in which case exp = 1
   resultWillBeOne <= shiftVal(wE+1);
   --  mantissa with implicit bit
   mXu <= "1" & Xfrac;
   -- Partial overflow/underflow detection
   oufl0 <= not shiftVal(wE+1) when shiftVal(wE downto 0) >= conv_std_logic_vector(21, wE+1) else '0';
   ---------------- cycle 0----------------
   shiftValIn <= shiftVal(4 downto 0);
   mantissa_shift: LeftShifter_14_by_max_21_uid3  -- pipelineDepth=0 maxInDelay=2.29952e-09
      port map ( clk  => clk,
                 rst  => rst,
                 R => fixX0,
                 S => shiftValIn,
                 X => mXu);
   fixX <=  fixX0(34 downto 13)when resultWillBeOne='0' else "0000000000000000000000";
   xMulIn <=  fixX(20 downto 13); -- truncation, error 2^-3
   mulInvLog2: FixRealKCM_M3_4_0_1_log_2_unsigned  -- pipelineDepth=0 maxInDelay=2.99488e-09
      port map ( clk  => clk,
                 rst  => rst,
                 R => absK,
                 X => xMulIn);
   minusAbsK <= (6 downto 0 => '0') - ('0' & absK);
   K <= minusAbsK when  XSign='1'   else ('0' & absK);
   ---------------- cycle 0----------------
   mulLog2: FixRealKCM_0_5_M16_log_2_unsigned  -- pipelineDepth=0 maxInDelay=4.99912e-09
      port map ( clk  => clk,
                 rst  => rst,
                 R => absKLog2,
                 X => absK);
   subOp1 <= fixX(15 downto 0) when XSign='0' else not (fixX(15 downto 0));
   subOp2 <= absKLog2(15 downto 0) when XSign='1' else not (absKLog2(15 downto 0));
   theYAdder: IntAdder_16_f126_uid23  -- pipelineDepth=0 maxInDelay=6.50528e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => '1',
                 R => Y,
                 X => subOp1,
                 Y => subOp2);

   -- Now compute the exp of this fixed-point value
   Addr1 <= Y(15 downto 7);
   Z <= Y(6 downto 0);
   Addr2 <= Z & (1 downto 0 => '0');
   table: MagicSPExpTable
      port map ( X1 => Addr1,
                 X2 => Addr2,
                 Y1 => expA_output,
                 Y2 => expZ_output);
   expA <=  expA_output(24 downto 8);
   expZminus1 <= expZ_output(7 downto 0);
   ---------------- cycle 0----------------
   -- Rounding expA to the same accuracy as expZminus1
   --   (truncation would not be accurate enough and require one more guard bit)
   Adder_expArounded0: IntAdder_8_f120_uid32  -- pipelineDepth=0 maxInDelay=2.186e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin =>  '1' ,
                 R => expArounded0,
                 X => expA(16 downto 9),
                 Y => "00000000");
   expArounded <= expArounded0(7 downto 1);
   ----------------Synchro barrier, entering cycle 1----------------
   TheLowerProduct: IntMultiplier_UsingDSP_7_8_9_unsigned_uid39  -- pipelineDepth=0 maxInDelay=4.36e-10
      port map ( clk  => clk,
                 rst  => rst,
                 R => lowerProduct,
                 X => expArounded_d1,
                 Y => expZminus1_d1);

   ----------------Synchro barrier, entering cycle 2----------------
   extendedLowerProduct <= ((16 downto 9 => '0') & lowerProduct_d1(8 downto 0));
   -- Final addition -- the product MSB bit weight is -k+2 = -7
   TheFinalAdder: IntAdder_17_f120_uid81  -- pipelineDepth=0 maxInDelay=4.4472e-10
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => '0',
                 R => expY,
                 X => expA_d2,
                 Y => extendedLowerProduct);

   needNoNorm <= expY(16);
   -- Rounding: all this should consume one row of LUTs
   preRoundBiasSig <= conv_std_logic_vector(31, wE+2)  & expY(15 downto 3) when needNoNorm = '1'
      else conv_std_logic_vector(30, wE+2)  & expY(14 downto 2) ;
   roundBit <= expY(2)  when needNoNorm = '1'    else expY(1) ;
   roundNormAddend <= K_d2(6) & K_d2 & (12 downto 1 => '0') & roundBit;
   roundedExpSigOperandAdder: IntAdder_21_f120_uid88  -- pipelineDepth=0 maxInDelay=3.07156e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => '0',
                 R => roundedExpSigRes,
                 X => preRoundBiasSig,
                 Y => roundNormAddend);

   -- delay at adder output is 4.22256e-09
   roundedExpSig <= roundedExpSigRes when Xexn_d2="01" else  "000" & (wE-2 downto 0 => '1') & (wF-1 downto 0 => '0');
   ofl1 <= not XSign_d2 and oufl0_d2 and (not Xexn_d2(1) and Xexn_d2(0)); -- input positive, normal,  very large
   ofl2 <= not XSign_d2 and (roundedExpSig(wE+wF) and not roundedExpSig(wE+wF+1)) and (not Xexn_d2(1) and Xexn_d2(0)); -- input positive, normal, overflowed
   ofl3 <= not XSign_d2 and Xexn_d2(1) and not Xexn_d2(0);  -- input was -infty
   ofl <= ofl1 or ofl2 or ofl3;
   ufl1 <= (roundedExpSig(wE+wF) and roundedExpSig(wE+wF+1))  and (not Xexn_d2(1) and Xexn_d2(0)); -- input normal
   ufl2 <= XSign_d2 and Xexn_d2(1) and not Xexn_d2(0);  -- input was -infty
   ufl3 <= XSign_d2 and oufl0_d2  and (not Xexn_d2(1) and Xexn_d2(0)); -- input negative, normal,  very large
   ufl <= ufl1 or ufl2 or ufl3;
   Rexn <= "11" when Xexn_d2 = "11"
      else "10" when ofl='1'
      else "00" when ufl='1'
      else "01";
   R <= Rexn & '0' & roundedExpSig(18 downto 0);
end architecture;
