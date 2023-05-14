module load2Cycle (
  input i_clk,
  input [6:0] i_opcode,

  output reg o_PCEnable_x,
  output reg o_regWriteLoad = 1'b0
);
  reg r_loadCount = 1'b0;
  // reg r_prevLoad = 1'b0;

  always @(negedge i_clk) begin
    if (i_opcode[6:2] == 5'b00000) begin // Load type
      if (r_loadCount) begin
      // Load count
        // r_prevLoad      <= 1'b1;
        r_loadCount     <= 1'b0;
        o_PCEnable_x      <= 1'b1;
        o_regWriteLoad  <= 1'b1;
      end else begin
      // Load !count
        // r_prevLoad     <= 1'b1;
        r_loadCount     <= 1'b1;
        o_PCEnable_x      <= 1'b0;
        o_regWriteLoad  <= 1'b0;
      end
    end else begin
      // if (r_prevLoad) begin
      // notLoad prev (!count)
        // r_prevLoad     <= 1'b0;
        r_loadCount     <= 1'b0;
        o_PCEnable_x      <= 1'b1;
        o_regWriteLoad  <= 1'b1;
      // end else begin
      // notLoad !prev (!count)
        // r_prevLoad  <= 1'b0;
        // r_loadCount <= 1'b0;
        // o_PCEnable_x  <= 1'b1;
        // o_regWriteLoad <= 1'b1;
      // end
    end
  end
  
endmodule