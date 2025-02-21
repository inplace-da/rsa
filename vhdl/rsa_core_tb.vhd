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
-- KEYWORDS		: rsa, core, testbench 
-- ----------------------------------------------------------------------------
-- PURPOSE		: RSA core testbench.
-- ----------------------------------------------------------------------------
-- INTERFACE
-- 
--       _________________________________________________________________
--      | rsa_core_tb                                                     |
--      |    __________            _______________                        |
--      |   |  clock   | core_clk |               |                       |
--      |   |__________|----------|               |           _________   |
--      |    __________           |               | core_err |         |  |
--      |   |   reset  | core_rst |               |----------|         |  |
--      |   |__________|----------|               | core_done| checker |  |
--      |    __________           |    rsa_core   |----------|         |  |
--      |   |          | core_load|     (DUV)     | core_dout|         |  |
--      |   |          |----------|               |----------|_________|  |
--      |   | stimulus | core_din |               |                       |
--      |   |          |----------|               |                       |
--		|	|__________|          |_______________|                       |
--      |_________________________________________________________________|



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
-- PARAMETER NAME 	type	DEFAULT			DESCRIPTION
-- CLK_PERIOD		real	20 ns			Clock period
-- DATA_FILE		string	stimulus.txt	Stimulus data
-- CHECKER_FILE		string	checker.txt		Expected results
-- RESULT_FILE		string	result.txt		Simulation results
-- RESET			[1,0]	0				logic level activity
-- LOAD				[1,0]	1				logic level activity
-- ----------------------------------------------------------------------------
-- REUSE ISSUES
-- Reset Strategy	: Synchronous
-- Clock Domains	: none
-- Critical Timing	: N/A
-- Instantiations	: 1
-- Synthesizable	: No
-- ----------------------------------------------------------------------------
-- LIBRARY & USES
library ieee;
	use	ieee.std_logic_1164.all;
	use ieee.std_logic_textio.all;
library std;
	use	std.textio.all;		
-------------------------------------------------------------------------------
entity rsa_core_tb is
	generic(
		CLK_PERIOD	: time 	:= 20 ns; 
		DATA_FILE	: string:= "stimulus.txt";
        CHECKER_FILE: string:= "checker.txt";
        RESULT_FILE : string:= "result.txt";
		RESET		: std_logic := '0';
		LOAD		: std_logic := '0');
end rsa_core_tb;
-------------------------------------------------------------------------------
architecture testbench of rsa_core_tb is
	-- DUV (Design Under Verification)DECLARATION
	component rsa_core is
--		generic(
--	 		DATA_WIDTH	: integer	:= 8;
--			CLK_EDGE	: std_logic := '1';	
--			RESET		: std_logic := '0';
--			LOAD		: std_logic := '1');
		port (
			core_clk	: in std_logic;
			core_rst	: in std_logic;
			core_load	: in std_logic;
			core_din	: in std_logic_vector(7 downto 0);
			core_done	: out std_logic;
			core_err	: out std_logic;		
			core_dout	: out std_logic_vector(7 downto 0));
	end component;
	
	signal core_clk	: std_logic;                                
	signal core_rst	: std_logic;                                
	signal core_load: std_logic;                                
	signal core_din	: std_logic_vector(7 downto 0);  
	signal core_done: std_logic;                               
	signal core_err	: std_logic;		                             
	signal core_dout: std_logic_vector(7 downto 0);

begin
	-- DUV INSTANTIATION
	duv: rsa_core
