module mux2(
  input [31:0] i_1, i_2,
  input i_sel,
  output [31:0] o_1
);

  assign o_1 = i_sel ? i_2 : i_1;

endmodule