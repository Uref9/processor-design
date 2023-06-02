// module exceptionHandler (
//   // from datapath
//   input [31:0] Di_PC,
//   input [11:0] Di_csr,
//   // from controller
//   input Di_ecall, Di_mret,

//   // to datapath
//   output [31:0] Do_CSRsData
// );
//   wire [11:0] Dw_csrFixed = ecall ? 12'h305 
//                                   : (mret ? 12'h341 
//                                           : Di_csr);

//   /* CSRs part */
// endmodule