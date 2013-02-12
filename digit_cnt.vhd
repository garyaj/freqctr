----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: A modified BCD counter 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity digit_cnt is
    Port ( clk         : in  STD_LOGIC;
           reset_in    : in  STD_LOGIC;
           inc_in      : in  STD_LOGIC;
           reset_out   : out STD_LOGIC;
           inc_out     : out STD_LOGIC;
           digit       : out STD_LOGIC_vector(3 downto 0);
           reset_blank : in  STD_LOGIC);
end digit_cnt;

architecture Behavioral of digit_cnt is
   signal state : std_logic_vector(3 downto 0) := x"F";
begin
   digit <= state;
   process(clk)
   begin
      if rising_edge(clk) then
         inc_out   <= '0';
         reset_out <= reset_in;
         if reset_in = '1' then
            if inc_in  = '1' then
               state <= x"1";
            elsif reset_blank = '1' then
               state <= x"F";
            else
               state <= x"0";
            end if;
         elsif inc_in = '1' then
            case state is
               when x"0" => state <= x"1";
               when x"1" => state <= x"2";
               when x"2" => state <= x"3";
               when x"3" => state <= x"4";
               when x"4" => state <= x"5";
               when x"5" => state <= x"6";
               when x"6" => state <= x"7";
               when x"7" => state <= x"8";
               when x"8" => state <= x"9";
               when x"9" => state <= x"0"; inc_out <= '1';
               when x"F" => state <= x"1";
               when others => state <= x"1";
            end case;
         end if;
      end if;
   end process;
end Behavioral;

