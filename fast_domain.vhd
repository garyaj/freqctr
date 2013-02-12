----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: The 'fast' capture/count part of the frequency counter
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fast_domain is
    Port ( clk       : in  STD_LOGIC;
           clkn      : in  STD_LOGIC;
           test_sig  : in  STD_LOGIC;
           pps       : in  STD_LOGIC;
           bcd_count : out  STD_LOGIC_VECTOR (31 downto 0);
           new_count : out  STD_LOGIC);
end fast_domain;

architecture Behavioral of fast_domain is
   COMPONENT delay4bit
   GENERIC( len : natural);
   PORT(
      clk   : IN std_logic;
      d_in  : IN std_logic_vector(3 downto 0);          
      d_out : OUT std_logic_vector(3 downto 0)
      );
   END COMPONENT;

   COMPONENT digit_cnt
   PORT(
      clk         : IN std_logic;
      reset_in    : IN std_logic;
      inc_in      : IN std_logic;
      reset_blank : IN std_logic;          
      reset_out   : OUT std_logic;
      inc_out     : OUT std_logic;
      digit       : OUT std_logic_vector(3 downto 0)
      );
   END COMPONENT;

   COMPONENT edge_detect
   PORT(
      clk : IN std_logic;
      clkn : IN std_logic;
      test_signal : IN std_logic;          
      rising_edge_found : OUT std_logic
      );
   END COMPONENT;
   
   signal ro0,ro1,ro2,ro3,ro4,ro5,ro6,ro7 : std_logic;
   signal io0,io1,io2,io3,io4,io5,io6,io7 : std_logic;
   signal cnt0,cnt1,cnt2,cnt3,cnt4,cnt5,cnt6,cnt7 : std_logic_vector(3 downto 0);
   signal c0,c1,c2,c3,c4,c5,c6,c7 : std_logic_vector(3 downto 0);
   signal edge_found    : std_logic;
   signal last_count    : std_logic_vector(31 downto 0) := x"12345678";
   signal new_count_sr  : std_logic_vector(15 downto 0) := (others => '0');
   signal pps_sr        : std_logic_vector(1 downto 0) := "00";
   signal restart_count : std_logic;

begin
   bcd_count <= last_count;
   new_count <= new_count_sr(15);

   Inst_edge_detect: edge_detect PORT MAP(
      clk => clk,
      clkn => clkn,
      test_signal => test_sig,
      rising_edge_found => edge_found
   );

   -- delays to get all the counter transistions in line
delay0 : delay4bit GENERIC MAP (len => 7) PORT MAP (clk => clk, d_in => cnt0, d_out => c0);
delay1 : delay4bit GENERIC MAP (len => 6) PORT MAP (clk => clk, d_in => cnt1, d_out => c1);
delay2 : delay4bit GENERIC MAP (len => 5) PORT MAP (clk => clk, d_in => cnt2, d_out => c2);
delay3 : delay4bit GENERIC MAP (len => 4) PORT MAP (clk => clk, d_in => cnt3, d_out => c3);
delay4 : delay4bit GENERIC MAP (len => 3) PORT MAP (clk => clk, d_in => cnt4, d_out => c4);
delay5 : delay4bit GENERIC MAP (len => 2) PORT MAP (clk => clk, d_in => cnt5, d_out => c5);
delay6 : delay4bit GENERIC MAP (len => 1) PORT MAP (clk => clk, d_in => cnt6, d_out => c6);
   c7 <= cnt7;
   -- the decimal counters
digit0: digit_cnt PORT MAP(clk => clk, reset_in => restart_count, inc_in => edge_found, reset_out => ro0, inc_out => io0, digit => cnt0, reset_blank => '0');
digit1: digit_cnt PORT MAP(clk => clk, reset_in => ro0, inc_in => io0, reset_out => ro1, inc_out => io1, digit => cnt1, reset_blank => '1');
digit2: digit_cnt PORT MAP(clk => clk, reset_in => ro1, inc_in => io1, reset_out => ro2, inc_out => io2, digit => cnt2, reset_blank => '1');
digit3: digit_cnt PORT MAP(clk => clk, reset_in => ro2, inc_in => io2, reset_out => ro3, inc_out => io3, digit => cnt3, reset_blank => '1');
digit4: digit_cnt PORT MAP(clk => clk, reset_in => ro3, inc_in => io3, reset_out => ro4, inc_out => io4, digit => cnt4, reset_blank => '1');
digit5: digit_cnt PORT MAP(clk => clk, reset_in => ro4, inc_in => io4, reset_out => ro5, inc_out => io5, digit => cnt5, reset_blank => '1');
digit6: digit_cnt PORT MAP(clk => clk, reset_in => ro5, inc_in => io5, reset_out => ro6, inc_out => io6, digit => cnt6, reset_blank => '1');
digit7: digit_cnt PORT MAP(clk => clk, reset_in => ro6, inc_in => io6, reset_out => ro7, inc_out => io7, digit => cnt7, reset_blank => '1');

reset_proc: process(clk)
   begin
      if rising_edge(clk) then
         if ro6 = '1' then
            last_count <= c7 & c6 & c5 & c4 & c3 & c2 &c1 & c0;
            new_count_sr <= "0111111111111111";
         else
            new_count_sr  <= new_count_sr(14 downto 0) & '0';
         end if;
        

         if pps_sr = "01" then
            restart_count <= '1';
         else
            restart_count <= '0';
         end if;
         pps_sr <= pps_sr(0) & pps;
      end if;
   end process;
end Behavioral;
