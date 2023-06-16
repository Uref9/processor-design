`define UMODE 2'b00

module exceptionHandling (
  // from datapath
  input [1:0] Ei_nowPrivMode,
  input [31:0] Ei_PC,
  input [31:0] Ei_inst,
  input [31:0] Ei_ALUOut,
  // from controller
  input Ei_exceptionFromInst,
  input [3:0] Ei_causeFromInst,
  input Ei_mret,
  input Ei_memWrite, Ei_memReq,

  // to datapath
  output [3:0] Eo_cause,
  output Eo_privRegEnable,
  // to controller
  output Eo_exception  // and to hazard
);
  assign Eo_privRegEnable = Eo_exception | Ei_mret;

  wire w_instAddrAlignVioException 
    = (Ei_PC[1:0] != 2'b00);
  wire w_instAccessFaultException 
    = ((Ei_nowPrivMode == `UMODE) && (32'h0 < Ei_PC) 
                                  && ( (Ei_PC < 32'h1_0000)
                                        | (32'h800_0000 < Ei_PC)));
  wire w_loadAccessFaultException
    = ((Ei_nowPrivMode == `UMODE) && (Ei_memReq && !Ei_memWrite) 
                                  && ( (Ei_ALUOut < 32'h800_0000)
                                        | (32'h1000_0000 < Ei_ALUOut))
      );
  wire w_storeAccessFaultException
    = ((Ei_nowPrivMode == `UMODE) && (Ei_memReq && Ei_memWrite)
                                  && ( (Ei_ALUOut < 32'h800_0000)
                                        | (32'h1000_0000 < Ei_ALUOut))
                                  && (Ei_ALUOut != 32'hf000_0000)
                                  && (Ei_ALUOut != 32'hff00_0000)
      );

  assign Eo_exception = 
    Ei_exceptionFromInst
    | w_instAddrAlignVioException // or Inst. addr. align vio. exc.
    | w_instAccessFaultException
    | w_loadAccessFaultException
    | w_storeAccessFaultException;
  assign Eo_cause = 
    setCause(Ei_causeFromInst, Ei_nowPrivMode, 
              w_instAddrAlignVioException,
              w_instAccessFaultException,
              w_loadAccessFaultException,
              w_storeAccessFaultException
            );
  
  function [3:0] setCause(
    input [3:0] Ei_causeFromInst,
    input [1:0] Ei_nowPrivMode,
    input i_instAddrAlignVioException,
    input i_instAccessFaultException,
    input i_loadAccessFaultException,
    input i_storeAccessFaultException
  );
    if (i_instAddrAlignVioException)  // instAddrAlignVioException
      setCause = 4'b0000;
    else if (i_instAccessFaultException)
      setCause = 4'b0001;
    else if (i_loadAccessFaultException)
      setCause = 4'b0101;
    else if (i_storeAccessFaultException)
      setCause = 4'b0111;
    else if (Ei_causeFromInst == 4'd8) // ecall by UorSorM
      setCause = Ei_causeFromInst + Ei_nowPrivMode;
    else
      setCause = Ei_causeFromInst;
  endfunction

endmodule