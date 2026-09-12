# Round-Robin Arbiter

<img src="REFERENCES/rr_concept.jpeg">

# Round-Robin Arbiter Architecture

This repository contains a parameterizable, highly optimized **Round-Robin Arbiter** implemented in SystemVerilog. It utilizes a parallel barrel-shifting mechanism to resolve priority scheduling in a single clock cycle, eliminating slow sequential loops and minimizing critical path delays.

---

## 1. Introduction & Basic Functionality

An **arbiter** manages access to shared resources among multiple competing requestors. A **Round-Robin** scheduling algorithm ensures fairness by rotating priority dynamically. Once a master is granted access, it is moved to the lowest priority tier for the next arbitration cycle, preventing resource starvation.

### Key Features
* **Parameterizable NUM_REQ (`NUM_REQ`)**: Easily scales to any number of requestors (default is 8).
* **Single-Cycle Execution**: Resolves priority combinations instantly using combinatorial bitwise manipulation.
* **No Starvation**: Fair resource distribution via a rotating pointer system.

---

## 2. Dynamic Rules & Allocation Strategy

### Arbitration Priority Rules
1. **Base Priority Pointer (`r_pointer`)**: Points to the requestor currently holding the highest priority.
2. **Ascending Order Evaluation**: Priority decreases from the pointer position going upward, wrapping around at the maximum bit NUM_REQ (`NUM_REQ-1`).
   $$\text{Priority Hierarchy: } r\_pointer \rightarrow (r\_pointer+1) \rightarrow \dots \rightarrow \text{NUM_REQ}-1 \rightarrow 0 \rightarrow \dots \rightarrow (r\_pointer-1)$$
3. **Pointer Upkeep**: If a grant is issued (`|o_grant`), the pointer updates to the index *immediately following* the granted channel. If no requests exist, the pointer maintains its position.



## 🔍 Detailed Execution Walkthrough

To understand the core hardware mechanics, consider a scenario where an 8-bit bus has multiple active requests under a rolling priority pointer.

### **Initial Setup Configuration**
* **Active Requests (`i_req`):** `8'b1010_0100` (Devices **7**, **5**, and **2** are requesting the bus)
* **Current Base Pointer (`r_pointer`):** `3'd3` (Priority rolls downward from index 3 \(\rightarrow\) 4 \(\rightarrow\) 5 \(\rightarrow\) 6 \(\rightarrow\) 7 \(\rightarrow\) 0 \(\rightarrow\) 1 \(\rightarrow\) 2)

---

### **Step 1: Right Circular Shift (`w_req_shift`)**
To align our rolling pointer context directly with the structural LSB (bit 0) of a static priority encoder, the input vector undergoes a dynamic right circular shift.
* **Logic Expression:** `(i_req >> r_pointer) | (i_req << (NUM_REQ - r_pointer))`
* **Evaluation:** `(8'b1010_0100 >> 3) | (8'b1010_0100 << 5)`
* **Resulting Vector:** **`8'b1001_0100`** *(The closest active request from our pointer line is now aligned at internal index 2)*

---

### **Step 2: Fixed Priority Encoding (`w_req_shift_prior`)**
Once aligned, standard fixed-priority rules dictate that the absolute lowest active bit (LSB) wins the cycle. The logic applies a bitwise isolate trick (`A & ~(A-1)`) to zero-out all secondary bits in parallel:
```text
  w_req_shift:         8'b1001_0100
  w_req_shift - 1:     8'b1001_0011
~(w_req_shift - 1):    8'b0110_1100
────────────────────────────────────
  w_req_shift_prior =  8'b0000_0100   <-- Internal Bit 2 Wins
```

---

### **Step 3: Distance Tracking & Pointer Advancement (`r_pointer_inc`)**
The combinatorial loop searches the isolated hot-bit array to record how many slots away the winner was situated relative to the current pointer position.
* **Detected Index (`r_pointer_inc`):** `3'd2` (The winning device sits exactly 2 slots ahead of the base pointer)
* **Next State Update Equation:** `(r_pointer + r_pointer_inc + 1'b1) % NUM_REQ`
* **Next Pointer Output:** `(3 + 2 + 1) = 6` *(The pointer steps immediately beyond the current winner to ensure transaction fairness in the next evaluation phase)*

---

### **Step 4: Left Circular Shift Back (`w_grant`)**
The localized grant vector (`8'b0000_0100`) is still mapped to the temporary execution alignment. It must be rotated left by `r_pointer` to project the signal back onto the correct physical interface wire.
* **Logic Expression:** `(w_req_shift_prior << r_pointer) | (w_req_shift_prior >> (NUM_REQ - r_pointer))`
* **Evaluation:** `(8'b0000_0100 << 3) | (8'b0000_0100 >> 5)`
* **Output Vector (`o_grant`):** **`8'b0010_0000`** *(Device 5 is successfully assigned the bus grant!)*

