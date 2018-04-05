-- FPLog613.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ ./flopoco -name=FPLog613 -frequency=120 -useHardMult=no FPLog 6 13 0
-- Updating entity name to: FPLog613
-- 
-- Final report:
-- |---Entity LZOC_13_4_uid3
-- |      Not pipelined
-- |---Entity LeftShifter_8_by_max_8_uid6
-- |      Not pipelined
-- |---Entity InvTable_0_6_7
-- |      Not pipelined
-- |---Entity IntAdder_17_f120_uid11
-- |      Not pipelined
-- |---Entity IntAdder_17_f120_uid18
-- |      Not pipelined
-- |---Entity IntSquarer_12_uid25
-- |      Not pipelined
-- |---Entity IntAdder_17_f120_uid28
-- |      Not pipelined
-- |---Entity LogTable_0_6_24
-- |      Not pipelined
-- |---Entity LogTable_1_4_20
-- |      Not pipelined
-- |---Entity IntAdder_24_f120_uid45
-- |      Not pipelined
-- |---Entity IntAdder_24_f120_uid52
-- |      Not pipelined
-- |   |---Entity KCMTable_6_90852_unsigned
-- |   |      Not pipelined
-- |---Entity IntIntKCM_6_90852_unsigned
-- |      Not pipelined
-- |---Entity IntAdder_30_f120_uid63
-- |      Not pipelined
-- |---Entity LZCShifter_30_to_24_counting_32_uid70
-- |      Pipeline depth = 1
-- |---Entity RightShifter_12_by_max_11_uid73
-- |      Not pipelined
-- |---Entity IntAdder_19_f120_uid76
-- |      Not pipelined
-- |---Entity IntAdder_19_f120_uid83
-- |      Not pipelined
-- Entity FPLog613
--    Pipeline depth = 6
-- Output file: flopoco.vhdl
-- vagrant@vagrant-ubuntu-trusty-32:~/flopoco-3.0.beta5$ cat flopoco.vhdl
--------------------------------------------------------------------------------
--                               LZOC_13_4_uid3
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

entity LZOC_13_4_uid3 is
   port ( clk, rst : in std_logic;
          I : in  std_logic_vector(12 downto 0);
          OZB : in  std_logic;
          O : out  std_logic_vector(3 downto 0)   );
end entity;

architecture arch of LZOC_13_4_uid3 is
signal sozb :  std_logic;
signal level4 :  std_logic_vector(15 downto 0);
signal digit4 :  std_logic;
signal level3 :  std_logic_vector(7 downto 0);
signal digit3 :  std_logic;
signal level2 :  std_logic_vector(3 downto 0);
signal digit2 :  std_logic;
signal level1 :  std_logic_vector(1 downto 0);
signal digit1 :  std_logic;
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   sozb <= OZB;
   level4<= I& (2 downto 0 => not(sozb));
   digit4<= '1' when level4(15 downto 8) = (15 downto 8 => sozb) else '0';
   level3<= level4(7 downto 0) when digit4='1' else level4(15 downto 8);
   digit3<= '1' when level3(7 downto 4) = (7 downto 4 => sozb) else '0';
   level2<= level3(3 downto 0) when digit3='1' else level3(7 downto 4);
   digit2<= '1' when level2(3 downto 2) = (3 downto 2 => sozb) else '0';
   level1<= level2(1 downto 0) when digit2='1' else level2(3 downto 2);
   digit1<= '1' when level1(1 downto 1) = (1 downto 1 => sozb) else '0';
   O <= digit4 & digit3 & digit2 & digit1;
end architecture;

--------------------------------------------------------------------------------
--                        LeftShifter_8_by_max_8_uid6
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

entity LeftShifter_8_by_max_8_uid6 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(7 downto 0);
          S : in  std_logic_vector(3 downto 0);
          R : out  std_logic_vector(15 downto 0)   );
end entity;

architecture arch of LeftShifter_8_by_max_8_uid6 is
signal level0 :  std_logic_vector(7 downto 0);
signal ps :  std_logic_vector(3 downto 0);
signal level1 :  std_logic_vector(8 downto 0);
signal level2 :  std_logic_vector(10 downto 0);
signal level3 :  std_logic_vector(14 downto 0);
signal level4 :  std_logic_vector(22 downto 0);
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
   R <= level4(15 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                               InvTable_0_6_7
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Florent de Dinechin (2007-2012)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
entity InvTable_0_6_7 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(5 downto 0);
          Y : out  std_logic_vector(6 downto 0)   );
end entity;

