module exceptionHandling (
  input i_exceptionFromInst,
  input [3:0] i_causeFromInst,
  input [1:0] i_nowPrivMode,
  input [31:0] i_PC,
  output o_exception,
  output [3:0] o_cause
);
  // wire [11:0] Dw_csrFixed = 
  //   Di_exceptionFromInst ? 12'h305 : (Di_mret ? 12'h341
  //                                     : Dw_csr); // mtvec(305) or csr to CSRsAddr
  // wire Dw_exceptionInID = Di_exceptionFromInst | 
  // if (Dw_PC[1:0] == 2'b00) begin  // InstAdrAlignVioException (cause:0)
  //   // 
  // end
  assign o_exception = 
    i_exceptionFromInst | (i_PC[1:0] != 2'b00);
  // assign o_exception = i_exceptionFromInst;
  assign o_cause = 
    setCause(i_causeFromInst, i_nowPrivMode, i_PC);
  
  function [3:0] setCause(
    input [3:0] i_causeFromInst,
    input [1:0] i_nowPrivMode,
    input [31:0] i_PC
  );
    if (i_PC[1:0] != 2'b00)  // instAddrAlignVioException
      setCause = 4'b0000;
    else if (i_causeFromInst == 4'd8) // ecall by UorSorM
      setCause = i_causeFromInst + i_nowPrivMode;
    else
      setCause = i_causeFromInst;
  endfunction

  // Instruction address align violation exception
  // wire instAddrAlignVioException = 

  // function exceptionFromImem(

  // );

    
  // endfunction
  
endmodule