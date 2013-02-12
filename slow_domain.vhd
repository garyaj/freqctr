----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Takes the pulse count and sends it out to the display. Runs
--              at 32MHz
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity slow_domain is
    Port ( clk : in  STD_LOGIC;
    
           bcd_count : in  STD_LOGIC_VECTOR (31 downto 0);
           new_count : in  STD_LOGIC;
           
           d_clk    : out STD_LOGIC;
           d_strobe : out STD_LOGIC;
           d_data   : out STD_LOGIC);
end slow_domain;

architecture Behavioral of slow_domain is
   COMPONENT dx_display
   PORT(
      clk       : IN std_logic;
      reset     : IN std_logic;
      segData   : IN std_logic_vector(31 downto 0);
      adv       : IN std_logic;          
      byte      : OUT std_logic_vector(7 downto 0);
      endCmd    : OUT std_logic;
      newData   : OUT std_logic);
   END COMPONENT;

   COMPONENT dx_display_xmit
   PORT(
      clk : IN std_logic;
      reset : IN std_logic;
      byte : IN std_logic_vector(7 downto 0);
      endCmd : IN std_logic;
      newData : IN std_logic;          
      adv : OUT std_logic;
      d_strobe : OUT std_logic;
      d_clk : OUT std_logic;
      d_data : OUT std_logic
      );
   END COMPONENT;

   signal byte       : std_logic_vector(7 downto 0);
   signal endCmd     : std_logic;
   signal newData    : std_logic;
   signal adv        : std_logic;
   signal reset      : std_logic;
   signal resetShift : std_logic_vector(15 downto 0) := (others => '1');
   signal newCountSr : std_logic_vector(1 downto 0) := "00";
begin
   reset <= resetShift(0);

   Inst_dx_display: dx_display PORT MAP(
      clk       => clk,
      reset     => reset,
      byte      => byte,
      endCmd    => endCmd,
      newData   => newData,
      segData   => bcd_count,
      adv       => adv
   );

   Inst_dx_display_xmit: dx_display_xmit PORT MAP(
      clk      => clk,
      reset    => reset,
      byte     => byte,
      endCmd   => endCmd,
      newData  => newData,
      adv      => adv,
      d_strobe => d_strobe,
      d_clk    => d_clk,
      d_data   => d_data
   );

reset_proc: process(clk)
   begin
      if rising_edge(clk) then
         if newCountSr = "01" then
            resetShift <= (others => '1');
         else
            resetShift <= '0' & resetShift(15 downto 1);
         end if;
         newCountSr <= newCountSr(0) & new_count;
      end if;
   end process;

end Behavioral;