architecture arch of InvTable_0_6_7 is
begin
  with X select  Y <=
   "1000000" when "000000",
   "1000000" when "000001",
   "0111111" when "000010",
   "0111110" when "000011",
   "0111101" when "000100",
   "0111100" when "000101",
   "0111011" when "000110",
   "0111010" when "000111",
   "0111001" when "001000",
   "0111001" when "001001",
   "0111000" when "001010",
   "0110111" when "001011",
   "0110110" when "001100",
   "0110110" when "001101",
   "0110101" when "001110",
   "0110100" when "001111",
   "0110100" when "010000",
   "0110011" when "010001",
   "0110010" when "010010",
   "0110010" when "010011",
   "0110001" when "010100",
   "0110001" when "010101",
   "0110000" when "010110",
   "0110000" when "010111",
   "0101111" when "011000",
   "0101111" when "011001",
   "0101110" when "011010",
   "0101110" when "011011",
   "0101101" when "011100",
   "0101101" when "011101",
   "0101100" when "011110",
   "0101100" when "011111",
   "1010110" when "100000",
   "1010101" when "100001",
   "1010100" when "100010",
   "1010011" when "100011",
   "1010010" when "100100",
   "1010010" when "100101",
   "1010001" when "100110",
   "1010000" when "100111",
   "1001111" when "101000",
   "1001111" when "101001",
   "1001110" when "101010",
   "1001101" when "101011",
   "1001100" when "101100",
   "1001100" when "101101",
   "1001011" when "101110",
   "1001010" when "101111",
   "1001010" when "110000",
   "1001001" when "110001",
   "1001000" when "110010",
   "1001000" when "110011",
   "1000111" when "110100",
   "1000111" when "110101",
   "1000110" when "110110",
   "1000101" when "110111",
   "1000101" when "111000",
   "1000100" when "111001",
   "1000100" when "111010",
   "1000011" when "111011",
   "1000011" when "111100",
   "1000010" when "111101",
   "1000010" when "111110",
   "1000001" when "111111",
   "-------" when others;
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_17_f120_uid11
--                    (IntAdderAlternative_17_f120_uid15)
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

entity IntAdder_17_f120_uid11 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(16 downto 0);
          Y : in  std_logic_vector(16 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(16 downto 0)   );
end entity;

architecture arch of IntAdder_17_f120_uid11 is
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
--                           IntAdder_17_f120_uid18
--                    (IntAdderAlternative_17_f120_uid22)
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

entity IntAdder_17_f120_uid18 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(16 downto 0);
          Y : in  std_logic_vector(16 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(16 downto 0)   );
end entity;

architecture arch of IntAdder_17_f120_uid18 is
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
--                            IntSquarer_12_uid25
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Pasca (2009)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
entity IntSquarer_12_uid25 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(11 downto 0);
          R : out  std_logic_vector(23 downto 0)   );
end entity;

architecture arch of IntSquarer_12_uid25 is
signal sX :  std_logic_vector(11 downto 0);
signal sY :  std_logic_vector(11 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   sX <= X;
   sY <= X;
   R <= sX * sY;
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_17_f120_uid28
--                    (IntAdderAlternative_17_f120_uid32)
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

entity IntAdder_17_f120_uid28 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(16 downto 0);
          Y : in  std_logic_vector(16 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(16 downto 0)   );
end entity;

architecture arch of IntAdder_17_f120_uid28 is
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
--                              LogTable_0_6_24
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Florent de Dinechin (2007-2012)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
entity LogTable_0_6_24 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(5 downto 0);
          Y : out  std_logic_vector(23 downto 0)   );
end entity;

architecture arch of LogTable_0_6_24 is
begin
  with X select  Y <=
   "111111110000000000000000" when "000000",
   "111111110000000000000000" when "000001",
   "000000110000100000010110" when "000010",
   "000001110010000010101111" when "000011",
   "000010110100101001010101" when "000100",
   "000011111000010110011001" when "000101",
   "000100111101001100010001" when "000110",
   "000110000011001101011110" when "000111",
   "000111001010011100100111" when "001000",
   "000111001010011100100111" when "001001",
   "001000010010111100011101" when "001010",
   "001001011100101111111010" when "001011",
   "001010100111111010000001" when "001100",
   "001010100111111010000001" when "001101",
   "001011110100011110000011" when "001110",
   "001101000010011111011010" when "001111",
   "001101000010011111011010" when "010000",
   "001110010010000001110000" when "010001",
   "001111100011001000111001" when "010010",
   "001111100011001000111001" when "010011",
   "010000110101111000111010" when "010100",
   "010000110101111000111010" when "010101",
   "010010001010010110001000" when "010110",
   "010010001010010110001000" when "010111",
   "010011100000100101001010" when "011000",
   "010011100000100101001010" when "011001",
   "010100111000101010111000" when "011010",
   "010100111000101010111000" when "011011",
   "010110010010101100100001" when "011100",
   "010110010010101100100001" when "011101",
   "010111101110101111101001" when "011110",
   "010111101110101111101001" when "011111",
   "101100110101110001110101" when "100000",
   "101101100101101011111000" when "100001",
   "101110010110001010001110" when "100010",
   "101111000111001101101100" when "100011",
   "101111111000110111001111" when "100100",
   "101111111000110111001111" when "100101",
   "110000101011000111110001" when "100110",
   "110001011110000000010000" when "100111",
   "110010010001100001101110" when "101000",
   "110010010001100001101110" when "101001",
   "110011000101101101001011" when "101010",
   "110011111010100011101110" when "101011",
   "110100110000000110011111" when "101100",
   "110100110000000110011111" when "101101",
   "110101100110010110101001" when "101110",
   "110110011101010101011010" when "101111",
   "110110011101010101011010" when "110000",
   "110111010101000100000011" when "110001",
   "111000001101100011111001" when "110010",
   "111000001101100011111001" when "110011",
   "111001000110110110010011" when "110100",
   "111001000110110110010011" when "110101",
   "111010000000111100101110" when "110110",
   "111010111011111000101000" when "110111",
   "111010111011111000101000" when "111000",
   "111011110111101011101000" when "111001",
   "111011110111101011101000" when "111010",
   "111100110100010111010100" when "111011",
   "111100110100010111010100" when "111100",
   "111101110001111101011001" when "111101",
   "111101110001111101011001" when "111110",
   "111110110000011111101011" when "111111",
   "------------------------" when others;
end architecture;

