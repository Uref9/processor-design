`define LOW 1'b0
`define HIGH 1'b1
// Privilege Mode
`define MMODE 2'b11

module exceptionDecoder (
  input [1:0] i_EXCOp,
  input [2:0] i_funct3,
  input [11:0] i_funct12,
  input [1:0] i_nowPrivMode,

  output [3:0] o_causeFromInst,
  output o_exceptionFromInst, o_mret
);

  assign { o_causeFromInst, o_exceptionFromInst, o_mret } 
  = exceptionDecoder( i_EXCOp, i_funct3, i_funct12 );

  function [5:0] exceptionDecoder(
    input [1:0] i_EXCOp,
    input [2:0] i_funct3,
    input [11:0] i_funct12
  );
    //                            causeFromInst_exceptionFromInst_mret
    case (i_EXCOp)
      2'b00:
                exceptionDecoder = 6'bxxxx_0_0;
      2'b01:
        if (i_funct3 == 3'b000)
          case (i_funct12)
            12'b0000_0000_0000: 
                exceptionDecoder = 6'b1000_1_0;  // ecall (default: by U-mode)
            // 12'b0000_0000_0001:                            // ebreak
            12'b0011_0000_0010: 
              if (i_nowPrivMode == `MMODE)
                exceptionDecoder = 6'bxxxx_0_1;  // mret
              else 
                exceptionDecoder = 6'b0010_0_0;  // mret but not M-mode now
            // 12'b0001_0000_0010: 
            //     exceptionDecoder = 6'bxxxx_0_0;  // sret
            default:            
                exceptionDecoder = 6'b0010_x_x;  // wfi, sfence.vma, ???
          endcase
      2'b10:    exceptionDecoder = 6'b0010_1_0;
    endcase
endfunction
endmodule