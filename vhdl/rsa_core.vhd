-------------------------------------------------------------------------------
-- COMPANY NAME	: InPlace Design Automation
-- AUTHOR		: Alcides Silveira Costa
-------------------------------------------------------------------------------
-- RELEASE HISTORY
-- DATE 			AUTHOR			DESCRIPTION
-- 24-Feb-2025		Alcides			Design environment migration to a Windows 7
--									VM running on Ubuntu 22.04.
-- 11-Oct-2009		Alcides			Creation
-------------------------------------------------------------------------------
-- KEYWORDS		: rsa, core, cipher 
-- ----------------------------------------------------------------------------
-- PURPOSE		: Core block. Computes the RSA algorithm C = M exp(e) mod n
-- ----------------------------------------------------------------------------
-- INTERFACE
--		   		  __________
--		  	 	 |		 	|
--	core_clk	-|		 	|
--	core_rst	-|		 	|- core_done
--				-|			|- core_err
--	core_load	-|		 	|- core_dout
--	core_din	-|		 	|
--		  		 |__________|
--
-- ----------------------------------------------------------------------------
-- PIN NAME		SIZE	DIRECTION	ACTIVE	DESCRIPTION
-- core_clk		1		in			user	System clock
-- core_rst		1		in			user	Reset
-- core_load	1		in			user	Load data from core_din when active
-- core_din		N		in			-		Data input. M/C, e/d and n are read
--											from this port (respectively).
--											Start computation after third data
--											is read.
-- core_done	1		out			1		Final result done on the core_dout
--											port when active.
-- core_err		1		out			1		Flag division by zero when active.
--											Outputs 0xFF on core_dout.
-- core_dout	N		out			-		Final result. Ciphered message.
-- ----------------------------------------------------------------------------
-- PARAMETER NAME 	RANGE	DEFAULT			DESCRIPTION
-- DATA_WIDTH		[N,1]	8				Data width. Defines message width.
-- CLK_EDGE			[1,0]	1				clock edge sensitivity
-- RESET			[1,0]	0				logic level activity
-- LOAD				[1,0]	1				logic level activity
-- ----------------------------------------------------------------------------
-- REUSE ISSUES
-- Reset Strategy	: Synchronous
-- Clock Domains	: system_clk
-- Critical Timing	: N/A
-- Instantiations	: 3
-- Synthesizable	: Yes
-- ----------------------------------------------------------------------------
-- LIBRARY & USES
library ieee;
	use	ieee.std_logic_1164.all;
-------------------------------------------------------------------------------
entity rsa_core is
	generic(
 		DATA_WIDTH	: integer	:= 8;
		CLK_EDGE	: std_logic := '1';	
		RESET		: std_logic := '0';
		LOAD		: std_logic := '0');
	port (
		core_clk	: in std_logic;
		core_rst	: in std_logic;
		core_load	: in std_logic;
		core_din	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		core_done	: out std_logic;
		core_err	: out std_logic;		
		core_dout	: out std_logic_vector(DATA_WIDTH-1 downto 0));
