---
title: "Lab 7"
author: "Carter Owens, Kyle Turley"
geometry: margin=2cm
---

## Procedures

**Introduction.** The goal of this lab was to design and implement a simple ADC system that displays a voltage to the 7-Segment display.

The procedures for this lab were as follows:

1. Create a Quartus project for the ADC 7-Segment display 
2. Create PLL and ADC modules from the IP Catalog
3. Design and implement a ADC module that reads a voltage from header pins
4. Create a simple breadboard design that utilizes the FPGA board header pins
5. Connect the modules and test the system on the FPGA board

Key Requirements:
- Create a potentiometer system that can vary resistance 
- Read the raw voltage values with an ADC
- Send the ADC values to the 7-Segment display

**Issues, Errors, and Stumbles.** The first major hurdle we had to overcome was determining which pins we needed to wire to our potentiometer to the board. We had to read the DE-10 schematic sheet as well as look at the ADC sample project to know for sure where the FPGA will be sending and receiving ADC related signals. Next, had issues when trying to use the ADC component in our project. 

## Results


## Figures and Code

See appendix for source code

## Conclusion


## Appendix