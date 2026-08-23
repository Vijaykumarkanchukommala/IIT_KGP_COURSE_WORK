Implementation of CNN(Convolutional Neural Network).

A CNN relies heavily on matrix multiplication and convolutions.To process an image, a CNN must multiply incoming data inputs (X) by static weight values (W) and sum them up.Therefore, a CNN hardware accelerator is essentially a massive, parallel grid of hundreds or thousands of these MAC units working together simultaneously.

A MAC unit performs two arithmetic operations in a single clock cycle: it multiplies two numbers and adds the result to a running total (an accumulator).
Mathematically, it computes:

  <img width="465" height="45" alt="image" src="https://github.com/user-attachments/assets/a1bb1c93-36f2-4ae5-acac-09312a3b264b" />

Multiplier: Takes inputs A and B and multiplies them.
Adder: Adds the product to the current value stored in the register.
Accumulator Register: A flip-flop or register that holds the running total and updates every clock cycle.


