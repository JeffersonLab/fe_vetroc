library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

entity gxbqsfp_per is
	generic(
		ADDR_INFO					: PER_ADDR_INFO;
		SIM_GTXRESET_SPEEDUP		: integer := 0;
		GTX_QUICKSIM				: boolean := false
	);
	port(
		----------------------------------------------------
		-- User ports --------------------------------------
		----------------------------------------------------
		SYSCLK_50				: in std_logic;
		ATXCLK_L					: in std_logic;
		ATXCLK_R					: in std_logic;

		-- Transceiver I/O
		FIBER_RX					: in std_logic_vector(0 to 3);
		FIBER_TX					: out std_logic_vector(0 to 3);

		CAL_BLK_POWERDOWN_L	: in std_logic;
		CAL_BLK_POWERDOWN_R	: in std_logic;
		CAL_BLK_BUSY_L			: in std_logic;
		CAL_BLK_BUSY_R			: in std_logic;
		RECONFIG_FROMGXB_L	: out std_logic_vector(67 downto 0);
		RECONFIG_FROMGXB_R	: out std_logic_vector(67 downto 0);
		RECONFIG_TOGXB_L		: in std_logic_vector(3 downto 0);
		RECONFIG_TOGXB_R		: in std_logic_vector(3 downto 0);

		CLK					: in std_logic;
		SYNC					: in std_logic;
		TX_D					: in std_logic_vector(63 downto 0);
		TX_SRC_RDY_N		: in std_logic;

		----------------------------------------------------
		-- Bus interface ports -----------------------------
		----------------------------------------------------
		BUS_RESET			: in std_logic;
		BUS_RESET_SOFT		: in std_logic;
		BUS_DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR				: in std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR				: in std_logic;
		BUS_RD				: in std_logic;
		BUS_ACK				: out std_logic
	);
end gxbqsfp_per;

architecture synthesis of gxbqsfp_per is
	component aurora_4lane_fd_str_wrapper is
		generic(
			SIM_GTXRESET_SPEEDUP			: integer := 0;
			GTX_QUICKSIM					: boolean := false
		);
		port(
			CLK						: in std_logic;

			-- TX Stream Interface
			TX_D						: in std_logic_vector(63 downto 0);
			TX_SRC_RDY_N			: in std_logic;
			TX_DST_RDY_N			: out std_logic;

			-- RX Stream Interface
			RX_D						: out std_logic_vector(63 downto 0);
			RX_SRC_RDY_N			: out std_logic;

			-- GTX Serial I/O
			RXP						: in std_logic_vector(0 to 3);
			TXP						: out std_logic_vector(0 to 3);

			--GTX Reference Clock Interface
			GTXD0_L					: in std_logic;
			GTXD0_R					: in std_logic;

			--SIV Specific
			CLK50						: in std_logic;
			CAL_BLK_POWERDOWN_L	: in std_logic;
			CAL_BLK_POWERDOWN_R	: in std_logic;
			CAL_BLK_BUSY_L			: in std_logic;
			CAL_BLK_BUSY_R			: in std_logic;
			RECONFIG_FROMGXB_L	: out std_logic_vector(67 downto 0);
			RECONFIG_FROMGXB_R	: out std_logic_vector(67 downto 0);
			RECONFIG_TOGXB_L		: in std_logic_vector(3 downto 0);
			RECONFIG_TOGXB_R		: in std_logic_vector(3 downto 0);

			-- Registers
			GXB_CTRL					: in std_logic_vector(31 downto 0);
			GXB_STATUS				: out std_logic_vector(31 downto 0);
			GXB_ERR_TILE0			: out std_logic_vector(31 downto 0);
			GXB_ERR_TILE1			: out std_logic_vector(31 downto 0)
		);
	end component;

	component gxbqsfp_mon is
		port(
			CLK				: in std_logic;

			TX_SRC_RDY_N	: in std_logic;
			TX_D				: in std_logic_vector(63 downto 0);

			LA_MASK_EN0		: in std_logic_vector(31 downto 0);
			LA_MASK_EN1		: in std_logic_vector(31 downto 0);
			LA_MASK_EN2		: in std_logic_vector(2 downto 0);
			LA_MASK_VAL0	: in std_logic_vector(31 downto 0);
			LA_MASK_VAL1	: in std_logic_vector(31 downto 0);
			LA_MASK_VAL2	: in std_logic_vector(2 downto 0);
			LA_ENABLE		: in std_logic;
			LA_READY			: out std_logic;
			LA_DO				: out slv32a(2 downto 0);
			LA_RDEN			: in std_logic_vector(2 downto 0)
		);
	end component;

	signal PI							: pbus_if_i := ('0', '0', x"00000000", x"0000", '0', '0', '0');
	signal PO							: pbus_if_o := (x"00000000", '0');

	signal GXB_CTRL_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal GXB_STATUS_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal GXB_ERR_TILE0_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal GXB_ERR_TILE1_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal GXB_STATUS2_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_EN0_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_EN1_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_EN2_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_VAL0_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_VAL1_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_MASK_VAL2_REG			: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_CTRL_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_STATUS_REG				: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_DO0_REG					: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_DO1_REG					: std_logic_vector(31 downto 0) := x"00000000";
	signal LA_DO2_REG					: std_logic_vector(31 downto 0) := x"00000000";

	signal TX_D_O					: std_logic_vector(63 downto 0);
	signal TX_SRC_RDY_N_O		: std_logic_vector(3 downto 0);

	signal GXB_CTRL					: std_logic_vector(31 downto 0);
	signal GXB_STATUS					: std_logic_vector(31 downto 0);
	signal GXB_ERR_TILE0				: std_logic_vector(31 downto 0);
	signal GXB_ERR_TILE1				: std_logic_vector(31 downto 0);

	signal LA_MASK_EN0				: std_logic_vector(31 downto 0);
	signal LA_MASK_EN1				: std_logic_vector(31 downto 0);
	signal LA_MASK_EN2				: std_logic_vector(2 downto 0);
	signal LA_MASK_VAL0				: std_logic_vector(31 downto 0);
	signal LA_MASK_VAL1				: std_logic_vector(31 downto 0);
	signal LA_MASK_VAL2				: std_logic_vector(2 downto 0);
	signal LA_ENABLE					: std_logic;
	signal LA_READY					: std_logic;
	signal LA_DO						: slv32a(2 downto 0);
	signal LA_RDEN						: std_logic_vector(2 downto 0);