--		generic map(
--	 		DATA_WIDTH	=> 8,
--			CLK_EDGE	=> '1',	
--			RESET		=> RESET,
--			LOAD		=> LOAD)
		port map (
			core_clk	=> core_clk,
			core_rst	=> core_rst,
			core_load	=> core_load,
			core_din	=> core_din,
			core_done	=> core_done,
			core_err	=> core_err,
			core_dout	=> core_dout);
		
	-- CLOCK GENERATION
	clock: process
	begin
		core_clk <= '0';
		wait for CLK_PERIOD/2;
		core_clk <= '1';
		wait for CLK_PERIOD/2;
	end process clock;

	-- RESET GENERATION
	rst: process
	begin
		core_rst <= not RESET;
		wait for 5*CLK_PERIOD;
		core_rst <= RESET;
		wait for 2*CLK_PERIOD;
		core_rst <= not RESET;
		wait;
	end process rst;
	
    -- STIMULUS GENERATION
    stimulus: process
    	-- file handle
	    file stimulus_handle	: text open READ_MODE  is DATA_FILE;
		variable line_var		: line;
		variable stimulus_var	: std_logic_vector(7 downto 0);
		
	begin
		core_load	<= not LOAD;
		while not endfile(stimulus_handle) loop
			wait for 20000*CLK_PERIOD;
			-- read text file line
			readline(stimulus_handle, line_var);
			-- convert text string into std_logic_vector 
			read(line_var, stimulus_var);
			-- send data to duv
			core_load <= LOAD;
			core_din <= stimulus_var;			
			wait for CLK_PERIOD;
			-- disable load signal and wait for the next cycle
			core_load	<= not LOAD;
			wait for 10*CLK_PERIOD;

			-- read text file line
			readline(stimulus_handle, line_var);
			-- convert text string into std_logic_vector 
			read(line_var, stimulus_var);
			-- send data to duv
			core_load <= LOAD;
			core_din <= stimulus_var;			
			wait for CLK_PERIOD;
			-- disable load signal and wait for the next cycle
			core_load	<= not LOAD;
			wait for 10*CLK_PERIOD;
			
			-- read text file line
			readline(stimulus_handle, line_var);
			-- convert text string into std_logic_vector 
			read(line_var, stimulus_var);
			-- send data to duv
			core_load <= LOAD;
			core_din <= stimulus_var;			
			wait for CLK_PERIOD;
			-- disable load signal and wait for the next cycle
			core_load	<= not LOAD;
			wait for 10*CLK_PERIOD;			
		end loop;
		wait;
	end process stimulus;
	
	-- CHECKER PROCESS
    checker: process
    	-- file handles
        file checker_handle : text open READ_MODE  is CHECKER_FILE;
        file result_handle  : text open WRITE_MODE is RESULT_FILE;
        
        -- ponteiro para string
        variable line_chk_var   : line;
        variable line_res_var   : line;
        variable checker_var    : std_logic_vector(7 downto 0);
        variable line_cnt_var   : integer := 0;

        variable msg0           : string(79 downto 1) := "-------------------------------------------------------------------------------";
        variable msg1           : string(39 downto 1) := "COMPANY NAME: InPlace Design Automation";
        variable msg2           : string(30 downto 1) := "AUTHOR: Alcides Silveira Costa";
        variable msg3           : string(18 downto 1) := "Simulation Results";
        variable msg4           : string(34 downto 1) := "             Result       Expected";
        variable msg5           : string(17 downto 1) := "End of Simulation";
        
        variable msg6           : string(5 downto 1)  := " === ";
        variable msg7           : string(10 downto 1) := " [PASSED] ";
        variable msg8           : string(5 downto 1)  := " =/= ";
        variable msg9           : string(10 downto 1) := " [FAILED] ";
        
        variable msg10          : string(5 downto 1) := "Test ";
        variable msg11          : string(2 downto 1) := ": ";
        
        
    begin
        -- Format result file header
        write(line_res_var, msg0);
        writeline(result_handle, line_res_var);
        write(line_res_var, msg1);
        writeline(result_handle, line_res_var);
        write(line_res_var, msg2);
        writeline(result_handle, line_res_var);
        write(line_res_var, msg3);
        writeline(result_handle, line_res_var);
        write(line_res_var, msg0);
        writeline(result_handle, line_res_var);
        write(line_res_var, msg4);
        writeline(result_handle, line_res_var);
        -- write result file
        while not endfile(checker_handle) loop
            wait until (core_done = '1');            
            -- read expected result
            readline(checker_handle, line_chk_var);
			-- convert text string into std_logic_vector 
            read(line_chk_var, checker_var);
            -- format data
            line_cnt_var := line_cnt_var + 1;
            write(line_res_var, msg10);            
            write(line_res_var, line_cnt_var, right, 6);
            write(line_res_var, msg11);            
      
            -- compare core result against expect result
            if (checker_var = core_dout) then
                -- PASSED
                write(line_res_var, core_dout);
                write(line_res_var, msg6);          
                write(line_res_var, checker_var);
                write(line_res_var, msg7);
            else
                -- FAILED
                write(line_res_var, core_dout);
                write(line_res_var, msg8);
                write(line_res_var, checker_var);
                write(line_res_var, msg9);
            end if;            
            writeline(result_handle, line_res_var);
            wait until (core_done = '0');
        end loop;
        write(line_res_var, msg0);
        writeline(result_handle, line_res_var);     
        write(line_res_var, msg5);
        writeline(result_handle, line_res_var);     
        file_close(checker_handle);
        file_close(result_handle);
        wait;
    end process checker;
end testbench;