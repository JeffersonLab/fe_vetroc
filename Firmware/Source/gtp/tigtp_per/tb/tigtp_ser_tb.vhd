library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.tigtp_ser_pkg.all;

entity tigtp_ser_tb is
end tigtp_ser_tb;

architecture testbench of tigtp_ser_tb is
	signal ALT_CLK_REF				: std_logic;
	signal ALT_CLK_REF5X				: std_logic;
	signal ALT_PLL_RESET				: std_logic;
	signal ALT_USER_CLK				: std_logic;
	signal ALT_RESET					: std_logic;
	signal ALT_USER_TX_CMD			: std_logic_vector(1 downto 0);
	signal ALT_USER_TX_DATA			: std_logic_vector(7 downto 0);
	signal ALT_USER_RX_CMD			: std_logic_vector(1 downto 0);
	signal ALT_USER_RX_DATA			: std_logic_vector(7 downto 0);
	signal ALT_USER_RX_ERROR_CNT	: std_logic_vector(15 downto 0);
	signal ALT_USER_RX_READY		: std_logic;
	signal ALT_TXD						: std_logic;
	signal ALT_RXD						: std_logic;
	signal ALT_SEND_DONE				: std_logic;

	signal XIL_CLK_REF				: std_logic;
	signal XIL_CLK_REF5X				: std_logic;
	signal XIL_PLL_RESET				: std_logic;
	signal XIL_USER_CLK				: std_logic;
	signal XIL_RESET					: std_logic;
	signal XIL_USER_TX_CMD			: std_logic_vector(1 downto 0);
	signal XIL_USER_TX_DATA			: std_logic_vector(7 downto 0);
	signal XIL_USER_RX_CMD			: std_logic_vector(1 downto 0);
	signal XIL_USER_RX_DATA			: std_logic_vector(7 downto 0);
	signal XIL_USER_RX_ERROR_CNT	: std_logic_vector(15 downto 0);
	signal XIL_USER_RX_READY		: std_logic;
	signal XIL_TXD						: std_logic;
	signal XIL_RXD						: std_logic;
	signal XIL_SEND_DONE				: std_logic;
