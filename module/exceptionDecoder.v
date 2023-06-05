`define LOW 1'b0
`define HIGH 1'b1

module exceptionDecoder (
  input [1:0] i_EXCOp,
  input [2:0] i_funct3,
  input [11:0] i_funct12,

  output [3:0] o_causeNum,
  output o_exception, o_mret
);

  assign { o_causeNum, o_exception, o_mret } 
  = exceptionDecoder( i_EXCOp, i_funct3, i_funct12 );

  function [5:0] exceptionDecoder(
    input [1:0] i_EXCOp,
    input [2:0] i_funct3,
    input [11:0] i_funct12
  );
    //                            causeNum_exception_mret
    case (i_EXCOp)
      2'b00:
                exceptionDecoder = 6'bxxxx_0_0;
      2'b01:
        if (i_funct3 == 3'b000)
          case (i_funct12)
            12'b0000_0000_0000: 
                exceptionDecoder = 6'b1000_1_0;  // ecall
            // 12'b0000_0000_0001:                            // ebreak
            12'b0011_0000_0010: 
                exceptionDecoder = 6'b0000_0_1;  // mret
            default:            
                exceptionDecoder = 6'b0010_x_x;  // sret, wfi, sfence.vma, ???
          endcase
      2'b10:    exceptionDecoder = 6'b0010_1_0;
    endcase
endfunction
endmodule