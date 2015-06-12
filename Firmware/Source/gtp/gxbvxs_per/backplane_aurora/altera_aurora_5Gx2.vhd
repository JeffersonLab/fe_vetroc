library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library utils;
use utils.utils_pkg.all;

entity altera_aurora_5Gx2 is
	generic(
		STARTING_CHANNEL_NUMBER	: natural;
		PMA_DIRECT					: std_logic := '0'
	);
	port(
		--Serial IO
		RX1P_IN						: in std_logic_vector(0 to 1);
		TX1P_OUT						: out std_logic_vector(0 to 1);
		
		--Reference Clocks and User Clock
		REFCLK						: in std_logic;
		PLLLKDET_OUT				: out std_logic;
		RXUSRCLK_IN					: in std_logic;
		RXUSRCLK2_IN				: in std_logic; -- Unused
		TXUSRCLK_IN					: in std_logic;
		TXUSRCLK2_IN				: in std_logic; -- Unused
		REFCLKOUT_OUT				: out std_logic; -- Aurora Open
		TXOUTCLK1_OUT				: out std_logic_vector(1 downto 0); -- Aurora clock loopback
		TXOUTCLK2_OUT				: out std_logic; -- Aurora Open
		
		--Global Logic Interface
		ENCHANSYNC_IN				: in std_logic;
		CHBONDDONE_OUT				: out std_logic_vector(1 DOWNTO 0);
		
		RXRESET_IN					: in std_logic_vector(1 DOWNTO 0);
		RXPOLARITY_IN				: in std_logic_vector(1 DOWNTO 0); -- Unused
		RXBUFERR_OUT				: out std_logic_vector(1 DOWNTO 0);
		RXDATA_OUT					: out std_logic_vector (31 downto 0);
		RXCHARISCOMMA_OUT			: out std_logic_vector (3 downto 0);
		RXCHARISK_OUT				: out std_logic_vector (3 downto 0);
		RXDISPERR_OUT				: out std_logic_vector (3 downto 0);
		RXNOTINTABLE_OUT			: out std_logic_vector (3 downto 0);
		RXREALIGN_OUT				: out std_logic_vector(1 DOWNTO 0);
		
		TXRESET_IN					: in std_logic_vector(1 downto 0);
		TXDATA_IN					: in std_logic_vector(31 downto 0);
		TXCHARISK_IN				: in std_logic_vector(3 downto 0);
		TXBUFFER_OUT				: out std_logic_vector(1 downto 0);
		
		-- Phase Align Interface
		ENMCOMMAALIGN_IN			: in std_logic_vector(1 DOWNTO 0);
		ENPCOMMAALIGN_IN			: in std_logic_vector(1 DOWNTO 0);
		RXRECCLK1_OUT				: out std_logic_vector(1 DOWNTO 0);  -- Aurora Open
		RXRECCLK2_OUT				: out std_logic_vector(1 DOWNTO 0);  -- Aurora Open
		
		--System Interface
		GTXRESET_IN					: in std_logic;
		LOOPBACK_IN					: in std_logic_vector (2 downto 0);
		POWERDOWN_IN				: in std_logic;
		
		--SIV Specific
		CLK50							: in std_logic;
		CAL_BLK_POWERDOWN			: in std_logic;
		CAL_BLK_BUSY				: in std_logic;
		RECONFIG_FROMGXB			: out std_logic_vector(67 downto 0);
		RECONFIG_TOGXB				: in std_logic_vector(3 downto 0)
	);
end altera_aurora_5Gx2;

