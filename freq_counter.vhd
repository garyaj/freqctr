----------------------------------------------------------------------------------
-- Engineer:       Mike Field <hamster@snap.net.nz>
-- 
-- Description: Top level of my frequency counter
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity freq_count is
    Port ( clk16     : in  STD_LOGIC;
	        clk12     : in  STD_LOGIC;
           d_clk     : out STD_LOGIC;
           d_strobe  : out STD_LOGIC;
           d_data    : out STD_LOGIC;
           ref       : out STD_LOGIC;
			  pps_out   : out STD_LOGIC;
			  clk12_out : out STD_LOGIC);
end freq_count;

architecture Behavioral of freq_count is
   COMPONENT clocking
   PORT(
   CLKIN_IN : IN std_logic;
   CLKFX_OUT : OUT std_logic;
   CLKFX180_OUT : OUT std_logic;
   CLKIN_IBUFG_OUT : OUT std_logic;
   CLK0_OUT : OUT std_logic;
   LOCKED_OUT : OUT std_logic
   );
   END COMPONENT;

   COMPONENT fast_domain
   PORT(
   clk       : IN std_logic;
   test_sig  : IN std_logic;
   pps       : IN std_logic;
   bcd_count : OUT std_logic_vector(31 downto 0);
   new_count : OUT std_logic
   );
   END COMPONENT;

   COMPONENT slow_domain
   PORT(
   clk : IN std_logic;
   bcd_count : IN std_logic_vector(31 downto 0);
   new_count : IN std_logic;
   d_clk : OUT std_logic;
   d_strobe : OUT std_logic;
   d_data : OUT std_logic
   );
   END COMPONENT;

   signal clk_fast      : std_logic;
   signal clk_slow      : std_logic;
   signal new_count     : std_logic;
   signal bcd_count     : std_logic_vector(31 downto 0);
   signal internal_ref  : unsigned(24 downto 0) := (others => '0');
   signal pps_in        : std_logic;
   signal pps           : std_logic;
   signal test_sig      : std_logic;
   
begin
   
   Inst_clocking: clocking PORT MAP(
   CLKIN_IN => clk16,
   CLKFX_OUT => clk_fast,
   CLKFX180_OUT => open,
   CLKIN_IBUFG_OUT => open,
   CLK0_OUT => clk_slow,
   LOCKED_OUT => open
   );
   
Inst_fast_domain: fast_domain PORT MAP(
   clk          => clk_fast,
   test_sig     => test_sig,
   pps          => pps_in,
   bcd_count    => bcd_count,
   new_count    => new_count
   );
   
Inst_slow_domain: slow_domain PORT MAP(
   clk => clk_slow,
   bcd_count => bcd_count,
   new_count => new_count,
   d_clk     => d_clk,
   d_strobe  => d_strobe,
   d_data    => d_data
   );

   process(clk_slow)
   begin
   if rising_edge(clk_slow) then

      if internal_ref < 160000 then -- 10ms pulse
         pps <= '1';
      else
         pps <= '0';
      end if;

      if internal_ref = 15999999 then -- 15999999
         internal_ref <= (others => '0');
      else
         internal_ref <= internal_ref+1;
      end if;
      ref <= std_logic(internal_ref(0));

   end if;
   end process;
	clk12_out <= clk12;
   pps_in <= pps;
	pps_out <= pps;
   test_sig <= clk12;
end Behavioral;

