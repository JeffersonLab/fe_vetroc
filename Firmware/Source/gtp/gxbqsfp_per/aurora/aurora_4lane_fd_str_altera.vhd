library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;

library utils;
use utils.utils_pkg.all;

entity aurora_4lane_fd_str_altera is
	port(
		--Serial IO
		RX1P_IN						: in std_logic_vector(0 to 3);
		TX1P_OUT						: out std_logic_vector(0 to 3);
		
		--Reference Clocks and User Clock
		REFCLK_L						: in std_logic;
		REFCLK_R						: in std_logic;
		PLLLKDET_OUT				: out std_logic_vector(1 downto 0);
		RXUSRCLK_IN					: in std_logic;
		TXUSRCLK_IN					: in std_logic;
		
		--Global Logic Interface
		ENCHANSYNC_IN				: in std_logic;
		CHBONDDONE_OUT				: out std_logic_vector(3 DOWNTO 0);
		
		RXRESET_IN					: in std_logic_vector(3 DOWNTO 0);
		RXBUFERR_OUT				: out std_logic_vector(3 DOWNTO 0);
		RXDATA_OUT					: out std_logic_vector (63 downto 0);
		RXCHARISCOMMA_OUT			: out std_logic_vector (7 downto 0);
		RXCHARISK_OUT				: out std_logic_vector (7 downto 0);
		RXDISPERR_OUT				: out std_logic_vector (7 downto 0);
		RXNOTINTABLE_OUT			: out std_logic_vector (7 downto 0);
		RXREALIGN_OUT				: out std_logic_vector(3 DOWNTO 0);
		
		TXRESET_IN					: in std_logic_vector(3 downto 0);
		TXDATA_IN					: in std_logic_vector(63 downto 0);
		TXCHARISK_IN				: in std_logic_vector(7 downto 0);
		TXBUFFER_OUT				: out std_logic_vector(3 downto 0);
		
		-- Phase Align Interface
		ENMCOMMAALIGN_IN			: in std_logic_vector(3 DOWNTO 0);
		ENPCOMMAALIGN_IN			: in std_logic_vector(3 DOWNTO 0);
		
		--System Interface
		GTXRESET_IN					: in std_logic;
		LOOPBACK_IN					: in std_logic_vector (2 downto 0);
		POWERDOWN_IN				: in std_logic;
		
		--SIV Specific
		CLK50							: in std_logic;
		CAL_BLK_POWERDOWN_L		: in std_logic;
		CAL_BLK_POWERDOWN_R		: in std_logic;
		CAL_BLK_BUSY_L				: in std_logic;
		CAL_BLK_BUSY_R				: in std_logic;
		RECONFIG_FROMGXB_L		: out std_logic_vector(67 downto 0);
		RECONFIG_FROMGXB_R		: out std_logic_vector(67 downto 0);
		RECONFIG_TOGXB_L			: in std_logic_vector(3 downto 0);
		RECONFIG_TOGXB_R			: in std_logic_vector(3 downto 0)
	);
end aurora_4lane_fd_str_altera;

