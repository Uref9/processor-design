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
  // [11:10] [9:8] [7:4] 
  // 00 11 XXXX 0x300-0x3ff
  reg [31:0]  mstatus,    // 300

              mie,        // 304
              mtvec,      // 305

              mscratch,   // 340
              mepc,       // 341
              mcause,     // 342
              mtval,      // 343
              mip;        // 344
  // read
  assign data_out = readCSRs(csr_addr);
  assign mstatus_out = mstatus;

  // write
  always @(negedge clk, negedge reset_x) begin
    if (!reset_x) begin
      mstatus <= 32'b0000_0000_0000_0000_0001_1000_1000_1000;
      mie <= 32'b0;
      mtvec <= 32'b0;
      mscratch <= 32'h802_0000;
      mepc <= 32'b0;
      mcause <= 32'b0;
      mtval <= 32'b0;
      mip <= 32'b0;
    end
    else if (ecall) begin
      mepc <= Di_PC; 
      // mepc <= Di_PC + 32'd4;  // when not impl. csrr+
      mcause <= 32'b0_000_0000_0000_0000_0000_0000_0000_1011; // 0 : 11 
      mstatus[3] <= 1'b0;
      mstatus[7] <= mstatus[3];
    end
    else if (mret) begin
      mstatus[3] <= mstatus[7];
      mstatus[7] <= mstatus[3];
    end
    else if (!wcsr_n) begin
      case (wr1_addr)
        12'h300: mstatus <= data1_in;

        12'h304: mie <= data1_in;
        12'h305: mtvec <= data1_in;

        12'h340: mscratch <= data1_in;
        12'h341: mepc <= data1_in;
        12'h342: mcause <= data1_in;
        12'h343: mtval <= data1_in;
        12'h344: mip <= data1_in;

        default:;
      endcase
    end
  end

  function [31:0] readCSRs(
    input [11:0] csr_addr
  );
    case (csr_addr)
      12'h300: readCSRs = mstatus;

      12'h304: readCSRs = mie;
      12'h305: readCSRs = mtvec;

      12'h340: readCSRs = mscratch;
      12'h341: readCSRs = mepc;
      12'h342: readCSRs = mcause;
      12'h343: readCSRs = mtval;
      12'h344: readCSRs = mip;

      default: readCSRs = 32'bx;
    endcase
  endfunction

  /* end of CSRs */
endmodule