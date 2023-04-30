module dffRst(
  input i_clk, i_reset_x,
  input [31:0] i_d,
  output reg [31:0] o_q
);

  always @(posedge i_clk, negedge i_reset_x) begin
    if (~i_reset_x) o_q <= 32'd0;
    else o_q <= i_d;
  end

endmodule