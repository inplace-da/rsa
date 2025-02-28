# The RSA Coprocessor
This repository contains the HDL code for an RSA coprocessor. The design was developed using older technologies and is currently being ported to newer EDA tools and technologies.

## Design Environment Installation
The design environment of this project originally runs on Windows XP. However, the current version runs on a Windows 7 (64-bit) virtual machine using VirtualBox 7.1. In order to run the RSA design in this environment, besides Windows 7, you will require the following updates for the design software to work properly: KB976932, KB2533552, KB3020369, KB3125574, and KB3102433. These packages can be downloaded from the [Microsoft Update Catalog](https://catalog.update.microsoft.com/Home.aspx).

After installing the Windows 7 packages, you need to install the following design software and applications:

1. ModelSim-Altera 6.4.a Stater Edition
2. Altera Quartus II 9.0 SP2
3. Firefox 115.20 ESR
4. GitHub Desktop v3.2.6
5. Git for Windows v2.46.2

> Use these exact versions if you want to make the design flow scripts and git commands to run smoohly.

## Running the Design Environment

You can clone the design enviroment using the Windows Command Prompt (cmd.exe). Follow the steps below:

1. Create the workspace and clone the RSA design environment
```
  mkdir workspaces
  cd workspaces
  git clone https://github.com/inplace-da/rsa.git inplace-rsa
```
2. Check if the HDL and Quartus II design software installation
```
  cd inplace-rsa
  run_elaboration.bat
```
> The **run_elaboration.bat** uses the Quartus II linter to check the HDL file syntax
3. Run a functional simulation using ModelSim
```
  run_func_simulation.bat
```
> The **run_func_simulation.bat** script compiles the design code. At the end of the script, the following screen must be diplayed.
![image](https://github.com/user-attachments/assets/dd26ec5e-fd05-499f-ab79-91d87b4431d8)
4. Additionally, you can run the complete Quartus II flow by running the run_all script. This complete flow runs functional simulation (ModelSim), timing simulation (ModelSim), static timing analisys (Quartus Timing), synthesis, mapping and assembly (Quartus II).
```
  run_all.bat
```

**Done!** The RSA coprocessor design environment is up and running. Please note that this environment uses older tools and is no longer supported. The instructions are kept here for record purposes until a newer design environment by ready to use.

## Historical Overview of the Project

The core of the RSA coprocessor was originally developed in June 2004 as part of Alcides Silveira Costa's undergraduate thesis at the Institut National Polytechnique de Grenoble (INPG). The core is based on the Montgomery modular multiplication algorithm and implements a pipelined-based architecture.

In February 2005, the core was enhanced during an undergraduate thesis at the Universidade Federal do Rio Grande do Sul, becoming a scalable RSA coprocessor [^1]. Later, in 2013, the design was further enhanced as part of a training course provided by the consultancy company Engineers at Work [^2], where the RSA coprocessor was implemented on two different FPGA boards: one using the Xilinx Spartan 3 FPGA (xc3s200) and another using the ALTERA Cyclone II (EP2C20F484C7) device. Mr. Costa was one of the founders of Engineers at Work, which ceased its operations in 2013. The RSA coprocessor remained unpublished since then.

In February 2025, nearly 20 years later, Mr. Costa, now co-founder of InPlace Design Automation, published the RSA coprocessor on GitHub. The intent of this projeft is to migrate the RSA coprocessor to newer EDA tools and prototyping boards, including the [Pitanga Virtual Board](https://www.inplace-da.com/).

[^1]: COSTA, Alcides Silveira Costa. Implementação de um co-processador RSA. 2005. Undergraduate Thesis
(Undergraduation in Computer Engineering) – Instituto de Informática, Universidade Federal do Rio Grande
do Sul, Porto Alegre, 2005. Available on: https://lume.ufrgs.br/handle/10183/173691. Accessed on February 28, 2025.
[^2]: COSTA, Alcides Silveira Costa. Fundamentos de VHDL em Lógica Programável v1.1. 2013. https://www.slideshare.net/slideshow/fundamentos-de-vhdl-em-lgica-programvel-v11/75871796. Accessed on February 28, 2025.
