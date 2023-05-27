# Proccesor Design
- RISC-V (32I)
- Verilog, SystemVerilog(test)

# Version
## single-cycle
-
- v0.1  temporary completion
## pipeline
- v0.2 Reduce jal penalty 2 to 1Cycle
      (Change judging stage, IE to IDstage)
- v0.1 temporary completion
      (forwarding, stall, flush)

# How to use
`./sttest.sh` for single-top_test

# Naming convention

- other (module, signal, etc.)
  - lowerCamelCase

- instans
  - snake_case

# References
- パタヘネ
- DDCA
- RISC-V 原典
