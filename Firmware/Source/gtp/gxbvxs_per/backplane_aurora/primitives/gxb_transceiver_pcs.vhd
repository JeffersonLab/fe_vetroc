library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library altera_mf;
use altera_mf.altera_mf_components.all;
 
entity gxb_transceiver_pcs is
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
end gxb_transceiver_pcs;

architecture rtl of gxb_transceiver_pcs is

	component gxb_transceiver_pma is
		generic(
			starting_channel_number		: NATURAL := 0
		);
		port(
			cal_blk_clk			: in std_logic;
			pll_inclk			: in std_logic;
			reconfig_clk		: in std_logic;
			reconfig_togxb		: in std_logic_vector(3 downto 0);
			rx_analogreset		: in std_logic_vector(1 downto 0);
			rx_cruclk			: in std_logic_vector(1 downto 0) :=  (others => '0');
			rx_datain			: in std_logic_vector(1 downto 0);
			tx_datain			: in std_logic_vector(39 downto 0);
			pll_locked			: out std_logic_vector(0 downto 0);
			reconfig_fromgxb	: out std_logic_vector(33 downto 0);
			rx_clkout			: out std_logic_vector(1 downto 0);
			rx_dataout			: out std_logic_vector(39 downto 0);
			rx_freqlocked		: out std_logic_vector(1 downto 0);
			tx_clkout			: out std_logic_vector(1 downto 0);
			tx_dataout			: out std_logic_vector(1 downto 0)
		);
	end component;

	component x2_encoder_8b10b 
		port(
			clk 			: in std_logic;
			kin_ena 		: in std_logic_vector(1 downto 0); 
			ein_dat 		: in std_logic_vector(15 downto 0); 
			eout_dat 	: out std_logic_vector(19 downto 0)
		);
	end component;

	component x2_decoder_8b10b 
		port(
			clk 			: in std_logic;
			din_dat 		: in std_logic_vector(19 downto 0); 
			dout_dat		: out std_logic_vector(15 downto 0); 
			dout_k      : out std_logic_vector(1 downto 0); 
			dout_kerr   : out std_logic_vector(1 downto 0); -- coding mistake detected
			dout_rderr  : out std_logic_vector(1 downto 0); -- running disparity mistake detected
			dout_rdcomb : out std_logic_vector(1 downto 0); -- running dispartiy output (comb)
			dout_rdreg  : out std_logic_vector(1 downto 0)  -- running disparity output (reg)
		);
	end component;

	component word_align is
		generic(
			align_pattern1			: std_logic_vector(9 downto 0) := "0101111100";	-- K28.5-
			align_pattern2			: std_logic_vector(9 downto 0) := "1010000011"	-- K28.5+
		);
		port(
			clk						: in std_logic;
			rx_enapatternalign	: in std_logic;
			rx_datain				: in std_logic_vector(19 downto 0);
			rx_dataout				: out std_logic_vector(19 downto 0);
			rx_patterndetect		: out std_logic_vector(1 downto 0);
			rx_syncstatus			: out std_logic_vector(1 downto 0)
		);
	end component;

	signal rx_datain_aligned	: std_logic_vector(39 downto 0);
	signal rx_dataout_pma		: std_logic_vector(39 downto 0);
	signal rx_datain_pcs			: std_logic_vector(39 downto 0);
	signal rx_clkout				: std_logic_vector(1 downto 0);
	signal rx_fifo_empty			: std_logic_vector(1 downto 0);
	signal rx_fifo_rdreq			: std_logic_vector(1 downto 0);

	signal q							: std_logic_vector(39 downto 0);
	signal tx_datain_pma			: std_logic_vector(39 downto 0);
	signal tx_dataout_pcs		: std_logic_vector(39 downto 0);
	signal tx_clkout				: std_logic_vector(1 downto 0);
	signal tx_clkout_n			: std_logic_vector(1 downto 0);
	signal tx_fifo_empty			: std_logic_vector(1 downto 0);
	signal tx_fifo_rdreq			: std_logic_vector(1 downto 0);
