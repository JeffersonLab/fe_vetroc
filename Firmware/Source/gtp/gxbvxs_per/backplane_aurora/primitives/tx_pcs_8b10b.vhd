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

library altera_mf;
use altera_mf.altera_mf_components.all;
 
entity tx_pcs_8b10b is
GENERIC
(
	RATE_5G_2_5Gn	: STD_LOGIC;
	starting_channel_number : NATURAL := 0;
	NUMBER_OF_LANES	: integer := 4;	  	-- NUMBER_OF_LANES
	LANEWIDTH		: integer := 32		-- LANEWIDTH for transceiver
);
PORT(
	--Reset				: IN STD_LOGIC ;
	cal_blk_clk			: IN STD_LOGIC ;
	cal_blk_powerdown	: IN STD_LOGIC;
	pll_inclk			: IN STD_LOGIC ;
	pll_locked			: out std_logic_vector(0 downto 0);

	reconfig_clk		: IN STD_LOGIC ;
	reconfig_togxb		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	reconfig_fromgxb	: OUT STD_LOGIC_VECTOR (33 DOWNTO 0);

	gxb_powerdown		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
	tx_digitalreset	: IN STD_LOGIC_VECTOR ((NUMBER_OF_LANES-1) DOWNTO 0);
	
	tx_coreclk			: IN STD_LOGIC;
	tx_datain			: IN STD_LOGIC_VECTOR (((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);
	tx_ctrlenable		: IN STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
	tx_dataout			: OUT STD_LOGIC_VECTOR ((NUMBER_OF_LANES - 1) downto 0)
);
END tx_pcs_8b10b;

architecture rtl of tx_pcs_8b10b is

	component x2_encoder_8b10b 
	PORT (
		clk 		: in std_logic;
		rst 		: in std_logic;
		kin_ena 	: in std_logic_vector(1 downto 0); 
		ein_dat 	: in std_logic_vector(15 downto 0); 
		eout_dat 	: out std_logic_vector(19 downto 0)
	);
	end component;

	component tx_pma
		GENERIC(
			starting_channel_number		: NATURAL := 0;
			RATE_5G_2_5Gn				: STD_LOGIC
		);
		PORT(
			cal_blk_clk			: IN STD_LOGIC;
			cal_blk_powerdown	: IN STD_LOGIC ;
			gxb_powerdown		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
			pll_inclk			: IN STD_LOGIC;
			pll_locked			: out std_logic_vector(0 downto 0);
			pll_powerdown		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
			reconfig_clk		: IN STD_LOGIC ;
			reconfig_fromgxb	: OUT STD_LOGIC_VECTOR (33 DOWNTO 0);
			reconfig_togxb		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			tx_clkout			: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			tx_datain			: IN STD_LOGIC_VECTOR (39 DOWNTO 0);
			tx_dataout			: OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
		);
	end component;
	
	signal tx_encoded			: std_logic_vector(((NUMBER_OF_LANES * 20)-1) downto 0);
	signal tx_encoded_q		: std_logic_vector(((NUMBER_OF_LANES * 20)-1) downto 0);
	signal tx_encoded_reg1	: std_logic_vector(((NUMBER_OF_LANES * 20)-1) downto 0);
	signal tx_encoded_reg2	: std_logic_vector(((NUMBER_OF_LANES * 20)-1) downto 0);
	signal tx_clkout_int		: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
	
	signal tx_fifo_empty		: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
	signal tx_fifo_rdreq		: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
begin
	
	-----------------------------------------------------------------------------------------------------------
--	Instantiate cascaded 8B/10B Encoder 3,2,1,0 
--- 3 is MSByte, 0 is LSByte
-----------------------------------------------------------------------------------------------------------	

	Generate_Cascaded8b10bencoder:
	FOR I IN 0 to NUMBER_OF_LANES-1 GENERATE
		
	Cascaded_8b10b_encoder_32bit_inst : x2_encoder_8b10b
	PORT MAP 
		(
			clk			=> tx_coreclk,
			rst		  	=> tx_digitalreset(I),	
			kin_ena		=> tx_ctrlenable((2*(I+1)-1) downto (2*I)),
			ein_dat		=> tx_datain((16*(I+1)-1) downto (16*I)),
			eout_dat		=> tx_encoded((20*(I+1)-1) downto (20*I))
		);
		
		dcfifo_component : dcfifo
		GENERIC MAP (
			intended_device_family => "Stratix IV",
			lpm_hint => "RAM_BLOCK_TYPE=MLAB",
			lpm_numwords => 16,
			lpm_showahead => "OFF",
			lpm_type => "dcfifo",
			lpm_width => 20,
			lpm_widthu => 4,
			overflow_checking => "ON",
			rdsync_delaypipe => 5,
			underflow_checking => "ON",
			use_eab => "ON",
			write_aclr_synch => "ON",
			wrsync_delaypipe => 5
		)
		PORT MAP (
			aclr		=> tx_digitalreset(I),
			wrclk		=> tx_coreclk,
			data		=> tx_encoded((20*(I+1)-1) downto (20*I)),
			wrreq		=> '1',--NOT tx_digitalreset(I),
			wrusedw	=> OPEN,
			wrfull	=> OPEN,
			rdclk		=> tx_clkout_int(I),
			rdreq		=> tx_fifo_rdreq(I),
			q			=> tx_encoded_q((20*(I+1)-1) downto (20*I)),
			rdempty	=> tx_fifo_empty(I),
			rdfull	=> OPEN
		);
		PROCESS(tx_clkout_int(I))
		BEGIN
			IF rising_edge(tx_clkout_int(I)) THEN
				tx_encoded_reg2((20*(I+1)-1) downto (20*I)) <= tx_encoded_q((20*(I+1)-1) downto (20*I));
			END IF;
		END PROCESS;

		tx_fifo_rdreq(I) <= not tx_fifo_empty(I);

	END GENERATE;

-----------------------------------------------------------------------------------------------------------
--	ALTGX Instantiation
-----------------------------------------------------------------------------------------------------------	
		
	pma_tx : tx_pma
	GENERIC MAP
	(
		starting_channel_number	=> starting_channel_number,
		RATE_5G_2_5Gn				=> RATE_5G_2_5Gn
	)
	PORT MAP
	(
		cal_blk_clk				=> cal_blk_clk,
		cal_blk_powerdown		=> cal_blk_powerdown,
		gxb_powerdown			=> gxb_powerdown,
		pll_inclk				=> pll_inclk,
		pll_locked				=> pll_locked,
		pll_powerdown			=> gxb_powerdown,
		reconfig_clk			=> reconfig_clk,
		reconfig_fromgxb		=> reconfig_fromgxb,
		reconfig_togxb			=> reconfig_togxb,
		tx_clkout				=> tx_clkout_int,
		tx_datain				=> tx_encoded_reg2,
		tx_dataout				=> tx_dataout
	);	
	
end rtl;