begin

	aurora_4lane_fd_str_wrapper_inst: aurora_4lane_fd_str_wrapper
		generic map(
			SIM_GTXRESET_SPEEDUP	=> SIM_GTXRESET_SPEEDUP,
			GTX_QUICKSIM			=> GTX_QUICKSIM
		)
		port map(
			CLK						=> CLK,
			TX_D						=> TX_D_O,
			TX_SRC_RDY_N			=> TX_SRC_RDY_N_O(0),
			TX_DST_RDY_N			=> open,
			RX_D						=> open,
			RX_SRC_RDY_N			=> open,
			RXP						=> FIBER_RX,
			TXP						=> FIBER_TX,
			GTXD0_L					=> ATXCLK_L,
			GTXD0_R					=> ATXCLK_R,
			CLK50						=> SYSCLK_50,
			CAL_BLK_POWERDOWN_L	=> CAL_BLK_POWERDOWN_L,
			CAL_BLK_POWERDOWN_R	=> CAL_BLK_POWERDOWN_R,
			CAL_BLK_BUSY_L			=> CAL_BLK_BUSY_L,
			CAL_BLK_BUSY_R			=> CAL_BLK_BUSY_R,
			RECONFIG_FROMGXB_L	=> RECONFIG_FROMGXB_L,
			RECONFIG_FROMGXB_R	=> RECONFIG_FROMGXB_R,
			RECONFIG_TOGXB_L		=> RECONFIG_TOGXB_L,
			RECONFIG_TOGXB_R		=> RECONFIG_TOGXB_R,
			GXB_CTRL					=> GXB_CTRL,
			GXB_STATUS				=> GXB_STATUS,
			GXB_ERR_TILE0			=> GXB_ERR_TILE0,
			GXB_ERR_TILE1			=> GXB_ERR_TILE1
		);

	serdeslanecrc_tx_gen: for I in 0 to 3 generate
		serdeslanecrc_tx_inst: serdeslanecrc_tx
			port map(
				CLK				=> CLK,
				TX_D_I			=> TX_D(I*16+15 downto I*16),
				TX_SRC_RDY_N_I	=> TX_SRC_RDY_N,
				TX_D_O			=> TX_D_O(I*16+15 downto I*16),
				TX_SRC_RDY_N_O	=> TX_SRC_RDY_N_O(I)
			);
	end generate;

	gxbqsfp_mon_inst: gxbqsfp_mon
		port map(
			CLK				=> CLK,
			TX_SRC_RDY_N	=> TX_SRC_RDY_N,
			TX_D				=> TX_D,
			LA_MASK_EN0		=> LA_MASK_EN0,
			LA_MASK_VAL0	=> LA_MASK_VAL0,
			LA_MASK_EN1		=> LA_MASK_EN1,
			LA_MASK_VAL1	=> LA_MASK_VAL1,
			LA_MASK_EN2		=> LA_MASK_EN2,
			LA_MASK_VAL2	=> LA_MASK_VAL2,
			LA_ENABLE		=> LA_ENABLE,
			LA_READY			=> LA_READY,
			LA_DO				=> LA_DO,
			LA_RDEN			=> LA_RDEN
		);

	PerBusCtrl_inst: PerBusCtrl
		generic map(
			ADDR_INFO		=> ADDR_INFO
		)
		port map(
			BUS_RESET		=> BUS_RESET,
			BUS_RESET_SOFT	=> BUS_RESET_SOFT,
			BUS_DIN			=> BUS_DIN,
			BUS_DOUT			=> BUS_DOUT,
			BUS_ADDR			=> BUS_ADDR,
			BUS_WR			=> BUS_WR,
			BUS_RD			=> BUS_RD,
			BUS_ACK			=> BUS_ACK,
			PER_CLK			=> CLK,
			PER_RESET		=> PI.RESET,
			PER_RESET_SOFT	=> PI.RESET_SOFT,
			PER_DIN			=> PI.DIN,
			PER_ADDR			=> PI.ADDR,
			PER_WR			=> PI.WR,
			PER_RD			=> PI.RD,
			PER_MATCH		=> PI.MATCH,
			PER_DOUT			=> PO.DOUT,
			PER_ACK			=> PO.ACK
		);

	--LA_CTRL_REG
	LA_ENABLE <= LA_CTRL_REG(0);

	--LA_STATUS_REG
	LA_STATUS_REG(0) <= LA_READY;
	LA_STATUS_REG(31 downto 1) <= (others=>'0');

	--LA_MASK_EN0_REG
	LA_MASK_EN0 <= LA_MASK_EN0_REG;

	--LA_MASK_VAL0_REG
	LA_MASK_VAL0 <= LA_MASK_VAL0_REG;

	--LA_MASK_EN1_REG
	LA_MASK_EN1 <= LA_MASK_EN1_REG;

	--LA_MASK_VAL1_REG
	LA_MASK_VAL1 <= LA_MASK_VAL1_REG;

	--LA_MASK_EN2_REG
	LA_MASK_EN2 <= LA_MASK_EN2_REG(2 downto 0);

	--LA_MASK_VAL2_REG
	LA_MASK_VAL2 <= LA_MASK_VAL2_REG(2 downto 0);

	--LA_DO0_REG
	LA_DO0_REG <= LA_DO(0);

	--LA_DO1_REG
	LA_DO1_REG <= LA_DO(1);

	--LA_DO2_REG
	LA_DO2_REG <= LA_DO(2);

	--GXB_CTRL_REG
	GXB_CTRL <= GXB_CTRL_REG;

	--GXB_STATUS_REG
	GXB_STATUS_REG <= GXB_STATUS;

	--GXB_ERR_TILE0_REG
	GXB_ERR_TILE0_REG <= GXB_ERR_TILE0;

	--GXB_ERR_TILE1_REG
	GXB_ERR_TILE1_REG <= GXB_ERR_TILE1;

	process(CLK)
	begin
		if rising_edge(CLK) then
			PO.ACK <= '0';
			
			-- GXB Registers
			rw_reg(		REG => GXB_CTRL_REG			,PI=>PI,PO=>PO, A => x"0000", RW => x"00000C01", I => x"00000001", R => x"00000400");
			ro_reg(		REG => GXB_STATUS_REG		,PI=>PI,PO=>PO, A => x"0010", RO => x"FFFFFFFF");
			ro_reg(		REG => GXB_ERR_TILE0_REG	,PI=>PI,PO=>PO, A => x"0018", RO => x"FFFFFFFF");
			ro_reg(		REG => GXB_ERR_TILE1_REG	,PI=>PI,PO=>PO, A => x"001C", RO => x"FFFFFFFF");

			-- Monitor Registers
			rw_reg(		REG => LA_CTRL_REG		,PI=>PI,PO=>PO, A => x"0020", RW => x"00000001");
			ro_reg(		REG => LA_STATUS_REG		,PI=>PI,PO=>PO, A => x"0024", RO => x"00000001");
			ro_reg_ack(	REG => LA_DO0_REG			,PI=>PI,PO=>PO, A => x"0030", RO => x"FFFFFFFF", ACK => LA_RDEN(0));
			ro_reg_ack(	REG => LA_DO1_REG			,PI=>PI,PO=>PO, A => x"0034", RO => x"FFFFFFFF", ACK => LA_RDEN(1));
			ro_reg_ack(	REG => LA_DO2_REG			,PI=>PI,PO=>PO, A => x"0038", RO => x"00000001", ACK => LA_RDEN(2));
			rw_reg(		REG => LA_MASK_EN0_REG	,PI=>PI,PO=>PO, A => x"0090", RW => x"FFFFFFFF");
			rw_reg(		REG => LA_MASK_EN1_REG	,PI=>PI,PO=>PO, A => x"0094", RW => x"FFFFFFFF");
			rw_reg(		REG => LA_MASK_EN2_REG	,PI=>PI,PO=>PO, A => x"0098", RW => x"00000001");
			rw_reg(		REG => LA_MASK_VAL0_REG	,PI=>PI,PO=>PO, A => x"00B0", RW => x"FFFFFFFF");
			rw_reg(		REG => LA_MASK_VAL1_REG	,PI=>PI,PO=>PO, A => x"00B4", RW => x"FFFFFFFF");
			rw_reg(		REG => LA_MASK_VAL2_REG	,PI=>PI,PO=>PO, A => x"00B8", RW => x"00000007");
		end if;
	end process;

end synthesis;
