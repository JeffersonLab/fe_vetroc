library ieee;
use ieee.std_logic_1164.all;

package perbus_pkg is

	constant A_WIDTH		: integer := 16;
	constant D_WIDTH		: integer := 32;

	type PER_ADDR_INFO is record
		BASE_ADDR		: std_logic_vector(A_WIDTH-1 downto 0);
		BASE_MASK		: std_logic_vector(A_WIDTH-1 downto 0);
		USER_MASK		: std_logic_vector(A_WIDTH-1 downto 0);
	end record;

	type BUS_ARRAY_TYPE is array(natural range <>) of std_logic_vector(D_WIDTH-1 downto 0);
	type PER_ADDR_INFO_ARRAY is array(natural range <>) of PER_ADDR_INFO;

	component perbusctrl is
		generic(
			ADDR_INFO	: PER_ADDR_INFO
		);
		port(
			BUS_RESET	: in std_logic;
			BUS_RESET_SOFT	: in std_logic;
			BUS_DIN		: in std_logic_vector(D_WIDTH-1 downto 0);
			BUS_DOUT		: out std_logic_vector(D_WIDTH-1 downto 0);
			BUS_ADDR		: in std_logic_vector(A_WIDTH-1 downto 0);
			BUS_WR		: in std_logic;
			BUS_RD		: in std_logic;
			BUS_ACK		: out std_logic;
			
			PER_CLK		: in std_logic;
			PER_RESET	: out std_logic;
			PER_RESET_SOFT	: out std_logic;
			PER_DIN		: out std_logic_vector(D_WIDTH-1 downto 0);
			PER_DOUT		: in std_logic_vector(D_WIDTH-1 downto 0);
			PER_ADDR		: out std_logic_vector(A_WIDTH-1 downto 0);
			PER_WR		: out std_logic;
			PER_RD		: out std_logic;
			PER_ACK		: in std_logic;
			PER_MATCH	: out std_logic
		);
	end component;

	component vme_mst_bridge is
		port(
			-- User ports --------------------------------------

			-- VME master interface
			bridge_select	: in std_logic;
			addr				: in std_logic_vector(7 downto 0);
			read_sig			: in std_logic; 
			write_sig		: in std_logic; 
			read_stb			: in std_logic;
			write_stb		: in std_logic;
			byte				: in std_logic_vector(3 downto 0);
			clk				: in std_logic;
			reset_hard		: in std_logic;
			reset_soft		: in std_logic;
				
			data_to_reg		: in std_logic_vector(31 downto 0);
			data_from_reg	: out std_logic_vector(31 downto 0);

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
	end component;

	type pbus_if_i is record
		RESET			: std_logic;
		RESET_SOFT	: std_logic;
		DIN			: std_logic_vector(D_WIDTH-1 downto 0);
		ADDR			: std_logic_vector(A_WIDTH-1 downto 0);
		WR				: std_logic;
		RD				: std_logic;
		MATCH			: std_logic;
	end record;

	type pbus_if_o is record
		DOUT			: std_logic_vector(D_WIDTH-1 downto 0);
		ACK			: std_logic;
	end record;

	procedure wo_reg(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant WO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant S	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant R	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant I	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: inout std_logic_vector(D_WIDTH-1 downto 0)
		);

	procedure wo_reg_ack(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant WO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant S	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant R	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant I	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: inout std_logic_vector(D_WIDTH-1 downto 0);
			signal ACK	: out std_logic
		);

	procedure ro_reg(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant RO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: in std_logic_vector(D_WIDTH-1 downto 0)
		);

	procedure ro_reg_ack(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant RO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: in std_logic_vector(D_WIDTH-1 downto 0);
			signal ACK	: out std_logic
		);

	procedure rw_reg(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant RW	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant WO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant S	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant R	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant I	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: inout std_logic_vector(D_WIDTH-1 downto 0)
		);

	procedure rw_reg_ack(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant RW	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant WO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant S	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant R	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant I	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: inout std_logic_vector(D_WIDTH-1 downto 0);
			signal ACK	: out std_logic
		);

end perbus_pkg;

package body perbus_pkg is
	procedure wo_reg(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant WO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant S	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant R	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant I	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: inout std_logic_vector(D_WIDTH-1 downto 0)
		) is
		variable addr_match	: std_logic;
		variable wr_match		: std_logic;
	begin
		if (PI.MATCH = '1') and (A = PI.ADDR) then
			addr_match := '1';
		else
			addr_match := '0';
		end if;

		wr_match := addr_match and PI.WR;

		if wr_match = '1' then
			PO.ACK <= '1';
	
			for J in 0 to D_WIDTH-1 loop
				if WO(J) = '1' then
					if R(J) = '1' then
						REG(J) <= '0';
					end if;

					if S(J) = '1' then
						REG(J) <= '1';
					end if;

					if PI.RESET = '1' then
						REG(J) <= I(J);
					elsif (PI.MATCH = '1') and (PI.WR = '1') and (A = PI.ADDR) then
						REG(J) <= PI.DIN(J);
					end if;
				end if;
			end loop;
		end if;
	end wo_reg;

	procedure wo_reg_ack(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant WO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant S	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant R	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant I	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: inout std_logic_vector(D_WIDTH-1 downto 0);
			signal ACK	: out std_logic
		) is
		variable addr_match	: std_logic;
		variable wr_match		: std_logic;
	begin
		ACK <= '0';

		if (PI.MATCH = '1') and (A = PI.ADDR) then
			addr_match := '1';
		else
			addr_match := '0';
		end if;

		wr_match := addr_match and PI.WR;

		if wr_match = '1' then
			PO.ACK <= '1';
			ACK <= '1';
	
			for J in 0 to D_WIDTH-1 loop
				if WO(J) = '1' then
					if R(J) = '1' then
						REG(J) <= '0';
					end if;

					if S(J) = '1' then
						REG(J) <= '1';
					end if;

					if PI.RESET = '1' then
						REG(J) <= I(J);
					elsif (PI.MATCH = '1') and (PI.WR = '1') and (A = PI.ADDR) then
						REG(J) <= PI.DIN(J);
					end if;
				end if;
			end loop;
		end if;
	end wo_reg_ack;

	procedure ro_reg(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant RO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: in std_logic_vector(D_WIDTH-1 downto 0)
		) is
		variable addr_match	: std_logic;
		variable rd_match		: std_logic;
	begin
		if (PI.MATCH = '1') and (A = PI.ADDR) then
			addr_match := '1';
		else
			addr_match := '0';
		end if;

		rd_match := addr_match and PI.RD;

		if rd_match = '1' then
			PO.DOUT <= (others=>'0');
			PO.ACK <= '1';

		for J in 0 to D_WIDTH-1 loop
			if RO(J) = '1' then
					PO.DOUT(J) <= REG(J);
				end if;			
			end loop;
		end if;
	end ro_reg;

	procedure ro_reg_ack(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant RO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: in std_logic_vector(D_WIDTH-1 downto 0);
			signal ACK	: out std_logic
		) is
		variable addr_match	: std_logic;
		variable rd_match		: std_logic;
	begin
		ACK <= '0';

		if (PI.MATCH = '1') and (A = PI.ADDR) then
			addr_match := '1';
		else
			addr_match := '0';
		end if;

		rd_match := addr_match and PI.RD;

		if rd_match = '1' then
			ACK <= '1';
			PO.DOUT <= (others=>'0');
			PO.ACK <= '1';

		for J in 0 to D_WIDTH-1 loop
			if RO(J) = '1' then
					PO.DOUT(J) <= REG(J);
				end if;
		end loop;
		end if;
	end ro_reg_ack;

	procedure rw_reg(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant RW	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant WO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant S	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant R	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant I	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: inout std_logic_vector(D_WIDTH-1 downto 0)
		) is
		variable addr_match	: std_logic;
		variable rd_match		: std_logic;
		variable wr_match		: std_logic;
	begin
		if (PI.MATCH = '1') and (A = PI.ADDR) then
			addr_match := '1';
		else
			addr_match := '0';
		end if;

		rd_match := addr_match and PI.RD;
		wr_match := addr_match and PI.WR;

		if (rd_match = '1') or (wr_match = '1') then
			PO.ACK <= '1';
		end if;

		if rd_match = '1' then
			PO.DOUT <= (others=>'0');
		end if;

		for J in 0 to D_WIDTH-1 loop
			if RW(J) = '1' then
				if rd_match = '1' then
					PO.DOUT(J) <= REG(J);
				end if;
			end if;
			if (WO(J) = '1') or (RW(J) = '1') then
				if R(J) = '1' then
					REG(J) <= '0';
				end if;

				if S(J) = '1' then
					REG(J) <= '1';
				end if;

				if PI.RESET = '1' then
					REG(J) <= I(J);
				elsif wr_match = '1' then
					REG(J) <= PI.DIN(J);
				end if;
			end if;

		end loop;
	end rw_reg;

	procedure rw_reg_ack(
			constant A	: std_logic_vector(A_WIDTH-1 downto 0);
			constant RW	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant WO	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant S	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant R	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			constant I	: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
			signal PI	: in pbus_if_i;
			signal PO	: out pbus_if_o;
			signal REG	: inout std_logic_vector(D_WIDTH-1 downto 0);
			signal ACK	: out std_logic
		) is
		variable addr_match	: std_logic;
		variable rd_match		: std_logic;
		variable wr_match		: std_logic;
	begin
		if (PI.MATCH = '1') and (A = PI.ADDR) then
			addr_match := '1';
		else
			addr_match := '0';
		end if;

		rd_match := addr_match and PI.RD;
		wr_match := addr_match and PI.WR;
		ACK <= '0';

		if (rd_match = '1') or (wr_match = '1') then
			ACK <= PI.WR;
			PO.ACK <= '1';
		end if;

		if rd_match = '1' then
			PO.DOUT <= (others=>'0');
		end if;

		for J in 0 to D_WIDTH-1 loop
			if RW(J) = '1' then
				if rd_match = '1' then
					PO.DOUT(J) <= REG(J);
				end if;
			end if;			
			if (WO(J) = '1') or (RW(J) = '1') then
				if R(J) = '1' then
					REG(J) <= '0';
				end if;

				if S(J) = '1' then
					REG(J) <= '1';
				end if;

				if PI.RESET = '1' then
					REG(J) <= I(J);
				elsif wr_match = '1' then
					REG(J) <= PI.DIN(J);
				end if;
			end if;

		end loop;
	end rw_reg_ack;

end perbus_pkg;