architecture synthesis of aurora_4lane_fd_str_altera is
	component gxb_transceiver IS
		generic(
			starting_channel_number		: NATURAL := 0
		);
		port(
			cal_blk_clk			: IN STD_LOGIC ;
			pll_inclk			: IN STD_LOGIC ;
			reconfig_clk		: IN STD_LOGIC ;
			reconfig_togxb		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			rx_analogreset		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			rx_coreclk			: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			rx_cruclk			: IN STD_LOGIC_VECTOR (1 DOWNTO 0) :=  (OTHERS => '0');
			rx_datain			: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			rx_digitalreset	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			rx_enapatternalign: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			tx_coreclk			: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			tx_ctrlenable		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			tx_datain			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			tx_digitalreset	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			pll_locked			: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
			reconfig_fromgxb	: OUT STD_LOGIC_VECTOR (16 DOWNTO 0);
			rx_clkout			: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			rx_ctrldetect		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			rx_dataout			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			rx_disperr			: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			rx_errdetect		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			rx_freqlocked		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			rx_syncstatus		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			tx_clkout			: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			tx_dataout			: OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
		);
	end component;

	component lane_bond is
		generic(
			LANE_NUM			: integer := 4
		);
		port(
			USER_CLK			: in std_logic;
			RESET				: in std_logic;
			ENABLE_BOND		: in std_logic;
			
			RX_DATA_IN		: in std_logic_vector(16*LANE_NUM-1 downto 0);
			RX_K_IN			: in std_logic_vector(2*LANE_NUM-1 downto 0);
			RX_C_IN			: in std_logic_vector(2*LANE_NUM-1 downto 0);
			
			RX_DATA_OUT		: out std_logic_vector(16*LANE_NUM-1 downto 0);
			RX_K_OUT			: out std_logic_vector(2*LANE_NUM-1 downto 0);
			RX_C_OUT			: out std_logic_vector(2*LANE_NUM-1 downto 0);
			
			BOND_DONE		: out std_logic;
			BOND_FAIL		: out std_logic
		);
	end component;

	signal rx_analogreset			: std_logic_vector(3 downto 0);
	signal rx_digitalreset			: std_logic_vector(3 downto 0);
	signal tx_digitalreset			: std_logic_vector(3 downto 0);
	signal pll_locked					: std_logic_vector(1 downto 0);
	signal rx_freqlocked				: std_logic_vector(3 downto 0);
	
	signal rx_dataout					: std_logic_vector(63 downto 0);
	signal rx_ctrldetect				: std_logic_vector(7 downto 0);
	signal rx_errdetect				: std_logic_vector(7 downto 0);
	signal rx_disperr					: std_logic_vector(7 downto 0);
	signal rx_buferr					: std_logic_vector(3 downto 0);
	signal tx_buferr					: std_logic_vector(3 downto 0);
	signal tx_dataout					: std_logic_vector(3 downto 0);

	signal rx_nocomma_cnt			: slv3a(3 downto 0);

	signal rx_enapatternalign		: std_logic_vector(3 downto 0);
	signal rx_enapatternalign_q	: std_logic_vector(3 downto 0);
	signal rx_enalign					: std_logic_vector(3 downto 0);
	signal rx_enalign_q				: std_logic_vector(3 downto 0);
	
	signal rxdata						: std_logic_vector(63 downto 0);
	signal rxcharisk					: std_logic_vector(7 downto 0);
	signal rxnotintable				: std_logic_vector(7 downto 0);
	signal rx_patterndetect			: std_logic_vector(7 downto 0);
	signal rx_syncstatus				: std_logic_vector(7 downto 0);
	signal rx_syncstatus_q			: std_logic_vector(7 downto 0);
	signal bond_reset_n				: std_logic;
	signal bond_complete				: std_logic;
	signal tx_clkout_int				: std_logic_vector(1 downto 0);
	signal rx_freqlock_cnt			: std_logic_vector(8 downto 0);
	signal rx_freqlock_cnt_done	: std_logic;
	signal BUSY_SREQ					: std_logic_vector(2 downto 0);
	signal RESET_BOND					: std_logic;
	signal CAL_BLK_BUSY				: std_logic;
