library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

entity gtxvxs_per is
	generic(
		SIM_GTXRESET_SPEEDUP	: integer := 0;
		ADDR_INFO				: PER_ADDR_INFO
	);
	port(
		-- User ports --------------------------------------
		GTXD10       	: in std_logic;
		RXP				: in std_logic_vector(0 to 1);
		RXN				: in std_logic_vector(0 to 1);
		TXP				: out std_logic_vector(0 to 1);
		TXN				: out std_logic_vector(0 to 1);

		CLK				: in std_logic;
		TX_D				: in std_logic_vector(31 downto 0);
		TX_SRC_RDY_N	: in std_logic;

		-- Bus interface ports -----------------------------
		BUS_CLK			: in std_logic;
		BUS_RESET		: in std_logic;
		BUS_RESET_SOFT	: in std_logic;
		BUS_DIN			: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT			: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR			: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR			: in std_logic;
		BUS_RD			: in std_logic;
		BUS_ACK			: out std_logic
	);
end gtxvxs_per;

architecture Synthesis of gtxvxs_per is
	component aurora_2lane_fd_str_wrapper is
		generic(
			SIM_GTXRESET_SPEEDUP	: integer := 0
		);
		port(
			-- External Signals
			GTXD10       	: in std_logic;
			RXP				: in std_logic_vector(0 to 1);
			RXN				: in std_logic_vector(0 to 1);
			TXP				: out std_logic_vector(0 to 1);
			TXN				: out std_logic_vector(0 to 1);
	
			CLK				: in std_logic;
			RX_D				: out std_logic_vector(31 downto 0);
			RX_SRC_RDY_N	: out std_logic;
			TX_D				: in std_logic_vector(31 downto 0);
			TX_SRC_RDY_N	: in std_logic;
			TX_DST_RDY_N	: out std_logic;
			
			-- Register Clock
			BUS_CLK			: in std_logic;
			
			-- Write Registers
			GTX_CTRL			: in std_logic_vector(31 downto 0);
			GTX_CTRL_TILE0	: in std_logic_vector(31 downto 0);
			GTX_DRP_CTRL	: in std_logic_vector(31 downto 0);
			
			-- Read Registers
			GTX_STATUS		: out std_logic_vector(31 downto 0);
			GTX_ERR_TILE0	: out std_logic_vector(31 downto 0)
		);
	end component;

	component gxbvxs_mon is
		port(
			CLK				: in std_logic;

			TX_SRC_RDY_N	: in std_logic;
			TX_D				: in std_logic_vector(31 downto 0);

			LA_CMP_MODE0	: in std_logic_vector(2 downto 0);
			LA_CMP_THR0		: in std_logic_vector(31 downto 0);
			LA_MASK_EN0		: in std_logic_vector(31 downto 0);
			LA_MASK_VAL0	: in std_logic_vector(31 downto 0);
			LA_MASK_EN1		: in std_logic_vector(2 downto 0);
			LA_MASK_VAL1	: in std_logic_vector(2 downto 0);
			LA_ENABLE		: in std_logic;
			LA_READY			: out std_logic;
			LA_DO				: out slv32a(1 downto 0);
			LA_RDEN			: in std_logic_vector(1 downto 0)
		);
	end component;

	signal PI_CLK					: pbus_if_i;
	signal PO_CLK					: pbus_if_o;
	signal PI_BUSCLK				: pbus_if_i;
	signal PO_BUSCLK				: pbus_if_o;
	signal BUS_DOUT_BUSCLK		: std_logic_vector(31 downto 0);
	signal BUS_DOUT_CLK			: std_logic_vector(31 downto 0);
	signal BUS_ACK_BUSCLK		: std_logic;
	signal BUS_ACK_CLK			: std_logic;

	signal GTX_CTRL_REG			: std_logic_vector(31 downto 0);
	signal GTX_CTRL_TILE0_REG	: std_logic_vector(31 downto 0);
	signal GTX_DRP_CTRL_REG		: std_logic_vector(31 downto 0);
	signal GTX_STATUS_REG		: std_logic_vector(31 downto 0);
	signal GTX_DRP_STATUS_REG	: std_logic_vector(31 downto 0);
	signal GTX_ERR_TILE0_REG	: std_logic_vector(31 downto 0);
	signal LA_CMP_MODE0_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_CMP_THR0_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_EN0_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_VAL0_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_EN1_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_VAL1_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_CTRL_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_STATUS_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_DO0_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_DO1_REG				: std_logic_vector(31 downto 0) := x"00000000";

	signal LA_CMP_MODE0			: std_logic_vector(2 downto 0);
	signal LA_CMP_THR0			: std_logic_vector(31 downto 0);
	signal LA_MASK_EN0			: std_logic_vector(31 downto 0);
	signal LA_MASK_VAL0			: std_logic_vector(31 downto 0);
	signal LA_MASK_EN1			: std_logic_vector(2 downto 0);
	signal LA_MASK_VAL1			: std_logic_vector(2 downto 0);
	signal LA_ENABLE				: std_logic;
	signal LA_READY				: std_logic;
	signal LA_DO					: slv32a(1 downto 0);
	signal LA_RDEN					: std_logic_vector(1 downto 0);

	signal TX_D_I					: std_logic_vector(31 downto 0);
	signal TX_D_O					: std_logic_vector(31 downto 0);
	signal TX_SRC_RDY_N_O		: std_logic_vector(1 downto 0);
