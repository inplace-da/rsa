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

REM ###################### Funtional Simulation ##############################
cd func_sim
vsim -do run.tcl
cd ..
