`define LOW 1'b0
`define HIGH 1'b1
module exceptionDecoder (
  input i_exception,
  input [2:0] i_funct3,
  input [11:0] i_funct12,

  output o_ecall, o_mret
);

  assign { o_ecall, o_mret } 
  = exceptionDecoder( i_exception, i_funct3, i_funct12 );

  function [1:0] exceptionDecoder(
    input i_exception,
    input [2:0] i_funct3,
    input [11:0] i_funct12
  );
    //                                          ecall_mret
    if (!i_exception) 
                              exceptionDecoder = 2'b0_0;
    else begin
      case (i_funct3)
        3'b000: 
        case (i_funct12)
          12'b0000_0000_0000: exceptionDecoder = 2'b1_0;  // ecall
          // 12'b0000_0000_0001: // ebreak
          12'b0011_0000_0010: exceptionDecoder = 2'b0_1;  // mret
          default:            exceptionDecoder = 2'bx_x;  // sret, wfi, sfence.vma
        endcase
        // csrr+
        // 3'b001: exceptionDecoder = ;
        // 3'b010: exceptionDecoder = ;
        default:              exceptionDecoder = 2'bx_x;  // csrr+
      endcase
    end
endfunction
endmodule