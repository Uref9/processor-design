// `include "module/readDataExtend.v"

module readDataExtend_test ();
  reg i_readDataSrc;
  reg [1:0] i_memSize;
  reg [31:0] i_readData;

  wire [31:0] o_readDataExt;

  reg [31:0] ans;
  reg res;

  readDataExtend read_data_extend (
    .i_readDataSrc, .i_memSize,
    .i_readData, 
    .o_readDataExt
  );

  function check;
    input i_readDataSrc;
    input [1:0] i_memSize;
    input [31:0] i_readData;
    input [31:0] o_readDataExt, ans;

    if (o_readDataExt !== ans) begin
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $display("%b : %b failed.", i_readDataSrc, i_memSize);
      $display("!!!!!!!!!!!!!!!!!!!!!!!!");
      $finish;
    end
  endfunction

  // initial begin
  //   $display("++++++++++++++++++++++++");
  //   $display("++++++++++++++++++++++++");
  //   $monitor ("%b(%2d) : %b %b\n", i_readDataSrc, i_readDataSrc, i_1, i_2,
  //             "        => %b [z:%b][ng:%b][nU:%b]\n", o_1, o_zero, o_neg, o_negU,
  //             "     ans : %b\n", ans,
  //             "-----------------------");
  // end

  initial begin
        i_readDataSrc = 1'b0;
        i_memSize     = 2'b00;
        i_readData    = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
        ans           = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
      
    #1 // (0:xx) load unsigned (through)
        i_readDataSrc = 1'b0;
        i_memSize     = 2'b00;
        i_readData    = 32'b0000_0000_0000_0000_1000_0000_1000_0000;
        ans           = 32'b0000_0000_0000_0000_1000_0000_1000_0000;
        #1
        res = check(i_readData, i_memSize, i_readData, o_readDataExt, ans);

    #1 // (1:xx) load signed
      #1 // (1:00) word
        i_readDataSrc = 1'b1;
        i_memSize     = 2'b00;
        i_readData    = 32'b0000_0000_0000_0000_1000_0000_1000_0000;
        ans           = 32'b0000_0000_0000_0000_1000_0000_1000_0000;
        #1
        res = check(i_readData, i_memSize, i_readData, o_readDataExt, ans);

      #1 // (1:01) half word
        i_readDataSrc = 1'b1;
        i_memSize     = 2'b01;
        i_readData    = 32'b0000_0000_0000_0000_1000_0000_1000_0000;
        ans           = 32'b1111_1111_1111_1111_1000_0000_1000_0000;
        #1
        res = check(i_readData, i_memSize, i_readData, o_readDataExt, ans);

      #1 // (1:10) byte
        i_readDataSrc = 1'b1;
        i_memSize     = 2'b10;
        i_readData    = 32'b0000_0000_0000_0000_1000_0000_1000_0000;
        ans           = 32'b1111_1111_1111_1111_1111_1111_1000_0000;
        #1
        res = check(i_readData, i_memSize, i_readData, o_readDataExt, ans);

      #1 // (1:11) byte2
        i_readDataSrc = 1'b1;
        i_memSize     = 2'b11;
        i_readData    = 32'b0000_0000_0000_0000_1000_0000_1000_0000;
        ans           = 32'b1111_1111_1111_1111_1111_1111_1000_0000;
        #1
        res = check(i_readData, i_memSize, i_readData, o_readDataExt, ans);

      #1 // (1:00) word
        i_readDataSrc = 1'b1;
        i_memSize     = 2'b00;
        i_readData    = 32'b0000_0000_0000_0000_1000_0000_1000_0000;
        ans           = 32'b0000_0000_0000_0000_1000_0000_1000_0000;
        #1
        res = check(i_readData, i_memSize, i_readData, o_readDataExt, ans);

    #1
    $display("unit test passed.");
    $finish;
  end
endmodule