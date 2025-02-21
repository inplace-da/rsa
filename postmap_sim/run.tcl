#############################################################################
## COMPANY NAME	: Engineers at Work
## AUTHOR		: Alcides Silveira Costa
## AUTHORS EMAIL: alcides@engineersatwork.com.br
#############################################################################
## RELEASE HISTORY
## VERSION 		DATE 			AUTHOR			DESCRIPTION
## 1.0.0 		02-Nov-2009		Alcides			Creation
## ##########################################################################
## PURPOSE		: Modelsim automation script for gate-level simulation (cell)
## REFERENCES	: 
## [1] ModelSim User’s Manual, Software Version 6.4a
## [2] ModelSim Reference Manual, Software Version 6.4a


# Comands in script file are echoed to the transcript pane as they are executed
transcript on

# deletes all desing units from the specified library if it exists
if {[file exists work]} {
	vdel -lib work -all
}

# creates new design/logical library
vlib work

# defines a mapping between a logical library name and a directory
vmap work work

# vcom compiles VHDL design units
# The vcom command compiles VHDL source code into a specified working library
# (or to the work library by default).
# -work <library_name>
# Specifies a logical name or pathname of a library that is to be mapped to the
# logical library work.
vcom -93 -work work ../postmap_files/rsa_core.vho \
					../vhdl/rsa_core_tb.vhd

# vsim loads a new design into the simulator
# -t [<multiplier>]<time_unit>
# Specifies the simulator time resolution. 
# -sdfmin | -sdftyp | -sdfmax[@<delayScale>] [<instance>=]<sdf_filename>
# Annotates VITAL or Verilog cells in the specified SDF file (a Standard Delay
# Format file) with minimum, typical, or maximum timing. Optional.
vsim -t ps -sdftyp /rsa_core_tb/duv=../postmap_files/rsa_core_vhd.sdo \
	work.rsa_core_tb(testbench)					

# The add wave -r /* command instructs ModelSim to save all signal values
# generated when the simulation is run.
add wave -r /*

# The run command advances the simulation by the specified number of timesteps
run 25ms

# Open ModelSim internal editor and show results
edit result.txt
