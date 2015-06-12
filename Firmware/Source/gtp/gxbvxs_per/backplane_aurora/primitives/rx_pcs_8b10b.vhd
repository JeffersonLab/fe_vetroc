----------------------------------------------------------------------------------------------------
-- (c)2007 Altera Corporation. All rights reserved.
--
-- Altera products are protected under numerous U.S. and foreign patents,
-- maskwork rights, copyrights and other intellectual property laws.
--
-- This reference design file, and your use thereof, is subject to and governed
-- by the terms and conditions of the applicable Altera Reference Design License
-- Agreement (either as signed by you or found at www.altera.com).  By using
-- this reference design file, you indicate your acceptance of such terms and
-- conditions between you and Altera Corporation.  In the event that you do not
-- agree with such terms and conditions, you may not use the reference design
-- file and please promptly destroy any copies you have made.
--
-- This reference design file is being provided on an "as-is" basis and as an
-- accommodation and therefore all warranties, representations or guarantees of
-- any kind (whether express, implied or statutory) including, without
-- limitation, warranties of merchantability, non-infringement, or fitness for
-- a particular purpose, are specifically disclaimed.  By making this reference
-- design file available, Altera expressly does not recommend, suggest or
-- require that this reference design file be used in combination with any
-- other product not provided by Altera.

-- Author : Peter Schepers

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
entity rx_pcs_8b10b is
GENERIC
(
	RATE_5G_2_5Gn				: STD_LOGIC;
	starting_channel_number : NATURAL := 0;
	NUMBER_OF_LANES	: integer := 4;	  	-- NUMBER_OF_LANES
	LANEWIDTH		: integer := 32		-- LANEWIDTH for transceiver
);
PORT
(
	--Reset							: IN STD_LOGIC;
	cal_blk_clk						: IN STD_LOGIC;
	cal_blk_powerdown				: IN STD_LOGIC;
	pll_inclk						: IN STD_LOGIC;
		
	reconfig_clk					: IN STD_LOGIC;
	reconfig_togxb					: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	reconfig_fromgxb				: OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
	
	gxb_powerdown					: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
	rx_analogreset					: IN STD_LOGIC_VECTOR ((NUMBER_OF_LANES-1) DOWNTO 0);
	rx_digitalreset				: IN STD_LOGIC_VECTOR ((NUMBER_OF_LANES-1) DOWNTO 0);
	
	rx_coreclk						: IN STD_LOGIC;
	rx_datain						: IN STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) DOWNTO 0); 
	rx_clkout						: OUT STD_LOGIC_VECTOR((NUMBER_OF_LANES - 1) downto 0);
	rx_dataout						: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);
	rx_ctrldetect					: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
	rx_disperr						: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
	rx_errdetect					: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
	rx_enapatternalign			: IN STD_LOGIC_VECTOR ((NUMBER_OF_LANES-1) downto 0);
	
	rx_patterndetect				: out std_logic_vector(3 downto 0);
	rx_syncstatus					: out std_logic_vector(3 downto 0)
);
END rx_pcs_8b10b;

architecture rtl of rx_pcs_8b10b is

	component rx_pma
	GENERIC 
	(
		RATE_5G_2_5Gn				: STD_LOGIC;
		starting_channel_number	:	NATURAL := 0
	);
	PORT
	(
		cal_blk_clk		: IN STD_LOGIC ;
		cal_blk_powerdown		: IN STD_LOGIC ;
		gxb_powerdown		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		reconfig_clk		: IN STD_LOGIC ;
		reconfig_togxb		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		rx_analogreset		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		rx_cruclk		: IN STD_LOGIC_VECTOR (1 DOWNTO 0) :=  (OTHERS => '0');
		rx_datain		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		reconfig_fromgxb		: OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
		rx_clkout		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		rx_dataout		: OUT STD_LOGIC_VECTOR (39 DOWNTO 0)
	);
	end component;

	COMPONENT rx_phase_comp IS
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		
		wrclk		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (19 DOWNTO 0);
		wrreq		: IN STD_LOGIC ;
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		rdfull		: OUT STD_LOGIC
	);
	END COMPONENT;


component x2_decoder_8b10b 
PORT (
    clk 		: in std_logic;
    rst 		: in std_logic;
	din_dat 	: in std_logic_vector(19 downto 0); 
	dout_dat	: out std_logic_vector(15 downto 0); 
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

type Bit6Type is array (0 to (NUMBER_OF_LANES-1)) of std_logic_vector(5 downto 0);

signal valid_encoded		: std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
signal rx_clkout_int		: std_logic_vector((NUMBER_OF_LANES-1) downto 0);

signal Reset_Rx_n			: std_logic;
signal Reset_I				: std_logic; 
signal Reset_I_int			: std_logic_vector((NUMBER_OF_LANES-1) downto 0); 
signal rx_unaligned			: std_logic_vector(((NUMBER_OF_LANES * 20)-1) downto 0);
signal rx_unaligned_reg		: std_logic_vector(((NUMBER_OF_LANES * 20)-1) downto 0);
signal rx_phase				: std_logic_vector(((NUMBER_OF_LANES * 20)-1) downto 0);
signal rx_bitslipped		: std_logic_vector(((NUMBER_OF_LANES * 20)-1) downto 0);
signal rx_aligned			: std_logic_vector(((NUMBER_OF_LANES * 20)-1) downto 0);
signal rx_valid_decoder		: std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);