--------------------------------------------------------------------------------
--                              LogTable_1_4_20
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Florent de Dinechin (2007-2012)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
entity LogTable_1_4_20 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(3 downto 0);
          Y : out  std_logic_vector(19 downto 0)   );
end entity;

architecture arch of LogTable_1_4_20 is
begin
  with X select  Y <=
   "00001000000000100000" when "0000",
   "00011000000000100000" when "0001",
   "00101000000100100001" when "0010",
   "00111000001100100101" when "0011",
   "01001000011000101110" when "0100",
   "01011000101000111111" when "0101",
   "01101000111101011000" when "0110",
   "01111001010101111110" when "0111",
   "10000001100011110100" when "1000",
   "10010010000010101111" when "1001",
   "10100010100101111010" when "1010",
   "10110011001101010111" when "1011",
   "11000011111001001010" when "1100",
   "11010100101001010101" when "1101",
   "11100101011101111001" when "1110",
   "11110110010110111010" when "1111",
   "--------------------" when others;
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_24_f120_uid45
--                    (IntAdderAlternative_24_f120_uid49)
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

entity IntAdder_24_f120_uid45 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(23 downto 0);
          Y : in  std_logic_vector(23 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(23 downto 0)   );
end entity;

architecture arch of IntAdder_24_f120_uid45 is
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
--                           IntAdder_24_f120_uid52
--                    (IntAdderAlternative_24_f120_uid56)
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

entity IntAdder_24_f120_uid52 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(23 downto 0);
          Y : in  std_logic_vector(23 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(23 downto 0)   );
end entity;

architecture arch of IntAdder_24_f120_uid52 is
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
--                         KCMTable_6_90852_unsigned
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Florent de Dinechin (2007-2012)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
entity KCMTable_6_90852_unsigned is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(5 downto 0);
          Y : out  std_logic_vector(22 downto 0)   );
end entity;

architecture arch of KCMTable_6_90852_unsigned is
begin
  with X select  Y <=
   "00000000000000000000000" when "000000",
   "00000010110001011100100" when "000001",
   "00000101100010111001000" when "000010",
   "00001000010100010101100" when "000011",
   "00001011000101110010000" when "000100",
   "00001101110111001110100" when "000101",
   "00010000101000101011000" when "000110",
   "00010011011010000111100" when "000111",
   "00010110001011100100000" when "001000",
   "00011000111101000000100" when "001001",
   "00011011101110011101000" when "001010",
   "00011110011111111001100" when "001011",
   "00100001010001010110000" when "001100",
   "00100100000010110010100" when "001101",
   "00100110110100001111000" when "001110",
   "00101001100101101011100" when "001111",
   "00101100010111001000000" when "010000",
   "00101111001000100100100" when "010001",
   "00110001111010000001000" when "010010",
   "00110100101011011101100" when "010011",
   "00110111011100111010000" when "010100",
   "00111010001110010110100" when "010101",
   "00111100111111110011000" when "010110",
   "00111111110001001111100" when "010111",
   "01000010100010101100000" when "011000",
   "01000101010100001000100" when "011001",
   "01001000000101100101000" when "011010",
   "01001010110111000001100" when "011011",
   "01001101101000011110000" when "011100",
   "01010000011001111010100" when "011101",
   "01010011001011010111000" when "011110",
   "01010101111100110011100" when "011111",
   "01011000101110010000000" when "100000",
   "01011011011111101100100" when "100001",
   "01011110010001001001000" when "100010",
   "01100001000010100101100" when "100011",
   "01100011110100000010000" when "100100",
   "01100110100101011110100" when "100101",
   "01101001010110111011000" when "100110",
   "01101100001000010111100" when "100111",
   "01101110111001110100000" when "101000",
   "01110001101011010000100" when "101001",
   "01110100011100101101000" when "101010",
   "01110111001110001001100" when "101011",
   "01111001111111100110000" when "101100",
   "01111100110001000010100" when "101101",
   "01111111100010011111000" when "101110",
   "10000010010011111011100" when "101111",
   "10000101000101011000000" when "110000",
   "10000111110110110100100" when "110001",
   "10001010101000010001000" when "110010",
   "10001101011001101101100" when "110011",
   "10010000001011001010000" when "110100",
   "10010010111100100110100" when "110101",
   "10010101101110000011000" when "110110",
   "10011000011111011111100" when "110111",
   "10011011010000111100000" when "111000",
   "10011110000010011000100" when "111001",
   "10100000110011110101000" when "111010",
   "10100011100101010001100" when "111011",
   "10100110010110101110000" when "111100",
   "10101001001000001010100" when "111101",
   "10101011111001100111000" when "111110",
   "10101110101011000011100" when "111111",
   "-----------------------" when others;
end architecture;

--------------------------------------------------------------------------------
--                         IntIntKCM_6_90852_unsigned
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: Bogdan Pasca, Florent de Dinechin (2009,2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntIntKCM_6_90852_unsigned is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(22 downto 0)   );
end entity;

architecture arch of IntIntKCM_6_90852_unsigned is
   component KCMTable_6_90852_unsigned is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(5 downto 0);
             Y : out  std_logic_vector(22 downto 0)   );
   end component;

signal Ri :  std_logic_vector(22 downto 0);
attribute rom_extract: string;
attribute rom_style: string;
attribute rom_extract of KCMTable_6_90852_unsigned: component is "yes";
attribute rom_style of KCMTable_6_90852_unsigned: component is "distributed";
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   KCMTable: KCMTable_6_90852_unsigned  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => X,
                 Y => Ri);
   R <= Ri;
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_30_f120_uid63
--                    (IntAdderAlternative_30_f120_uid67)
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

