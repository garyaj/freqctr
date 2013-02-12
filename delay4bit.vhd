----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Generic delay for a 4bit signal
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity delay4bit is
   generic (len : natural);
    Port ( clk : in  STD_LOGIC;
           d_in : in  STD_LOGIC_VECTOR (3 downto 0);
           d_out : out  STD_LOGIC_VECTOR (3 downto 0));
end delay4bit;

architecture Behavioral of delay4bit is
   signal sr : std_logic_vector(4*len-1 downto 0);
begin
   d_out <= sr(4*len-1 downto 4*(len-1));
   process(clk)
   begin
      if rising_edge(clk) then
         sr <= sr(4*len-5 downto 0) & d_in;
      end if;
   end process;

end Behavioral;