begin

	lane_gen: for I in 0 to 1 generate
		-- RX PCS
		x2_decoder_8b10b_inst: x2_decoder_8b10b
			port map(
				clk			=> rx_coreclk,
				din_dat		=> rx_datain_aligned(20*I+19 downto 20*I),	
				dout_dat		=> rx_dataout(16*I+15 downto 16*I),
				dout_k		=> rx_ctrldetect(2*I+1 downto 2*I),
				dout_kerr	=> rx_errdetect(2*I+1 downto 2*I),
				dout_rderr	=> rx_disperr(2*I+1 downto 2*I)
			);

		word_align_inst: word_align
			generic map(
				align_pattern1			=> "0101111100",
				align_pattern2			=> "1010000011"
			)
			port map(
				clk						=> rx_coreclk,
				rx_enapatternalign	=> rx_enapatternalign(I),
				rx_datain				=> rx_datain_pcs(20*I+19 downto 20*I),
				rx_dataout				=> rx_datain_aligned(20*I+19 downto 20*I),
				rx_syncstatus			=> rx_syncstatus(2*I+1 downto 2*I),
				rx_patterndetect		=> open
			);

		-- RX PMA->PCS FIFO
		rx_pma_pcs_fifo: dcfifo
			generic map(
				intended_device_family	=> "STRATIX IV",
				lpm_hint						=> "RAM_BLOCK_TYPE=MLAB",
				lpm_numwords				=> 16,
				lpm_showahead				=> "OFF",
				lpm_type						=> "dcfifo",
				lpm_width					=> 20,
				lpm_widthu					=> 4,
				overflow_checking			=> "ON",
				rdsync_delaypipe			=> 5,
				underflow_checking		=> "ON",
				use_eab						=> "ON",
				write_aclr_synch			=> "ON",
				wrsync_delaypipe			=> 5
			)
			port map(
				aclr		=> rx_digitalreset(I),
				wrclk		=> rx_clkout(I),
				data		=> rx_dataout_pma(20*I+19 downto 20*I),
				wrreq		=> '1',
				wrusedw	=> open,
				wrfull	=> open,
				rdclk		=> rx_coreclk,
				rdreq		=> rx_fifo_rdreq(I),
				q			=> rx_datain_pcs(20*I+19 downto 20*I),
				rdempty	=> rx_fifo_empty(I),
				rdfull	=> open
			);

		rx_fifo_rdreq(I) <= not rx_fifo_empty(I);

		-- TX PCS
		x2_encoder_8b10b_inst: x2_encoder_8b10b
			port map(
				clk			=> tx_coreclk,
				kin_ena		=> tx_ctrlenable(2*I+1 downto 2*I),
				ein_dat		=> tx_datain(16*I+15 downto 16*I),
				eout_dat		=> tx_dataout_pcs(20*I+19 downto 20*I)
			);
		
		-- TX PCS->PMA FIFO
		tx_pcs_pma_fifo: dcfifo
			generic map(
				intended_device_family	=> "STRATIX IV",
				lpm_hint						=> "RAM_BLOCK_TYPE=MLAB",
				lpm_numwords				=> 16,
				lpm_showahead				=> "OFF",
				lpm_type						=> "dcfifo",
				lpm_width					=> 20,
				lpm_widthu					=> 4,
				overflow_checking			=> "ON",
				rdsync_delaypipe			=> 5,
				underflow_checking		=> "ON",
				use_eab						=> "ON",
				write_aclr_synch			=> "ON",
				wrsync_delaypipe			=> 5
			)
			port map(
				aclr		=> tx_digitalreset(I),
				wrclk		=> tx_coreclk,
				data		=> tx_dataout_pcs(20*I+19 downto 20*I),
				wrreq		=> '1',
				wrusedw	=> open,
				wrfull	=> open,
				rdclk		=> tx_clkout_n(I),
				rdreq		=> tx_fifo_rdreq(I),
				q			=> q(20*I+19 downto 20*I),
				rdempty	=> tx_fifo_empty(I),
				rdfull	=> open
			);

		process(tx_clkout_n)
		begin
			if rising_edge(tx_clkout_n(I)) then
				tx_datain_pma(20*I+19 downto 20*I) <= q(20*I+19 downto 20*I);
			end if;
		end process;

		-- use for 2.5Gbps (125MHz parallel) rates
		tx_clkout_n(I) <= tx_clkout(I);

		-- use for 5Gbps (250MHz parallel) rates
--		tx_clkout_n(I) <= not tx_clkout(I);
		tx_fifo_rdreq(I) <= not tx_fifo_empty(I);
	end generate;

	gxb_transceiver_pma_inst: gxb_transceiver_pma
		generic map(
			starting_channel_number	=> starting_channel_number
		)
		port map(
			cal_blk_clk			=> cal_blk_clk,
			pll_inclk			=> pll_inclk,
			reconfig_clk		=> reconfig_clk,
			reconfig_togxb		=> reconfig_togxb,
			rx_analogreset		=> rx_analogreset,
			rx_cruclk(0)		=> pll_inclk,
			rx_cruclk(1)		=> pll_inclk,
			rx_datain			=> rx_datain,
			tx_datain			=> tx_datain_pma,
			pll_locked			=> pll_locked,
			reconfig_fromgxb	=> reconfig_fromgxb,
			rx_clkout			=> rx_clkout,
			rx_dataout			=> rx_dataout_pma,
			rx_freqlocked		=> rx_freqlocked,
			tx_clkout			=> tx_clkout,
			tx_dataout			=> tx_dataout
		);

end rtl;
