library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library utils;
use utils.utils_pkg.all;

use work.perbus_pkg.all;

entity gxbconfig_per is
	generic(
		ADDR_INFO		: PER_ADDR_INFO
	);
	port(
		----------------------------------------------------
		-- User ports --------------------------------------
		----------------------------------------------------
		SYSCLK_50			: in std_logic;
		CAL_BLK_POWERDOWN	: out std_logic;
		CAL_BLK_BUSY		: out std_logic;
		RECONFIG_TOGXB		: out std_logic_vector(3 downto 0);
		RECONFIG_FROMGXB	: in std_logic_vector(611 downto 0);

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
end gxbconfig_per;

architecture synthesis of gxbconfig_per is
	component reconfig_side is
		port(
			ctrl_address				: in std_logic_vector(15 downto 0);
			ctrl_read					: in std_logic;
			ctrl_write					: in std_logic;
			ctrl_writedata				: in std_logic_vector(15 downto 0);
			logical_channel_address	: in std_logic_vector(7 downto 0);
			read							: in std_logic;
			reconfig_clk				: in std_logic;
			reconfig_fromgxb			: in std_logic_vector(611 downto 0);
			reconfig_mode_sel			: in std_logic_vector(3 downto 0);
			rx_eqctrl					: in std_logic_vector(3 downto 0);
			rx_eqdcgain					: in std_logic_vector(2 downto 0);
			tx_preemp_0t				: in std_logic_vector(4 downto 0);
			tx_preemp_1t				: in std_logic_vector(4 downto 0);
			tx_preemp_2t				: in std_logic_vector(4 downto 0);
			tx_vodctrl					: in std_logic_vector(2 downto 0);
			write_all					: in std_logic;
			busy							: out std_logic;
			ctrl_readdata				: out std_logic_vector(15 downto 0);
			ctrl_waitrequest			: out std_logic;
			data_valid					: out std_logic;
			error							: out std_logic;
			reconfig_togxb				: out std_logic_vector(3 downto 0);
			rx_eqctrl_out				: out std_logic_vector(3 downto 0);
			rx_eqdcgain_out			: out std_logic_vector(2 downto 0);
			tx_preemp_0t_out			: out std_logic_vector(4 downto 0);
			tx_preemp_1t_out			: out std_logic_vector(4 downto 0);
			tx_preemp_2t_out			: out std_logic_vector(4 downto 0);
			tx_vodctrl_out				: out std_logic_vector(2 downto 0)
		);
	end component;

	signal PI								: pbus_if_i := ('0', '0', x"00000000", x"0000", '0', '0', '0');
	signal PO								: pbus_if_o := (x"00000000", '0');

	signal CTRL_ADDRESS					: std_logic_vector(15 downto 0);
	signal CTRL_READ						: std_logic;
	signal CTRL_WRITE						: std_logic;
	signal CTRL_WRITEDATA				: std_logic_vector(15 downto 0);
	signal LOGICAL_CHANNEL_ADDRESS	: std_logic_vector(7 downto 0);
	signal READ								: std_logic;
	signal RECONFIG_MODE_SEL			: std_logic_vector(3 downto 0);
	signal RX_EQCTRL						: std_logic_vector(3 downto 0);
	signal RX_EQDCGAIN					: std_logic_vector(2 downto 0);
	signal TX_PREEMP_0T					: std_logic_vector(4 downto 0);
	signal TX_PREEMP_1T					: std_logic_vector(4 downto 0);
	signal TX_PREEMP_2T					: std_logic_vector(4 downto 0);
	signal TX_VODCTRL						: std_logic_vector(2 downto 0);
	signal WRITE_ALL						: std_logic;
	signal BUSY								: std_logic;
	signal CTRL_READDATA					: std_logic_vector(15 downto 0);
	signal CTRL_WAITREQUEST				: std_logic;
	signal DATA_VALID						: std_logic;
	signal ERROR							: std_logic;
	signal RX_EQCTRL_OUT					: std_logic_vector(3 downto 0);
	signal RX_EQDCGAIN_OUT				: std_logic_vector(2 downto 0);
	signal TX_PREEMP_0T_OUT				: std_logic_vector(4 downto 0);
	signal TX_PREEMP_1T_OUT				: std_logic_vector(4 downto 0);
	signal TX_PREEMP_2T_OUT				: std_logic_vector(4 downto 0);
	signal TX_VODCTRL_OUT				: std_logic_vector(2 downto 0);

	signal GXBCFG_TXRX_IN				: std_logic_vector(31 downto 0) := x"00000000";
	signal GXBCFG_TXRX_OUT				: std_logic_vector(31 downto 0) := x"00000000";
	signal GXBCFG_CTRL					: std_logic_vector(31 downto 0) := x"00000000";
	signal GXBCFG_CTRL2					: std_logic_vector(31 downto 0) := x"00000000";
	signal GXBCFG_STATUS					: std_logic_vector(31 downto 0) := x"00000000";

	signal RESET							: std_logic;
begin

	-----------------------------------
	-- GXBCFG_TXRX_IN Register Mapping
	-----------------------------------
	RX_EQCTRL <= GXBCFG_TXRX_IN(3 downto 0);
	RX_EQDCGAIN <= GXBCFG_TXRX_IN(6 downto 4);
	TX_PREEMP_0T <= GXBCFG_TXRX_IN(11 downto 7);
	TX_PREEMP_1T <= GXBCFG_TXRX_IN(16 downto 12);
	TX_PREEMP_2T <= GXBCFG_TXRX_IN(21 downto 17);
	TX_VODCTRL <= GXBCFG_TXRX_IN(24 downto 22);

	-----------------------------------
	-- GXBCFG_TXRX_OUT Register Mapping
	-----------------------------------
	GXBCFG_TXRX_OUT(3 downto 0) <= RX_EQCTRL_OUT;
	GXBCFG_TXRX_OUT(6 downto 4) <= RX_EQDCGAIN_OUT;
	GXBCFG_TXRX_OUT(11 downto 7) <= TX_PREEMP_0T_OUT;
	GXBCFG_TXRX_OUT(16 downto 12) <= TX_PREEMP_1T_OUT;
	GXBCFG_TXRX_OUT(21 downto 17) <= TX_PREEMP_2T_OUT;
	GXBCFG_TXRX_OUT(24 downto 22) <= TX_VODCTRL_OUT;

	-----------------------------------
	-- GXBCFG_STATUS Register Mapping
	-----------------------------------
	GXBCFG_STATUS(15 downto 0) <= CTRL_READDATA;
	GXBCFG_STATUS(16) <= BUSY;
	GXBCFG_STATUS(17) <= DATA_VALID;
	GXBCFG_STATUS(18) <= ERROR;

	-----------------------------------
	-- GXBCFG_CTRL Register Mapping
	-----------------------------------
	LOGICAL_CHANNEL_ADDRESS <= GXBCFG_CTRL(7 downto 0);
	RECONFIG_MODE_SEL <= GXBCFG_CTRL(11 downto 8);
	READ <= GXBCFG_CTRL(12);
	WRITE_ALL <= GXBCFG_CTRL(13);

	process(SYSCLK_50)
	begin
		if rising_edge(SYSCLK_50) then
			if RESET = '1' then
				CTRL_READ <= '0';
			elsif GXBCFG_CTRL(14) = '1' then
				CTRL_READ <= '1';
			elsif CTRL_WAITREQUEST = '0' then
				CTRL_READ <= '0';
			end if;
		end if;
	end process;

	process(SYSCLK_50)
	begin
		if rising_edge(SYSCLK_50) then
			if RESET = '1' then
				CTRL_WRITE <= '0';
			elsif GXBCFG_CTRL(15) = '1' then
				CTRL_WRITE <= '1';
			elsif CTRL_WAITREQUEST = '0' then
				CTRL_WRITE <= '0';
			end if;
		end if;
	end process;
	
	CAL_BLK_POWERDOWN <= GXBCFG_CTRL(16) when BUSY = '0' else '0';

	CAL_BLK_BUSY <= BUSY;
			
	-----------------------------------
	-- GXBCFG_CTRL2 Register Mapping
	-----------------------------------
	CTRL_WRITEDATA <= GXBCFG_CTRL2(31 downto 16);
	CTRL_ADDRESS <= GXBCFG_CTRL2(15 downto 0);

	RESET <= PI.RESET;

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
			PER_CLK			=> SYSCLK_50,
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

	process(SYSCLK_50)
	begin
		if rising_edge(SYSCLK_50) then
			PO.ACK <= '0';
			
			-- GXB Config Registers
			ro_reg(	REG => GXBCFG_STATUS		,PI=>PI,PO=>PO, A => x"0000", RO => x"0007FFFF");
			rw_reg(	REG => GXBCFG_CTRL		,PI=>PI,PO=>PO, A => x"0004", RW => x"0001FFFF", R => x"0000F000");
			rw_reg(	REG => GXBCFG_CTRL2		,PI=>PI,PO=>PO, A => x"0008", RW => x"FFFFFFFF");
			rw_reg(	REG => GXBCFG_TXRX_IN	,PI=>PI,PO=>PO, A => x"000C", WO => x"01FFFFFF");
			ro_reg(	REG => GXBCFG_TXRX_OUT	,PI=>PI,PO=>PO, A => x"0010", RO => x"01FFFFFF");

		end if;
	end process;

	reconfig_side_inst: reconfig_side
		port map(
			ctrl_address				=> CTRL_ADDRESS,
			ctrl_read					=> CTRL_READ,
			ctrl_write					=> CTRL_WRITE,
			ctrl_writedata				=> CTRL_WRITEDATA,
			logical_channel_address	=> LOGICAL_CHANNEL_ADDRESS,
			read							=> READ,
			reconfig_clk				=> SYSCLK_50,
			reconfig_fromgxb			=> RECONFIG_FROMGXB,
			reconfig_mode_sel			=> RECONFIG_MODE_SEL,
			rx_eqctrl					=> RX_EQCTRL,
			rx_eqdcgain					=> RX_EQDCGAIN,
			tx_preemp_0t				=> TX_PREEMP_0T,
			tx_preemp_1t				=> TX_PREEMP_1T,
			tx_preemp_2t				=> TX_PREEMP_2T,
			tx_vodctrl					=> TX_VODCTRL,
			write_all					=> WRITE_ALL,
			busy							=> BUSY,
			ctrl_readdata				=> CTRL_READDATA,
			ctrl_waitrequest			=> CTRL_WAITREQUEST,
			data_valid					=> DATA_VALID,
			error							=> ERROR,
			reconfig_togxb				=> RECONFIG_TOGXB,
			rx_eqctrl_out				=> RX_EQCTRL_OUT,
			rx_eqdcgain_out			=> RX_EQDCGAIN_OUT,
			tx_preemp_0t_out			=> TX_PREEMP_0T_OUT,
			tx_preemp_1t_out			=> TX_PREEMP_1T_OUT,
			tx_preemp_2t_out			=> TX_PREEMP_2T_OUT,
			tx_vodctrl_out				=> TX_VODCTRL_OUT
		);

end synthesis;
