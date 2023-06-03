// module exceptionHandler (
//   // from datapath
//   input [11:0] Di_csr,
//   // from controller
//   input Di_mret, Di_exception,

//   // to datapath
//   output [11:0] Do_csrFixed
// );
//   // assign Do_csrFixed = Di_ecall ? 12'h305 
//   //                               : (Di_mret ? 12'h341 
//   //                                           : Di_csr);

//   function [11:0] csrFix(
//     input [11:0] Di_csr,
//     input Di_mret, Di_exception
//   );

//   endfunction

//   /* CSRs part */
// endmodule