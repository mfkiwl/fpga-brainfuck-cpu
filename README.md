# Braninfuck CPU for FPGA

This repository contains a source code and desing of the CPU processing the Brainfuck code in FPGA. 

* Development board [CYC1000](https://shop.trenz-electronic.de/en/Products/Trenz-Electronic/CYC1000-Intel-Cyclone-10/)
* Languages - VHDL, Bluespec

You can use the [Bluespec Compiler Docker](https://github.com/benycze/bsc-docker-container) for the translation of the Bluespec code if you don't want to install it inside your live system.

The project is using the following open-source libraries:

* <https://github.com/jakubcabal/uart-for-fpga> - project with the implementation of the UART module which allows communication between PC and FPGA core
* <https://github.com/kevinpt/vhdl-extras/blob/master/rtl/extras/synchronizing.vhdl> - project with helping componets (mainly used the library for data synchronization across clock domains)

To clone the repository, run:

```bash
git clone --recursive https://github.com/benycze/fpga-brainfuck
```

## Structure of the project

The project contains following folders:

* _board_  - HDL desing and Quartus project
* _sw_ - Software for communication and synthesis and translation of Brainfuck program

## How to translate the code

TODO

## How to translate and upload the code

TODO
