`define LOW 1'b0
`define HIGH 1'b1

module exceptionDecoder (
  input i_exception,
  input [2:0] i_funct3,
  input [11:0] i_funct12,

  output o_ecall, o_mret,
  output o_csrWrite, o_csrSrc,
  output [1:0] o_csrLUCtrl
);

  assign {
    o_ecall, o_mret,
    o_csrWrite, o_csrSrc, o_csrLUCtrl
  } 
  = exceptionDecoder( i_exception, i_funct3, i_funct12 );

  function [5:0] exceptionDecoder(
    input i_exception,
    input [2:0] i_funct3,
    input [11:0] i_funct12
  );
    //                                    ecall_mret_csrW_csrSrc_csrLUCtr2
    if (!i_exception) 
                              exceptionDecoder = 6'b0_0_0_0_00;
    else begin
      case (i_funct3)
        3'b000: 
        case (i_funct12)
          12'b0000_0000_0000: exceptionDecoder = 6'b1_0_0_0_00;  // ecall
          // 12'b0000_0000_0001: // ebreak
          12'b0011_0000_0010: exceptionDecoder = 6'b0_1_0_0_00;  // mret
          default:            exceptionDecoder = 6'bx_x_x_x_xx;  // sret, wfi, sfence.vma, ???
        endcase
        // csrr+
        3'b001:               exceptionDecoder = 6'b0_0_1_0_01; // csrrw
        3'b010:               exceptionDecoder = 6'b0_0_1_0_10; // csrrs
        3'b011:               exceptionDecoder = 6'b0_0_1_0_11; // csrrc
        3'b101:               exceptionDecoder = 6'b0_0_1_1_01; // csrrwi
        3'b110:               exceptionDecoder = 6'b0_0_1_1_10; // csrrsi
        3'b111:               exceptionDecoder = 6'b0_0_1_1_11; // csrrci
        default:              exceptionDecoder = 6'bx_x_x_x_xx; // ???
      endcase
    end
endfunction
endmodule