---

## 📊 Functional Timing Simulation Waveforms

The timing diagram below demonstrates the signal transitions over a clock boundary based on the step-by-step trace conditions described above:

```text
                  __    __    __    __ 
i_clk          __|  |__|  |__|  |__|  |__
               ──────────────────────────
i_req          XX   8'b1010_0100   XXXXXX  (Requests at Bits 7, 5, 2 active)
               ──────────────────────────
r_pointer      XX       3'd3       XX3'd6  (Advances safely past the winner)
               ──────────────────────────
w_req_shift    XX   8'b1001_0100   XXXXXX  (Shifted right to position the pointer)
               ──────────────────────────
w_req_shift_pr XX   8'b0000_0100   XXXXXX  (Isolated LSB winner at local Index 2)
               ──────────────────────────
r_pointer_inc  XX       3'd2       XXXXXX  (Tracks that winner is 2 slots ahead)
               ──────────────────────────
o_grant        XX   8'b0010_0000   XXXXXX  (Shifted left back; Grants Device 5)
```

```text
                +-------------------------------+
                |         i_req [7:0]           |
                +---------------+---------------+
                                |
                                | (Right Circular Shift by r_pointer)
                                v
                +-------------------------------+
                |       w_req_shift [7:0]       |
                +---------------+---------------+
                                |
                                | (LSB-Priority Bitwise Extraction: X & ~(X - 1))
                                v
                +-------------------------------+
                |    w_req_shift_prior [7:0]    |
                +-------+---------------+-------+
                        |               |
   (Find Bit Index)     |               | (Left Circular Shift by r_pointer)
                        v               v
                +---------------+---------------+
                | r_pointer_inc |  w_grant/o_grant [7:0]
                +-------+-------+---------------+
                        |               |
                        |   +-------+   |
                        +-->|   +   |   | (|w_grant / Any Grant Active?)
                            +---+---+   |
                                |       v
                                |   +-------+
       r_pointer (Next Cycle) <--+---| Clock |
                                    +-------+

```

```text
                          Example: r_pointer = 2, i_req = 8'b0010_1000

 i_req[7:0]:             [7]   [6]   [5]   [4]   [3]   [2]   [1]   [0]
                          0     0     1     0     1     0     0     0
                                                          ^ (Current Pointer)
                                      |
                     RIGHT CIRCULAR SHIFT BY r_pointer (2)
                                      v
 w_req_shift[7:0]:       [7]   [6]   [5]   [4]   [3]   [2]   [1]   [0]
                          0     0     0     0     1     0     1     0
                                                          ^ Lowest bit set = Index 1
                                      |
                           FIXED PRIORITY ENCODER
                                      v
 w_req_shift_prior[7:0]: [7]   [6]   [5]   [4]   [3]   [2]   [1]   [0]
                          0     0     0     0     0     0     1     0
                                                          ^ w_req_shift_prior[1] is high
                                      |
                                      +-----------------------+
                                      |                       |
                     LEFT CIRCULAR SHIFT BY r_pointer (2)     | PRIORITY ENCODER INDEX
                                      |                       v
                                      v               r_pointer_inc = 3'd1
 o_grant[7:0]:           [7]   [6]   [5]   [4]   [3]   [2]   [1]   [0]
                          0     0     0     0     1     0     0     0
                                                  ^ Grant awarded to bit 3

                                      |
                          UPDATE POINTER FOR NEXT CYCLE
       Next r_pointer = (r_pointer + r_pointer_inc + 1) % 8 = (2 + 1 + 1) % 8 = 4

```

**Data Flow Breakdown**

* **Right Circular Shift (`w_req_shift`)**: Rotates `i_req` right by `r_pointer` positions so that the current priority start position aligns at bit 0.
* **Priority Encoding (`w_req_shift_prior`)**: Uses `X & ~(X - 1)` to isolate the lowest active bit (LSB) from the shifted perspective.
* **Left Circular Shift (`w_grant`)**: Rotates the isolated grant bit left by `r_pointer` positions to map it back to the original bit position.
* **Offset Calculation (`r_pointer_inc`)**: Detects which index in `w_req_shift_prior` is high, representing how many positions away the winner is from the current pointer.
* **Pointer Update (`r_pointer`)**: Advances the pointer to `(current_pointer + offset + 1) % NUM_REQ` on the next clock edge to ensure fair round-robin arbitration.
