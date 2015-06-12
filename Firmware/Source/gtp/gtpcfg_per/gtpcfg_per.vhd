library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.perbus_pkg.all;
use work.gtpcfg_per_pkg.all;

entity gtpcfg_per is
	generic(
		ADDR_INFO		: PER_ADDR_INFO
	);
	port(
		----------------------------------------------------
		-- User ports --------------------------------------
		----------------------------------------------------
		CPLD_FPGA_GPIO	: out std_logic_vector(15 downto 2);

		LED_AMBER		: out std_logic;
		LED_RED			: out std_logic;

		TI_SCL			: in std_logic;
		TI_SDA			: inout std_logic;
		TI_SDA_OE		: out std_logic;

		----------------------------------------------------
		-- Bus interface ports -----------------------------
		----------------------------------------------------
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
end gtpcfg_per;

architecture synthesis of gtpcfg_per is
	component ti_i2c_slave is
		port(
			CLK			: in std_logic;

			SLAVE_ADR	: in std_logic_vector(6 downto 0);

			USER_WR		: out std_logic;
			USER_RD		: out std_logic;
			USER_ADDR	: out std_logic_vector(7 downto 0);		
			USER_DIN		: out std_logic_vector(15 downto 0);
			USER_DOUT	: in std_logic_vector(15 downto 0);

			SCL			: in std_logic;
			SDA			: inout std_logic;
			SDA_OE		: out std_logic
		);
	end component;

	signal BOARD_ID_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal FIRMWARE_REV_REG	: std_logic_vector(31 downto 0) := x"00000000";
	signal CPU_STATUS_REG	: std_logic_vector(31 downto 0) := x"00000000";
	signal HOSTNAME0_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal HOSTNAME1_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal HOSTNAME2_REG		: std_logic_vector(31 downto 0) := x"00000000";
	signal HOSTNAME3_REG		: std_logic_vector(31 downto 0) := x"00000000";

	signal PI					: pbus_if_i := ('0', '0', x"00000000", x"0000", '0', '0', '0');
	signal PO					: pbus_if_o := (x"00000000", '0');

	signal USER_WR				: std_logic;
	signal USER_RD				: std_logic;
	signal USER_ADDR			: std_logic_vector(7 downto 0);		
	signal USER_DIN			: std_logic_vector(15 downto 0);
	signal USER_DOUT			: std_logic_vector(15 downto 0);
begin

	ti_i2c_slave_inst: ti_i2c_slave
		port map(
			CLK			=> BUS_CLK,
			SLAVE_ADR	=> SLAVE_ADR,
			USER_WR		=> USER_WR,
			USER_RD		=> USER_RD,
			USER_ADDR	=> USER_ADDR,
			USER_DIN		=> USER_DIN,
			USER_DOUT	=> USER_DOUT,
			SCL			=> TI_SCL,
			SDA			=> TI_SDA,
			SDA_OE		=> TI_SDA_OE
		);

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			if USER_WR = '1' then
				case USER_ADDR is
					--when ...	=> ... <= USER_DIN;
					when others	=> null;
				end case;
			end if;
		end if;
	end process;

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			if USER_RD = '1' then
				case USER_ADDR is
					when x"00"	=> USER_DOUT <= BOARD_ID_REG(15 downto 0);
					when x"01"	=> USER_DOUT <= BOARD_ID_REG(31 downto 16);
					when x"02"	=> USER_DOUT <= FIRMWARE_REV_REG(15 downto 0);
					when x"03"	=> USER_DOUT <= FIRMWARE_REV_REG(31 downto 16);
					when x"04"	=> USER_DOUT <= CPU_STATUS_REG(15 downto 0);
					when x"05"	=> USER_DOUT <= CPU_STATUS_REG(31 downto 16);
					when x"06"	=> USER_DOUT <= HOSTNAME0_REG(15 downto 0);
					when x"07"	=> USER_DOUT <= HOSTNAME0_REG(31 downto 16);
					when x"08"	=> USER_DOUT <= HOSTNAME1_REG(15 downto 0);
					when x"09"	=> USER_DOUT <= HOSTNAME1_REG(31 downto 16);
					when x"0A"	=> USER_DOUT <= HOSTNAME2_REG(15 downto 0);
					when x"0B"	=> USER_DOUT <= HOSTNAME2_REG(31 downto 16);
					when x"0C"	=> USER_DOUT <= HOSTNAME3_REG(15 downto 0);
					when x"0D"	=> USER_DOUT <= HOSTNAME3_REG(31 downto 16);
					when others	=> USER_DOUT <= x"FFFF";
				end case;
			end if;
		end if;
	end process;

	-----------------------------------
	-- Registers
	-----------------------------------	

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
			PER_CLK			=> BUS_CLK,
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

	-----------------------------------
	-- Register BOARD_ID_REG Mapping
	-----------------------------------	
	BOARD_ID_REG <= BOARD_ID;

	-----------------------------------
	-- Register FIRMWARE_REV_REG Mapping
	-----------------------------------	
	FIRMWARE_REV_REG <= FIRMWARE_REV;

	-----------------------------------
	-- Register CPU_STATUS_REG Mapping
	-----------------------------------	
	LED_AMBER <= CPU_STATUS_REG(0);						-- GTP O/S booted and running GTP server app
	LED_RED <= CPU_STATUS_REG(1);							-- GTP server app activity indicator
	CPLD_FPGA_GPIO <= CPU_STATUS_REG(15 downto 2);	-- to CPLD for reconfig

	process(BUS_CLK)
	begin
		if rising_edge(BUS_CLK) then
			PO.ACK <= '0';

			ro_reg(	REG => BOARD_ID_REG				,PI=>PI,PO=>PO, A => x"0000", RO => x"FFFFFFFF");
			ro_reg(	REG => FIRMWARE_REV_REG			,PI=>PI,PO=>PO, A => x"0004", RO => x"FFFFFFFF");
			rw_reg(	REG => CPU_STATUS_REG			,PI=>PI,PO=>PO, A => x"0008", RW => x"0000FFFF", I => x"0000FFFC");
			rw_reg(	REG => HOSTNAME0_REG				,PI=>PI,PO=>PO, A => x"000C", RW => x"FFFFFFFF");
			rw_reg(	REG => HOSTNAME1_REG				,PI=>PI,PO=>PO, A => x"0010", RW => x"FFFFFFFF");
			rw_reg(	REG => HOSTNAME2_REG				,PI=>PI,PO=>PO, A => x"0014", RW => x"FFFFFFFF");
			rw_reg(	REG => HOSTNAME3_REG				,PI=>PI,PO=>PO, A => x"0018", RW => x"FFFFFFFF");
		end if;
	end process;


end synthesis;
