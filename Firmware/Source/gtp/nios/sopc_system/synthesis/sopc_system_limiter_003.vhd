-- sopc_system_limiter_003.vhd

-- Generated using ACDS version 13.0sp1 232 at 2015.06.12.15:50:14

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sopc_system_limiter_003 is
	generic (
		PKT_DEST_ID_H             : integer := 84;
		PKT_DEST_ID_L             : integer := 84;
		PKT_TRANS_POSTED          : integer := 65;
		PKT_TRANS_WRITE           : integer := 66;
		MAX_OUTSTANDING_RESPONSES : integer := 5;
		PIPELINED                 : integer := 0;
		ST_DATA_W                 : integer := 95;
		ST_CHANNEL_W              : integer := 2;
		VALID_WIDTH               : integer := 2;
		ENFORCE_ORDER             : integer := 1;
		PREVENT_HAZARDS           : integer := 0;
		PKT_BYTE_CNT_H            : integer := 72;
		PKT_BYTE_CNT_L            : integer := 70;
		PKT_BYTEEN_H              : integer := 35;
		PKT_BYTEEN_L              : integer := 32
	);
	port (
		clk                    : in  std_logic                     := '0';             --       clk.clk
		reset                  : in  std_logic                     := '0';             -- clk_reset.reset
		cmd_sink_ready         : out std_logic;                                        --  cmd_sink.ready
		cmd_sink_valid         : in  std_logic                     := '0';             --          .valid
		cmd_sink_data          : in  std_logic_vector(94 downto 0) := (others => '0'); --          .data
		cmd_sink_channel       : in  std_logic_vector(1 downto 0)  := (others => '0'); --          .channel
		cmd_sink_startofpacket : in  std_logic                     := '0';             --          .startofpacket
		cmd_sink_endofpacket   : in  std_logic                     := '0';             --          .endofpacket
		cmd_src_ready          : in  std_logic                     := '0';             --   cmd_src.ready
		cmd_src_data           : out std_logic_vector(94 downto 0);                    --          .data
		cmd_src_channel        : out std_logic_vector(1 downto 0);                     --          .channel
		cmd_src_startofpacket  : out std_logic;                                        --          .startofpacket
		cmd_src_endofpacket    : out std_logic;                                        --          .endofpacket
		rsp_sink_ready         : out std_logic;                                        --  rsp_sink.ready
		rsp_sink_valid         : in  std_logic                     := '0';             --          .valid
		rsp_sink_channel       : in  std_logic_vector(1 downto 0)  := (others => '0'); --          .channel
		rsp_sink_data          : in  std_logic_vector(94 downto 0) := (others => '0'); --          .data
		rsp_sink_startofpacket : in  std_logic                     := '0';             --          .startofpacket
		rsp_sink_endofpacket   : in  std_logic                     := '0';             --          .endofpacket
		rsp_src_ready          : in  std_logic                     := '0';             --   rsp_src.ready
		rsp_src_valid          : out std_logic;                                        --          .valid
		rsp_src_data           : out std_logic_vector(94 downto 0);                    --          .data
		rsp_src_channel        : out std_logic_vector(1 downto 0);                     --          .channel
		rsp_src_startofpacket  : out std_logic;                                        --          .startofpacket
		rsp_src_endofpacket    : out std_logic;                                        --          .endofpacket
		cmd_src_valid          : out std_logic_vector(1 downto 0)                      -- cmd_valid.data
	);
end entity sopc_system_limiter_003;