begin

	TX_D_I <= TX_D;

	aurora_2lane_fd_str_wrapper_inst: aurora_2lane_fd_str_wrapper
		generic map(
			SIM_GTXRESET_SPEEDUP	=> SIM_GTXRESET_SPEEDUP
		)
		port map(
			GTXD10       	=> GTXD10,
			RXP				=> RXP,
			RXN				=> RXN,
			TXP				=> TXP,
			TXN				=> TXN,
			CLK				=> CLK,
			RX_D				=> open,
			RX_SRC_RDY_N	=> open,
			TX_D				=> TX_D_O,
			TX_SRC_RDY_N	=> TX_SRC_RDY_N_O(0),
			TX_DST_RDY_N	=> open,
			BUS_CLK			=> BUS_CLK,
			GTX_CTRL			=> GTX_CTRL_REG,
			GTX_CTRL_TILE0	=> GTX_CTRL_TILE0_REG,
			GTX_DRP_CTRL	=> GTX_DRP_CTRL_REG,
			GTX_STATUS		=> GTX_STATUS_REG,
			GTX_ERR_TILE0	=> GTX_ERR_TILE0_REG
		);

	serdeslanecrc_tx_gen: for I in 0 to 1 generate
		serdeslanecrc_tx_inst: serdeslanecrc_tx
			port map(
				CLK				=> CLK,
				TX_D_I			=> TX_D_I(I*16+15 downto I*16),
				TX_SRC_RDY_N_I	=> TX_SRC_RDY_N,
				TX_D_O			=> TX_D_O(I*16+15 downto I*16),
				TX_SRC_RDY_N_O	=> TX_SRC_RDY_N_O(I)
			);
	end generate;

	gxbvxs_mon_inst: gxbvxs_mon
		port map(
			CLK				=> CLK,
			TX_SRC_RDY_N	=> TX_SRC_RDY_N,
			TX_D				=> TX_D,
			LA_CMP_MODE0	=> LA_CMP_MODE0,
			LA_CMP_THR0		=> LA_CMP_THR0,
			LA_MASK_EN0		=> LA_MASK_EN0,
			LA_MASK_VAL0	=> LA_MASK_VAL0,
			LA_MASK_EN1		=> LA_MASK_EN1,
			LA_MASK_VAL1	=> LA_MASK_VAL1,
			LA_ENABLE		=> LA_ENABLE,
			LA_READY			=> LA_READY,
			LA_DO				=> LA_DO,
			LA_RDEN			=> LA_RDEN
		);

	-----------------------------------
	-- Register Multi-clock domain mux
	-----------------------------------	

	BUS_DOUT <= BUS_DOUT_CLK when BUS_ACK_CLK = '1' else
               BUS_DOUT_BUSCLK when BUS_ACK_BUSCLK = '1' else
					x"00000000";

	BUS_ACK <= BUS_ACK_CLK or BUS_ACK_BUSCLK;

	-----------------------------------
	-- Registers "CLK" domain
	-----------------------------------	

	PerBusCtrl_CLK_inst: PerBusCtrl
		generic map(
			ADDR_INFO		=> ADDR_INFO
		)
		port map(
			BUS_RESET		=> BUS_RESET,
			BUS_RESET_SOFT	=> BUS_RESET_SOFT,
			BUS_DIN			=> BUS_DIN,
			BUS_DOUT			=> BUS_DOUT_CLK,
			BUS_ADDR			=> BUS_ADDR,
			BUS_WR			=> BUS_WR,
			BUS_RD			=> BUS_RD,
			BUS_ACK			=> BUS_ACK_CLK,
			PER_CLK			=> CLK,
			PER_RESET		=> PI_CLK.RESET,
			PER_RESET_SOFT	=> PI_CLK.RESET_SOFT,
			PER_DIN			=> PI_CLK.DIN,
			PER_ADDR			=> PI_CLK.ADDR,
			PER_WR			=> PI_CLK.WR,
			PER_RD			=> PI_CLK.RD,
			PER_MATCH		=> PI_CLK.MATCH,
			PER_DOUT			=> PO_CLK.DOUT,
			PER_ACK			=> PO_CLK.ACK
		);

	--LA_CTRL_REG
	LA_ENABLE <= LA_CTRL_REG(0);

	--LA_STATUS_REG
	LA_STATUS_REG(0) <= LA_READY;
	LA_STATUS_REG(31 downto 1) <= (others=>'0');

	--LA_CMP_MODE0_REG
	LA_CMP_MODE0 <= LA_CMP_MODE0_REG(2 downto 0);

	--LA_CMP_THR0_REG
	LA_CMP_THR0 <= LA_CMP_THR0_REG;

	--LA_MASK_EN0_REG
	LA_MASK_EN0 <= LA_MASK_EN0_REG;

	--LA_MASK_VAL0_REG
	LA_MASK_VAL0 <= LA_MASK_VAL0_REG;

	--LA_MASK_EN1_REG
	LA_MASK_EN1 <= LA_MASK_EN1_REG(2 downto 0);

	--LA_MASK_VAL1_REG
	LA_MASK_VAL1 <= LA_MASK_VAL1_REG(2 downto 0);

	--LA_DO0_REG
	LA_DO0_REG <= LA_DO(0);

	--LA_DO1_REG
	LA_DO1_REG <= LA_DO(1);

	process(CLK)
	begin
		if rising_edge(CLK) then
			PO_CLK.ACK <= '0';
			
			rw_reg(		REG => GTX_CTRL_REG			,PI=>PI_CLK,PO=>PO_CLK, A => x"0000", RW => x"00000FFF", I => x"00000203");
			rw_reg(		REG => GTX_CTRL_TILE0_REG	,PI=>PI_CLK,PO=>PO_CLK, A => x"0004", RW => x"0FFF0FFF", I => x"05420542");
			ro_reg(		REG => GTX_STATUS_REG		,PI=>PI_CLK,PO=>PO_CLK, A => x"0010", RO => x"00003333");
			ro_reg(		REG => GTX_ERR_TILE0_REG	,PI=>PI_CLK,PO=>PO_CLK, A => x"0018", RO => x"FFFFFFFF");

			wo_reg(		REG => LA_CTRL_REG			,PI=>PI_CLK,PO=>PO_CLK, A => x"0030", WO => x"00000001");
			ro_reg(		REG => LA_STATUS_REG			,PI=>PI_CLK,PO=>PO_CLK, A => x"0034", RO => x"00000001");
			ro_reg_ack(	REG => LA_DO0_REG				,PI=>PI_CLK,PO=>PO_CLK, A => x"0040", RO => x"FFFFFFFF", ACK => LA_RDEN(0));
			ro_reg_ack(	REG => LA_DO1_REG				,PI=>PI_CLK,PO=>PO_CLK, A => x"0044", RO => x"00000007", ACK => LA_RDEN(1));
			wo_reg(		REG => LA_CMP_MODE0_REG		,PI=>PI_CLK,PO=>PO_CLK, A => x"0060", WO => x"00000007");
			wo_reg(		REG => LA_CMP_THR0_REG		,PI=>PI_CLK,PO=>PO_CLK, A => x"0080", WO => x"FFFFFFFF");
			wo_reg(		REG => LA_MASK_EN0_REG		,PI=>PI_CLK,PO=>PO_CLK, A => x"00A0", WO => x"FFFFFFFF");
			wo_reg(		REG => LA_MASK_EN1_REG		,PI=>PI_CLK,PO=>PO_CLK, A => x"00A4", WO => x"00000007");
			wo_reg(		REG => LA_MASK_VAL0_REG		,PI=>PI_CLK,PO=>PO_CLK, A => x"00C0", WO => x"FFFFFFFF");
			wo_reg(		REG => LA_MASK_VAL1_REG		,PI=>PI_CLK,PO=>PO_CLK, A => x"00C4", WO => x"00000007");
		end if;
	end process;

	-----------------------------------
	-- Registers "BUS_CLK" domain
	-----------------------------------	

	PerBusCtrl_BUSCLK_inst: PerBusCtrl
		generic map(
			ADDR_INFO		=> ADDR_INFO
		)
		port map(
			BUS_RESET		=> BUS_RESET,
			BUS_RESET_SOFT	=> BUS_RESET_SOFT,
			BUS_DIN			=> BUS_DIN,
			BUS_DOUT			=> BUS_DOUT_BUSCLK,
			BUS_ADDR			=> BUS_ADDR,
			BUS_WR			=> BUS_WR,
			BUS_RD			=> BUS_RD,
			BUS_ACK			=> BUS_ACK_BUSCLK,
			PER_CLK			=> BUS_CLK,
			PER_RESET		=> PI_BUSCLK.RESET,
			PER_RESET_SOFT	=> PI_BUSCLK.RESET_SOFT,
			PER_DIN			=> PI_BUSCLK.DIN,
			PER_ADDR			=> PI_BUSCLK.ADDR,
			PER_WR			=> PI_BUSCLK.WR,
			PER_RD			=> PI_BUSCLK.RD,
			PER_MATCH		=> PI_BUSCLK.MATCH,
			PER_DOUT			=> PO_BUSCLK.DOUT,
			PER_ACK			=> PO_BUSCLK.ACK
		);

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			PO_BUSCLK.ACK <= '0';
			
			rw_reg(		REG => GTX_DRP_CTRL_REG		,PI=>PI_BUSCLK,PO=>PO_BUSCLK, A => x"000C", RW => x"037FFFFF", R => x"03000000");
			ro_reg(		REG => GTX_DRP_STATUS_REG	,PI=>PI_BUSCLK,PO=>PO_BUSCLK, A => x"0014", RO => x"0001FFFF");
		end if;
	end process;
	
end Synthesis;
