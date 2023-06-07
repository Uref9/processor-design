`define UMODE 2'b00

module exceptionHandling (
  input i_exceptionFromInst,
  input [3:0] i_causeFromInst,
  input [1:0] i_nowPrivMode,
  input [31:0] i_PC,
  input [31:0] i_inst,
  output o_exception,
  output [3:0] o_cause
);
  wire w_instAddrAlignVioException 
    = (i_PC[1:0] != 2'b00);
  wire w_instAccessFaultException 
    = ((i_nowPrivMode == `UMODE) && (32'h0 < i_PC) 
                                  && (i_PC < 32'h1_0000));
    // = 1'b0;

  assign o_exception = 
    i_exceptionFromInst
    | w_instAddrAlignVioException // or Inst. addr. align vio. exc.
    | w_instAccessFaultException;
  assign o_cause = 
    setCause(i_causeFromInst, i_nowPrivMode, 
              w_instAddrAlignVioException,
              w_instAccessFaultException);
  
  function [3:0] setCause(
    input [3:0] i_causeFromInst,
    input [1:0] i_nowPrivMode,
    input i_instAddrAlignVioException,
    input i_instAccessFaultException
  );
    if (i_instAddrAlignVioException)  // instAddrAlignVioException
      setCause = 4'b0000;
    else if (i_instAccessFaultException)
      setCause = 4'b0001;
    else if (i_causeFromInst == 4'd8) // ecall by UorSorM
      setCause = i_causeFromInst + i_nowPrivMode;
    else
      setCause = i_causeFromInst;
  endfunction

endmodule