architecture rtl of sopc_system_limiter_003 is
	component altera_merlin_traffic_limiter is
		generic (
			PKT_DEST_ID_H             : integer := 0;
			PKT_DEST_ID_L             : integer := 0;
			PKT_TRANS_POSTED          : integer := 0;
			PKT_TRANS_WRITE           : integer := 0;
			MAX_OUTSTANDING_RESPONSES : integer := 0;
			PIPELINED                 : integer := 0;
			ST_DATA_W                 : integer := 72;
			ST_CHANNEL_W              : integer := 1;
			VALID_WIDTH               : integer := 1;
			ENFORCE_ORDER             : integer := 1;
			PREVENT_HAZARDS           : integer := 0;
			PKT_BYTE_CNT_H            : integer := 0;
			PKT_BYTE_CNT_L            : integer := 0;
			PKT_BYTEEN_H              : integer := 0;
			PKT_BYTEEN_L              : integer := 0
		);
		port (
			clk                    : in  std_logic                     := 'X';             -- clk
			reset                  : in  std_logic                     := 'X';             -- reset
			cmd_sink_ready         : out std_logic;                                        -- ready
			cmd_sink_valid         : in  std_logic                     := 'X';             -- valid
			cmd_sink_data          : in  std_logic_vector(94 downto 0) := (others => 'X'); -- data
			cmd_sink_channel       : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- channel
			cmd_sink_startofpacket : in  std_logic                     := 'X';             -- startofpacket
			cmd_sink_endofpacket   : in  std_logic                     := 'X';             -- endofpacket
			cmd_src_ready          : in  std_logic                     := 'X';             -- ready
			cmd_src_data           : out std_logic_vector(94 downto 0);                    -- data
			cmd_src_channel        : out std_logic_vector(1 downto 0);                     -- channel
			cmd_src_startofpacket  : out std_logic;                                        -- startofpacket
			cmd_src_endofpacket    : out std_logic;                                        -- endofpacket
			rsp_sink_ready         : out std_logic;                                        -- ready
			rsp_sink_valid         : in  std_logic                     := 'X';             -- valid
			rsp_sink_channel       : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- channel
			rsp_sink_data          : in  std_logic_vector(94 downto 0) := (others => 'X'); -- data
			rsp_sink_startofpacket : in  std_logic                     := 'X';             -- startofpacket
			rsp_sink_endofpacket   : in  std_logic                     := 'X';             -- endofpacket
			rsp_src_ready          : in  std_logic                     := 'X';             -- ready
			rsp_src_valid          : out std_logic;                                        -- valid
			rsp_src_data           : out std_logic_vector(94 downto 0);                    -- data
			rsp_src_channel        : out std_logic_vector(1 downto 0);                     -- channel
			rsp_src_startofpacket  : out std_logic;                                        -- startofpacket
			rsp_src_endofpacket    : out std_logic;                                        -- endofpacket
			cmd_src_valid          : out std_logic_vector(1 downto 0)                      -- data
		);
	end component altera_merlin_traffic_limiter;

begin

	limiter_003 : component altera_merlin_traffic_limiter
		generic map (
			PKT_DEST_ID_H             => PKT_DEST_ID_H,
			PKT_DEST_ID_L             => PKT_DEST_ID_L,
			PKT_TRANS_POSTED          => PKT_TRANS_POSTED,
			PKT_TRANS_WRITE           => PKT_TRANS_WRITE,
			MAX_OUTSTANDING_RESPONSES => MAX_OUTSTANDING_RESPONSES,
			PIPELINED                 => PIPELINED,
			ST_DATA_W                 => ST_DATA_W,
			ST_CHANNEL_W              => ST_CHANNEL_W,
			VALID_WIDTH               => VALID_WIDTH,
			ENFORCE_ORDER             => ENFORCE_ORDER,
			PREVENT_HAZARDS           => PREVENT_HAZARDS,
			PKT_BYTE_CNT_H            => PKT_BYTE_CNT_H,
			PKT_BYTE_CNT_L            => PKT_BYTE_CNT_L,
			PKT_BYTEEN_H              => PKT_BYTEEN_H,
			PKT_BYTEEN_L              => PKT_BYTEEN_L
		)
		port map (
			clk                    => clk,                    --       clk.clk
			reset                  => reset,                  -- clk_reset.reset
			cmd_sink_ready         => cmd_sink_ready,         --  cmd_sink.ready
			cmd_sink_valid         => cmd_sink_valid,         --          .valid
			cmd_sink_data          => cmd_sink_data,          --          .data
			cmd_sink_channel       => cmd_sink_channel,       --          .channel
			cmd_sink_startofpacket => cmd_sink_startofpacket, --          .startofpacket
			cmd_sink_endofpacket   => cmd_sink_endofpacket,   --          .endofpacket
			cmd_src_ready          => cmd_src_ready,          --   cmd_src.ready
			cmd_src_data           => cmd_src_data,           --          .data
			cmd_src_channel        => cmd_src_channel,        --          .channel
			cmd_src_startofpacket  => cmd_src_startofpacket,  --          .startofpacket
			cmd_src_endofpacket    => cmd_src_endofpacket,    --          .endofpacket
			rsp_sink_ready         => rsp_sink_ready,         --  rsp_sink.ready
			rsp_sink_valid         => rsp_sink_valid,         --          .valid
			rsp_sink_channel       => rsp_sink_channel,       --          .channel
			rsp_sink_data          => rsp_sink_data,          --          .data
			rsp_sink_startofpacket => rsp_sink_startofpacket, --          .startofpacket
			rsp_sink_endofpacket   => rsp_sink_endofpacket,   --          .endofpacket
			rsp_src_ready          => rsp_src_ready,          --   rsp_src.ready
			rsp_src_valid          => rsp_src_valid,          --          .valid
			rsp_src_data           => rsp_src_data,           --          .data
			rsp_src_channel        => rsp_src_channel,        --          .channel
			rsp_src_startofpacket  => rsp_src_startofpacket,  --          .startofpacket
			rsp_src_endofpacket    => rsp_src_endofpacket,    --          .endofpacket
			cmd_src_valid          => cmd_src_valid           -- cmd_valid.data
		);

end architecture rtl; -- of sopc_system_limiter_003
