# Proccesor Design
- RISC-V (RV32I)
- Verilog, SystemVerilog(test)

# Version
## single-cycle
-
- v0.1  temporary completion
## pipeline
- v0.11 Add store access fault exception
- v0.10 Add load access fault exception and move exceptioinHandling module in datapath to in top
- v0.9 Add ebreak Inst. and inst. access fault exception (not use PMP or pmpcfg CSRs)
- v0.8 Add Inst. addr. align violation exception and Move mret ID to EX
- v0.7 Add privilege mode and move ID to EX in writing CSRs
- v0.6 Add Illegal inst. exception
- v0.5 Add csrrw, etc. and solve branch->jal probrem
- v0.5-pre Add csrrw, etc. (not completely confirm)
- v0.4 Add Forwarding MEM to EX in jal, jalr
- v0.3 Add ecall(only direct-mode) and mret Inst.
- v0.2 Reduce jal penalty 2 to 1Cycle
      - (Change judging stage, IE to IDstage)
- v0.1 temporary completion
      - (forwarding, stall, flush)

# How to use
`./shell/toptest.sh [single | pipeline]` to top_test for single or pipeline

# Naming convention

- other (module, signal, etc.)
  - lowerCamelCase

- instans
  - snake_case

# References
- パタヘネ
- DDCA
- RISC-V 原典
