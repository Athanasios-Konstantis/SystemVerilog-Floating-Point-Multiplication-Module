# SystemsVerilog Floating-Point Multiplication Module

A synthesizable, modular IEEE‑754 single‑precision (32‑bit) floating‑point multiplier implemented in SystemVerilog. The design separates concerns into clear stages: unpacking, multiplication, normalization, rounding, and exception handling, with assertions for basic protocol and range checks. Two simple testbenches are included.

## Overview
- Standard: IEEE‑754 single precision (binary32)
- Rounding: Round to nearest, ties to even (RN‑TiesEven)
- Exceptions supported: NaN propagation, infinities, zero rules, overflow/underflow flags
- Modular pipeline-style design, intended for simulation and synthesis

## File layout
- `fp_mult_top.sv` — Top-level wrapper connecting all submodules; primary interface for integration.
- `main_module.sv` — Core control/data-path integration (unpacking, special-case handling, stage orchestration).
- `multiplication.sv` — Integer mantissa multiplication and exponent pre-sum.
- `normalization.sv` — Normalizes the product mantissa (leading-one alignment) and adjusts exponent.
- `rounding.sv` — Applies IEEE‑754 rounding (RN‑TiesEven), generates guard/round/sticky, handles overflow/underflow to exponent.
- `exception.sv` — Detects and handles special inputs (NaN, Inf, zeros), generates status flags and canonical NaNs.
- `globals.sv` — Common typedefs/parameters/macros (e.g., widths, bias constants).
- `assertions.sv` — SystemVerilog assertions for interface and invariants.
- `tb1.sv`, `tb2.sv` — Testbenches with sample vectors and wave dumping.
- `HW2_project_report_Athanasios_Konstantis_10537.pdf` — Project report.

## Interfaces (top-level)
The exact signal names may vary slightly; the typical contract is:
- Inputs
  - `a [31:0]` — IEEE‑754 single-precision operand A
  - `b [31:0]` — IEEE‑754 single-precision operand B
  - `clk` — clock (if using sequential stages)
  - `rst_n` — active‑low reset (if used)
  - Optional `en/valid` — input handshake
- Outputs
  - `result [31:0]` — IEEE‑754 single-precision product
  - `flags` — struct or bits: `invalid`, `overflow`, `underflow`, `inexact`
  - Optional `ready/valid` — output handshake

Refer to `fp_mult_top.sv` and `main_module.sv` for exact port lists.

## IEEE‑754 behavior
- NaN × anything → NaN (quiet NaN propagation)
- ±Inf × 0 → invalid operation (flag set), canonical NaN
- ±Inf × finite → ±Inf (sign XOR)
- Zero rules: sign handling per IEEE (sign XOR), magnitude zero
- Normal finite × finite: integer multiply of mantissas with hidden bit, exponent add with bias correction, normalize, round, pack
- Rounding: RN‑TiesEven; sticky/guard/round bits collected in `rounding.sv`

## Assertions and status
- Basic parameter width checks
- Optional protocol assertions (valid/ready if present)
- Flags via `exception.sv` and rounding overflow/underflow paths

## How to run simulations (Windows PowerShell)
Below are ways to run the provided testbenches. Ensure your simulator supports SystemVerilog (IEEE‑1800‑2012).

### ModelSim/Questa
```powershell
# Create a work library
vlib work; vmap work work

# Compile sources
vlog -sv globals.sv assertions.sv exception.sv multiplication.sv normalization.sv rounding.sv main_module.sv fp_mult_top.sv tb1.sv

# Run testbench tb1
vsim -c work.tb1 -do "run -all; quit"

# Optionally run tb2
vlog -sv tb2.sv; vsim -c work.tb2 -do "run -all; quit"
```

### Icarus Verilog (SystemVerilog)
Icarus requires the `-g2012` flag for SystemVerilog.
```powershell
iverilog -g2012 -o sim_tb1 globals.sv assertions.sv exception.sv multiplication.sv normalization.sv rounding.sv main_module.sv fp_mult_top.sv tb1.sv
vvp sim_tb1

iverilog -g2012 -o sim_tb2 globals.sv assertions.sv exception.sv multiplication.sv normalization.sv rounding.sv main_module.sv fp_mult_top.sv tb2.sv
vvp sim_tb2
```

### Verilator (lint + C++ sim)
Verilator flow compiles SV to C++ and needs a C++ testbench or `--exe` harness. If `tb1.sv` is purely SV, you can start with lint:
```powershell
verilator --sv --lint-only globals.sv assertions.sv exception.sv multiplication.sv normalization.sv rounding.sv main_module.sv fp_mult_top.sv tb1.sv
```
For full simulation, wrap with a C++ harness or use `--binary` if your version supports it.

## Expected outputs
- Console prints (if present in testbenches)
- Waveform files (e.g., `dump.vcd`) driven by `tb1.sv`/`tb2.sv`
- Check flags for corner cases (NaN/Inf/zero), and verify rounding on fractional products

## Synthesis notes
- Uses combinational + small sequential logic; should synthesize on common FPGA tools
- Replace `$display`/assertions with synthesis‑friendly wrappers if needed
- Confirm target toolchain’s support for SV constructs used in `assertions.sv`


## License
Educational use. If you plan broader distribution, add a proper license file.

## Author
Athanasios Konstantis 