end rsa_core;
-------------------------------------------------------------------------------
architecture structural of rsa_core is
	-- COMPONENT DECLARATION SECTION
	component rsa_core_mult is
		generic(	
			DATA_WIDTH	: integer := 8;
			CLK_EDGE	: std_logic:='1';
			RESET		: std_logic:='0';
			START		: std_logic:='1');
		port(
			mult_clk	: in std_logic;
			mult_rst	: in std_logic;
			mult_start	: in std_logic;
			mult_a		: in std_logic_vector(DATA_WIDTH-1 downto 0);
			mult_b		: in std_logic_vector(DATA_WIDTH-1 downto 0);
			mult_done	: out std_logic;
			mult_c		: out std_logic_vector(2*DATA_WIDTH-1 downto 0));
	end component;
	
	component rsa_core_mod is
		generic(
			DATA_WIDTH	: integer := 8;
			CLK_EDGE	: std_logic:='1';
			RESET		: std_logic:='0';
			START		: std_logic:='1');
		port(
			mod_clk		: in std_logic;
			mod_rst		: in std_logic;
			mod_start	: in std_logic;
			mod_a		: in std_logic_vector(2*DATA_WIDTH-1 downto 0);
			mod_b		: in std_logic_vector(DATA_WIDTH-1 downto 0);
			mod_done	: out std_logic;
			mod_err		: out std_logic;
			mod_c	: out std_logic_vector(DATA_WIDTH-1 downto 0));
	end component;
	
	component rsa_core_ctrl is
		generic(
			DATA_WIDTH	: integer := 8;
			CLK_EDGE	: std_logic:='1';
			RESET		: std_logic:='0';
			LOAD		: std_logic:='0');
		port(
			ctrl_clk	: in std_logic;
			ctrl_rst	: in std_logic;
			ctrl_load	: in std_logic;
			ctrl_din	: in std_logic_vector(DATA_WIDTH-1 downto 0);
			ctrl_loadx	: in std_logic;		
			ctrl_dinx	: in std_logic_vector(DATA_WIDTH-1 downto 0);
			ctrl_done	: out std_logic;
			ctrl_err	: out std_logic;
			ctrl_c		: out std_logic_vector(DATA_WIDTH-1 downto 0);
			ctrl_start	: out std_logic;
			ctrl_n		: out std_logic_vector(DATA_WIDTH-1 downto 0);
			ctrl_m		: out std_logic_vector(DATA_WIDTH-1 downto 0);
			ctrl_doutx	: out std_logic_vector(DATA_WIDTH-1 downto 0));
	end component;

	-- INTERNAL CONNECTIONS
	signal ctrl_start_sig	: std_logic;
	signal ctrl_m_sig		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal ctrl_n_sig		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal ctrl_doutx_sig	: std_logic_vector(DATA_WIDTH-1 downto 0);
	
	signal mult_done_sig	: std_logic;
	signal mult_c_sig		: std_logic_vector(2*DATA_WIDTH-1 downto 0);
	
	signal mod_done_sig		: std_logic;
	signal mod_c_sig		: std_logic_vector(DATA_WIDTH-1 downto 0);

begin
	-- COMPONENT INSTANTIATION SECTION
	rsa_core_mult_blk: rsa_core_mult
		generic map(	
			DATA_WIDTH	=> DATA_WIDTH,
			CLK_EDGE	=> CLK_EDGE,
			RESET		=> RESET,
			START		=> '1')
		port map(
			mult_clk	=> core_clk,
			mult_rst	=> core_rst,
			mult_start	=> ctrl_start_sig,
			mult_a		=> ctrl_m_sig,
			mult_b		=> ctrl_doutx_sig,
			mult_done	=> mult_done_sig,
			mult_c		=> mult_c_sig);

	rsa_core_mod_blk: rsa_core_mod
		generic map(
			DATA_WIDTH	=> DATA_WIDTH,
			CLK_EDGE	=> CLK_EDGE,  
			RESET		=> RESET,     
			START		=> '1')
		port map(
			mod_clk		=> core_clk,
			mod_rst		=> core_rst,
			mod_start	=> mult_done_sig,
			mod_a		=> mult_c_sig,
			mod_b		=> ctrl_n_sig,
			mod_done	=> mod_done_sig,
			mod_err		=> open,
			mod_c		=> mod_c_sig);

	rsa_core_ctrl_blk: rsa_core_ctrl
		generic map(
			DATA_WIDTH	=> DATA_WIDTH,
			CLK_EDGE	=> CLK_EDGE,
			RESET		=> RESET,
			LOAD		=> LOAD)
		port map(
			ctrl_clk	=> core_clk,
			ctrl_rst	=> core_rst,
			ctrl_load	=> core_load,
			ctrl_din	=> core_din,
			ctrl_loadx	=> mod_done_sig,
			ctrl_dinx	=> mod_c_sig,
			ctrl_done	=> core_done,
			ctrl_err	=> core_err,
			ctrl_c		=> core_dout,
			ctrl_start	=> ctrl_start_sig,
			ctrl_n		=> ctrl_n_sig,
			ctrl_m		=> ctrl_m_sig,
			ctrl_doutx	=> ctrl_doutx_sig);		
end structural;
