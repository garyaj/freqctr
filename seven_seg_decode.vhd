----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Decoding for the dx 7seg display.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seven_seg_decode is
    Port ( clk : in std_logic;
           data : in  STD_LOGIC_VECTOR (3 downto 0);
           decoded : out  STD_LOGIC_VECTOR (7 downto 0));
end seven_seg_decode;

architecture Behavioral of seven_seg_decode is

begin
   
   process(clk)
   begin
      if rising_edge(clk) then
         case data is
            when "0000" => decoded <= "00111111";
            when "0001" => decoded <= "00000110";
            when "0010" => decoded <= "01011011";
            when "0011" => decoded <= "01001111";
            when "0100" => decoded <= "01100110"; 
            when "0101" => decoded <= "01101101"; 
            when "0110" => decoded <= "01111101";
            when "0111" => decoded <= "00000111";
            when "1000" => decoded <= "01111111";
            when "1001" => decoded <= "01100111";
            when "1111" => decoded <= "00000000";
            when others => decoded <= "10000000"; -- decimal point
         end case;
      end if;
   end process;
end Behavioral;

