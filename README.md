# Proccesor Design
- RISC-V (RV32I)
- Verilog, SystemVerilog(test)

# Version
## single-cycle
-
- v0.1  temporary completion
## pipeline
- v0.4 Correspond to Forwarding MEM to EX in jal, jalr
- v0.3 Correspond to ecall(only direct-mode) and mret Inst.
- v0.2 Reduce jal penalty 2 to 1Cycle
      - (Change judging stage, IE to IDstage)
- v0.1 temporary completion
      - (forwarding, stall, flush)

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
