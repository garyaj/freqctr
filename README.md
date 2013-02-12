# freqctr


### A 0-99MHz Frequency Counter implemented in an S3A FPGA.

#### Hacked from Mike Field's code [here](http://hamsterworks.co.nz/mediawiki/index.php/Frequency_counter)

#### Prerequisites

* Avnet S3A eval kit (no longer available from Avnet; eBay maybe?)
* DX.com's [8-digit LED display](http://dx.com/p/8x-digital-tube-8x-key-8x-double-color-led-module-81873?rt=1&p=2&m=2&r=3&k=1&t=1&s=80208&u=81873).
* Avnet AvProg programming utility
* Xilinx's ISE Design Suite (I used 14.1).
* Mike Field's [code](http://hamsterworks.co.nz/mediawiki/index.php/Frequency_counter)

The EVK has a 16MHz clock whereas Mike's Papilio One has a 32MHz clock.
I only had to change `freq_counter.vhd` as follows:

	11,12c11,12
	<     Port ( clk16     : in  STD_LOGIC;
	<            clk12     : in  STD_LOGIC;
	---
	>     Port ( clk32    : in  STD_LOGIC;
	>            test_sig : in  STD_LOGIC;
	17,18c17,18
	<            pps_out   : out STD_LOGIC;
	<            clk12_out : out STD_LOGIC);
	---
	>            pps_in   : in  STD_LOGIC;
	>            pps_out  : out STD_LOGIC);
	59,61d58
	<    signal pps_in        : std_logic;
	<    signal pps           : std_logic;
	<    signal test_sig      : std_logic;
	66c63
	<    CLKIN_IN => clk16,
	---
	>    CLKIN_IN => clk32,
	95,96c92,93
	<       if internal_ref < 160000 then -- 10ms pulse
	<          pps <= '1';
	---
	>       if internal_ref < 320000 then -- 10ms pulse
	>          pps_out <= '1';
	98c95
	<          pps <= '0';
	---
	>          pps_out <= '0';
	101c98
	<       if internal_ref = 15999999 then -- 15999999
	---
	>       if internal_ref = 31999999 then -- 31999999
	110,113c107
	<    clk12_out <= clk12;
	<    pps_in <= pps;
	<    pps_out <= pps;
	<    test_sig <= clk12;
	---
	>

In summary:

* create an internal signal (`pps`) instead of connecting a 1pps signal to  `pps_in` externally
* connect `test_sig` to `clk12` (a 12MHz clock generated on the board)
* change the `internal_ref` process to output a pulse for 160000 clock cycles (10ms) whereas for a 32MHz clock obviously this would be 320000.
* similarly, reset `internal_ref` every 16 million cycles for a 16MHz clock (32 million for 32MHz)
* for my interest I output `clk12` on an external pin, `clk12_out`.


The other `.vhd` files are unchanged. The constraints file, `freq_counter.ucf`, obviously has different settings.

#### 224MHz clock

You must use Xilinx's Clocking Wizard to create a DCM_SP module named `clocking.vhd` with input frequency of 16MHz, `CLKFX_OUT` and `CLKFX180_OUT` selected and the multiplier set to 14. This makes `clk_fast` (aka `CLKFX_OUT`) run at 244MHz as per Mike's design. (More info on how to use the Clocking Wizard is in [Xilinx's ISE in-depth tutorial](http://www.xilinx.com/support/documentation/sw_manuals/xilinx14_1/ise_tutorial_ug695.pdf)). `clk_slow` (aka `CLK0_OUT`) mirrors the system clock, originally 32MHz, but 16MHz in this version. The dxdisplay chip doesn't seem to mind being run at half the speed.

#### Display uses too much current for MBA.

I sadly discovered the hard way that the USB output on my MacBook Air is insufficient to power both the EVK and the dxdisplay.

#### SPI Flash to the rescue
AvProg allows a (compressed) version of `freq_count.bit` to be stored in the SPI flash chip   on the EVK which will load and start on power up. This allowed me to connect the USB plug on the EVK to a wall-wart charger which has plenty of power.

