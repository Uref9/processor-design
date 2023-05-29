module exceptionHandler (
  // from test
  input clk, reset_x,
  // from datapath
  input [31:0] Di_PC,
  // from controller
  input Di_ecall, Di_mret,

  // to datapath
  output [31:0] Do_mepc, Do_mtvec
);

  assign Do_mepc = r_mepc;
  assign Do_mtvec = r_mtvec;


  /* CSRs part */
  reg [31:0] r_mepc, r_mcause, r_mtvec;
  reg r_mstatusb3MIE, r_mstatusb7MPIE; // MIE, MPIE

  always @(posedge clk, negedge reset_x) begin
    if (!reset_x) begin
      r_mepc <= 32'b0;
      r_mcause <= 32'b0;
      r_mtvec <= 32'b0;
      r_mstatusb3MIE <= 1'b1;
      r_mstatusb7MPIE <= 1'b1;
    end
    else if (Di_ecall) begin
      // r_mepc <= Di_PC; 
      r_mepc <= Di_PC + 32'd4;  // Delete after impl. csrr+
      r_mcause <= 32'b0_000_0000_0000_0000_0000_0000_0000_1011; // 0 : 11 
      r_mstatusb3MIE <= 1'b0;
      r_mstatusb7MPIE <= r_mstatusb3MIE;
    end
    else if (Di_mret) begin
      r_mstatusb3MIE <= r_mstatusb7MPIE;
      r_mstatusb7MPIE <= r_mstatusb3MIE;
    end
  end
  /* end of CSRs */


endmodule