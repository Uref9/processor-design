module mux2 #(
  parameter WIDTH = 32
)(
  input [WIDTH-1:0]   i_1, i_2,
  input               i_sel,
  output [WIDTH-1:0]  o_1
);

  assign o_1 = i_sel ? i_2 : i_1;

endmodule