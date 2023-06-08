`define UMODE 2'b00

module exceptionHandling (
  // from datapath
  input [1:0] i_nowPrivMode,
  input [31:0] i_PC,
  input [31:0] i_inst,
  input [31:0] i_ALUOut,
  // from controller
  input i_exceptionFromInst,
  input [3:0] i_causeFromInst,
  input i_mret,
  input i_memWrite, i_memReq,

  // to datapath
  output [3:0] o_cause,
  output o_privRegEnable,
  // to controller
  output o_exception  // and to hazard
);
  assign o_privRegEnable = o_exception | i_mret;

  wire w_instAddrAlignVioException 
    = (i_PC[1:0] != 2'b00);
  wire w_instAccessFaultException 
    = ((i_nowPrivMode == `UMODE) && (32'h0 < i_PC) 
                                  && (i_PC < 32'h1_0000));
  wire w_loadAccessFaultException
    = ((i_nowPrivMode == `UMODE) && (i_memReq && !i_memWrite) 
                                  && ((i_ALUOut < 32'h800_0000)
                                      | 32'h1000_0000 < i_ALUOut));

  assign o_exception = 
    i_exceptionFromInst
    | w_instAddrAlignVioException // or Inst. addr. align vio. exc.
    | w_instAccessFaultException
    | w_loadAccessFaultException;
  assign o_cause = 
    setCause(i_causeFromInst, i_nowPrivMode, 
              w_instAddrAlignVioException,
              w_instAccessFaultException,
              w_loadAccessFaultException
            );
  
  function [3:0] setCause(
    input [3:0] i_causeFromInst,
    input [1:0] i_nowPrivMode,
    input i_instAddrAlignVioException,
    input i_instAccessFaultException,
    input i_loadAccessFaultException
  );
    if (i_instAddrAlignVioException)  // instAddrAlignVioException
      setCause = 4'b0000;
    else if (i_instAccessFaultException)
      setCause = 4'b0001;
    else if (i_loadAccessFaultException)
      setCause = 4'b0101;
    else if (i_causeFromInst == 4'd8) // ecall by UorSorM
      setCause = i_causeFromInst + i_nowPrivMode;
    else
      setCause = i_causeFromInst;
  endfunction

endmodule