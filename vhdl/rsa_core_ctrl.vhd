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
-- KEYWORDS		: rsa, core, control 
-- ----------------------------------------------------------------------------
-- PURPOSE		: Control the rsa computation by sending and reading control
--				  signals from the rsa_core_mult and rsa_core_mod blocks.
-- ----------------------------------------------------------------------------
-- INTERFACE
--		   		  _______
--		  	 	 |		 |
--	crtl_clk	-|		 |- ctrl_done
--	ctrl_rst	-|		 |- ctrl_c
--	ctrl_load	-|		 |- ctrl_err
--	ctrl_din	-|		 |- ctrl_start
--				 |		 |- ctrl_n
--	ctrl_loadx	-|		 |- ctrl_m
--	ctrl_dinx	-|		 |- ctrl_doutx
--		  		 |_______|
--
-- ----------------------------------------------------------------------------
-- PIN NAME		SIZE	DIRECTION	ACTIVE	DESCRIPTION
-- crtl_clk		1		in			user	System clock
-- ctrl_rst		1		in			user	Reset
-- ctrl_load	1		in			user	Load data from ctrl_din
-- ctrl_din		N		in			-		Data input. M/C, e/d and n are read
--											from this port.
-- ctrl_loadx	1		in			1		Load data from port ctrl_dinx
-- ctrl_dinx	1		in			-		Partial RSA result. This data must
--											be fed interactively into the
--											rsa_core_mult and rsa_core_mod
--											blocks (ctrl_dinx =
--											ctrl_m * ctrl_doutx mod ctrl_n)
-- ctrl_done	1		out			1		RSA result done on the ctrl_c port
--											when active.
-- ctrl_c		N		out			-		Final ciphered message
--											(C = M exp (e) mod n)
-- ctrl_err		1		out			1		Flag division by zero when active
-- ctrl_start	1		out			1		Start iteration. Partial result
--											from previous iteration is written
--											on ctrl_doutx. Original message
--											and modulus are written on ctrl_m
--											and ctrl_n
-- ctrl_n		N		out			-		Modulus n
-- ctrl_m		N		out			-		Original message to be ciphered
-- ctrl_doutx	N		out			-		Partial ciphered message
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
-- Instantiations	: N/A
-- Synthesizable	: Yes
-- ----------------------------------------------------------------------------
-- LIBRARY & USES
library ieee;
	use	ieee.std_logic_1164.all;
	use	ieee.std_logic_arith.all;	
	use ieee.std_logic_unsigned.all;
-------------------------------------------------------------------------------	
entity rsa_core_ctrl is
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
end rsa_core_ctrl;
-------------------------------------------------------------------------------
architecture behavioral of rsa_core_ctrl is
	-- constants
	constant ONE	: std_logic_vector(DATA_WIDTH-1 downto 0):= conv_std_logic_vector(1, DATA_WIDTH);
	
	-- FSM
	type states is (INIT,	-- initializes state machine
					LOAD_M,	-- load message to be ciphered when ctrl_load is active
					WAIT_M, -- wait ctrl_load button to be released
					LOAD_E, -- load exponent when ctrl_load is active
					WAIT_E, -- wait ctrl_load button to be released
					LOAD_N, -- load modulus when ctrl_load is active
					WAIT_N, -- wait ctrl_load button to be released. Start
							-- computation when ctrl_load is released.
					ERROR,  -- Error state. Flag division by zero.
					CASE0,  -- Special case. Expoent is zero. No iterations
							-- needed.
					ANALYZE,-- Analyze expoent contents. Control iterations.
					DONE,   -- Iteration finished. Computation is done.
					CASE1,  -- Special case. Exponent is one. No iterations
							-- is needed.
					CASE2,  -- Exponent is greater than one. Several iterations
							-- are neeeded.
					START); -- Start iteration.
				
	signal state_reg, state_ns: states;	
	
	-- DATAPATH
	signal n_reg	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal e_reg	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal m_reg	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal x_reg	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal c_reg	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal err_ff	: std_logic;
	signal start_ff	: std_logic;
	signal done_ff	: std_logic;	
