module exception (
  // from test
  input clk, reset_x,
  // from datapath
  input [31:0] Di_PC,

  // to datapath
  output reg [31:0] Do_mtvec
);

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
    else begin
      // ecall
      r_mepc <= Di_PC; 
      r_mcause <= 32'b0_000_0000_0000_0000_0000_0000_0000_1011; // 0 : 11 
      r_mstatusb3MIE <= 1'b0;
      Do_mtvec <= r_mtvec;
    end
  end
  /* end of CSRs */


endmodule