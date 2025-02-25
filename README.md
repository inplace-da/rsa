# How to Setup de Design Enviroment
This repository contains HDL and design files for implementing a scalable RSA coprocessor on the Pitanga Virtual Board.

## Software Compatibility
The design environment of the RSA project originally runs on Windows XP. However, this version migrates the original project to a Windows 7 VM on VirtualBox 7.1, with the host OS being Ubuntu 22.04.

The Windows 7 configuration requires the following updates for the FPGA design software to run: KB976932, KB2533552, KB3020369, KB3125574, and KB3102433. These packages can be downloaded from the [Microsoft Update Catalog](https://catalog.update.microsoft.com/home.aspx).

After configuring the OS requirements, install the following design softwares:

1. ModelSim-Altera 6.4.a Stater Edition
2. Altera Quartus II 9.0 SP2
3. GitHub Desktop v3.2.6
4. Git for Windows v2.46.2-64

Use the exact version if you want to make the design flow scripts run smoohly.

## Running the Design Environment
