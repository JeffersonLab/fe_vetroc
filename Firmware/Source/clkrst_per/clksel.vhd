library ieee;
use ieee.std_logic_1164.all;

entity clksel is
	port(
		CLK				: in std_logic;

		CLKSRC_RELOAD	: in std_logic;
		CLKSRC_GTPA		: in std_logic_vector(1 downto 0);
		CLKSRC_GTPB		: in std_logic_vector(1 downto 0);
		CLKSRC_FPGA		: in std_logic_vector(1 downto 0);
		CLKSRC_TD		: in std_logic_vector(1 downto 0);

		CLK_SOUT			: out std_logic_vector(1 downto 0);
		CLK_SIN			: out std_logic_vector(1 downto 0);
		CLK_LOAD			: out std_logic;
		CLK_CONF			: out std_logic
	);
end clksel;

architecture synthesis of clksel is
	type CLKSEL_STATE_TYPE is (IDLE,
	                           SEL_GTPA, PULSE_GTPA, CLEAR_GTPA,
	                           SEL_GTPB, PULSE_GTPB, CLEAR_GTPB,
	                           SEL_FPGA, PULSE_FPGA, CLEAR_FPGA,
	                           SEL_TD, PULSE_TD, CLEAR_TD,
	                           PULSE_CONF);

	signal CLKSEL_STATE			: CLKSEL_STATE_TYPE;
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if CLKSRC_RELOAD = '1' then
				CLKSEL_STATE <= SEL_TD;
			else
				case CLKSEL_STATE is
					when SEL_TD			=> CLK_SOUT <= "00"; CLK_SIN <= CLKSRC_TD;   CLK_LOAD <= '0'; CLK_CONF <= '0'; CLKSEL_STATE <= PULSE_TD;
					when PULSE_TD		=> CLK_SOUT <= "00"; CLK_SIN <= CLKSRC_TD;   CLK_LOAD <= '1'; CLK_CONF <= '0'; CLKSEL_STATE <= CLEAR_TD;
					when CLEAR_TD		=> CLK_SOUT <= "00"; CLK_SIN <= CLKSRC_TD;   CLK_LOAD <= '0'; CLK_CONF <= '0'; CLKSEL_STATE <= SEL_GTPB;

					when SEL_GTPB		=> CLK_SOUT <= "01"; CLK_SIN <= CLKSRC_GTPB; CLK_LOAD <= '0'; CLK_CONF <= '0'; CLKSEL_STATE <= PULSE_GTPB;
					when PULSE_GTPB	=> CLK_SOUT <= "01"; CLK_SIN <= CLKSRC_GTPB; CLK_LOAD <= '1'; CLK_CONF <= '0'; CLKSEL_STATE <= CLEAR_GTPB;
					when CLEAR_GTPB	=> CLK_SOUT <= "01"; CLK_SIN <= CLKSRC_GTPB; CLK_LOAD <= '0'; CLK_CONF <= '0'; CLKSEL_STATE <= SEL_FPGA;

					when SEL_FPGA		=> CLK_SOUT <= "10"; CLK_SIN <= CLKSRC_FPGA; CLK_LOAD <= '0'; CLK_CONF <= '0'; CLKSEL_STATE <= PULSE_FPGA;
					when PULSE_FPGA	=> CLK_SOUT <= "10"; CLK_SIN <= CLKSRC_FPGA; CLK_LOAD <= '1'; CLK_CONF <= '0'; CLKSEL_STATE <= CLEAR_FPGA;
					when CLEAR_FPGA	=> CLK_SOUT <= "10"; CLK_SIN <= CLKSRC_FPGA; CLK_LOAD <= '0'; CLK_CONF <= '0'; CLKSEL_STATE <= SEL_GTPA;

					when SEL_GTPA		=> CLK_SOUT <= "11"; CLK_SIN <= CLKSRC_GTPA; CLK_LOAD <= '0'; CLK_CONF <= '0'; CLKSEL_STATE <= PULSE_GTPA;
					when PULSE_GTPA	=> CLK_SOUT <= "11"; CLK_SIN <= CLKSRC_GTPA; CLK_LOAD <= '1'; CLK_CONF <= '0'; CLKSEL_STATE <= CLEAR_GTPA;
					when CLEAR_GTPA	=> CLK_SOUT <= "11"; CLK_SIN <= CLKSRC_GTPA; CLK_LOAD <= '0'; CLK_CONF <= '0'; CLKSEL_STATE <= PULSE_CONF;

					when PULSE_CONF	=> CLK_SOUT <= "00"; CLK_SIN <= "00";        CLK_LOAD <= '0'; CLK_CONF <= '1'; CLKSEL_STATE <= IDLE;

					--IDLE
					when others			=> CLK_SOUT <= "00"; CLK_SIN <= "00";        CLK_LOAD <= '0'; CLK_CONF <= '0';
				end case;
			end if;
		end if;
	end process;

end synthesis;
