module dffREC #(
  parameter WIDTH = 32,
  parameter INITIAL_VALUE = 32'b0
)(
  input i_clock, i_reset_x, i_enable, i_clear,
  input [31:0] i_d,
  output reg [31:0] o_q
);

  always @(posedge i_clock, negedge i_reset_x) begin
    if (!i_reset_x)       o_q <= INITIAL_VALUE;
    else if (i_enable)
      if (i_clear)        o_q <= INITIAL_VALUE;
      else                o_q <= i_d;
  end

  
endmodule