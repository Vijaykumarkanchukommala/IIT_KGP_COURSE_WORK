# Round-Robin Arbiter with Barrel-Shifter Architecture

This repository contains a parameterizable, highly optimized **Round-Robin Arbiter** implemented in SystemVerilog. It utilizes a parallel barrel-shifting mechanism to resolve priority scheduling in a single clock cycle, eliminating slow sequential loops and minimizing critical path delays.

---

## 1. Introduction & Basic Functionality

An **arbiter** manages access to shared resources among multiple competing requestors. A **Round-Robin** scheduling algorithm ensures fairness by rotating priority dynamically. Once a master is granted access, it is moved to the lowest priority tier for the next arbitration cycle, preventing resource starvation.

### Key Features
* **Parameterizable Width (`WIDTH`)**: Easily scales to any number of requestors (default is 8).
* **Single-Cycle Execution**: Resolves priority combinations instantly using combinatorial bitwise manipulation.
* **No Starvation**: Fair resource distribution via a rotating pointer system.

---

## 2. Dynamic Rules & Allocation Strategy

### Arbitration Priority Rules
1. **Base Priority Pointer (`r_pointer`)**: Points to the requestor currently holding the highest priority.
2. **Ascending Order Evaluation**: Priority decreases from the pointer position going upward, wrapping around at the maximum bit width (`WIDTH-1`).
   $$\text{Priority Hierarchy: } r\_pointer \rightarrow (r\_pointer+1) \rightarrow \dots \rightarrow \text{WIDTH}-1 \rightarrow 0 \rightarrow \dots \rightarrow (r\_pointer-1)$$
3. **Pointer Upkeep**: If a grant is issued (`|o_grant`), the pointer updates to the index *immediately following* the granted channel. If no requests exist, the pointer maintains its position.

### Logical Flow Diagram

Save your flowchart image as `flowchart.png` in your repository folder and it will render perfectly below:

<img src="REFERENCES/flow_chart.ijg">

---

## 3. Data-Path Execution Matrix

To visualize how the hardware handles wrapping arrays without state machines, trace this 8-bit allocation matrix scenario:

* **Current Pointer (`r_pointer`)**: `3` (Meaning Channel 3 has top priority)
* **Incoming Requests (`i_req`)**: `8'b1010_1000` (Requests active on channels 3, 5, 7)

| Signal Name | Width | Binary / Vector Value | Operational Explanation |
| :--- | :--- | :--- | :--- |
| **`i_req`** | 8 | `1010_1000` | Input requests from clients. |
| **`w_req_frame`** | 16 | `1010_1000_1010_1000` | Concatenation `{i_req, i_req}` to handle wrap-around loop. |
| **`w_req_fram_shift`** | 16 | `0001_0101_0001_0101` | Right-shifted by `r_pointer` (3). Brings highest priority bit to index `0`. |
| **`w_req_fram_shift_prior`** | 16 | `0000_0000_0000_0001` | Bitwise Priority Isolation: `A & ~(A - 1)`. Isolates lowest active bit. |
| **`w_grant_shift`** | 8 | `0000_0001` | Lower `WIDTH` chunk isolated. This maps back to the grant in shifted space. |
| **`w_grant_frame`** | 16 | `0000_1000_0000_0000` | Left shifted back by `r_pointer` (3) to original grid space. |
| **`o_grant`** | 8 | `0000_1000` | Sliced from upper half. **Channel 3 safely receives the grant**. |

---

## 4. In-Depth RTL Code Explanation

This section breaks down the physical hardware synthesis of the SystemVerilog implementation.

### 4.1 Interface and Parameters
```systemverilog
parameter int WIDTH = 8
```
Defines total arbitration slots. `localparam POINTER_INC_WIDTH = $clog2(WIDTH);` calculates the exact register bit-width needed to store binary indices.

### 4.2 Array Mirroring and Dynamic Translation
```systemverilog
assign w_req_frame = {i_req, i_req};
assign w_req_fram_shift = w_req_frame >> r_pointer;
```
By mirroring `i_req` into a double-length bus, requests that wrap past the maximum index boundary are effortlessly captured on a linear array. Shifting right by `r_pointer` moves the current highest-priority channel directly down to index `0`.

### 4.3 Combinatorial Priority Isolation
```systemverilog
assign w_req_fram_shift_prior = w_req_fram_shift & ~(w_req_fram_shift - 1);
```
This is an optimized hardware trick for detecting the **Least Significant Bit (LSB)**:
* Subtracting `1` from a binary string flips all bits up to and including the lowest set bit.
* Performing a bitwise `NOT` (`~`) on that value restores those bits to their original state, while clearing everything else.
* A bitwise `AND` (`&`) isolates only the first asserted request in priority order.

### 4.4 Spatial Reverse-Translation
```systemverilog
assign w_grant_shift = w_req_fram_shift_prior[WIDTH-1:0]; 
assign w_grant_frame = {w_grant_shift, w_grant_shift} << r_pointer;
assign o_grant       = w_grant_frame[WIDTH+:WIDTH];
```
After isolating the single granted channel in the shifted domain, the vector is duplicated and shifted back left by `r_pointer` to return it to its true coordinate space. Slicing the upper `WIDTH` block (`[WIDTH+:WIDTH]`) extracts the final safe grant vector.

### 4.5 Pointer Increment and Priority Update
```systemverilog
always @(*) begin
  r_pointer_inc = {POINTER_INC_WIDTH{1'b0}};
  for(grant_i = 0; grant_i < WIDTH; grant_i = grant_i + 1) begin
    if(w_grant_shift[grant_i]) begin
      r_pointer_inc = grant_i[POINTER_INC_WIDTH-1:0];
    end
  end
end
```
A combinatorial loop locates which offset index inside `w_grant_shift` was awarded the resource. This index translates directly to the variable offset value `r_pointer_inc`.

```systemverilog
always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
        r_pointer <= {POINTER_INC_WIDTH{1'b0}};
    end else if (|o_grant) begin
        r_pointer <= r_pointer + r_pointer_inc + 1'd1;
    end
end
```
On the next rising clock edge, if any grant was generated (`|o_grant`), the pointer increments to `r_pointer + r_pointer_inc + 1`. This pushes the channel that just received a grant to the very bottom of the priority stack for the next round.

