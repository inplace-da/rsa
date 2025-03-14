REM ###########################################################################
REM COMPANY NAME: InPlace Design Automation
REM AUTHOR		: Alcides Silveira Costa
REM ###########################################################################
REM RELEASE HISTORY
REM DATE 			AUTHOR			DESCRIPTION
REM 24-Feb-2025		Alcides			Desing flow adaptation to Windows 7 on a VM
REM									running on Ubuntu 22.04
REM 02-Nov-2009		Alcides			Creation
REM ###########################################################################
REM PURPOSE		: Quartus II design flow automation script
REM REFERENCES	: 
REM [1] Quartus II Scripting Reference Manual, March 2009, v9.0
REM [2] ModelSim Reference Manual, Software Version 6.4a

REM ################################## Lint ##################################
REM Check the specified design file for syntax and semantic errors
quartus_map rsa --analyze_file=vlog/rsa.v    
quartus_map rsa --analyze_file=vlog/rsa_core.v
quartus_map rsa --analyze_file=vlog/rsa_core_mult.v
quartus_map rsa --analyze_file=vlog/rsa_core_mod.v
quartus_map rsa --analyze_file=vlog/rsa_core_ctrl.v
quartus_map rsa --analyze_file=vlog/rsa_io.v
quartus_map rsa --analyze_file=vlog/rsa_io_ctrl.v
quartus_map rsa --analyze_file=vlog/rsa_io_dec.v

REM Check all the design files in a design for syntax and semantic
REM errors, and perform a netlist extraction.
quartus_map rsa --analysis_and_elaboration
