----------------------------------------------------------------------------------
-- Engineer: Mike Field   <hamster@snap.net.nz>
-- 
-- Description:  Driver for the DealExteme display board, 
--  8 x 7 segs
--  8 x bi-colour LED
--  8 x buttons
--
-- Dependencies: None
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dx_display is
    Port ( clk       : in  STD_LOGIC;
           reset     : in  STD_LOGIC;
           byte      : out STD_LOGIC_VECTOR(7 downto 0);
           endCmd    : out STD_LOGIC;
           newData   : out STD_LOGIC;
           segData   : in  STD_LOGIC_VECTOR(31 downto 0);
           adv       : in  STD_LOGIC);
end dx_display;

architecture Behavioral of dx_display is
   COMPONENT seven_seg_decode
   PORT(
      clk : IN std_logic;
      data : IN std_logic_vector(3 downto 0);          
      decoded : OUT std_logic_vector(7 downto 0)
      );
   END COMPONENT;


   signal counter     : std_logic_vector(4 downto 0) := (others => '0');
   signal nextcounter : unsigned(4 downto 0);
   constant leds_green  : std_logic_vector(7 downto 0) := (others => '0');
   constant leds_red    : std_logic_vector(7 downto 0) := (others => '0');
   signal decode_in   : std_logic_vector(3 downto 0) := (others => '0');
   signal decode_out  : std_logic_vector(7 downto 0) := (others => '0');
   signal next_decode_in : std_logic_vector(3 downto 0) := (others => '0');
begin
   nextcounter <= unsigned(counter) + 1;

Inst_seven_seg_decode: seven_seg_decode PORT MAP(
      clk => clk,
      data => decode_in,
      decoded => decode_out
   );
   
data_proc: process(counter,segData, decode_out)
   begin
      next_decode_in <= "0000";
      case counter is
         when  "00000" => byte <= x"40"; endCmd <= '1'; newData <= '1';   -- Set address mode - auto inc
         when  "00001" => byte <= x"8C"; endCmd <= '1'; newData <= '1';   -- Turn display on, brightness 4 of 7
         when  "00010" => byte <= x"C0"; endCmd <= '0'; newData <= '1';   -- Write at the left display
            next_decode_in <= segData(31 downto 28);
         
         when  "00011" => byte <= decode_out; endCmd <= '0'; newData <= '1';
         when  "00100" => -- LED1 
            byte    <= "000000" & leds_red(0) & leds_green(0); 
            endCmd  <= '0'; 
            newData <= '1'; 
            next_decode_in <= segData(27 downto 24);
         
         when  "00101" => byte <= decode_out; endCmd <= '0'; newData <= '1';   
         when  "00110" => -- LED2 
            byte    <= "000000" & leds_red(1) & leds_green(1); 
            endCmd  <= '0'; 
            newData <= '1'; 
            next_decode_in <= segData(23 downto 20);
         
         when  "00111" => byte <= decode_out; endCmd <= '0'; newData <= '1';
         when  "01000" => -- LED3 red
            byte <= "000000" & leds_red(2) & leds_green(2); 
            endCmd <= '0'; 
            newData <= '1'; 
            next_decode_in <= segData(19 downto 16);
         
         when  "01001" => byte <= decode_out; endCmd <= '0'; newData <= '1';
         when  "01010" => -- LED4 green
            byte <= "000000" & leds_red(3) & leds_green(3); 
            endCmd <= '0'; 
            newData <= '1'; 
            next_decode_in <= segData(15 downto 12);
         
         when  "01011" => byte <= decode_out; endCmd <= '0'; newData <= '1';
         when  "01100" => -- LED5
            byte <= "000000" & leds_red(4) & leds_green(4); 
            endCmd <= '0'; 
            newData <= '1'; 
            next_decode_in <= segData(11 downto 8);
         
         when  "01101" => byte <= decode_out; endCmd <= '0'; newData <= '1';
         when  "01110" => -- LED6 
            byte <= "000000" & leds_red(5) & leds_green(5); 
            endCmd <= '0'; 
            newData <= '1';   
            next_decode_in <= segData(7 downto 4);
         
         when  "01111" => byte <= decode_out; endCmd <= '0'; newData <= '1';
         when  "10000" => -- led 7
            byte <= "000000" & leds_red(6) & leds_green(6); 
            endCmd <= '0'; 
            newData <= '1';
            next_decode_in <= segData(3 downto 0);
            
         when  "10001" =>  byte <= decode_out; endCmd <= '0'; newData <= '1';   
         when  "10010" => -- led 8
            byte <= "000000" & leds_red(7) & leds_green(7); 
            endCmd <= '1'; 
            newData <= '1';
            
         when  others => byte <= x"FF"; endCmd <= '1'; newData <= '0';  -- End of data / idle
      end case;
   end process;
   
clk_proc: process(clk)
   begin
      if rising_edge(clk) then
         if reset = '1' then 
            counter <= (others => '0');
         elsif adv = '1' and counter /= "11111" then
            counter <= std_logic_vector(nextcounter);
            decode_in <= next_decode_in;
         end if;
      end if;
   end process;
end Behavioral;

