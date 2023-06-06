module exceptionHandling (
  input [3:0] i_causeFromInst,
  input [1:0] i_nowPrivMode,
  output [3:0] o_cause
);
  // wire [11:0] Dw_csrFixed = 
  //   Di_exceptionFromInst ? 12'h305 : (Di_mret ? 12'h341
  //                                     : Dw_csr); // mtvec(305) or csr to CSRsAddr
  // wire Dw_exceptionInID = Di_exceptionFromInst | 
  // if (Dw_PC[1:0] == 2'b00) begin  // InstAdrAlignVioException (cause:0)
  //   // 
  // end
  assign o_cause = 
    (i_causeFromInst == 4'd8)? i_causeFromInst + i_nowPrivMode // ecall UorSorM
                              : i_causeFromInst;    
  
  // Instruction address align violation exception
  // wire instAddrAlignVioException = 

  // function exceptionFromImem(

  // );

    
  // endfunction
  
  // function [3:0] setCause(
  //   input [3:0] i_causeFromInst,
  //   input [1:0] i_nowPrivMode
  // );

  // endfunction
endmodule