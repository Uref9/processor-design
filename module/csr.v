module csr (
  // from test
  input clk, reset,
  // from datapath
  input [31:0] Di_PC,
  // from controller
  input Di_ecall,

  // to datapath
  output reg [31:0] Do_epc
);

  /* csrReg part */
  reg [31:0] mepc, mcause, mtvec;
  reg mstatusb3, mstatusb7; // MIE, MPIE

  always @(posedge clk, negedge reset) begin
    if (!reset) begin
      mepc <= 32'b0;
      mcause <= 32'b0;
      mtvec <= 32'b0;
      mstatusb3 <= 1'b1;
      mstatusb7 <= 1'b1;
    end
    else begin
      case (Di_ecall)
        1'b1: begin
          mepc <= Di_PC; 
          mcause <= 32'b0_000_0000_0000_0000_0000_0000_0000_1011; // 0 : 11 
          mstatusb3 <= 1'b0;
          Do_epc <= mtvec;
        end
      endcase
      
    end
  end


endmodule