---
title: "Lab 2"
author: "Carter Owens, Kyle Turley"
geometry: margin=2cm
---

## Procedures

### Introduction

The goal of this lab is to design, implement, and test a Stopwatch. constraints for this lab is to utilize the 50MHz internal clock and have the stopwatch track within a 100th of a second. we also cannot use a clock divider.

The procedures for this lab are as follows\

1. Create a Quartus project using the System Builder application

2. Create an initial implementation of the stopwatch

3. Create a testbench to test the ten-bit counter & verify correct behavior

4. Compile and load the counter onto the FPGA for visual confirmation

### Issues and Errors

we continued to have issues with questa and the waveform not updating in the waveform viewer.

### Stumbles

## Results

*Refer to Figure 1 and 2 for details of implementation* we first used an internal counter to convert the 50 MHz clock to count 100ths of a second, we then created a module that converts a binary number into a seven segment output.

## Figures

![Stopwatch VHDL Code](IMAGE_NAME.png "Stopwatch VHDL Code")

![Testbench Code](IMAGE_NAME.png "Testbench Code")

![Questa Simulation](IMAGE_NAME.png "Questa Simulation")
