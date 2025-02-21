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
quartus_map rsa --analyze_file=vhdl/rsa.vhd       
quartus_map rsa --analyze_file=vhdl/rsa_core.vhd
quartus_map rsa --analyze_file=vhdl/rsa_core_mult.vhd
quartus_map rsa --analyze_file=vhdl/rsa_core_mod.vhd
quartus_map rsa --analyze_file=vhdl/rsa_core_ctrl.vhd
quartus_map rsa --analyze_file=vhdl/rsa_io.vhd
quartus_map rsa --analyze_file=vhdl/rsa_io_ctrl.vhd
quartus_map rsa --analyze_file=vhdl/rsa_io_dec.vhd

REM Check all the design files in a design for syntax and semantic
REM errors, and perform a netlist extraction.
quartus_map rsa --analysis_and_elaboration

REM ###################### Funtional Simulation ##############################
cd func_sim
vsim -do run.tcl
cd ..

REM ################################ Synthesis ################################
REM Maps design files (VHDL files) to the target specific cells (technology
REM mapping). Do not write the .qsf file (--write_settings_files=off option)
quartus_map rsa --write_settings_files=off

REM Timing analysis. These estimated timing delays are primitive results,
REM which are not as accurate as the results obtained by running the Timing
REM Analyzer based on results from the Fitter.
quartus_tan rsa --post_map --zero_ic_delays

REM Generate post-map files (VHDL) for simulation on ModelSim Altera
quartus_eda rsa --simulation=on --output_directory=postmap_files --write_settings_files=off

REM ###################### Postmap Simulation ################################
REM cd postmap_sim
REM #vsim -do run.tcl
REM cd ..

REM ############################## Place & Route #############################
REM Places and routes the design.
quartus_fit rsa --write_settings_files=off

REM Timing analysis (batch mode)
quartus_sta rsa

REM Generating a Post-Fit Simulation Netlist for ModelSim Altera
quartus_eda rsa --simulation=on --output_directory=postfit_files --write_settings_files=off

REM ###################### Postfit Simulation ################################
REM cd postfit_sim
REM Run Slow Model Simulation
REM vsim -do run_slow.tcl
REM Run Fast Model Simulation
REM vsim -do run_fast.tcl
REM cd ..

REM ###################### Timing Analysis ###################################
REM Timing analysis (gui mode)
quartus_staw rsa

REM ############################ Assembly ####################################
REM Generates a device programming image, in the form of one or more
REM Programmer Object Files (.pof), SRAM Object Files (.sof), Hexadecimal
REM (Intel-Format) Output Files (.hexout), Tabular Text Files (.ttf), and
REM Raw Binary Files(.rbf), from a successful fit (that is, place and route).
quartus_asm rsa --write_settings_files=off

REM ############################ Program #####################################
REM programs altera devices on JTAG mode. The Programmer uses the 
REM SRAM Object Files (.sof) file format.
REM quartus_pgm -c USB-Blaster -m JTAG -o p;rsa.sof

REM programs altera devices on Active Serial mode. The Programmer uses the 
REM Programmer Object Files (.pof) file format. 
REM quartus_pgm -c USB-Blaster -m AS -o pv;rsa.pof
