// `include "module/immExtend.v"

module immExtend_test ();
  reg [2:0] i_immSrc;
  reg [31:0]i_inst;

  wire [31:0] o_immExt;

  reg [31:0] ans;
  reg res;


  immExtend imm_extend(
    .i_immSrc, .i_inst, 
    .o_immExt
  );

  function check;
    input [2:0] i_immSrc;
    input [31:0] o_immExt, ans;
    if (o_immExt !== ans) begin
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $display("%b failed.", i_immSrc);
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $finish;
    end
  endfunction
  
  // initial begin
  //   $display("+++++++++++++++++++++++++++++++++++++++++++");
  //   $display("+++++++++++++++++++++++++++++++++++++++++++");
  //   $monitor("%b : %b\n    : %b\nans : %b\n---------------------",
  //             i_immSrc, i_inst, o_immExt, ans);
  // end

  initial begin

      i_immSrc  = 3'b000;
      i_inst    = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
      ans       = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    
    #1 // I load+
      i_immSrc  = 3'b000;
      i_inst    = 32'b1111_1111_1111_0000_0000_0000_0000_0000;
      ans       = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
      #1
        res = check(i_immSrc, o_immExt, ans);
    
    #1 // I R+i 
      i_immSrc  = 3'b001;
      i_inst    = 32'b0111_1111_1111_0000_0000_0000_0000_0000;
      ans       = 32'b0000_0000_0000_0000_0000_0111_1111_1111;
      #1
        res = check(i_immSrc, o_immExt, ans);
    
    #1 // I sll, shamt
      i_immSrc  = 3'b010;
      i_inst    = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
      ans       = 32'b0000_0000_0000_0000_0000_0000_0001_1111;
      #1
        res = check(i_immSrc, o_immExt, ans);
    
    #1 // S
      i_immSrc  = 3'b011;
      i_inst    = 32'b1111_1110_0000_0000_0000_1111_1000_0000;
      ans       = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
      #1
        res = check(i_immSrc, o_immExt, ans);
    
    #1 // U
      i_immSrc  = 3'b100;
      i_inst    = 32'b1111_1111_1111_1111_1111_0000_0000_0000;
      ans       = 32'b1111_1111_1111_1111_1111_0000_0000_0000;
      #1
        res = check(i_immSrc, o_immExt, ans);
    
    #1 // B
      i_immSrc  = 3'b101;
      i_inst    = 32'b1111_0000_1111_0000_1111_0000_1111_0000;
      ans       = 32'b1111_1111_1111_1111_1111_1111_0000_0000;
      #1
        res = check(i_immSrc, o_immExt, ans);
    
    #1 // I jalr
      i_immSrc  = 3'b110;
      i_inst    = 32'b1000_0000_0001_0000_0000_0000_0000_0000;
      ans       = 32'b1111_1111_1111_1111_1111_1000_0000_0001;
      #1
        res = check(i_immSrc, o_immExt, ans);
    
    #1 // J
      i_immSrc  = 3'b111;
      i_inst    = 32'b1111_0000_1111_0000_1111_0000_1111_0000;
      ans       = 32'b1111_1111_1111_0000_1111_1111_0000_1110;
      #1
        res = check(i_immSrc, o_immExt, ans);
    
    #1 // ???
      i_immSrc  = 3'bxxx;
      i_inst    = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
      ans       = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
      #1
        res = check(i_immSrc, o_immExt, ans);
    
    #1
      $display("unit test passed.");
      $finish;
  end
  
endmodule