# BIT SCAN ARBITER 
The bitscan function takes a set of request lines and allows only the least significant “1” to propagate. This function is handy for prioritizing interrupt request lines.

# Bitscan (Priority Masking Unit)

The `bitscan` module is a parameterized, purely combinational hardware component designed for fixed-priority arbitration. It processes an arbitrary input request vector (`i_req`) and propagates only the least significant set bit (LSB "1") to the output (`o_grant`), masking all higher-order request lines.

This block is ideal for interrupt request lines, bus arbiters, memory scheduling, and FIFO pointer alignment where strict LSB-first priority is required.

---

## Key Features

- **Strict LSB-First Priority**: Always grants access to the active request line with the lowest index.
- **One-Hot Output**: Guarantees that `o_grant` contains at most a single asserted bit (`1`).
- **Optimal Hardware Efficiency**: Utilizes Two's Complement properties ($\text{Req} \ \& \ -\text{Req}$) to avoid multi-level tree delays or ripple-carry overhead.
- **Fully Parameterized**: Easily configurable bit-width via the `WIDTH` parameter.

---

## Hardware Implementation & Logic

The bitscan logic avoids complex conditional loops by leveraging binary arithmetic properties:

$o\_grant = i\_req \ \& \ (\sim i\_req + 1)$

This translates directly to bitwise ANDing the request with its two's complement negation ($i\_req \ \& \ -i\_req$).

---

## Module Parameters

| Parameter | Type | Default | Description |
| :--- | :--- | :---: | :--- |
| `WIDTH` | `int` | `8` | Bit-width of the request input bus and grant output bus. |

---

## Port Interface

| Port Name | Direction | Bit Width | Type | Description |
| :--- | :--- | :--- | :--- | :--- |
| `i_req` | Input | `[WIDTH-1:0]` | `logic` | Active-high input request vector. |
| `o_grant` | Output | `[WIDTH-1:0]` | `logic` | Active-high one-hot output vector representing the granted request line. |

---

## Priority Truth Table ($WIDTH = 4$)

| `i_req[3:0]` | `o_grant[3:0]` | Granted Index | Description |
| :---: | :---: | :---: | :--- |
| `4'b0000` | `4'b0000` | None | No active requests; output remains all zeros. |
| `4'b0001` | `4'b0001` | Bit 0 | Request 0 active. |
| `4'b0010` | `4'b0010` | Bit 1 | Request 1 active. |
| `4'b0011` | `4'b0001` | Bit 0 | Bit 0 and Bit 1 active; Bit 0 takes priority. |
| `4'b1010` | `4'b0010` | Bit 1 | Bit 1 takes priority over Bit 3. |
| `4'b1100` | `4'b0100` | Bit 2 | Bit 2 takes priority over Bit 3. |
| `4'b1111` | `4'b0001` | Bit 0 | All requests active; lowest index (Bit 0) granted. |

---

## SystemVerilog Instantiation

```systemverilog
// Example 8-bit priority masking instance
bitscan #(
    .WIDTH(8)
) u_bitscan (
    .i_req  (i_req),   // Input:  [7:0] active-high request vector
    .o_grant(o_grant)  // Output: [7:0] active-high one-hot grant vector
);
