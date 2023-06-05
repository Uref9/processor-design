module CSRs (
  // from test
  input clk, reset_x,
  // from datapath
  input [11:0] csr_addr,
  input [11:0] wr1_addr,
  input [31:0] data1_in,
    // special
    input [31:0] Di_PC,
    input        ecall, mret,
  // from controller
  input wcsr_n,

  // output
  output [31:0] data_out
  // output [31:0] mstatus_out


);
  // Now Privilege Mode
  // U : 00
  // S : 01
  //(H : 10)
  // M : 11
  reg [1:0] r_nowPrivilegeMode;
  always @(negedge reset_x) begin
    r_nowPrivilegeMode <= 00;
  end

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

  // write
  always @(negedge clk, negedge reset_x) begin
    if (!reset_x) begin
      r_mstatus <= 32'b0000_0000_0000_0000_0001_1000_1000_1000;
      r_mie <= 32'b0;
      r_mtvec <= 32'b0;
      r_mscratch <= 32'h802_0000;
      r_mepc <= 32'b0;
      r_mcause <= 32'b0;
      r_mtval <= 32'b0;
      r_mip <= 32'b0;
    end
    else if (ecall) begin
      r_mepc <= Di_PC; 
      // r_mepc <= Di_PC + 32'd4;  // when not impl. csrr+
      r_mcause <= 32'b0_000_0000_0000_0000_0000_0000_0000_1011; // 0 : 11 
      r_mstatus[3] <= 1'b0;
      r_mstatus[7] <= r_mstatus[3];
    end
    else if (mret) begin
      r_mstatus[3] <= r_mstatus[7];
      r_mstatus[7] <= r_mstatus[3];
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