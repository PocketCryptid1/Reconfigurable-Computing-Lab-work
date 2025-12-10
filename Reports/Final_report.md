---
title: "Final Project"
author: "Carter Owens, Kyle Turley"
geometry: margin=2cm
---

## Procedures

**Introduction.** The goal of this lab was to design and implement a tetris style game on the DE10-Lite Board.

The procedures for this lab were as follows:

1. Create a Quartus project
1. Design and implement a graphics module that draws on the screen.
2. Create a simple breadboard design that holds the push buttons and buzzer
3. Create the game logic
4. test the system

Key Requirements:
- game functions as described in the requirements document
- the game board draws properly on the display
  
**Issues, Errors, and Stumbles.** 
we had very few issues with creating the graphics module, however the game logic led to several unforeseen issues, clearing pieces and falling pieces were incredibly difficult to implement and led to several headaches and missteps.
we encountered several issues with dropping inputs and overcorrections, the animations did not play correctly, the piece clearing had several problems.

## Results

we were able to create a somewhat functional final project, the core ideas are implemented however there are quite a few bugs we were unable to track down. first, the movement was inconsistent, sometimes it would drop inputs or move multiple times for a single input. second, the clearing algorithm had several bugs, it would only clear blocks after the next block landed, it also would clear extra blocks that were not supposed to clear, finally the sound was not functioning perfectly, it did generate 4 different tones, however it played the tones constantly, we attempted to resolve these bugs, but we ran out of time and frankly were too mentally and emotionally drained to continue searching, the codebase was a mess of attempted patches and fixes that neither of us understood anymore.


## Conclusion

in this lab, we attempted to create a tetris style game, it led to several issues and frustrations, however it was very informative, especially with the creation of the graphics stack. 
we also learned a lot about the intricacies of state machines


