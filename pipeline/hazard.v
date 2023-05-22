module hazard (
  // from datapath
  input [4:0] Di_rs1, Di_rs2,
  input [4:0] Ei_rs1, Ei_rs2,
  input [4:0] Ei_rd,
  input [4:0] Mi_rd,
  input [4:0] Wi_rd,
  // from controller
  input [1:0] Ei_PCSrc,
  input [1:0] Ei_resultSrc,
  input [1:0] Mi_resultSrc,
  input Mi_regWrite,
  input Wi_regWrite,

  // to datapath
  output [1:0] Eo_forwardIn1Src, Eo_forwardIn2Src,
  // to both (datapath, controller)
  output Fo_stall,
  output Do_stall,
  output Do_flush,
  output Eo_flush
);
  wire w_lwStall;

  // forwarding
  assign Eo_forwardIn1Src = forwarding1(
                              Di_rs1, Ei_rs1,
                              Ei_rd, Mi_rd, Wi_rd,
                              Ei_resultSrc, Mi_resultSrc,
                              Mi_regWrite, Wi_regWrite
                            ); 
  assign Eo_forwardIn2Src = forwarding2(
                              Di_rs2, Ei_rs2,
                              Ei_rd, Mi_rd, Wi_rd,
                              Ei_resultSrc, Mi_resultSrc,
                              Mi_regWrite, Wi_regWrite
                            ); 

  // stall and flush
  assign w_lwStall = (Ei_resultSrc == 2'b01) // isLoad?
                    & ((Di_rs1 == Ei_rd)
                      | (Di_rs2 == Ei_rd));
  assign Fo_stall = w_lwStall;                    
  assign Do_stall = w_lwStall;                    
  assign Do_flush = (Ei_PCSrc != 2'b00); // NextPC != PC+4                 
  assign Eo_flush = (Ei_PCSrc != 2'b00) | w_lwStall;


  function [3:0] forwarding1(
    input [4:0] Di_rs1, Ei_rs1,
    input [4:0] Ei_rd, Mi_rd, Wi_rd,
    // from controller
    input [1:0] Ei_resultSrc, Mi_resultSrc,
    input Mi_regWrite, Wi_regWrite
  );
    if (Ei_rs1 != 5'b0)
      if (Ei_rs1 == Mi_rd)
        if (Mi_regWrite)
          if (Mi_resultSrc == 2'b00)
                        forwarding1 = 2'b11;  // Mo_ALUOut
          else if (Mi_resultSrc == 2'b10)       
                        forwarding1 = 2'b10;  // Mw_immPlus
      else if ((Ei_rs1 == Wi_rd) & Wi_regWrite) 
                        forwarding1 = 2'b01;  // Ww_result
    else                forwarding1 = 2'b00;  // Ew_RD1
  endfunction

  function [3:0] forwarding2(
    input [4:0] Di_rs2, Ei_rs2,
    input [4:0] Ei_rd, Mi_rd, Wi_rd,
    // from controller
    input [1:0] Ei_resultSrc, Mi_resultSrc,
    input Mi_regWrite, Wi_regWrite
  );

    if (Ei_rs2 != 5'b0)
      if (Ei_rs2 == Mi_rd)
        if (Mi_regWrite)
          if (Mi_resultSrc == 2'b00)
                        forwarding2 = 2'b11; // Mo_ALUOut
          else if (Mi_resultSrc == 2'b10)       
                        forwarding2 = 2'b10; // Mw_immPlus
      else if ((Ei_rs2 == Wi_rd) & Wi_regWrite) 
                        forwarding2 = 2'b01; // Ww_result
    else                forwarding2 = 2'b00;
  endfunction

endmodule