signal rx_dataout_8b10b 	: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);
signal rx_ctrldetect_8b10b	: std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
signal rx_dataout_int 	: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);
signal rx_ctrldetect_int	: std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
signal Bitslip				: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal AlignChanged			:Bit6Type;
--signal RxError				: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal rx_disperr_i			: STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
signal rx_errdetect_i		: STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
signal Zeroes				: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal Ones					: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal WordAligned			: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal ByteAligned			: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
--signal rx_patterndetect_int : STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
signal rx_patterndetect_final : STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
signal pll_locked_int			: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal rx_digitalreset_combined	: std_logic;
--signal rx_enapatternalign 		: std_logic_vector((NUMBER_OF_LANES - 1) downto 0);
signal ByteSwap					: std_logic_vector((NUMBER_OF_LANES - 1) downto 0);
signal rdenable					: std_logic;
signal wrenable					: std_logic;

SIGNAL rx_freqlocked_i		: STD_LOGIC_VECTOR ((NUMBER_OF_LANES-1) DOWNTO 0) := (others=>'0');
SIGNAL wrreq				: STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) downto 0);
	signal rx_patterndetect_align	: std_logic_vector(3 downto 0);
begin

	rx_clkout <= rx_clkout_int;
	
-----------------------------------------------------------------------------------------------------------
--	ALTGX Instantiation
-----------------------------------------------------------------------------------------------------------	

	pma_rx: rx_pma
		generic map(
			RATE_5G_2_5Gn				=> RATE_5G_2_5Gn,
			starting_channel_number	=> starting_channel_number
		)
		port map(
			cal_blk_clk			=> cal_blk_clk,
			cal_blk_powerdown	=> cal_blk_powerdown,
			gxb_powerdown(0)	=> gxb_powerdown(0),
			gxb_powerdown(1)	=> gxb_powerdown(0),
			
			reconfig_clk		=> reconfig_clk,
			reconfig_togxb		=> reconfig_togxb,
			reconfig_fromgxb	=> reconfig_fromgxb,
			
			rx_analogreset		=> rx_analogreset,
			rx_cruclk(0)		=> pll_inclk,
			rx_cruclk(1)		=> pll_inclk,
			rx_datain			=> rx_datain,
			rx_clkout			=> rx_clkout_int,
			rx_dataout			=> rx_unaligned
		);
	
	gen_phase_comp: for i in 0 TO NUMBER_OF_LANES-1 generate
		process(rx_clkout_int(i))
		begin
			if rising_edge(rx_clkout_int(i)) then
				rx_unaligned_reg(20*i+19 downto 20*i) <= rx_unaligned(20*i+19 downto 20*i);
			end if;
		end process;

		wrreq(i) <= not rx_analogreset(i);

		phase_comp: rx_phase_comp
			port map(
				aclr		=> rx_digitalreset(i),
				wrclk		=> rx_clkout_int(i),
				data		=> rx_unaligned_reg(20*i+19 downto 20*i),
				wrreq		=> wrreq(i),
				wrfull	=> open,
				wrusedw	=> open,
				rdclk		=> rx_coreclk,
				rdreq		=> '1',
				q			=> rx_phase(20*i+19 downto 20*i),
				rdempty	=> open,
				rdfull	=> open
			);
	end generate;
	
-----------------------------------------------------------------------------------------------------------
--	Instantiate Wordaligner function
-----------------------------------------------------------------------------------------------------------	

	Generate_wordalign: for I in 0 to NUMBER_OF_LANES-1 generate
		word_align_inst: word_align
			generic map(
				align_pattern1			=> "0101111100",
				align_pattern2			=> "1010000011"
			)
			port map(
				clk						=> rx_coreclk,
				rx_enapatternalign	=> rx_enapatternalign(I),
				rx_datain				=> rx_phase((20*(I+1)-1) downto (20*I)),
				rx_dataout				=> rx_bitslipped((20*(I+1)-1) downto (20*I)),
				rx_syncstatus			=> rx_syncstatus(2*I+1 downto 2*I),
				rx_patterndetect		=> rx_patterndetect_align(2*I+1 downto 2*I)
			);
	end generate;

-----------------------------------------------------------------------------------------------------------
--	Instantiate cascaded 8B/10B Decoder
-----------------------------------------------------------------------------------------------------------	

	Generate_Cascaded8b10bdecoder: for i in 0 to NUMBER_OF_LANES-1 generate
		Cascaded_8b10b_decoder_32bit_inst: x2_decoder_8b10b 
		port map(
			clk			=> rx_coreclk,
			rst		  	=> rx_digitalreset(i),	
			din_dat		=> rx_bitslipped((20*(I+1)-1) downto (20*I)),	
			dout_dat	=> rx_dataout((16*(I+1)-1) downto (16*I)), --rx_dataout_8b10b
			dout_k		=> rx_ctrldetect((2*I + 1) downto 2*I), --rx_ctrldetect_8b10b
			dout_kerr	=> rx_errdetect_i((2*I + 1) downto (2*I)),
			dout_rderr	=> rx_disperr_i((2*I + 1) downto (2*I))
		);
	end generate;

	rx_errdetect	<= rx_errdetect_i;
	rx_disperr		<= rx_disperr_i;

	process(rx_coreclk)
	begin
		if rising_edge(rx_coreclk) then
			rx_patterndetect <= rx_patterndetect_align;
		end if;
	end process;

end rtl;
