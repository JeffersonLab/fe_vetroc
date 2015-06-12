library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

use work.perbus_pkg.all;

entity vme_mst_bridge is
	port(
		-- User ports --------------------------------------

		-- VME master interface
		bridge_select	: in std_logic;
		addr				: in std_logic_vector(A_WIDTH-1 downto 0);
		read_sig			: in std_logic; 
		write_sig		: in std_logic; 
		read_stb			: in std_logic;
		write_stb		: in std_logic;
		byte				: in std_logic_vector(3 downto 0);
		clk				: in std_logic;
		reset_hard		: in std_logic;
		reset_soft		: in std_logic;
			
		data_to_reg		: in std_logic_vector(D_WIDTH-1 downto 0);
		data_from_reg	: out std_logic_vector(D_WIDTH-1 downto 0);

		hold_vme			: out std_logic;

		-- Bus interface ports (Master) --------------------
		BUS_CLK			: out std_logic;
		BUS_RESET		: out std_logic;
		BUS_RESET_SOFT	: out std_logic;
		BUS_DIN			: out std_logic_vector(D_WIDTH-1 downto 0);
		BUS_DOUT			: in std_logic_vector(D_WIDTH-1 downto 0);
		BUS_ADDR			: out std_logic_vector(A_WIDTH-1 downto 0);
		BUS_WR			: out std_logic;
		BUS_RD			: out std_logic;
		BUS_ACK			: in std_logic
	);
end vme_mst_bridge;

architecture Synthesis of vme_mst_bridge is
	component perbus_mst_sm is
		port(
			CLK			: in std_logic;
			RESET			: in std_logic;
			
			WRITE_SIG	: in std_logic;
			READ_SIG		: in std_logic;
			BUS_ACK		: in std_logic;

			BUS_DIN_EN	: out std_logic;
			BUS_DOUT_EN	: out std_logic;
			BUS_WR		: out std_logic;
			BUS_RD		: out std_logic;
			BUSY			: out std_logic
		);
	end component;

	signal BUS_DIN_EN		: std_logic;
	signal BUS_DOUT_EN	: std_logic;
	signal write_sig_sel	: std_logic;
	signal read_sig_sel	: std_logic;
	signal reset_soft_q	: std_logic_vector(7 downto 0);
	signal reset_soft_or	: std_logic;
	signal reset_hard_q	: std_logic_vector(7 downto 0);
	signal reset_hard_or	: std_logic;
begin

	BUS_CLK <= clk;
	BUS_RESET <= reset_hard_or;
	BUS_RESET_SOFT <= reset_soft_or;
	write_sig_sel <= bridge_select and write_sig;
	read_sig_sel <= bridge_select and read_sig;

	process(clk)
	begin
		if rising_edge(clk) then
			BUS_ADDR <= addr;
			reset_hard_q <= reset_hard_q(reset_hard_q'length-2 downto 0) & reset_hard;
			reset_hard_or <= or_reduce(reset_hard_q);
			reset_soft_q <= reset_soft_q(reset_soft_q'length-2 downto 0) & (reset_soft or reset_hard);
			reset_soft_or <= or_reduce(reset_soft_q);
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if BUS_DIN_EN = '1' then
				BUS_DIN <= data_to_reg;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if BUS_DOUT_EN = '1' then
				data_from_reg <= BUS_DOUT;
			end if;
		end if;
	end process;

	perbus_mst_sm_inst: perbus_mst_sm
		port map(
			CLK			=> CLK,
			RESET			=> reset_hard_or,
			WRITE_SIG	=> write_sig_sel,
			READ_SIG		=> read_sig_sel,
			BUS_ACK		=> BUS_ACK,
			BUS_DIN_EN	=> BUS_DIN_EN,
			BUS_DOUT_EN	=> BUS_DOUT_EN,
			BUS_WR		=> BUS_WR,
			BUS_RD		=> BUS_RD,
			BUSY			=> hold_vme
		);

end Synthesis;
