// mstatus bit field
`define MIE 3
`define MPIE 7
`define MPP 12:11

// PrivilegeMode
`define UMODE 2'b00
`define MMODE 2'b11

module CSRs (
  // from test
  input clk, reset_x,
  // from datapath
  input [11:0] csr_addr,
  input [11:0] wr1_addr,
  input [31:0] data1_in,
  input [31:0] mstatus_in, mepc_in, mtval_in, 
  input [3:0] mcause_in,
  input [1:0] nowPrivMode,
  // input         mstatus_update,
    // special
    input exceptionFromInst, mret,
  // from controller
  input wcsr_n,


  // output
  output [31:0] data_out,
  output reg [1:0] nextPrivMode,
  output [31:0] mstatus_out, mtvec_out, mepc_out
);

  /* controll status registers */
  // [11:10] [9:8] [7:4] 
  // 00 11 XXXX 0x300-0x3ff
  reg [31:0]  r_mstatus,    // 300

              r_mie,        // 304
              r_mtvec,      // 305

              r_mscratch,   // 340
              r_mepc,       // 341
              r_mcause,     // 342
              r_mtval,      // 343
              r_mip;        // 344
  // read
  assign data_out = readCSRs(csr_addr);
  assign mstatus_out = r_mstatus;
  assign mtvec_out = r_mtvec;
  assign mepc_out = r_mepc;

  // write
               // other
  always @(negedge clk, negedge reset_x) begin
    if (!reset_x) begin
      r_mstatus[`MIE] <= 1'b1;
      // r_mstatus[`MPIE] <= 1'b1;
      // r_mstatus[`MPP] <= 2'b11;
      r_mie <= 32'bx;
      r_mtvec <= 32'h0000_0000;
      r_mscratch <= 32'h802_0000; // ?
      r_mepc <= 32'bx;
      r_mcause <= 32'bx;
      r_mtval <= 32'bx;
      r_mip <= 32'bx;
    end
    else if (exceptionFromInst) begin
      r_mepc <= mepc_in; 
      // r_mepc <= r_mepc_in + 32'd4;  // when not impl. csrr+
      r_mcause <= { 28'b0, mcause_in };
      r_mstatus[`MPIE] <= r_mstatus[`MIE];
      r_mstatus[`MIE] <= 1'b0;
      r_mstatus[`MPP] <= nowPrivMode;
      nextPrivMode <= `MMODE;
      if (mcause_in == 4'd2)  // illegal inst. exception
        r_mtval <= mtval_in;
    end
    else if (mret) begin
      r_mstatus[`MIE] <= r_mstatus[`MPIE];
      r_mstatus[`MPIE] <= 1'b1;
      r_mstatus[`MPP] <= `UMODE;
      nextPrivMode <= r_mstatus[`MPP];
    end
    else if (!wcsr_n) begin
      case (wr1_addr)
        12'h300: r_mstatus <= data1_in;

        12'h304: r_mie <= data1_in;
        12'h305: r_mtvec <= data1_in;

        12'h340: r_mscratch <= data1_in;
        12'h341: r_mepc <= data1_in;
        12'h342: r_mcause <= data1_in;
        12'h343: r_mtval <= data1_in;
        12'h344: r_mip <= data1_in;

        default:;
      endcase
    end
  end

  function [31:0] readCSRs(
    input [11:0] csr_addr
  );
    case (csr_addr)
      12'h300: readCSRs = r_mstatus;

      12'h304: readCSRs = r_mie;
      12'h305: readCSRs = r_mtvec;

      12'h340: readCSRs = r_mscratch;
      12'h341: readCSRs = r_mepc;
      12'h342: readCSRs = r_mcause;
      12'h343: readCSRs = r_mtval;
      12'h344: readCSRs = r_mip;

      default: readCSRs = 32'bx;
    endcase
  endfunction

  /* end of CSRs */
endmodule