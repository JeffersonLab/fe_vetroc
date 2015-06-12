library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library utils;
use utils.utils_pkg.all;

entity lane_bond is
	generic(
		LANE_NUM			: integer := 4
	);
	port(
		USER_CLK			: in std_logic;
		RESET				: in std_logic;
		ENABLE_BOND		: in std_logic;
		
		RX_DATA_IN		: in std_logic_vector(16*LANE_NUM-1 downto 0);
		RX_K_IN			: in std_logic_vector(2*LANE_NUM-1 downto 0);
		RX_C_IN			: in std_logic_vector(2*LANE_NUM-1 downto 0);
		
		RX_DATA_OUT		: out std_logic_vector(16*LANE_NUM-1 downto 0);
		RX_K_OUT			: out std_logic_vector(2*LANE_NUM-1 downto 0);
		RX_C_OUT			: out std_logic_vector(2*LANE_NUM-1 downto 0);
		
		BOND_DONE		: out std_logic;
		BOND_FAIL		: out std_logic
	);
end lane_bond;

architecture synthesis of lane_bond is
	type BOND_STATE_TYPE is (INIT, CHECK_BONDED, RESET_A_CNT, BOND_FAILED, BOND_PASSED);

	constant K							: std_logic_vector(7 downto 0) := x"BC";
	constant R							: std_logic_vector(7 downto 0) := x"1C";
	constant A							: std_logic_vector(7 downto 0) := x"7C";

	signal BOND_STATE					: BOND_STATE_TYPE;
	signal BOND_STATE_NEXT			: BOND_STATE_TYPE;
	signal A_CNT						: unsigned(1 downto 0) := (others=>'0');
	signal A_CNT_INC					: std_logic := '0';
	signal A_CNT_RST					: std_logic := '0';
	signal A_CNT_DEC					: std_logic := '0';
	signal A_CNT_MIN					: std_logic := '0';
	signal A_CNT_MAX					: std_logic := '0';
	signal GOT_A						: std_logic_vector(LANE_NUM-1 downto 0) := (others=>'0');
	signal GOT_A_ALL					: std_logic := '0';
	signal GOT_A_ANY					: std_logic := '0';
	signal OFFSET						: unsigned(3*LANE_NUM-1 downto 0) := (others=>'0');
	signal OFFSET_DONE				: std_logic := '0';
	signal OFFSET_INC					: std_logic := '0';
	signal OFFSET_RST					: std_logic := '0';
	signal BOND_TIMEOUT_CNT			: unsigned(5 downto 0) := (others=>'0');
	signal BOND_TIMEOUT_CNT_RST	: std_logic := '0';
	signal BOND_TIMEOUT_CNT_DONE	: std_logic := '0';
	signal RX_DATA						: std_logic_vector(16*LANE_NUM-1 downto 0) := (others=>'0');
	signal RX_K							: std_logic_vector(2*LANE_NUM-1 downto 0) := (others=>'0');
	signal RX_C							: std_logic_vector(2*LANE_NUM-1 downto 0) := (others=>'0');
