module dffRst(
  input i_clk, i_reset,
  input [31:0] i_d,
  output reg [31:0] o_q
);

  always @(posedge i_clk, posedge i_reset) begin
    if (i_reset) o_q <= 0;
    else o_q <= i_d;
  end

endmodule