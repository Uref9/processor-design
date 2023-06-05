// PrivilegeMode
`define UMODE 2'b00
`define MMODE 2'b11

module privilegeMode (
  input clk, reset_x, enable,
  input [1:0] i_nextPrivMode,

  output reg [1:0] o_nowPrivMode
);

  // Now Privilege Mode
  // U : 00
  // S : 01
  //(H : 10)
  // M : 11
  
  always @(posedge clk, negedge reset_x) begin
    if (!reset_x)
      o_nowPrivMode <= `UMODE;
    else if (enable)
      o_nowPrivMode <= i_nextPrivMode;
  end

  
endmodule