module PCReg(
  input i_clk, i_reset_x, i_enable_x,
  input [31:0] i_d,
  output reg [31:0] o_q
);

  parameter PC_ORIGIN = 32'h1_0000; // PC start position.

  always @(posedge i_clk, negedge i_reset_x) begin
    if (!i_reset_x)       o_q <= PC_ORIGIN;
    else if (i_enable_x)  o_q <= i_d;
    // else                o_q <= o_q;
  end

endmodule