entity IntAdder_30_f120_uid63 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(29 downto 0);
          Y : in  std_logic_vector(29 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(29 downto 0)   );
end entity;

architecture arch of IntAdder_30_f120_uid63 is
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
--                   LZCShifter_30_to_24_counting_32_uid70
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

entity LZCShifter_30_to_24_counting_32_uid70 is
   port ( clk, rst : in std_logic;
          I : in  std_logic_vector(29 downto 0);
          Count : out  std_logic_vector(4 downto 0);
          O : out  std_logic_vector(23 downto 0)   );
end entity;

architecture arch of LZCShifter_30_to_24_counting_32_uid70 is
signal level5 :  std_logic_vector(29 downto 0);
signal count4, count4_d1 :  std_logic;
signal level4 :  std_logic_vector(29 downto 0);
signal count3, count3_d1 :  std_logic;
signal level3, level3_d1 :  std_logic_vector(29 downto 0);
signal count2, count2_d1 :  std_logic;
signal level2 :  std_logic_vector(26 downto 0);
signal count1 :  std_logic;
signal level1 :  std_logic_vector(24 downto 0);
signal count0 :  std_logic;
signal level0 :  std_logic_vector(23 downto 0);
signal sCount :  std_logic_vector(4 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            count4_d1 <=  count4;
            count3_d1 <=  count3;
            level3_d1 <=  level3;
            count2_d1 <=  count2;
         end if;
      end process;
   level5 <= I ;
   count4<= '1' when level5(29 downto 14) = (29 downto 14=>'0') else '0';
   level4<= level5(29 downto 0) when count4='0' else level5(13 downto 0) & (15 downto 0 => '0');

   count3<= '1' when level4(29 downto 22) = (29 downto 22=>'0') else '0';
   level3<= level4(29 downto 0) when count3='0' else level4(21 downto 0) & (7 downto 0 => '0');

   count2<= '1' when level3(29 downto 26) = (29 downto 26=>'0') else '0';
   ----------------Synchro barrier, entering cycle 1----------------
   level2<= level3_d1(29 downto 3) when count2_d1='0' else level3_d1(25 downto 0) & (0 downto 0 => '0');

   count1<= '1' when level2(26 downto 25) = (26 downto 25=>'0') else '0';
   level1<= level2(26 downto 2) when count1='0' else level2(24 downto 0);

   count0<= '1' when level1(24 downto 24) = (24 downto 24=>'0') else '0';
   level0<= level1(24 downto 1) when count0='0' else level1(23 downto 0);

   O <= level0;
   sCount <= count4_d1 & count3_d1 & count2_d1 & count1 & count0;
   Count <= sCount;
end architecture;

--------------------------------------------------------------------------------
--                      RightShifter_12_by_max_11_uid73
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

entity RightShifter_12_by_max_11_uid73 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(11 downto 0);
          S : in  std_logic_vector(3 downto 0);
          R : out  std_logic_vector(22 downto 0)   );
end entity;

architecture arch of RightShifter_12_by_max_11_uid73 is
signal level0 :  std_logic_vector(11 downto 0);
signal ps :  std_logic_vector(3 downto 0);
signal level1 :  std_logic_vector(12 downto 0);
signal level2 :  std_logic_vector(14 downto 0);
signal level3 :  std_logic_vector(18 downto 0);
signal level4 :  std_logic_vector(26 downto 0);
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
   R <= level4(26 downto 4);
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_19_f120_uid76
--                    (IntAdderAlternative_19_f120_uid80)
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

entity IntAdder_19_f120_uid76 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(18 downto 0);
          Y : in  std_logic_vector(18 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(18 downto 0)   );
end entity;

architecture arch of IntAdder_19_f120_uid76 is
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
--                           IntAdder_19_f120_uid83
--                    (IntAdderAlternative_19_f120_uid87)
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

entity IntAdder_19_f120_uid83 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(18 downto 0);
          Y : in  std_logic_vector(18 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(18 downto 0)   );
end entity;

architecture arch of IntAdder_19_f120_uid83 is
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
--                                  FPLog613
--                         (IterativeLog_6_13_0_120)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved
-- Authors: F. de Dinechin, C. Klein  (2008-2011)
--------------------------------------------------------------------------------
-- Pipeline depth: 6 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPLog613 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(6+13+2 downto 0);
          R : out  std_logic_vector(6+13+2 downto 0)   );
end entity;

