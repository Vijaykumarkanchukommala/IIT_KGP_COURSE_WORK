# ADDER
<img src="../REFERENCES/images/half_full_adder.png">

## Half ADDER

### Truth table

| Input A | Input B | Carry (C) | Sum (S) |
| :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 |
| 1 | 1 | 1 | 0 |

## Full ADDER

### Truth table

| Input A | Input B | Carry In ($C_{in}$) | Carry Out ($C_{out}$) | Sum (S) |
| :---: | :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 | 1 |
| 0 | 1 | 0 | 0 | 1 |
| 0 | 1 | 1 | 1 | 0 |
| 1 | 0 | 0 | 0 | 1 |
| 1 | 0 | 1 | 1 | 0 |
| 1 | 1 | 0 | 1 | 0 |
| 1 | 1 | 1 | 1 | 1 |

## Ripple carry adder
<img src="../REFERENCES/images/ripple_carry_adder.png">

## Carry look ahead adder
<img src="../REFERENCES/images/carry_look_head_adder.png">

## Number representation  
<img src="../REFERENCES/images/number_representation.png">

## UNSIGNED ADDER & SIGNED ADDER
<img src="../REFERENCES/images/addition.png">





## 8-Bit Binary Addition

### Output Bit Width Rule (`WIDTH + 1`)
When adding two $N$-bit numbers, the result can exceed the $N$-bit capacity. To store the sum without loss or overflow, **$N + 1$ bits** are required. 

* For **8-bit inputs ($N = 8$)**, the output sum requires **9 bits ($WIDTH + 1 = 9$)**, where the 9th bit is the Carry Out / Sign extension bit.

---

### 1. Unsigned 8-Bit Addition Example
* **Range:** `0` to `255`
* **Maximum possible sum:** $255 + 255 = 510$ (requires 9 bits)

**Example: $140 + 125 = 265$**
* Input A: $140_{10}$ = `10001100`
* Input B: $125_{10}$ = `01111101`

| Operand | Binary Value | Decimal Value |
| :--- | :---: | :---: |
| Input A | `10001100` | 140 |
| Input B | `01111101` | 125 |
| **Sum (9 bits)** | **`100001001`** | **265** |

---

### 2. Signed 8-Bit Addition Examples (2's Complement)
* **Range:** `-128` to `+127`
* MSB (Most Significant Bit) acts as the sign bit (`0` = Positive, `1` = Negative).
* Extending to 9 bits ($WIDTH + 1$) guarantees accurate signed results without overflow errors.

#### Case A: Two Positive Numbers ($+45 + +35 = +80$)
* Input A: $+45_{10}$ = `00101101`
* Input B: $+35_{10}$ = `00011001`



| Operand | Binary Value | Decimal Value |
| :--- | :---: | :---: |
| Input A | `00101101` | +45 |
| Input B | `00011001` | +35 |
| **Sum (9 bits)** | **`001010000`** | **+80** |

---

#### Case B: One Positive and One Negative Number ($+60 + -25 = +35$)
* Input A: $+60_{10}$ = `00111100`
* Input B: $-25_{10}$ = `11100111` (2's Complement of 25)


| Operand | Binary Value | Decimal Value |
| :--- | :---: | :---: |
| Input A | `00111100` | +60 |
| Input B | `11100111` | -25 |
| **Sum (9 bits)** | **`000100011`** | **+35** |

---

#### Case C: Two Negative Numbers ($-40 + -50 = -90$)
* Sign-extended to 9 bits so the MSB correctly represents the negative sign bit.
* Input A: $-40_{10}$ = `11011000`
* Input B: $-50_{10}$ = `11001110`

| Operand | Binary Value | Decimal Value |
| :--- | :---: | :---: |
| Input A | `11011000` | -40 |
| Input B | `11001110` | -50 |
| **Sum (9 bits)** | **`110100110`** | **-90** |


