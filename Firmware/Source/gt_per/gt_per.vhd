library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

entity gt_per is
	generic(
		SIM_GTRESET_SPEEDUP	: string := "FALSE";
		ADDR_INFO				: PER_ADDR_INFO
	);
	port(
		-- User ports --------------------------------------
		GT_REFCLK     	: in std_logic;
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
end gt_per;

architecture Synthesis of gt_per is
	component gt_wrapper is
		generic(
			SIM_GTRESET_SPEEDUP	: string := "FALSE"
		);
		port(
			-- External Signals
			GT_REFCLK		: in std_logic;
			RXP				: in std_logic_vector(0 to 1);
			RXN				: in std_logic_vector(0 to 1);
			TXP				: out std_logic_vector(0 to 1);
			TXN				: out std_logic_vector(0 to 1);

			-- Parallel Interface
			CLK				: in std_logic;
			RX_D				: out std_logic_vector(31 downto 0);
			RX_SRC_RDY_N	: out std_logic;
			TX_D				: in std_logic_vector(31 downto 0);
			TX_SRC_RDY_N	: in std_logic;
			TX_DST_RDY_N	: out std_logic;
		
			-- DRP Interface
			DRP_CLK			: in std_logic;
			DRP_ADDR			: in std_logic_vector(8 downto 0);
			DRP_DI			: in std_logic_vector(15 downto 0);
			DRP_DO			: out std_logic_vector(15 downto 0);
			DRP_DEN			: in std_logic_vector(0 to 1);
			DRP_DWE			: in std_logic;
			DRP_RDY			: out std_logic;
			
			-- GTP configuration/status bits
			POWER_DOWN		: in std_logic;
			GT_RESET			: in std_logic;
			RESET				: in std_logic;
			LOOPBACK			: in std_logic_vector(2 downto 0);
			PRBS_SEL			: in std_logic_vector(2 downto 0);
			ERR_RST			: in std_logic;
			ERR_CNT			: out std_logic_vector(15 downto 0);

			HARD_ERR			: out std_logic;
			LANE_UP			: out std_logic_vector(0 to 1);
			CHANNEL_UP		: out std_logic;
			TX_LOCK			: out std_logic
		);
	end component;

	component gt_mon is
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

	signal GT_CTRL_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal GT_DRP_CTRL_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal GT_STATUS_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal GT_DRP_STATUS_REG	: std_logic_vector(31 downto 0) := x"00000000";
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

	-- Register Bits
	signal DRP_ADDR				: std_logic_vector(8 downto 0);
	signal DRP_DI					: std_logic_vector(15 downto 0);
	signal DRP_DO					: std_logic_vector(15 downto 0);
	signal DRP_DEN					: std_logic_vector(0 to 1);
	signal DRP_DWE					: std_logic;
	signal DRP_RDY					: std_logic;
	signal POWER_DOWN				: std_logic;
	signal GT_RESET				: std_logic;
	signal RESET					: std_logic;
	signal LOOPBACK				: std_logic_vector(2 downto 0);
	signal PRBS_SEL				: std_logic_vector(2 downto 0);
	signal ERR_RST					: std_logic;
	signal ERR_CNT					: std_logic_vector(15 downto 0);
	signal HARD_ERR				: std_logic;
	signal LANE_UP					: std_logic_vector(0 to 1);
	signal CHANNEL_UP				: std_logic;
	signal TX_LOCK					: std_logic;

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

	gt_wrapper_inst: gt_wrapper
		generic map(
			SIM_GTRESET_SPEEDUP	=> SIM_GTRESET_SPEEDUP
		)
		port map(
			GT_REFCLK		=> GT_REFCLK,
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
			DRP_CLK			=> BUS_CLK,
			DRP_ADDR			=> DRP_ADDR,
			DRP_DI			=> DRP_DI,
			DRP_DO			=> DRP_DO,
			DRP_DEN			=> DRP_DEN,
			DRP_DWE			=> DRP_DWE,
			DRP_RDY			=> DRP_RDY,
			POWER_DOWN		=> POWER_DOWN,
			GT_RESET			=> GT_RESET,
			RESET				=> RESET,
			LOOPBACK			=> LOOPBACK,
			PRBS_SEL			=> PRBS_SEL,
			ERR_RST			=> ERR_RST,
			ERR_CNT			=> ERR_CNT,
			HARD_ERR			=> HARD_ERR,
			LANE_UP			=> LANE_UP,
			CHANNEL_UP		=> CHANNEL_UP,
			TX_LOCK			=> TX_LOCK
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

	gt_mon_inst: gt_mon
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

	--GT_CTRL_REG
	POWER_DOWN <= GT_CTRL_REG(0);
	GT_RESET <= GT_CTRL_REG(1);
	LOOPBACK <= GT_CTRL_REG(4 downto 2);
	PRBS_SEL <= GT_CTRL_REG(7 downto 5);
	RESET <= GT_CTRL_REG(9);
	ERR_RST <= GT_CTRL_REG(10);

	--GT_STATUS_REG
	GT_STATUS_REG(0) <= HARD_ERR;
	GT_STATUS_REG(1) <= TX_LOCK;
	GT_STATUS_REG(2) <= LANE_UP(0);
	GT_STATUS_REG(3) <= LANE_UP(1);
	GT_STATUS_REG(4) <= CHANNEL_UP;
	GT_STATUS_REG(31 downto 16) <= ERR_CNT;

	process(CLK)
	begin
		if rising_edge(CLK) then
			PO_CLK.ACK <= '0';
			
			rw_reg(		REG => GT_CTRL_REG			,PI=>PI_CLK,PO=>PO_CLK, A => x"0000", RW => x"000006FF", I => x"00000303");
			ro_reg(		REG => GT_STATUS_REG			,PI=>PI_CLK,PO=>PO_CLK, A => x"0010", RO => x"FFFF001F");

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

	--GT_DRP_CTRL_REG
	DRP_DI <= GT_DRP_CTRL_REG(15 downto 0);
	DRP_ADDR <= GT_DRP_CTRL_REG(24 downto 16);
	DRP_DWE <= GT_DRP_CTRL_REG(25);
	DRP_DEN(0) <= GT_DRP_CTRL_REG(26);
	DRP_DEN(1) <= GT_DRP_CTRL_REG(27);

	--GT_DRP_STATUS_REG
	GT_DRP_STATUS_REG(15 downto 0) <= DRP_DO;
	GT_DRP_STATUS_REG(16) <= DRP_RDY;

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			PO_BUSCLK.ACK <= '0';
			
			rw_reg(		REG => GT_DRP_CTRL_REG		,PI=>PI_BUSCLK,PO=>PO_BUSCLK, A => x"000C", RW => x"0FFFFFFF", R => x"0C000000");
			ro_reg(		REG => GT_DRP_STATUS_REG	,PI=>PI_BUSCLK,PO=>PO_BUSCLK, A => x"0014", RO => x"0001FFFF");
		end if;
	end process;
	
end Synthesis;