architecture arch of FPLog613 is
   component IntAdder_17_f120_uid11 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(16 downto 0);
             Y : in  std_logic_vector(16 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(16 downto 0)   );
   end component;

   component IntAdder_17_f120_uid18 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(16 downto 0);
             Y : in  std_logic_vector(16 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(16 downto 0)   );
   end component;

   component IntAdder_17_f120_uid28 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(16 downto 0);
             Y : in  std_logic_vector(16 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(16 downto 0)   );
   end component;

   component IntAdder_19_f120_uid76 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(18 downto 0);
             Y : in  std_logic_vector(18 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(18 downto 0)   );
   end component;

   component IntAdder_19_f120_uid83 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(18 downto 0);
             Y : in  std_logic_vector(18 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(18 downto 0)   );
   end component;

   component IntAdder_24_f120_uid45 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(23 downto 0);
             Y : in  std_logic_vector(23 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(23 downto 0)   );
   end component;

   component IntAdder_24_f120_uid52 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(23 downto 0);
             Y : in  std_logic_vector(23 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(23 downto 0)   );
   end component;

   component IntAdder_30_f120_uid63 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(29 downto 0);
             Y : in  std_logic_vector(29 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(29 downto 0)   );
   end component;

   component IntIntKCM_6_90852_unsigned is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(22 downto 0)   );
   end component;

   component IntSquarer_12_uid25 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(11 downto 0);
             R : out  std_logic_vector(23 downto 0)   );
   end component;

   component InvTable_0_6_7 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(5 downto 0);
             Y : out  std_logic_vector(6 downto 0)   );
   end component;

   component LZCShifter_30_to_24_counting_32_uid70 is
      port ( clk, rst : in std_logic;
             I : in  std_logic_vector(29 downto 0);
             Count : out  std_logic_vector(4 downto 0);
             O : out  std_logic_vector(23 downto 0)   );
   end component;

   component LZOC_13_4_uid3 is
      port ( clk, rst : in std_logic;
             I : in  std_logic_vector(12 downto 0);
             OZB : in  std_logic;
             O : out  std_logic_vector(3 downto 0)   );
   end component;

   component LeftShifter_8_by_max_8_uid6 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(7 downto 0);
             S : in  std_logic_vector(3 downto 0);
             R : out  std_logic_vector(15 downto 0)   );
   end component;

   component LogTable_0_6_24 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(5 downto 0);
             Y : out  std_logic_vector(23 downto 0)   );
   end component;

   component LogTable_1_4_20 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(3 downto 0);
             Y : out  std_logic_vector(19 downto 0)   );
   end component;

   component RightShifter_12_by_max_11_uid73 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(11 downto 0);
             S : in  std_logic_vector(3 downto 0);
             R : out  std_logic_vector(22 downto 0)   );
   end component;