begin
	-- OUTPUT SIGNALS CONNECTIONS
	ctrl_c		<= c_reg;
	ctrl_n		<= n_reg;
	ctrl_m		<= m_reg;
	ctrl_doutx	<= x_reg;	

	ctrl_done 	<= done_ff;
	ctrl_start	<= start_ff;
	ctrl_err	<= err_ff;

	-- NEXT STATE DECODE LOGIC
	fsm: process(ctrl_rst, ctrl_load, n_reg, e_reg, ctrl_loadx, state_reg)
	begin
		if (ctrl_rst = RESET) then
			state_ns 	<= INIT;
		else
			case state_reg is
				when INIT =>
					state_ns <= LOAD_M;
	
				when LOAD_M =>
					if (ctrl_load = LOAD) then
						state_ns <= WAIT_M;
					else
						state_ns <= LOAD_M;
					end if;
	
				when WAIT_M =>
					if (ctrl_load = LOAD) then
						state_ns <= WAIT_M;
					else
						state_ns <= LOAD_E;
					end if;
	
				when LOAD_E =>
					if (ctrl_load = LOAD) then
						state_ns <= WAIT_E;
					else
						state_ns <= LOAD_E;
					end if;

				when WAIT_E =>
					if (ctrl_load = LOAD) then
						state_ns <= WAIT_E;
					else
						state_ns <= LOAD_N;
					end if;

				when LOAD_N =>
					if (ctrl_load = LOAD) then
						state_ns <= WAIT_N;
					else
						state_ns <= LOAD_N;
					end if;
	
				when WAIT_N =>
					if (ctrl_load = LOAD) then
						state_ns <= WAIT_N;
					else
						if (n_reg = 0) then
							state_ns <= ERROR;
						else
							if (e_reg = 0) then
								state_ns <= CASE0;
							elsif (e_reg = 1) then
								state_ns <= CASE1;
							else
								state_ns <= CASE2;
							end if;
						end if;
					end if;
					
				when ERROR =>
					state_ns <= LOAD_M;

				when CASE0 =>
					state_ns <= ANALYZE;
	
				when ANALYZE =>
					if (ctrl_loadx = '0') then
						state_ns <= ANALYZE;
					else
						if (e_reg = 0) then
							state_ns <= DONE;
						else
							state_ns <= START;
						end if;					
					end if;

				when DONE =>
					state_ns <= LOAD_M;

				when CASE1 =>
					state_ns <= ANALYZE;
					
				when CASE2 =>
					state_ns <= ANALYZE;
										
				when START =>
					state_ns <= ANALYZE;

				when others =>
					state_ns <= INIT;			
			end case;
		end if;
	end process fsm;

	-- RTL TRANSFERS (DATAPATH)
	rtl: process (ctrl_clk)
	begin
		if(ctrl_clk'event and ctrl_clk=CLK_EDGE)then		
			case state_reg is
				when INIT =>
					err_ff	<= '0';
					start_ff<= '0';
					done_ff	<= '0';
					
				when LOAD_M =>
					m_reg	<= ctrl_din;
					x_reg	<= ctrl_din;
					done_ff	<= '0';
										
				when WAIT_M =>
					null;
										
				when LOAD_E =>
					e_reg	<= ctrl_din;
	
				when WAIT_E =>
					null;
						
				when LOAD_N =>
					n_reg	<= ctrl_din;

				when WAIT_N =>
					null;
					
				when ERROR =>
					done_ff		<= '1';
					err_ff		<= '1';
					c_reg	<= (others => '1');

				when CASE0 =>
					start_ff	<= '1';
					m_reg		<= ONE;
					x_reg		<= ONE;

				when ANALYZE =>
					x_reg		<= ctrl_dinx;
					start_ff	<= not '1';
					
				when DONE =>
					c_reg	<= x_reg;
					done_ff		<= '1';
					err_ff		<= '0';
					
				when CASE1 =>
					x_reg		<= ONE;
					start_ff	<= '1';
					e_reg		<= e_reg - 1;

				when CASE2 =>
					start_ff	<= '1';
					e_reg		<= e_reg - 2;
					
				when START =>
					start_ff	<= '1';
					e_reg		<= e_reg - 1;
					
				when others =>
					null;
			end case;	
			state_reg <= state_ns;
		end if;
	end process rtl;
end behavioral;
