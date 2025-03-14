#############################################################################
## RELEASE HISTORY
## VERSION 		DATE 			AUTHOR			DESCRIPTION
## 1.0.0 		02-Nov-2009		Alcides			Creation
## ##########################################################################
## PURPOSE		: Modelsim automation script for functional simulation
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
vlog -work work ../vlog/rsa_core_ctrl.v \
				../vlog/rsa_core_mult.v \
				../vlog/rsa_core_mod.v \
				../vlog/rsa_core.v \
				../vlog/rsa_core_tb.v

# vsim loads a new design into the simulator
# Specify the post-simulation database file name with the -debugDB=<db_pathname>
# argument to the vsim command. If a database pathname is not specified, ModelSim
# creates a database with the file name vsim.dbg in the current working directory.
# This database contains dataflow connectivity information.
# Specify the dataset that will contain the database with -wlf <db_pathname>.
# If a dataset name is not specified, the default name will be vsim.wlf.
# The debug database and the dataset that contains it should have the same base name
#(db_pathname).
# -t [<multiplier>]<time_unit>
# Specifies the simulator time resolution. 
vsim -t 1ns -debugDB=database.dbg -wlf database.wlf work.rsa_core_tb

# The add wave -r /* command instructs ModelSim to save all signal values
# generated when the simulation is run.
add wave -r /*

# The run command advances the simulation by the specified number of timesteps
run 25ms

# Open ModelSim internal editor and show results
edit result.txt