begin

	CHBONDDONE_OUT <= (OTHERS => bond_complete);

	rx_freqlock_cnt_done <= '1' when rx_freqlock_cnt = conv_std_logic_vector(2**rx_freqlock_cnt'length-1, rx_freqlock_cnt'length) else '0';

	RESET_BOND <= rx_digitalreset(0) or rx_digitalreset(1);

	CAL_BLK_BUSY <= CAL_BLK_BUSY_R or CAL_BLK_BUSY_L;

	process(CAL_BLK_BUSY, RXUSRCLK_IN)
	begin
		if CAL_BLK_BUSY = '1' then
			BUSY_SREQ <= (others=>'0');
		elsif rising_edge(RXUSRCLK_IN) then
			BUSY_SREQ <= '0' & BUSY_SREQ(BUSY_SREQ'length-1 downto 1);
		end if;
	end process;

	process(POWERDOWN_IN, TXUSRCLK_IN)
	begin
		if POWERDOWN_IN = '1' then
			tx_digitalreset <= "1111";
			rx_digitalreset <= "1111";
			rx_analogreset <= "1111";
			rx_freqlock_cnt <= (others=>'0');
		elsif rising_edge(TXUSRCLK_IN) then
			if (pll_locked(0) = '1') and (pll_locked(1) = '1') then
				tx_digitalreset <= "0000";
			else
				tx_digitalreset <= TXRESET_IN;
				rx_digitalreset <= "1111";
				rx_analogreset <= "1111";
				rx_freqlock_cnt <= (others=>'0');
			end if;

			if (tx_digitalreset = "0000") and (BUSY_SREQ(0) = '0') then
				rx_analogreset <= "0000";
			end if;

			if (rx_freqlocked /= "1111") then
				rx_freqlock_cnt <= (others=>'0');
			elsif (rx_freqlocked = "1111") and (rx_freqlock_cnt_done = '0') then
				rx_freqlock_cnt <= rx_freqlock_cnt + 1;
			end if;

			if rx_freqlock_cnt_done = '1' then
				rx_digitalreset <= RXRESET_IN;
			else
				rx_digitalreset <= "1111";
			end if;
		end if;
	end process;

	RXBUFERR_OUT <= (OTHERS => '0');
	TXBUFFER_OUT <= (OTHERS => '0');

	PLLLKDET_OUT <= pll_locked;
	RXREALIGN_OUT <= ((rx_syncstatus(7) and not rx_syncstatus_q(7)) or (rx_syncstatus(6) and not rx_syncstatus_q(6))) &
	                 ((rx_syncstatus(5) and not rx_syncstatus_q(5)) or (rx_syncstatus(4) and not rx_syncstatus_q(4))) &
	                 ((rx_syncstatus(3) and not rx_syncstatus_q(3)) or (rx_syncstatus(2) and not rx_syncstatus_q(2))) &
	                 ((rx_syncstatus(1) and not rx_syncstatus_q(1)) or (rx_syncstatus(0) and not rx_syncstatus_q(0)));

	process(RXUSRCLK_IN)
	begin
		if rising_edge(RXUSRCLK_IN) then
			rx_syncstatus_q <= rx_syncstatus;
		end if;
	end process;

	align_rst_gen: for I in 0 to 3 generate
		process(RXUSRCLK_IN)
		begin
			if rising_edge(RXUSRCLK_IN) then
				if (ENMCOMMAALIGN_IN(I) = '0' and ENPCOMMAALIGN_IN(I) = '0') then
					rx_nocomma_cnt(I) <= (others=>'0');
				elsif ((ENMCOMMAALIGN_IN(I) = '1') or (ENPCOMMAALIGN_IN(I) = '1')) and
						((rx_patterndetect(2*I) = '1') or (rx_patterndetect(2*I+1) = '1')) then
					rx_nocomma_cnt(I) <= (others=>'0');
				else
					rx_nocomma_cnt(I) <= rx_nocomma_cnt(I) + 1;
				end if;
			end if;
		end process;

		rx_enapatternalign(I) <= '1' when rx_nocomma_cnt(I) = "111" else '0';
	end generate;

	patterndetect_gen: for I in 0 to 7 generate
		process(RXUSRCLK_IN)
		begin
			if rising_edge(RXUSRCLK_IN) then
				if (rx_ctrldetect(I) = '1') and (rx_dataout(I*8+7 downto I*8) = x"BC") then
					rx_patterndetect(I) <= '1';
				else
					rx_patterndetect(I) <= '0';
				end if;
			end if;
		end process;
	end generate;

	RECONFIG_FROMGXB_L(67 downto 17) <= (others=>'0');

	gxb_transceiver_L_inst: gxb_transceiver
		generic map(
			starting_channel_number	=> 128
		)
		port map( 
			cal_blk_clk						=> CLK50,
			pll_inclk						=> REFCLK_L,
			pll_locked(0)					=> pll_locked(0),
			reconfig_clk					=> CLK50,
			reconfig_togxb					=> RECONFIG_TOGXB_L,
			reconfig_fromgxb				=> RECONFIG_FROMGXB_L(16 downto 0),
			rx_analogreset(0)				=> rx_analogreset(1),
			rx_analogreset(1)				=> rx_analogreset(3),
			rx_digitalreset(0)			=> rx_digitalreset(1),
			rx_digitalreset(1)			=> rx_digitalreset(3),
			rx_coreclk(0)					=> RXUSRCLK_IN,
			rx_coreclk(1)					=> RXUSRCLK_IN,
			rx_datain(0)					=> RX1P_IN(1),
			rx_datain(1)					=> RX1P_IN(3),
			rx_dataout(15 downto 0)		=> rx_dataout(31 downto 16),
			rx_dataout(31 downto 16)	=> rx_dataout(63 downto 48),
			rx_ctrldetect(1 downto 0)	=> rx_ctrldetect(3 downto 2),
			rx_ctrldetect(3 downto 2)	=> rx_ctrldetect(7 downto 6),
			rx_disperr(1 downto 0)		=> rx_disperr(3 downto 2),
			rx_disperr(3 downto 2)		=> rx_disperr(7 downto 6),
			rx_errdetect(1 downto 0)	=> rx_errdetect(3 downto 2),
			rx_errdetect(3 downto 2)	=> rx_errdetect(7 downto 6),
			rx_enapatternalign(0)		=> rx_enapatternalign(1),
			rx_enapatternalign(1)		=> rx_enapatternalign(3),
			rx_syncstatus(1 downto 0)	=> rx_syncstatus(3 downto 2),
			rx_syncstatus(3 downto 2)	=> rx_syncstatus(7 downto 6),
			rx_freqlocked(0)				=> rx_freqlocked(1),
			rx_freqlocked(1)				=> rx_freqlocked(3),
			rx_cruclk(0)					=> REFCLK_L,
			rx_cruclk(1)					=> REFCLK_L,
			rx_clkout						=> open,
			tx_digitalreset(0)			=> tx_digitalreset(2),
			tx_digitalreset(1)			=> tx_digitalreset(0),
			tx_coreclk(0)					=> TXUSRCLK_IN,
			tx_coreclk(1)					=> TXUSRCLK_IN,
			tx_datain(15 downto 0)		=> TXDATA_IN(47 downto 32),
			tx_datain(31 downto 16)		=> TXDATA_IN(15 downto 0),
			tx_ctrlenable(1 downto 0)	=> TXCHARISK_IN(5 downto 4),
			tx_ctrlenable(3 downto 2)	=> TXCHARISK_IN(1 downto 0),
			tx_dataout(0)					=> TX1P_OUT(2),
			tx_dataout(1)					=> TX1P_OUT(0),
			tx_clkout						=> open
		);

	RECONFIG_FROMGXB_R(67 downto 17) <= (others=>'0');

	gxb_transceiver_R_inst: gxb_transceiver
		generic map(
			starting_channel_number	=> 128
		)
		port map( 
			cal_blk_clk						=> CLK50,
			pll_inclk						=> REFCLK_R,
			pll_locked(0)					=> pll_locked(1),
			reconfig_clk					=> CLK50,
			reconfig_togxb					=> RECONFIG_TOGXB_R,
			reconfig_fromgxb				=> RECONFIG_FROMGXB_R(16 downto 0),
			rx_analogreset(0)				=> rx_analogreset(0),
			rx_analogreset(1)				=> rx_analogreset(2),
			rx_digitalreset(0)			=> rx_digitalreset(0),
			rx_digitalreset(1)			=> rx_digitalreset(2),
			rx_coreclk(0)					=> RXUSRCLK_IN,
			rx_coreclk(1)					=> RXUSRCLK_IN,
			rx_datain(0)					=> RX1P_IN(0),
			rx_datain(1)					=> RX1P_IN(2),
			rx_dataout(15 downto 0)		=> rx_dataout(15 downto 0),
			rx_dataout(31 downto 16)	=> rx_dataout(47 downto 32),
			rx_ctrldetect(1 downto 0)	=> rx_ctrldetect(1 downto 0),
			rx_ctrldetect(3 downto 2)	=> rx_ctrldetect(5 downto 4),
			rx_disperr(1 downto 0)		=> rx_disperr(1 downto 0),
			rx_disperr(3 downto 2)		=> rx_disperr(5 downto 4),
			rx_errdetect(1 downto 0)	=> rx_errdetect(1 downto 0),
			rx_errdetect(3 downto 2)	=> rx_errdetect(5 downto 4),
			rx_enapatternalign(0)		=> rx_enapatternalign(0),
			rx_enapatternalign(1)		=> rx_enapatternalign(2),
			rx_syncstatus(1 downto 0)	=> rx_syncstatus(1 downto 0),
			rx_syncstatus(3 downto 2)	=> rx_syncstatus(5 downto 4),
			rx_freqlocked(0)				=> rx_freqlocked(0),
			rx_freqlocked(1)				=> rx_freqlocked(2),
			rx_cruclk(0)					=> REFCLK_R,
			rx_cruclk(1)					=> REFCLK_R,
			rx_clkout						=> open,
			tx_digitalreset(0)			=> tx_digitalreset(3),
			tx_digitalreset(1)			=> tx_digitalreset(1),
			tx_coreclk(0)					=> TXUSRCLK_IN,
			tx_coreclk(1)					=> TXUSRCLK_IN,
			tx_datain(15 downto 0)		=> TXDATA_IN(63 downto 48),
			tx_datain(31 downto 16)		=> TXDATA_IN(31 downto 16),
			tx_ctrlenable(1 downto 0)	=> TXCHARISK_IN(7 downto 6),
			tx_ctrlenable(3 downto 2)	=> TXCHARISK_IN(3 downto 2),
			tx_dataout(0)					=> TX1P_OUT(3),
			tx_dataout(1)					=> TX1P_OUT(1),
			tx_clkout						=> open
		);

	lane_bond_inst: lane_bond
		generic map(
			LANE_NUM			=> 4
		)
		port map(
			USER_CLK			=> RXUSRCLK_IN,
			RESET				=> RESET_BOND,
			ENABLE_BOND		=> ENCHANSYNC_IN,
			RX_DATA_IN		=> rx_dataout,
			RX_K_IN			=> rx_ctrldetect,
			RX_C_IN			=> rx_patterndetect,
			RX_DATA_OUT		=> RXDATA_OUT,
			RX_K_OUT			=> RXCHARISK_OUT,
			RX_C_OUT			=> RXCHARISCOMMA_OUT,
			BOND_DONE		=> bond_complete,
			BOND_FAIL		=> open
		);

	-- RX Parallel Data & Control
	rxnotintable <= rx_errdetect;
	RXNOTINTABLE_OUT <= rxnotintable;
	RXDISPERR_OUT <= rx_disperr;

end synthesis;
