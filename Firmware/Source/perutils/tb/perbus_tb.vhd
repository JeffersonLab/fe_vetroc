library ieee;
use ieee.std_logic_1164.all;

library perbus;
use perbus.perbus_pkg.all;

entity perbus_tb is
end perbus_tb;

architecture testbench of perbus_tb is
	signal PI				: pbus_if_i;
	signal PO				: pbus_if_o;
	signal TESTREG0_ACK	: std_logic;
	signal TESTREG1_ACK	: std_logic;
	signal TESTREG0		: std_logic_vector(D_WIDTH-1 downto 0);
	signal TESTREG1		: std_logic_vector(D_WIDTH-1 downto 0);
begin

	process
	begin
		PI.CLK <= '0';
		wait for 5 ns;
		PI.CLK <= '1';
		wait for 5 ns;
	end process;

	process
	begin
		PI.RESET <= '1';
		PI.DIN <= x"00000000";
		PI.ADDR <= x"0000";
		PI.WR <= '0';
		PI.RD <= '0';
		PI.MATCH <= '0';
		wait for 100 ns;
		wait until rising_edge(PI.CLK);
		PI.RESET <= '0';
		wait for 100 ns;
		wait until rising_edge(PI.CLK);

		PI.DIN <= x"A5A500FF";
		PI.ADDR <= x"0004";
		PI.WR <= '1';
		PI.MATCH <= '1';
		wait until rising_edge(PI.CLK);
		PI.DIN <= x"00000000";
		PI.ADDR <= x"0000";
		PI.WR <= '0';
		PI.MATCH <= '0';

		wait until rising_edge(PI.CLK);
		PI.ADDR <= x"0004";
		PI.RD <= '1';
		PI.MATCH <= '1';
		wait until rising_edge(PI.CLK);
		PI.ADDR <= x"0000";
		PI.RD <= '0';
		PI.MATCH <= '0';
		
		wait;
	end process;

 	process(PI.CLK)
 	begin
 		if rising_edge(PI.CLK) then
			PO.ACK <= '0';

 			regio(PI=>PI,PO=>PO,ADDR=>x"0004",RBITS=>x"FFFFFFFF",WBITS=>x"FFFFFFFF",IVAL=>x"12345678",REG=>TESTREG0);
			regio(PI=>PI,PO=>PO,ADDR=>x"0008",RBITS=>x"FFFFFFFF",WBITS=>x"FFFFFFFF",IVAL=>x"ABCDEF01",REG=>TESTREG1);

 		end if;
 	end process;

end testbench;