begin

	process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
			if RESET = '1' then
				BOND_STATE <= INIT;
			else
				BOND_STATE <= BOND_STATE_NEXT;
			end if;
		end if;
	end process;

	process(BOND_STATE, ENABLE_BOND, GOT_A_ALL, GOT_A_ANY, BOND_TIMEOUT_CNT_DONE, OFFSET_DONE, A_CNT_MAX)
	begin
		BOND_STATE_NEXT <= BOND_STATE;
		BOND_DONE <= '0';
		BOND_FAIL <= '0';
		OFFSET_RST <= '0';
		OFFSET_INC <= '0';
		BOND_TIMEOUT_CNT_RST <= '0';
		A_CNT_INC <= '0';
		A_CNT_DEC <= '0';
		A_CNT_RST <= '0';

		case BOND_STATE is
			when CHECK_BONDED =>
				A_CNT_INC <= GOT_A_ALL;
				A_CNT_DEC <= GOT_A_ANY and not GOT_A_ALL;

				if BOND_TIMEOUT_CNT_DONE = '1' then
					if OFFSET_DONE = '1' then
						BOND_STATE_NEXT <= BOND_FAILED;
					else
						OFFSET_INC <= '1';
						BOND_STATE_NEXT <= RESET_A_CNT;
					end if;
				elsif A_CNT_MAX = '1' then
					BOND_STATE_NEXT <= BOND_PASSED;
				end if;

			when RESET_A_CNT =>
				BOND_TIMEOUT_CNT_RST <= '1';
				A_CNT_RST <= '1';
				BOND_STATE_NEXT <= CHECK_BONDED;

			when BOND_FAILED =>
				BOND_FAIL <= '1';

			when BOND_PASSED =>
				BOND_DONE <= '1';

			when others =>	--INIT
				OFFSET_RST <= '1';
				if ENABLE_BOND = '1' then
					BOND_STATE_NEXT <= RESET_A_CNT;
				end if;

		end case;
	end process;

	OFFSET_DONE <= '1' when OFFSET = unsigned(slv_ones(OFFSET'length)) else '0';

	process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
			if OFFSET_RST = '1' then
				OFFSET <= (others=>'0');
			elsif OFFSET_INC = '1' then
				OFFSET <= OFFSET + 1;
			end if;
		end if;
	end process;

	BOND_TIMEOUT_CNT_DONE <= '1' when BOND_TIMEOUT_CNT = unsigned(slv_ones(BOND_TIMEOUT_CNT'length)) else '0';

	process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
			if BOND_TIMEOUT_CNT_RST = '1' then
				BOND_TIMEOUT_CNT <= (others=>'0');
			elsif BOND_TIMEOUT_CNT_DONE = '0' then
				BOND_TIMEOUT_CNT <= BOND_TIMEOUT_CNT + 1;
			end if;
		end if;
	end process;

	process(USER_CLK)
	begin
		if rising_edge(USER_CLK) then
			if A_CNT_RST = '1' then
				A_CNT <= (others=>'0');
			elsif A_CNT_DEC = '1' and A_CNT_MIN = '0' then
				A_CNT <= A_CNT - 1;
			elsif A_CNT_INC = '1' and A_CNT_MAX = '0' then
				A_CNT <= A_CNT + 1;
			end if;
		end if;
	end process;

	A_CNT_MIN <= '1' when A_CNT = to_unsigned(0, 2) else '0';
	A_CNT_MAX <= '1' when A_CNT = to_unsigned(3, 2) else '0';

	GOT_A_ALL <= and_reduce(GOT_A);
	GOT_A_ANY <= or_reduce(GOT_A);

	sdp_ram_gen: for I in 0 to LANE_NUM-1 generate
		signal WR_ADDR		: unsigned(2 downto 0) := (others=>'0');
		signal RD_ADDR		: unsigned(2 downto 0) := (others=>'0');
		signal DIN			: std_logic_vector(19 downto 0) := (others=>'0');
		signal DOUT			: std_logic_vector(19 downto 0) := (others=>'0');
		signal OFFSET_LOC	: unsigned(2 downto 0) := (others=>'0');
	begin

		DIN <= RX_C_IN(2*I+1 downto 2*I) &
		       RX_K_IN(2*I+1 downto 2*I) &
		       RX_DATA_IN(16*I+15 downto 16*I);

		process(USER_CLK)
		begin
			if rising_edge(USER_CLK) then
				WR_ADDR <= WR_ADDR + 1;
				RD_ADDR <= WR_ADDR + OFFSET_LOC;
				RX_C_OUT(2*I+1 downto 2*I) <= RX_C(2*I+1 downto 2*I);
				RX_K_OUT(2*I+1 downto 2*I) <= RX_K(2*I+1 downto 2*I);
				RX_DATA_OUT(16*I+15 downto 16*I) <= RX_DATA(16*I+15 downto 16*I);
				OFFSET_LOC <= OFFSET(3*I+2 downto 3*I);

				if (DOUT(7 downto 0) = A and DOUT(16) = '1') or (DOUT(15 downto 8) = A and DOUT(17) = '1') then
					GOT_A(I) <= '1';
				else
					GOT_A(I) <= '0';
				end if;
			end if;
		end process;

		sdp_ram_inst: sdp_ram
			generic map(
				D_WIDTH		=> 20,
				A_WIDTH		=> 3,
				DOUT_REG		=> false
			)
			port map(
				WR_CLK	=> USER_CLK,
				WR			=> '1',
				WR_ADDR	=> std_logic_vector(WR_ADDR),
				DIN		=> DIN,
				RD_CLK	=> USER_CLK,
				RD			=> '1',
				RD_ADDR	=> std_logic_vector(RD_ADDR),
				DOUT		=> DOUT
			);

		RX_C(2*I+1 downto 2*I) <= DOUT(19 downto 18);
		RX_K(2*I+1 downto 2*I) <= DOUT(17 downto 16);
		RX_DATA(16*I+15 downto 16*I) <= DOUT(15 downto 0);
	end generate;

end synthesis;
