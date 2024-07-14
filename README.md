# Béchamel Live-Playable Video FPGA Dev Board

A Lattice iCE40HX1K-based **FPGA Dev Board** geared towards DIYers and artists for **live-playable video experiments**.

| ![image](https://github.com/user-attachments/assets/bf17c343-4a2a-4723-ada7-5bc602cbb8f3) | ![open_source](https://github.com/user-attachments/assets/3fbdfb6a-2741-4e5c-9634-7913a16e93b9) |

| ![image](https://github.com/user-attachments/assets/ec43d231-f804-41db-ba54-e15a378fc0b0) | ![image](https://github.com/user-attachments/assets/5524e9eb-a8dd-4333-9468-72597a95a8ff) |


# About the Béchamel :

Developed to be a fun video synthesis device to either modify a video stream or generate simple reactive patterns.

Béchamel started off as a discrete logic chip synth device and has since evolved into a more flexible FPGA platform.


# Features :

- Tangible, playable mechanical button interface
- Relatively low-cost, single board design
- HDMI and VGA out
- Reverse polarity and fuse protection

# Minimal BOM :
- 1x PCB
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


# HARDWARE BUILD INSTRUCTIONS

**Option #0 : PCB Fab+Assembly**

**Option #1 : Stencil + PCB oven**

**Option #2 : Hand soldering (with flux)**

# SOFTWARE BUILD INSTRUCTIONS

**Option #1 : Open-source Toolchain**

[Yoysis](https://github.com/YosysHQ/yosys)

**Option #2 : IceCube2 Toolchain**

[iCEcube2](https://www.latticesemi.com/iCEcube2)

- Request a licence by email
- Install iCEcube2 and Diamond Programmer
- Start a new project, load verilog files(.v) and pin constraints (.pcf)
- Upload binary file to flash memory

## License

MIT

## Contributors