architecture alt_aur_arch OF altera_aurora_5Gx2 is
	component gxb_transceiver_pcs is
		generic(
			starting_channel_number : natural := 0
		);
		port(
			cal_blk_clk				: in std_logic;
			pll_inclk				: in std_logic;
			pll_locked				: out std_logic_vector(0 downto 0);

			reconfig_clk			: in std_logic;
			reconfig_togxb			: in std_logic_vector(3 downto 0);
			reconfig_fromgxb		: out std_logic_vector(33 downto 0);

			rx_analogreset			: in std_logic_vector(1 downto 0);
			rx_digitalreset		: in std_logic_vector(1 downto 0);
			rx_coreclk				: in std_logic;
			rx_datain				: in std_logic_vector(1 downto 0); 
			rx_dataout				: out std_logic_vector(31 downto 0);
			rx_ctrldetect			: out std_logic_vector(3 downto 0);
			rx_disperr				: out std_logic_vector(3 downto 0);
			rx_errdetect			: out std_logic_vector(3 downto 0);
			rx_enapatternalign	: in std_logic_vector(1 downto 0);	
			rx_syncstatus			: out std_logic_vector(3 downto 0);
			rx_freqlocked			: out std_logic_vector(1 downto 0);

			tx_digitalreset		: in std_logic_vector(1 downto 0);		
			tx_coreclk				: in std_logic;
			tx_datain				: in std_logic_vector(31 downto 0);
			tx_ctrlenable			: in std_logic_vector(3 downto 0);
			tx_dataout				: out std_logic_vector(1 downto 0)
		);
	end component;

	component gxb_transceiver is
		generic(
			starting_channel_number		: natural := 0
		);
		port(
			cal_blk_clk				: in std_logic;
			pll_inclk				: in std_logic;
			pll_locked				: out std_logic_vector(0 downto 0);
			
			reconfig_clk			: in std_logic;
			reconfig_togxb			: in std_logic_vector(3 downto 0);
			reconfig_fromgxb		: out std_logic_vector(16 downto 0);
			
			rx_analogreset			: in std_logic_vector(1 downto 0);
			rx_digitalreset		: in std_logic_vector(1 downto 0);
			rx_coreclk				: in std_logic_vector(1 downto 0);
			rx_datain				: in std_logic_vector(1 downto 0);
			rx_dataout				: out std_logic_vector(31 downto 0);
			rx_ctrldetect			: out std_logic_vector(3 downto 0);
			rx_disperr				: out std_logic_vector(3 downto 0);
			rx_errdetect			: out std_logic_vector(3 downto 0);
			rx_enapatternalign	: in std_logic_vector(1 downto 0);
			rx_syncstatus			: out std_logic_vector(3 downto 0);
			rx_freqlocked			: out std_logic_vector(1 downto 0);
			rx_cruclk				: in std_logic_vector(1 downto 0) :=  (others => '0');
			rx_clkout				: out std_logic_vector(1 downto 0);

			tx_digitalreset		: in std_logic_vector(1 downto 0) := (others => '0');
			tx_coreclk				: in std_logic_vector(1 downto 0);
			tx_datain				: in std_logic_vector(31 downto 0);
			tx_ctrlenable			: in std_logic_vector(3 downto 0);
			tx_dataout				: out std_logic_vector(1 downto 0);
			tx_clkout				: out std_logic_vector(1 downto 0)
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
	
	signal reconfig_fromgxb_pma	: std_logic_vector(67 downto 0);
	signal reconfig_fromgxb_nor	: std_logic_vector(16 downto 0);
	
	signal rx_analogreset			: std_logic_vector(1 downto 0);
	signal rx_digitalreset			: std_logic_vector(1 downto 0);
	signal tx_digitalreset			: std_logic_vector(1 downto 0);
	signal pll_locked					: std_logic;
	signal rx_freqlocked				: std_logic_vector(1 downto 0);
	
	signal rx_dataout					: std_logic_vector(31 downto 0);
	signal rx_ctrldetect				: std_logic_vector(3 downto 0);
	signal rx_errdetect				: std_logic_vector(3 downto 0);
	signal rx_disperr					: std_logic_vector(3 downto 0);
	signal rx_buferr					: std_logic_vector(1 downto 0);
	signal tx_buferr					: std_logic_vector(1 downto 0);
	signal tx_dataout					: std_logic_vector(1 downto 0);

	signal rx_nocomma_cnt			: slv3a(1 downto 0);

	signal rx_enapatternalign		: std_logic_vector(1 downto 0);
	signal rx_enapatternalign_q	: std_logic_vector(1 downto 0);
	signal rx_enalign					: std_logic_vector(1 downto 0);
	signal rx_enalign_q				: std_logic_vector(1 downto 0);
	
	signal rxdata						: std_logic_vector(31 downto 0);
	signal rxcharisk					: std_logic_vector(3 downto 0);
	signal rxnotintable				: std_logic_vector(3 downto 0);
	signal rx_patterndetect			: std_logic_vector(3 downto 0);
	signal rx_syncstatus				: std_logic_vector(3 downto 0);
	signal rx_syncstatus_q			: std_logic_vector(3 downto 0);
	signal bond_reset_n				: std_logic;
	signal bond_complete				: std_logic;
	signal tx_clkout_int				: std_logic_vector(1 downto 0);
	signal rx_freqlock_cnt			: std_logic_vector(8 downto 0);
	signal rx_freqlock_cnt_done	: std_logic;
	signal BUSY_SREQ					: std_logic_vector(2 downto 0);
	signal RESET_BOND					: std_logic;
begin

	CHBONDDONE_OUT <= (OTHERS => bond_complete);

	rx_freqlock_cnt_done <= '1' when rx_freqlock_cnt = conv_std_logic_vector(2**rx_freqlock_cnt'length-1, rx_freqlock_cnt'length) else '0';

	RESET_BOND <= rx_digitalreset(0) or rx_digitalreset(1);

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
			tx_digitalreset <= "11";
			rx_digitalreset <= "11";
			rx_analogreset <= "11";
			rx_freqlock_cnt <= (others=>'0');
		elsif rising_edge(TXUSRCLK_IN) then
			if pll_locked = '1' then
				tx_digitalreset <= "00";
			else
				tx_digitalreset <= TXRESET_IN;
				rx_digitalreset <= "11";
				rx_analogreset <= "11";
				rx_freqlock_cnt <= (others=>'0');
			end if;

			if (pll_locked = '1') and (BUSY_SREQ(0) = '0') then
				rx_analogreset <= "00";
			end if;

			if (rx_freqlocked /= "11") then
				rx_freqlock_cnt <= (others=>'0');
			elsif (rx_freqlocked = "11") and (rx_freqlock_cnt_done = '0') then
				rx_freqlock_cnt <= rx_freqlock_cnt + 1;
			end if;

			if rx_freqlock_cnt_done = '1' then
				rx_digitalreset <= RXRESET_IN;
			else
				rx_digitalreset <= "11";
			end if;
		end if;
	end process;

	-- Unused Clocks
	REFCLKOUT_OUT <= '0';
	TXOUTCLK1_OUT <= "00";
	TXOUTCLK2_OUT <= '0';
	RXRECCLK1_OUT <= (OTHERS => '0');
	RXRECCLK2_OUT <= (OTHERS => '0');
	PLLLKDET_OUT <= pll_locked;
	RXBUFERR_OUT <= (OTHERS => '0');
	TXBUFFER_OUT <= (OTHERS => '0');
	TXOUTCLK1_OUT <= "00";

	RXREALIGN_OUT <= ((rx_syncstatus(3) and not rx_syncstatus_q(3)) or (rx_syncstatus(2) and not rx_syncstatus_q(2))) &
	                 ((rx_syncstatus(1) and not rx_syncstatus_q(1)) or (rx_syncstatus(0) and not rx_syncstatus_q(0)));

	process(RXUSRCLK_IN)
	begin
		if rising_edge(RXUSRCLK_IN) then
			rx_syncstatus_q <= rx_syncstatus;
		end if;
	end process;

	align_rst_gen: for I in 0 to 1 generate
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

	patterndetect_gen: for I in 0 to 3 generate
		rx_patterndetect(I) <= '1' when (rx_ctrldetect(I) = '1') and
		                                (rx_dataout(I*8+7 downto I*8) = x"BC") else '0';
	end generate;
	
	gen_normal: if PMA_DIRECT = '0' generate
		RECONFIG_FROMGXB(67 downto 17) <= (others=>'0');

		gxb_transceiver_inst: gxb_transceiver
			generic map(
				starting_channel_number	=> STARTING_CHANNEL_NUMBER
			)
			port map( 
				cal_blk_clk				=> CLK50,
				pll_inclk				=> REFCLK,
				pll_locked(0)			=> pll_locked,

				reconfig_clk			=> CLK50,
				reconfig_togxb			=> RECONFIG_TOGXB,
				reconfig_fromgxb		=> RECONFIG_FROMGXB(16 downto 0),

				rx_analogreset			=> rx_analogreset,
				rx_digitalreset		=> rx_digitalreset,
				rx_coreclk(0)			=> RXUSRCLK_IN,
				rx_coreclk(1)			=> RXUSRCLK_IN,
				rx_datain(0)			=> RX1P_IN(0),
				rx_datain(1)			=> RX1P_IN(1),
				rx_dataout				=> rx_dataout,
				rx_ctrldetect			=> rx_ctrldetect,
				rx_disperr				=> rx_disperr,
				rx_errdetect			=> rx_errdetect,
				rx_enapatternalign	=> rx_enapatternalign,
				rx_syncstatus			=> rx_syncstatus,
				rx_freqlocked			=> rx_freqlocked,
				rx_cruclk(0)			=> REFCLK,
				rx_cruclk(1)			=> REFCLK,
				rx_clkout				=> open,

				tx_digitalreset		=> tx_digitalreset,
				tx_coreclk(0)			=> TXUSRCLK_IN,
				tx_coreclk(1)			=> TXUSRCLK_IN,
				tx_datain				=> TXDATA_IN,
				tx_ctrlenable			=> TXCHARISK_IN,
				tx_dataout(0)			=> TX1P_OUT(0),
				tx_dataout(1)			=> TX1P_OUT(1),
				tx_clkout				=> open
			);
	end generate;	

	gen_pma_direct: if PMA_DIRECT = '1' generate
		RECONFIG_FROMGXB(67 downto 34) <= (others=>'0');

		gxb_transceiver_pcs_inst: gxb_transceiver_pcs
			generic map(
				starting_channel_number	=> starting_channel_number
			)
			port map(
				cal_blk_clk				=> CLK50,
				pll_inclk				=> REFCLK,
				pll_locked(0)			=> pll_locked,
				reconfig_clk			=> CLK50,
				reconfig_togxb			=> RECONFIG_TOGXB,
				reconfig_fromgxb		=> RECONFIG_FROMGXB(33 downto 0),
				rx_analogreset			=> rx_analogreset,
				rx_digitalreset		=> rx_digitalreset,
				rx_coreclk				=> RXUSRCLK_IN,
				rx_datain(0)			=> RX1P_IN(0),
				rx_datain(1)			=> RX1P_IN(1),
				rx_dataout				=> rx_dataout,
				rx_ctrldetect			=> rx_ctrldetect,
				rx_disperr				=> rx_disperr,
				rx_errdetect			=> rx_errdetect,
				rx_enapatternalign	=> rx_enapatternalign,
				rx_syncstatus			=> rx_syncstatus,
				rx_freqlocked			=> rx_freqlocked,
				tx_digitalreset		=> tx_digitalreset,
				tx_coreclk				=> TXUSRCLK_IN,
				tx_datain				=> TXDATA_IN,
				tx_ctrlenable			=> TXCHARISK_IN,
				tx_dataout(0)			=> TX1P_OUT(0),
				tx_dataout(1)			=> TX1P_OUT(1)
			);
	end generate;
	
	lane_bond_inst: lane_bond
		generic map(
			LANE_NUM			=> 2
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
end alt_aur_arch;