begin

	XIL_RXD <= ALT_TXD;
	ALT_RXD <= XIL_TXD;

	----------------------------------
	-- ALTERA EPS4 TIGTP INSTANCE
	----------------------------------

	alt_tigtp_ser_inst: tigtp_ser
		generic map(
			FPGA					=> "STRATIX4"
		)
		port map(
			CLK_REF				=> ALT_CLK_REF,
			CLK_REF_5X			=> ALT_CLK_REF5X,
			PLL_RESET			=> ALT_PLL_RESET,
			USER_CLK				=> ALT_USER_CLK,
			RESET					=> ALT_RESET,
			USER_TX_CMD			=> ALT_USER_TX_CMD,
			USER_TX_DATA		=> ALT_USER_TX_DATA,
			USER_RX_CMD			=> ALT_USER_RX_CMD,
			USER_RX_DATA		=> ALT_USER_RX_DATA,
			USER_RX_ERROR_CNT	=> ALT_USER_RX_ERROR_CNT,
			USER_RX_READY		=> ALT_USER_RX_READY,
			TXD					=> ALT_TXD,
			RXD					=> ALT_RXD
		);

	ALT_CLK_REF5X <= '0';

	process
	begin
		ALT_CLK_REF <= '1';
		wait for 2 ns;
		ALT_CLK_REF <= '0';
		wait for 2 ns;
	end process;

	process
	begin
		ALT_PLL_RESET <= '1';
		ALT_RESET <= '1';
		ALT_USER_TX_CMD <= (others=>'0');
		ALT_USER_TX_DATA <= (others=>'0');
		ALT_SEND_DONE <= '0';

		wait for 100 ns;
		ALT_PLL_RESET <= '0';
		wait for 100 ns;
		wait until rising_edge(ALT_USER_CLK);
		ALT_RESET <= '0';
		wait until rising_edge(ALT_USER_CLK) and XIL_USER_RX_READY = '1' and XIL_SEND_DONE = '1';
		wait for 100 ns;

		for I in 0 to 255 loop
			wait until rising_edge(ALT_USER_CLK);
			ALT_USER_TX_CMD <= TIGTP_CMD_SOP;

			wait until rising_edge(ALT_USER_CLK);
			ALT_USER_TX_CMD <= TIGTP_CMD_DATA;
			ALT_USER_TX_DATA <= conv_std_logic_vector(I, ALT_USER_TX_DATA'length);

			wait until rising_edge(ALT_USER_CLK);
			ALT_USER_TX_CMD <= TIGTP_CMD_EOP;

			wait until rising_edge(ALT_USER_CLK);
			ALT_USER_TX_CMD <= TIGTP_CMD_IDLE;
			wait until rising_edge(ALT_USER_CLK);
			ALT_USER_TX_CMD <= TIGTP_CMD_IDLE;
			wait until rising_edge(ALT_USER_CLK);
			ALT_USER_TX_CMD <= TIGTP_CMD_IDLE;
		end loop;

		ALT_SEND_DONE <= '1';

		wait;
	end process;

	process
	begin
		while true loop
			wait until rising_edge(ALT_USER_CLK);
			if (ALT_USER_RX_READY = '1') and (ALT_USER_RX_CMD = TIGTP_CMD_SOP) then
				report "SOP Received" severity note;
			elsif (ALT_USER_RX_READY = '1') and (ALT_USER_RX_CMD = TIGTP_CMD_EOP) then
				report "EOP Received" severity note;
			elsif (ALT_USER_RX_READY = '1') and (ALT_USER_RX_CMD = TIGTP_CMD_DATA) then
				report "Data Received: " & integer'image(conv_integer(ALT_USER_RX_DATA)) severity note;
			end if;
		end loop;
	end process;

	----------------------------------
	-- XILINX V5 TIGTP INSTANCE
	----------------------------------

	xil_tigtp_ser_inst: tigtp_ser
		generic map(
			FPGA					=> "VIRTEX5"
		)
		port map(
			CLK_REF				=> XIL_CLK_REF,
			CLK_REF_5X			=> XIL_CLK_REF5X,
			PLL_RESET			=> XIL_PLL_RESET,
			USER_CLK				=> XIL_USER_CLK,
			RESET					=> XIL_RESET,
			USER_TX_CMD			=> XIL_USER_TX_CMD,
			USER_TX_DATA		=> XIL_USER_TX_DATA,
			USER_RX_CMD			=> XIL_USER_RX_CMD,
			USER_RX_DATA		=> XIL_USER_RX_DATA,
			USER_RX_ERROR_CNT	=> XIL_USER_RX_ERROR_CNT,
			USER_RX_READY		=> XIL_USER_RX_READY,
			TXD					=> XIL_TXD,
			RXD					=> XIL_RXD
		);

	process
	begin
		XIL_CLK_REF5X <= '1';
		wait for 1 ns;
		XIL_CLK_REF5X <= '0';
		wait for 1 ns;
	end process;

	process
	begin
		XIL_CLK_REF <= '1';
		wait for 5 ns;
		XIL_CLK_REF <= '0';
		wait for 5 ns;
	end process;

	process
	begin
		XIL_PLL_RESET <= '1';
		XIL_RESET <= '1';
		XIL_USER_TX_CMD <= (others=>'0');
		XIL_USER_TX_DATA <= (others=>'0');
		XIL_SEND_DONE <= '0';

		wait for 100 ns;
		XIL_PLL_RESET <= '0';
		wait for 100 ns;
		wait until rising_edge(XIL_USER_CLK);
		XIL_RESET <= '0';
		wait until rising_edge(XIL_USER_CLK) and ALT_USER_RX_READY = '1';
		wait for 100 ns;

		for I in 0 to 255 loop
			wait until rising_edge(XIL_USER_CLK);
			XIL_USER_TX_CMD <= TIGTP_CMD_SOP;

			wait until rising_edge(XIL_USER_CLK);
			XIL_USER_TX_CMD <= TIGTP_CMD_DATA;
			XIL_USER_TX_DATA <= conv_std_logic_vector(I, XIL_USER_TX_DATA'length);

			wait until rising_edge(XIL_USER_CLK);
			XIL_USER_TX_CMD <= TIGTP_CMD_EOP;

			wait until rising_edge(XIL_USER_CLK);
			XIL_USER_TX_CMD <= TIGTP_CMD_IDLE;
			wait until rising_edge(XIL_USER_CLK);
			XIL_USER_TX_CMD <= TIGTP_CMD_IDLE;
			wait until rising_edge(XIL_USER_CLK);
			XIL_USER_TX_CMD <= TIGTP_CMD_IDLE;
		end loop;

		XIL_SEND_DONE <= '1';

		wait;
	end process;

	process
	begin
		while true loop
			wait until rising_edge(XIL_USER_CLK);
			if (XIL_USER_RX_READY = '1') and (XIL_USER_RX_CMD = TIGTP_CMD_SOP) then
				report "SOP Received" severity note;
			elsif (XIL_USER_RX_READY = '1') and (XIL_USER_RX_CMD = TIGTP_CMD_EOP) then
				report "EOP Received" severity note;
			elsif (XIL_USER_RX_READY = '1') and (XIL_USER_RX_CMD = TIGTP_CMD_DATA) then
				report "Data Received: " & integer'image(conv_integer(XIL_USER_RX_DATA)) severity note;
			end if;
		end loop;
	end process;

end testbench;
