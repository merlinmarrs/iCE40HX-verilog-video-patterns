![bechamel_logo_Plan de travail 1](https://github.com/user-attachments/assets/a3b16d4a-b1e6-4357-a8fe-4a8e616bc0d5)

# Video FPGA Dev Board

A Lattice iCE40HX1K-based FPGA developement board for live-playable video experiments.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![image](https://github.com/user-attachments/assets/bf17c343-4a2a-4723-ada7-5bc602cbb8f3) 


|                          |                          |
:-------------------------:|:-------------------------:
![image](https://github.com/user-attachments/assets/ec43d231-f804-41db-ba54-e15a378fc0b0)  | ![IMG_3808-1024x683](https://github.com/user-attachments/assets/49c9bb74-0dcc-44ab-9191-4f8257c90dd5)




# Features :

- 9-key mechanical button interface
- Relatively low-cost, single board design
- HDMI and VGA out
- Reverse polarity and fuse protection

# Minimal BOM :

[Excel BOM Mouser / Digikey ](https://github.com/merlinmarrs/iCE40HX-verilog-video-patterns/tree/main/PCB%20files)

- 9x Mechanical keyboard keys
- 1x FPGA iCE40HX1K-TQ144
- 1x 100MHz clock oscillator
- 1x SRAM 2Mb 256Kx8
- 1x Flash N25Q032A13ESC40F
- 1x USB-C SMD 6 pin connector
- 1x 3.3V reg TLV73333PDBVT 
- 1x 1.2V reg TLV73312PDBVT
- 1x PFET
- 1x Resettable Fuse
- 1x D-SUB 15 connector
- 1x HDMI Connector 
- 50x 0.1µF capacitor 0805
- 50x  10kΩ, 1.8kΩ, 1kΩ, 470Ω, 270Ω, 120Ω resistors 0805
- 5x LEDs 0805
- 2x Dual-row headers

optional extras : (1x Raspberry Pi Zero, 1x Micro SD holder, 2x 10kΩ potentiometers, 1x fast op-amp, 1x 3.5mm audio jack, 1x dual SMD dip switch, 1x SMD pushbutton)


# PCB files

[KiCAD and Eagle PCBs](https://github.com/merlinmarrs/iCE40HX-verilog-video-patterns/tree/main/PCB%20files)

![open_source](https://github.com/user-attachments/assets/3fbdfb6a-2741-4e5c-9634-7913a16e93b9) 


# HDL files

[Verilog, Pin constraints, and synthesized binaries ](https://github.com/merlinmarrs/iCE40HX-verilog-video-patterns/tree/main/verilog)

To compile and upload files :

[Yoysis Open-source Toolchain ](https://github.com/YosysHQ/yosys)

![image](https://github.com/user-attachments/assets/e97e0af4-468f-498d-b59e-337a35ea7318)


[iCEcube2 Toolchain](https://www.latticesemi.com/iCEcube2)

![image](https://github.com/user-attachments/assets/38ef87e1-ef5c-4168-aa9f-647281c609ce)



## Acknowledgements

Mike Field <hamster@snap.net.nz> for his minimalDVID_encoder.vhd : A quick and dirty DVI-D implementation

OLIMEX FPGA dev board https://github.com/OLIMEX/iCE40HX1K-EVB/tree/master

ALHAMBRA FPGA https://github.com/FPGAwars/Alhambra-II-FPGA/tree/master

HDL Bits https://hdlbits.01xz.net/wiki/Main_Page

