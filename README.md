# The RSA Coprocessor
This repository contains the HDL code of an RSA coprocessor. The design was developped in older technologies and it is being ported to newer EDA tools and technologies.

## Design Software Compatibility
The design environment of the RSA project originally runs on Windows XP. However, the working version of this project is running on a Windows 7 VM on VirtualBox 7.1, with the host OS being Ubuntu 22.04. In order to run the RSA design on this environment, beside the Windows 7, you will require the following updates for the FPGA design software to run: KB976932, KB2533552, KB3020369, KB3125574, and KB3102433. These packages can be downloaded from the [Microsoft Update Catalog](https://catalog.update.microsoft.com/home.aspx).

After configuring the OS requirements, install the following design softwares:

1. ModelSim-Altera 6.4.a Stater Edition
2. Altera Quartus II 9.0 SP2
3. GitHub Desktop v3.2.6
4. Git for Windows v2.46.2-64

Use these exact versions if you want to make the design flow scripts run smoohly.

## Running the Design Environment

<pre>
  TODO
</pre>


## A Brief Timeline of the of this Work
The core of the RSA coprocessor was originally developped in June 2004 as part of the undergraduate thesis of Alcides Silveira Costa at the Institut Nationale Polytechnique de Grenoble (INPG). The core is based on the montgomery modular multiplication algorithm and it implements a pipelined-based architecture. In February 2005, the core was enhanced as part of the undergraduate thesis at the Universidade Federal do Rio Grande do Sul and became an scalable RSA coprocessor [^1]. Later on, in 2013, the design was again enhanced as part of a training course provided by the consultancy company Engineers at Work [^2] where Mr. Costa was one of the proprietaries. In the part 2 of this training, the RSA coprocessor was implemented on two different FPGA boards: one using the Xilinx Spartan 3 FPGA (xc3s200) and another using the ALTERA Cyclone II (EP2C20F484C7) device. Engineers at work ceased its operations in 2013, and the RSA coprocessor remained unpuslished since then.

In February 2025, almost 20 years later, Alcides Silveira Costa, now co-founder of InPlace Design Automation, publish the RSA coprocessor in Github with the intent to port it to newer EDA tools and design flows including the [Pitanga Virtual Board](https://www.inplace-da.com/).


[^1]: COSTA, Alcides Silveira Costa. Implementação de um co-processador RSA. 2005. Undergraduate Thesis
(Undergraduation in Computer Engineering) – Instituto de Informática, Universidade Federal do Rio Grande
do Sul, Porto Alegre, 2005. Available on: https://lume.ufrgs.br/handle/10183/173691. Accessed on February 28, 2025.
[^2]: COSTA, Alcides Silveira Costa. Fundamentos de VHDL em Lógica Programável v1.1. 2013. https://www.slideshare.net/slideshow/fundamentos-de-vhdl-em-lgica-programvel-v11/75871796. Accessed on February 28, 2025.


