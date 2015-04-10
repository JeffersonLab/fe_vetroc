library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.utils_pkg.all;

entity indexer_tb is
end indexer_tb;

architecture testbench of indexer_tb is
	component indexer is
		generic(
			-- Max number of elements buffer can hold=2**A_WIDTH_BUF
			A_WIDTH_BUF		: integer := 9;
			-- Time variable width. Maximum run time=2**T_WIDTH*4ns before rollover
			D_WIDTH			: integer := 16;
			T_WIDTH			: integer := 16;
			N_WIDTH			: integer := 6
		);
		port(
			-- WR_CLK domain
			WR_CLK			: in std_logic;
			WR					: in std_logic;
			DIN				: in std_logic_vector(D_WIDTH-1 downto 0);
			TIN				: in std_logic_Vector(T_WIDTH-1 downto 0);
			-- Note: RESET must be asserted before using to ensure erase pointer is set in proper position
			RESET				: in std_logic;
			
			-- RD_CLK domain
			RD_CLK			: in std_logic;

			RD_ADDR			: in std_logic_vector(A_WIDTH_BUF-1 downto 0);
			DOUT				: out std_logic_vector(D_WIDTH-1 downto 0);
			TOUT				: out std_logic_vector(T_WIDTH-1 downto 0);

			RD_ADDR_IDX		: in std_logic_vector(T_WIDTH-1 downto 0);
			ADDR_IDX			: out std_logic_vector(A_WIDTH_BUF-1 downto 0);
			LEN_IDX			: out std_logic_vector(N_WIDTH-1 downto 0);
			VALID_IDX		: out std_logic
		);
	end component;

	constant A_WIDTH_BUF		: integer := 9;
	constant D_WIDTH			: integer := 16;
	constant T_WIDTH			: integer := 16;
	constant N_WIDTH			: integer := 6;

	signal WR_CLK				: std_logic := '0';
	signal WR					: std_logic := '0';
	signal DIN					: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
	signal TIN					: std_logic_Vector(T_WIDTH-1 downto 0) := (others=>'0');
	signal RESET				: std_logic := '0';
	signal RD_CLK				: std_logic := '0';
	signal RD_ADDR				: std_logic_vector(A_WIDTH_BUF-1 downto 0) := (others=>'0');
	signal DOUT					: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
	signal TOUT					: std_logic_vector(T_WIDTH-1 downto 0) := (others=>'0');
	signal RD_ADDR_IDX		: std_logic_vector(T_WIDTH-1 downto 0) := (others=>'0');
	signal ADDR_IDX			: std_logic_vector(A_WIDTH_BUF-1 downto 0) := (others=>'0');
	signal LEN_IDX				: std_logic_vector(N_WIDTH-1 downto 0) := (others=>'0');
	signal VALID_IDX			: std_logic := '0';
begin

	indexer_inst: indexer
		generic map(
			A_WIDTH_BUF		=> A_WIDTH_BUF,
			D_WIDTH			=> D_WIDTH,
			T_WIDTH			=> T_WIDTH,
			N_WIDTH			=> N_WIDTH
		)
		port map(
			WR_CLK			=> WR_CLK,
			WR					=> WR,
			DIN				=> DIN,
			TIN				=> TIN,
			RESET				=> RESET,
			RD_CLK			=> RD_CLK,
			RD_ADDR			=> RD_ADDR,
			DOUT				=> DOUT,
			TOUT				=> TOUT,
			RD_ADDR_IDX		=> RD_ADDR_IDX,
			ADDR_IDX			=> ADDR_IDX,
			LEN_IDX			=> LEN_IDX,
			VALID_IDX		=> VALID_IDX
		);

	process
	begin
		WR_CLK <= '1';
		wait for 2 ns;
		WR_CLK <= '0';
		wait for 2 ns;
	end process;

	process
	begin
		RD_CLK <= '1';
		wait for 5 ns;
		RD_CLK <= '0';
		wait for 5 ns;
	end process;

	process
	begin
		RD_ADDR <= (others=>'0');
		RD_ADDR_IDX <= (others=>'0');
		wait for 400 ns;
		wait until rising_edge(RD_CLK);

		for a in 0 to 31 loop
			RD_ADDR_IDX <= conv_std_logic_vector(a, RD_ADDR_IDX'length);
			wait until rising_edge(RD_CLK);
			wait until rising_edge(RD_CLK);
			wait until rising_edge(RD_CLK);
			wait until rising_edge(RD_CLK);
			wait until rising_edge(RD_CLK);
			report "Cluster Index t=" & integer'image(a) &
			       ", valid=" & to_string(VALID_IDX) &
			       ", bufaddr=" & to_string(ADDR_IDX) &
			       ", len=" & to_string(LEN_IDX);
			wait until rising_edge(RD_CLK);
			wait until rising_edge(RD_CLK);
		end loop;
-- 		DOUT					: std_logic_vector(D_WIDTH-1 downto 0) := (others=>'0');
-- 		TOUT					: std_logic_vector(T_WIDTH-1 downto 0) := (others=>'0');
-- 		ADDR_IDX				: std_logic_vector(A_WIDTH_BUF-1 downto 0) := (others=>'0');
-- 		LEN_IDX				: std_logic_vector(N_WIDTH-1 downto 0) := (others=>'0');
--			VALID_IDX
		wait;
	end process;

	process
		procedure WriteCluster(d : in integer; t : in integer) is
		begin
			report "WriteCluster(d=" & integer'image(d) & ",t=" & integer'image(t) & ")" severity note;
			WR <= '1';
			DIN <= conv_std_logic_vector(d, DIN'length);
			TIN <= conv_std_logic_vector(t, TIN'length);
			wait until rising_edge(WR_CLK);
			WR <= '0';
		end WriteCluster;
	begin
		WR <= '0';
		DIN <= (others=>'0');
		TIN <= conv_std_logic_vector(0, TIN'length);
		RESET <= '1';
		wait for 100 ns;
		wait until rising_edge(WR_CLK);
		RESET <= '0';
		wait for 100 ns;
		wait until rising_edge(WR_CLK);

		--WriteCluster(din,tin)
		WriteCluster(100, 10);
		wait until rising_edge(WR_CLK);
		wait until rising_edge(WR_CLK);

		WriteCluster(101, 12);
		WriteCluster(102, 12);
		wait until rising_edge(WR_CLK);
		wait until rising_edge(WR_CLK);

		WriteCluster(102, 13);
		WriteCluster(103, 13);
		WriteCluster(104, 13);
		wait until rising_edge(WR_CLK);
		wait until rising_edge(WR_CLK);

		WriteCluster(105, 15);
		WriteCluster(106, 16);
		wait until rising_edge(WR_CLK);
		wait until rising_edge(WR_CLK);

		WriteCluster(107, 18);
		WriteCluster(108, 19);
		WriteCluster(109, 19);
		WriteCluster(110, 21);
		WriteCluster(111, 22);
		WriteCluster(112, 22);
		WriteCluster(113, 22);
		wait until rising_edge(WR_CLK);
		wait until rising_edge(WR_CLK);

		wait;
	end process;


end testbench;
