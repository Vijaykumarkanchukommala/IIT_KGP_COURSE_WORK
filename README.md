<h1> Implementation of CNN(Convolutional Neural Network) </h1>

A CNN relies heavily on matrix multiplication and convolutions.To process an image, a CNN must multiply incoming data inputs (X) by static weight values (W) and sum them up.Therefore, a CNN hardware accelerator is essentially a massive, parallel grid of hundreds or thousands of these MAC units working together simultaneously.

<img src="REFERENCES/images/cnn_example.png" alt="App Screenshot" >

<h2> AI is Just Massive Matrix Multiplication </h2>
At a mathematical level, AI models (like ChatGPT, Stable Diffusion, or CNNs) do not "think." They perform billions of dot products and matrix multiplications.
To calculate a single output neuron, the chip must multiply dozens of inputs by dozens of trained "weights" and add them all together.
Because a MAC unit multiplies and accumulates in a single step, it is perfectly optimized for this exact math.

<h2>The Core of Convolutional Layers (CNNs)</h2>
In image-processing AI (CNNs), a small matrix called a "kernel" slides across an image to detect edges, shapes, and objects. At every single pixel, the hardware performs a Multiply-Accumulate operation.3. Pipelining for Extreme SpeedIn your SystemVerilog RTL design, MAC units are arranged in grids called Systolic Arrays or Vector Processing Units.Data flows through these arrays like water through pipes.One MAC unit passes its result directly to the next one, allowing the AI chip to compute trillions of operations per second (TOPS) while saving massive amounts of power.

<img src="REFERENCES/images/cnn.png" alt="App Screenshot" width="500">



A MAC unit performs two arithmetic operations in a single clock cycle: it multiplies two numbers and adds the result to a running total (an accumulator).
Mathematically, it computes:

<img width="465" height="45" alt="image" src="https://github.com/user-attachments/assets/a1bb1c93-36f2-4ae5-acac-09312a3b264b" />

Multiplier: Takes inputs A and B and multiplies them.
Adder: Adds the product to the current value stored in the register.
Accumulator Register: A flip-flop or register that holds the running total and updates every clock cycle.
<img src="REFERENCES/images/mac_parallel.png" alt="App Screenshot" width="500">

<h3>Implemented items so far:</h3>
<ol>
<li>Initial parallel/sequential MAC</li>
<li>Addr</li>
<li>RAM</li>
</ol>