signal XExnSgn, XExnSgn_d1, XExnSgn_d2, XExnSgn_d3, XExnSgn_d4, XExnSgn_d5, XExnSgn_d6 :  std_logic_vector(2 downto 0);
signal FirstBit :  std_logic;
signal Y0, Y0_d1, Y0_d2 :  std_logic_vector(14 downto 0);
signal Y0h :  std_logic_vector(12 downto 0);
signal sR, sR_d1, sR_d2, sR_d3, sR_d4, sR_d5, sR_d6 :  std_logic;
signal absZ0 :  std_logic_vector(7 downto 0);
signal E :  std_logic_vector(5 downto 0);
signal absE, absE_d1, absE_d2, absE_d3, absE_d4, absE_d5 :  std_logic_vector(5 downto 0);
signal EeqZero :  std_logic;
signal lzo, lzo_d1, lzo_d2, lzo_d3, lzo_d4, lzo_d5 :  std_logic_vector(3 downto 0);
signal pfinal_s :  std_logic_vector(3 downto 0);
signal shiftval :  std_logic_vector(4 downto 0);
signal shiftvalinL :  std_logic_vector(3 downto 0);
signal shiftvalinR, shiftvalinR_d1, shiftvalinR_d2, shiftvalinR_d3, shiftvalinR_d4, shiftvalinR_d5 :  std_logic_vector(3 downto 0);
signal doRR, doRR_d1, doRR_d2, doRR_d3, doRR_d4 :  std_logic;
signal small, small_d1, small_d2, small_d3, small_d4, small_d5, small_d6 :  std_logic;
signal small_absZ0_normd_full :  std_logic_vector(15 downto 0);
signal small_absZ0_normd, small_absZ0_normd_d1, small_absZ0_normd_d2, small_absZ0_normd_d3, small_absZ0_normd_d4, small_absZ0_normd_d5 :  std_logic_vector(7 downto 0);
signal A0, A0_d1, A0_d2, A0_d3, A0_d4 :  std_logic_vector(5 downto 0);
signal InvA0, InvA0_d1 :  std_logic_vector(6 downto 0);
signal P0, P0_d1 :  std_logic_vector(21 downto 0);
signal Z1 :  std_logic_vector(15 downto 0);
signal A1, A1_d1 :  std_logic_vector(3 downto 0);
signal B1 :  std_logic_vector(11 downto 0);
signal ZM1, ZM1_d1 :  std_logic_vector(15 downto 0);
signal P1 :  std_logic_vector(19 downto 0);
signal Y1 :  std_logic_vector(20 downto 0);
signal EiY1 :  std_logic_vector(16 downto 0);
signal addXIter1 :  std_logic_vector(16 downto 0);
signal EiYPB1, EiYPB1_d1 :  std_logic_vector(16 downto 0);
signal Pp1 :  std_logic_vector(16 downto 0);
signal Z2 :  std_logic_vector(16 downto 0);
signal Zfinal :  std_logic_vector(16 downto 0);
signal squarerIn :  std_logic_vector(11 downto 0);
signal Z2o2_full :  std_logic_vector(23 downto 0);
signal Z2o2_full_dummy, Z2o2_full_dummy_d1 :  std_logic_vector(23 downto 0);
signal Z2o2_normal :  std_logic_vector(8 downto 0);
signal addFinalLog1pY :  std_logic_vector(16 downto 0);
signal Log1p_normal, Log1p_normal_d1 :  std_logic_vector(16 downto 0);
signal L0 :  std_logic_vector(23 downto 0);
signal S1 :  std_logic_vector(23 downto 0);
signal L1 :  std_logic_vector(19 downto 0);
signal sopX1 :  std_logic_vector(23 downto 0);
signal S2, S2_d1 :  std_logic_vector(23 downto 0);
signal almostLog :  std_logic_vector(23 downto 0);
signal adderLogF_normalY :  std_logic_vector(23 downto 0);
signal LogF_normal :  std_logic_vector(23 downto 0);
signal absELog2 :  std_logic_vector(22 downto 0);
signal absELog2_pad :  std_logic_vector(29 downto 0);
signal LogF_normal_pad :  std_logic_vector(29 downto 0);
signal lnaddX :  std_logic_vector(29 downto 0);
signal lnaddY :  std_logic_vector(29 downto 0);
signal Log_normal :  std_logic_vector(29 downto 0);
signal E_normal :  std_logic_vector(4 downto 0);
signal Log_normal_normd :  std_logic_vector(23 downto 0);
signal Z2o2_small_bs :  std_logic_vector(11 downto 0);
signal Z2o2_small_s :  std_logic_vector(22 downto 0);
signal Z2o2_small :  std_logic_vector(18 downto 0);
signal Z_small :  std_logic_vector(18 downto 0);
signal Log_smallY :  std_logic_vector(18 downto 0);
signal nsRCin :  std_logic;
signal Log_small :  std_logic_vector(18 downto 0);
signal E0_sub :  std_logic_vector(1 downto 0);
signal ufl, ufl_d1 :  std_logic;
signal E_small, E_small_d1 :  std_logic_vector(5 downto 0);
signal Log_small_normd, Log_small_normd_d1 :  std_logic_vector(16 downto 0);
signal E0offset :  std_logic_vector(5 downto 0);
signal ER :  std_logic_vector(5 downto 0);
signal Log_g :  std_logic_vector(16 downto 0);
signal round :  std_logic;
signal fraX :  std_logic_vector(18 downto 0);
signal fraY :  std_logic_vector(18 downto 0);
signal EFR :  std_logic_vector(18 downto 0);
constant g: positive := 4;
constant log2wF: positive := 4;
constant pfinal: positive := 7;
constant sfinal: positive := 17;
constant targetprec: positive := 24;
constant wE: positive := 6;
constant wF: positive := 13;
attribute rom_extract: string;
attribute rom_style: string;
attribute rom_extract of InvTable_0_6_7: component is "yes";
attribute rom_style of InvTable_0_6_7: component is "block";
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            XExnSgn_d1 <=  XExnSgn;
            XExnSgn_d2 <=  XExnSgn_d1;
            XExnSgn_d3 <=  XExnSgn_d2;
            XExnSgn_d4 <=  XExnSgn_d3;
            XExnSgn_d5 <=  XExnSgn_d4;
            XExnSgn_d6 <=  XExnSgn_d5;
            Y0_d1 <=  Y0;
            Y0_d2 <=  Y0_d1;
            sR_d1 <=  sR;
            sR_d2 <=  sR_d1;
            sR_d3 <=  sR_d2;
            sR_d4 <=  sR_d3;
            sR_d5 <=  sR_d4;
            sR_d6 <=  sR_d5;
            absE_d1 <=  absE;
            absE_d2 <=  absE_d1;
            absE_d3 <=  absE_d2;
            absE_d4 <=  absE_d3;
            absE_d5 <=  absE_d4;
            lzo_d1 <=  lzo;
            lzo_d2 <=  lzo_d1;
            lzo_d3 <=  lzo_d2;
            lzo_d4 <=  lzo_d3;
            lzo_d5 <=  lzo_d4;
            shiftvalinR_d1 <=  shiftvalinR;
            shiftvalinR_d2 <=  shiftvalinR_d1;
            shiftvalinR_d3 <=  shiftvalinR_d2;
            shiftvalinR_d4 <=  shiftvalinR_d3;
            shiftvalinR_d5 <=  shiftvalinR_d4;
            doRR_d1 <=  doRR;
            doRR_d2 <=  doRR_d1;
            doRR_d3 <=  doRR_d2;
            doRR_d4 <=  doRR_d3;
            small_d1 <=  small;
            small_d2 <=  small_d1;
            small_d3 <=  small_d2;
            small_d4 <=  small_d3;
            small_d5 <=  small_d4;
            small_d6 <=  small_d5;
            small_absZ0_normd_d1 <=  small_absZ0_normd;
            small_absZ0_normd_d2 <=  small_absZ0_normd_d1;
            small_absZ0_normd_d3 <=  small_absZ0_normd_d2;
            small_absZ0_normd_d4 <=  small_absZ0_normd_d3;
            small_absZ0_normd_d5 <=  small_absZ0_normd_d4;
            A0_d1 <=  A0;
            A0_d2 <=  A0_d1;
            A0_d3 <=  A0_d2;
            A0_d4 <=  A0_d3;
            InvA0_d1 <=  InvA0;
            P0_d1 <=  P0;
            A1_d1 <=  A1;
            ZM1_d1 <=  ZM1;
            EiYPB1_d1 <=  EiYPB1;
            Z2o2_full_dummy_d1 <=  Z2o2_full_dummy;
            Log1p_normal_d1 <=  Log1p_normal;
            S2_d1 <=  S2;
            ufl_d1 <=  ufl;
            E_small_d1 <=  E_small;
            Log_small_normd_d1 <=  Log_small_normd;
         end if;
      end process;
   XExnSgn <=  X(wE+wF+2 downto wE+wF);
   FirstBit <=  X(wF-1);
   Y0 <= "1" & X(wF-1 downto 0) & "0" when FirstBit = '0' else "01" & X(wF-1 downto 0);
   Y0h <= Y0(wF downto 1);
   -- Sign of the result;
   sR <= '0'   when  (X(wE+wF-1 downto wF) = ('0' & (wE-2 downto 0 => '1')))  -- binade [1..2)
     else not X(wE+wF-1);                -- MSB of exponent
   absZ0 <=   Y0(wF-pfinal+1 downto 0)          when (sR='0') else
             ((wF-pfinal+1 downto 0 => '0') - Y0(wF-pfinal+1 downto 0));
   E <= (X(wE+wF-1 downto wF)) - ("0" & (wE-2 downto 1 => '1') & (not FirstBit));
   absE <= ((wE-1 downto 0 => '0') - E)   when sR = '1' else E;
   EeqZero <= '1' when E=(wE-1 downto 0 => '0') else '0';
   ---------------- cycle 0----------------
   lzoc1: LZOC_13_4_uid3  -- pipelineDepth=0 maxInDelay=5.23e-10
      port map ( clk  => clk,
                 rst  => rst,
                 I => Y0h,
                 O => lzo,
                 OZB => FirstBit);
   ---------------- cycle 0----------------
   pfinal_s <= "0111";
   shiftval <= ('0' & lzo) - ('0' & pfinal_s);
   shiftvalinL <= shiftval(3 downto 0);
   shiftvalinR <= shiftval(3 downto 0);
   doRR <= shiftval(log2wF); -- sign of the result
   small <= EeqZero and not(doRR);
   ---------------- cycle 0----------------
   -- The left shifter for the 'small' case
   small_lshift: LeftShifter_8_by_max_8_uid6  -- pipelineDepth=0 maxInDelay=6.05874e-09
      port map ( clk  => clk,
                 rst  => rst,
                 R => small_absZ0_normd_full,
                 S => shiftvalinL,
                 X => absZ0);
   small_absZ0_normd <= small_absZ0_normd_full(7 downto 0); -- get rid of leading zeroes
   ----------------Synchro barrier, entering cycle 0----------------
   ---------------- The range reduction box ---------------
   A0 <= X(12 downto 7);
   ----------------Synchro barrier, entering cycle 1----------------
   -- First inv table
   itO: InvTable_0_6_7  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => A0_d1,
                 Y => InvA0);
   ----------------Synchro barrier, entering cycle 2----------------
   P0 <= InvA0_d1 * Y0_d2;

   ----------------Synchro barrier, entering cycle 3----------------
   Z1 <= P0_d1(15 downto 0);

   A1 <= Z1(15 downto 12);
   B1 <= Z1(11 downto 0);
   ZM1 <= Z1;
   ----------------Synchro barrier, entering cycle 4----------------
   P1 <= A1_d1*ZM1_d1;
   ----------------Synchro barrier, entering cycle 5----------------
    -- delay at multiplier output is 0
   ---------------- cycle 3----------------
   Y1 <= "1" & (3 downto 0 => '0') & Z1;
   EiY1 <= Y1(20 downto 4)  when A1(3) = '1'
     else  "0" & Y1(20 downto 5);
   addXIter1 <= "0" & B1 & (3 downto 0 => '0');
   addIter1_1: IntAdder_17_f120_uid11  -- pipelineDepth=0 maxInDelay=8.6e-11
      port map ( clk  => clk,
                 rst  => rst,
                 Cin =>  '0',
                 R => EiYPB1,
                 X => addXIter1,
                 Y => EiY1);

   ----------------Synchro barrier, entering cycle 4----------------
   Pp1 <= (0 downto 0 => '1') & not(P1(19 downto 4));
   addIter2_1: IntAdder_17_f120_uid18  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 Cin =>  '1',
                 R => Z2,
                 X => EiYPB1_d1,
                 Y => Pp1);

 -- the critical path at the adder output = 1.92172e-09
   Zfinal <= Z2;
   --  Synchro between RR box and case almost 1
   squarerIn <= Zfinal(sfinal-1 downto sfinal-12) when doRR_d4='1'
                    else (small_absZ0_normd_d4 & (3 downto 0 => '0'));
   squarer: IntSquarer_12_uid25  -- pipelineDepth=0 maxInDelay=2.88844e-09
      port map ( clk  => clk,
                 rst  => rst,
                 R => Z2o2_full,
                 X => squarerIn);
   Z2o2_full_dummy <= Z2o2_full;
   Z2o2_normal <= Z2o2_full_dummy (23  downto 15);
   addFinalLog1pY <= (pfinal downto 0  => '1') & not(Z2o2_normal);
   addFinalLog1p_normalAdder: IntAdder_17_f120_uid28  -- pipelineDepth=0 maxInDelay=6.59216e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin =>  '1',
                 R => Log1p_normal,
                 X => Zfinal,
                 Y => addFinalLog1pY);

   -- Now the log tables, as late as possible
   ----------------Synchro barrier, entering cycle 0----------------
   ----------------Synchro barrier, entering cycle 0----------------
   ----------------Synchro barrier, entering cycle 4----------------
   -- First log table
   ltO: LogTable_0_6_24  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => A0_d4,
                 Y => L0);
   S1 <= L0;
   lt1: LogTable_1_4_20  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 X => A1_d1,
                 Y => L1);
   sopX1 <= ((23 downto 20 => '0') & L1);
   adderS1: IntAdder_24_f120_uid45  -- pipelineDepth=0 maxInDelay=4.36e-10
      port map ( clk  => clk,
                 rst  => rst,
                 Cin =>  '0' ,
                 R => S2,
                 X => S1,
                 Y => sopX1);

   ----------------Synchro barrier, entering cycle 5----------------
   almostLog <= S2_d1;
   adderLogF_normalY <= ((targetprec-1 downto sfinal => '0') & Log1p_normal_d1);
   adderLogF_normal: IntAdder_24_f120_uid52  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => '0',
                 R => LogF_normal,
                 X => almostLog,
                 Y => adderLogF_normalY);
   ----------------Synchro barrier, entering cycle 5----------------
   Log2KCM: IntIntKCM_6_90852_unsigned  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 R => absELog2,
                 X => absE_d5);
   ----------------Synchro barrier, entering cycle 5----------------
   absELog2_pad <=   absELog2 & (targetprec-wF-g-1 downto 0 => '0');
   LogF_normal_pad <= (wE-1  downto 0 => LogF_normal(targetprec-1))  & LogF_normal;
   lnaddX <= absELog2_pad;
   lnaddY <= LogF_normal_pad when sR_d5='0' else not(LogF_normal_pad);
   lnadder: IntAdder_30_f120_uid63  -- pipelineDepth=0 maxInDelay=2.16872e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => sR_d5,
                 R => Log_normal,
                 X => lnaddX,
                 Y => lnaddY);

   final_norm: LZCShifter_30_to_24_counting_32_uid70  -- pipelineDepth=1 maxInDelay=3.97144e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Count => E_normal,
                 I => Log_normal,
                 O => Log_normal_normd);
   Z2o2_small_bs <= Z2o2_full_dummy_d1(23 downto 12);
   ao_rshift: RightShifter_12_by_max_11_uid73  -- pipelineDepth=0 maxInDelay=2.77888e-09
      port map ( clk  => clk,
                 rst  => rst,
                 R => Z2o2_small_s,
                 S => shiftvalinR_d5,
                 X => Z2o2_small_bs);
   ---------------- cycle 5----------------
   -- output delay at shifter output is 1.262e-09
     -- send the MSB to position pfinal
   Z2o2_small <=  (pfinal-1 downto 0  => '0') & Z2o2_small_s(22 downto 11);
   -- mantissa will be either Y0-z^2/2  or  -Y0+z^2/2,  depending on sR
   Z_small <= small_absZ0_normd_d5 & (10 downto 0 => '0');
   Log_smallY <= Z2o2_small when sR_d5='1' else not(Z2o2_small);
   nsRCin <= not ( sR_d5 );
   log_small_adder: IntAdder_19_f120_uid76  -- pipelineDepth=0 maxInDelay=2.23744e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => nsRCin,
                 R => Log_small,
                 X => Z_small,
                 Y => Log_smallY);

 -- critical path here is 3.34244e-09
   -- Possibly subtract 1 or 2 to the exponent, depending on the LZC of Log_small
   E0_sub <=   "11" when Log_small(wF+g+1) = '1'
          else "10" when Log_small(wF+g+1 downto wF+g) = "01"
          else "01" ;
   -- The smallest log will be log(1+2^{-wF}) \approx 2^{-wF}  = 2^-13
   -- The smallest representable number is 2^{1-2^(wE-1)} = 2^-31
   -- No underflow possible
   ufl <= '0';
   E_small <=  ("0" & (wE-2 downto 2 => '1') & E0_sub)  -  ((wE-1 downto 4 => '0') & lzo_d5) ;
   Log_small_normd <= Log_small(wF+g+1 downto 2) when Log_small(wF+g+1)='1'
           else Log_small(wF+g downto 1)  when Log_small(wF+g)='1'  -- remove the first zero
           else Log_small(wF+g-1 downto 0)  ; -- remove two zeroes (extremely rare, 001000000 only)
   ----------------Synchro barrier, entering cycle 6----------------
   E0offset <= "100100"; -- E0 + wE
   ER <= E_small_d1(5 downto 0) when small_d6='1'
      else E0offset - ((5 downto 5 => '0') & E_normal);
   ---------------- cycle 6----------------
   Log_g <=  Log_small_normd_d1(wF+g-2 downto 0) & "0" when small_d6='1'           -- remove implicit 1
      else Log_normal_normd(targetprec-2 downto targetprec-wF-g-1 );  -- remove implicit 1
   round <= Log_g(g-1) ; -- sticky is always 1 for a transcendental function
   -- if round leads to a change of binade, the carry propagation magically updates both mantissa and exponent
   fraX <= (ER & Log_g(wF+g-1 downto g)) ;
   fraY <= ((wE+wF-1 downto 1 => '0') & round);
   finalRoundAdder: IntAdder_19_f120_uid83  -- pipelineDepth=0 maxInDelay=2.86488e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => '0',
                 R => EFR,
                 X => fraX,
                 Y => fraY);
   R(wE+wF+2 downto wE+wF) <= "110" when ((XExnSgn_d6(2) and (XExnSgn_d6(1) or XExnSgn_d6(0))) or (XExnSgn_d6(1) and XExnSgn_d6(0))) = '1' else
                              "101" when XExnSgn_d6(2 downto 1) = "00"  else
                              "100" when XExnSgn_d6(2 downto 1) = "10"  else
                              "00" & sR_d6 when (((Log_normal_normd(targetprec-1)='0') and (small_d6='0')) or ( (Log_small_normd_d1 (wF+g-1)='0') and (small_d6='1'))) or (ufl_d1 = '1') else
                               "01" & sR_d6;
   R(wE+wF-1 downto 0) <=  EFR;
end architecture;
