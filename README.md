# CORDIC Trigonometric Engine (Verilog)

A Verilog implementation of the **CORDIC (Coordinate Rotation Digital Computer)** algorithm to calculate **Sine**, **Cosine**, and **Tangent** using only **shift-and-add operations**. The design is written for FPGA implementation and simulated using **Xilinx Vivado**.

---

## Features

- Computes **sin(θ), cos(θ), and tan(θ)**
- 16-bit fixed-point (Q1.15) implementation
- Uses only **adders, subtractors and shifters**
- No multipliers required
- Sequential architecture (16 iterations)
- Simulated and verified in Xilinx Vivado

---

## Algorithm

The CORDIC algorithm rotates a vector through a sequence of predefined micro-rotations.

At each iteration:

```
if (z >= 0)
{
    x = x - (y >> i);
    y = y + (x >> i);
    z = z - atan(2^-i);
}
else
{
    x = x + (y >> i);
    y = y - (x >> i);
    z = z + atan(2^-i);
}
```

The angle is gradually reduced to zero while the X and Y values converge to:

```
X = cos(θ)
Y = sin(θ)
```

Finally,

```
tan(θ) = sin(θ) / cos(θ)
```

---

## Hardware Architecture

The implementation consists of:

- Shift Unit
- Add/Subtract Unit
- Arctangent Lookup Table (LUT)
- Control Logic
- Registers for X, Y and Z values

<p align="center">
<img src="docs/architecture.png" width="700">
</p>

---

## Fixed Point Representation

| Signal | Format |
|---------|--------|
| Angle | Q1.15 |
| Cosine | Q1.15 |
| Sine | Q1.15 |
| Tangent | 32-bit Signed |

Initial CORDIC gain compensation:

```
GAIN = 19897
```

which corresponds to

```
1 / K ≈ 0.607252
```

---

## Inputs and Outputs

| Signal | Direction | Description |
|---------|-----------|-------------|
| clk | Input | System clock |
| rst | Input | Active-high reset |
| en | Input | Starts computation |
| angle | Input | Input angle (Q1.15) |
| cos_out | Output | Cosine value |
| sin_out | Output | Sine value |
| tan_out | Output | Tangent value |
| valid | Output | Goes HIGH when outputs are ready |

---

## Simulation

The testbench verifies the design for multiple input angles.

Test cases:

- 0°
- 30°
- 45°
- 89°
- -45°

Example simulation waveform:

<p align="center">
<img src="docs/waveform.png" width="900">
</p>

---

## Sample Results

| Angle | Cosine | Sine | Tangent |
|--------|--------|------|----------|
| 0° | 32767 | 5 | 5 |
| 30° | 28373 | 16390 | 18928 |
| 45° | 23173 | 23164 | 32755 |
| 89° | 18207 | 27241 | 49026 |

*Values are represented in fixed-point (Q1.15). Small errors are expected due to finite iterations and fixed-point arithmetic.*

---

## Project Structure

```
CORDIC/
│
├── cordic.v
├── tb_cordic.v
├── README.md
└── docs/
    ├── architecture.png
    └── waveform.png
```

---

## How to Run

1. Open Xilinx Vivado.
2. Create a new RTL project.
3. Add `cordic.v` as a design source.
4. Add `tb_cordic.v` as a simulation source.
5. Run **Behavioral Simulation**.
6. Observe the waveform and console output.

---

## Future Improvements

- Increase precision using more iterations
- Support pipelined architecture
- Extend angle range to full 360°
- Improve tangent accuracy near ±90°
- FPGA implementation and timing analysis

---

## References
- https://www.allaboutcircuits.com/technical-articles/an-introduction-to-the-cordic-algorithm/
- J. E. Volder, *The CORDIC Trigonometric Computing Technique*, 1959.
- Xilinx CORDIC IP Documentation.

---

**Author:** Shivam Rohatgi  
**Education:** BTech in Electronics and Communication Engineering from Delhi Technological University(DTU)
**Language:** Verilog HDL  
**Simulation Tool:** Xilinx Vivado
