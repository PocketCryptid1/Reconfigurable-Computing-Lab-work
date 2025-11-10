---
title: "Lab 7"
author: "Carter Owens, Kyle Turley"
geometry: margin=2cm
---

## Procedures

**Introduction.** The goal of this lab was to design and implement a VGA controller in VHDL capable of displaying solid colors and a sequence of national flags on a VGA monitor. The project required creating a VGA timing module, a flag display controller, and integrating user input for flag selection.

The procedures for this lab were as follows:

1. Create a Quartus project for the VGA flag viewer
2. Design and implement a VGA timing module to generate correct sync signals and pixel coordinates
3. Implement a flag display controller to output the correct RGB values for each flag
4. Integrate button debouncing for reliable user input
5. Connect the modules and test the system on the FPGA board

Key Requirements:
- Generate correct VGA sync signals for 640x480@60Hz
- Output 12-bit RGB color values to the VGA DAC
- Display a sequence of national flags, selectable by button press
- Debounce user input buttons for flag navigation and reset

**Issues, Errors, and Stumbles.** The first major hurdle we had to overcome was determining which pins we needed to wire to our potentiameter 

## Results

The final implementation met the following requirements:

1. **VGA Timing Generation:**
   - The VGA module generated correct horizontal and vertical sync signals for 640x480@60Hz.
   - Pixel coordinates were correctly output for use by the flag display logic.

2. **Flag Display Controller:**
   - The flag viewer module output the correct RGB values for each flag, with color bands and layouts matching the target designs.
   - Button presses cycled through a sequence of national flags, with a reset button to return to the first flag.

3. **User Interface:**
   - Button debouncing was implemented to ensure reliable flag changes and reset behavior.
   - The system responded smoothly to user input.

4. **System Integration:**
   - The VGA and flag viewer modules were successfully integrated and tested on the FPGA board.
   - The display was stable, and the flag sequence cycled as intended after correcting the top-level module.

## Figures and Code

See appendix for source code

## Conclusion

This lab provided valuable experience in VGA signal generation, color encoding, and modular VHDL design. The main challenge was a project configuration error that set the wrong top-level module, which delayed progress on the flag display logic. Once resolved, the system functioned as intended, and we gained a deeper understanding of both VGA timing and the importance of correct project setup in Quartus.

Key learnings include:
- The importance of careful project configuration and top-level module selection
- VGA timing and color encoding for 640x480@60Hz displays
- Modular VHDL design and integration
- Practical debugging strategies for FPGA projects

## Appendix