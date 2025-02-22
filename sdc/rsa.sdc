###########################################################################
# COMPANY NAME	: InPlace Design Automation
# AUTHOR		: Alcides Silveira Costa
###########################################################################
# RELEASE HISTORY
# DATE 			AUTHOR			DESCRIPTION
# 24-Feb-2025		Alcides			Desing flow adaptation to Windows 7 on a VM
#									running on Ubuntu 22.04
# 02-Nov-2009		Alcides			Creation
# ##########################################################################
# PURPOSE		: Modelsim automation script for gate-level simulation (cell)
# REFERENCES	: 
# [1] Quartus II TimeQuest Timing Analyzer Cookbook, August 2008
# [2] SDC and TimeQuest API Reference Manual, March 2009, v4.0
# [3] TimeQuest Timing Analyzer: Native SDC Support for Timing Analysis of
# FPGA-Based Designs, White Paper, May 2006, v1.0

###############################################################################
# Global Settings

# clock period in nanoseconds
set TCLK 20.0
# clock jitter in nanosenconds
# Aging: ±5 ppm per year max
# Frequency Stability (0°C to +70°C): ±100 ppm
# Total Jitter (10 years): 10*5ppm + 100ppm = 150ppm
set JITTER [expr 150.0*($TCLK/1000000.0)]

###############################################################################
# Core Constraints

# Defines a clock. Period in nanoseconds.
create_clock -name rsa_clk_obj -period $TCLK [get_ports {rsa_clk}]

# Specifies the clock uncertainty on the clock network (Jitter). Use -setup
# to avoid jitter being counted on hold checks.
set_clock_uncertainty -setup -from [get_clocks {rsa_clk_obj}] -to  \
	[get_clocks {rsa_clk_obj}] $JITTER

# Specifies clock latency for a given clock or clock target.
# There are two types of latency: network and source. Network latency is the
# clock network delay between the clock and register clock pins. Source
# latency is the clock network delay between the clock and its source
# (e.g., the system clock or base clock of a generated clock).
set_clock_latency -source -early 0.35 [get_clocks {rsa_clk_obj}]
set_clock_latency -source -late  0.37 [get_clocks {rsa_clk_obj}]

###############################################################################
# Input to Core Settings

# This Tco is the min/max value of the Tco for the external module.
set Tco_max 2.0
set Tco_min 1.75
# Td is the min/max trace delay of datain from the external device
set Td_min 1.1
set Td_max 1.3
# Calculate the input delay numbers
set input_min [expr $Td_min + $Tco_min]
set input_max [expr $Td_max + $Tco_max]

create_clock -name vrsa_clk_source -period $TCLK
# Specifies the clock uncertainty on the clock network (Jitter). Use -setup
# to avoid jitter being counted on hold checks.
set_clock_uncertainty -setup -from [get_clocks {vrsa_clk_source}] \
	-to  [get_clocks {vrsa_clk_source}] $JITTER

set_clock_latency -source -early -rise 0.32 [get_clocks {vrsa_clk_source}]
set_clock_latency -source -late -rise  0.34 [get_clocks {vrsa_clk_source}]
set_input_delay -clock [get_clocks {vrsa_clk_source}] -min $input_min [get_ports {rsa_din*}]
set_input_delay -clock [get_clocks {vrsa_clk_source}] -max $input_max [get_ports {rsa_din*}]
set_input_delay -clock [get_clocks {vrsa_clk_source}] -min $input_min [get_ports rsa_load]
set_input_delay -clock [get_clocks {vrsa_clk_source}] -max $input_max [get_ports rsa_load]
set_input_delay -clock [get_clocks {vrsa_clk_source}] -min $input_min [get_ports rsa_rst]
set_input_delay -clock [get_clocks {vrsa_clk_source}] -max $input_max [get_ports rsa_rst]

###############################################################################
# Core to Output Settings

# This Tsu/Th is the value of the Tsu/Th for the external device.
set Tsu 2.8
set Th 0.1
# This is the min/max trace delay of dataout to the external device.
set Td_min 1.2
set Td_max 1.4
# Calculate the output delay numbers
set output_max [expr $Td_max + $Tsu]
set output_min [expr $Td_min - $Th]

create_clock -name vrsa_clk_dest -period $TCLK
# Specifies the clock uncertainty on the clock network (Jitter). Use -setup
# to avoid jitter being counted on hold checks.
set_clock_uncertainty -setup -from [get_clocks {vrsa_clk_dest}] \
	-to  [get_clocks {vrsa_clk_dest}] $JITTER

set_clock_latency -source -early -rise 2.3 [get_clocks {vrsa_clk_dest}]
set_clock_latency -source -late  -rise 2.4 [get_clocks {vrsa_clk_dest}]
set_output_delay -clock [get_clocks {vrsa_clk_dest}] -min $output_min [all_outputs]
set_output_delay -clock [get_clocks {vrsa_clk_dest}] -max $output_max [all_outputs]

# Reference: SDC and TimeQuest API Reference Manual, March 2009, v4.0
