`timescale 1ns/1ps
`define IN_TOTAL 100000000000
// `include "single/top.v"

module top_test;
   
   //*** parameter declarations ***//
   parameter CYCLE       = 10;
   parameter HALF_CYCLE  =  5;
   parameter STB         =  8;
   parameter SKEW        =  2;
   parameter BIT_WIDTH    = 32;
   parameter BYTE_SIZE    =  8;
   parameter IMEM_LATENCY = 1;  // instruction memory latency
   parameter DMEM_LATENCY = 1;  // data memory latency
   parameter IMEM_START = 32'h0000_0000;
   parameter DMEM_START = 32'h0800_0000;
   parameter IMEM_SIZE = 8000000;  // instruction memory size
   parameter DMEM_SIZE = 8000000;  // data memory size
   parameter STDOUT_ADDR = 32'hf0000000;
   parameter EXIT_ADDR = 32'hff000000;

   //*** reg,wire declarations ***//
   reg       clk,rst;
   reg       ACKD_n;
   reg       ACKI_n;
   reg [BIT_WIDTH-1:0] IDT;
   reg [2:0]           OINT_n;
   reg [BIT_WIDTH-1:0] Reg_temp;

   wire [BIT_WIDTH-1:0] IAD;
   wire [BIT_WIDTH-1:0] DAD;
   wire                 MREQ;
   wire                 WRITE;
   wire [1:0]           SIZE;
   wire                 IACK_n;
   wire [BIT_WIDTH-1:0] DDT;

   integer              i;
   integer              CIL, CDLL, CDSL;  // counter for emulate memory access latency
   integer              Reg_data, Dmem_data, Imem_data;   // file pointer for "Reg_out.dat", "Dmem.out"
   integer              Max_Daddr;  // integer for remenbering maximum accessed addr of data memory
   reg [BIT_WIDTH-1:0]  Daddr, Iaddr;

   reg [BYTE_SIZE-1:0]   DATA_Imem[IMEM_START:IMEM_START + IMEM_SIZE];   // use in readmemh  (Instruction mem)       
   reg [BYTE_SIZE-1:0]   DATA_Dmem[DMEM_START:DMEM_START + DMEM_SIZE];   // use in readmemh (Data mem)

   //*** module instantations ***//
   top u_top_1(//Inputs
               .clk(clk), .rst(rst),
               .ACKD_n(ACKD_n), .ACKI_n(ACKI_n), 
               .IDT(IDT), .OINT_n(OINT_n),
      
               //Outputs
               .IAD(IAD), .DAD(DAD), 
               .MREQ(MREQ), .WRITE(WRITE), 
               .SIZE(SIZE), .IACK_n(IACK_n), 
      
               //Inout
               .DDT(DDT)
               );
   
   //*** clock generation ***//
   always begin
      clk = 1'b1;
      #(HALF_CYCLE) clk = 1'b0;
      #(HALF_CYCLE);
   end

   //*** initialize ***//
   initial begin
      //*** read input data ***//
      $readmemh("single/test/mem/Imem.dat", DATA_Imem);
      $readmemh("single/test/mem/Dmem.dat", DATA_Dmem);

      Max_Daddr = 0;

      //*** reset OINT_n, ACKI_n, ACKD_n, CIL, CDL ***//
      OINT_n = 3'b111;
      ACKI_n = 1'b1;
      ACKD_n = 1'b1;
      CIL = 0;
      CDLL = 0;
      CDSL = 0;

      //*** reset ***//
      rst = 1'b1;
      #1 rst = 1'b0;
      #CYCLE rst = 1'b1;
   end

   // mine
   
   initial begin
      #HALF_CYCLE;
      
      //*** data input loop ***//
      for (i = 0; i < `IN_TOTAL; i = i + 1) begin
         Iaddr = u_top_1.IAD;            
         fetch_task1;

         Daddr = u_top_1.DAD;
         load_task1;
         store_task1;
         
         // if (0 < i && i < 35) begin
         //    // $display("--- info registers ---");
         //    info_registers_task;
         //    // $display("--- end i.r. ---");
         // end
         
         // #(STB);
         #CYCLE;
         release DDT;
      end // for (i = 0; i < `IN_TOTAL; i =i +1)

      $display("\nReach IN_TOTAL.");
      dump_task1;
      info_registers_task;
      $finish;

   end // initial begin

   //*** description for wave form ***//
   initial begin
      // $monitor($stime," PC=%h INST=%h", IAD, IDT);
      // $monitor($stime," PC=%h INST=%h DAD=%h Daddr=%h DDT=%h", IAD, IDT, DAD, Daddr, DDT);
      // $monitor($stime," PC= %h INST= %b %b %b %b", IAD, IDT[31:12], IDT[11:7], IDT[6:2], IDT[1:0]);
      // $monitor($stime," PC= %h INST= %b %b %b %b", IAD, IDT[31:12], IDT[11:7], IDT[6:2], IDT[1:0],
      //                   " : DAD=%h DDT=%h", Daddr, DDT);
   // For Icarus verilog
      // $dumpfile("top_test.vcd");
      $dumpfile("./single/test/log/top_test.vcd");
      $dumpvars(0, u_top_1);
   // For NCverilog
      //$shm_open("waves.shm");
      //$shm_probe("AS");
   end


   //*** tasks ***//
   task  info_registers_task;
      integer i;
      for (i =0; i < 32; i = i+1)  // output register to Reg_data (Reg_out.dat)
      begin
         Reg_temp = u_top_1.datapath.register
                     .u_DW_ram_2r_w_s_dff.mem >> (BIT_WIDTH * i);
         if (((i+1) % 4) != 0) begin
            $write("[x%2d]: %h ", i, Reg_temp);
         end
         else begin
            $display("[x%2d]: %h ", i, Reg_temp);
         end
      end
   endtask

   task fetch_task1;
      begin
         CIL = CIL + 1;
         if(CIL == IMEM_LATENCY)
            begin
               IDT = {DATA_Imem[Iaddr], DATA_Imem[Iaddr+1], 
                        DATA_Imem[Iaddr+2], DATA_Imem[Iaddr+3]};

               ACKI_n = 1'b0;
               CIL = 0;
            end
         else
            begin
               IDT = 32'hxxxxxxxx;
               ACKI_n = 1'b1;
            end // else: !if(CIL == IMEM_LATENCY)
      end
   endtask // fetch_task1
   
   task load_task1;
      begin
         if(u_top_1.MREQ && !u_top_1.WRITE)
         begin

            if (Max_Daddr < Daddr)
               begin
                  Max_Daddr = Daddr;
               end

            CDLL = CDLL + 1;
            CDSL = 0;
            if(CDLL == DMEM_LATENCY)
               begin
                  if(SIZE == 2'b00)
                     begin
                        force DDT[BIT_WIDTH-1:0] = {DATA_Dmem[Daddr], DATA_Dmem[Daddr + 1],
                                                   DATA_Dmem[Daddr + 2], DATA_Dmem[Daddr + 3]};
                     end
                  else if(SIZE == 2'b01)
                     begin
                        force DDT[BIT_WIDTH-1:0] = {{16{1'b0}}, DATA_Dmem[{Daddr[BIT_WIDTH-1:2],2'b10} - Daddr[1:0]], 
                                       DATA_Dmem[{Daddr[BIT_WIDTH-1:2],2'b10} - Daddr[1:0] + 1]};
                     end
                  else
                     begin
                        force DDT[BIT_WIDTH-1:0] = {{24{1'b0}}, DATA_Dmem[{Daddr[BIT_WIDTH-1:2],2'b11} - Daddr[1:0]]};
                     end // else: !if(SIZE == 2'b01)

                  ACKD_n = 1'b0;
                  CDLL = 0;

               end // if (CDLL == DMEM_LATENCY)
            else
               begin
                  ACKD_n = 1'b1;
               end // else: !if(CDLL == DMEM_LATENCY)
         end // if (u_top_1.MREQ && !u_top_1.WRITE)
      end
   endtask // load_task1
   
   task store_task1;
      begin
         if(u_top_1.MREQ && u_top_1.WRITE)
         begin

            if (Daddr == EXIT_ADDR)
               begin
                  $display("\nExited by program.");
                  $display("TOTAL: %d [ns]", i*CYCLE);

                  // dump_task1;
                  info_registers_task;

                  $finish;
               end
            else if (Daddr != STDOUT_ADDR)
               begin
                  if (Max_Daddr < Daddr)
                     begin
                        Max_Daddr = Daddr;
                     end
               end

            CDSL = CDSL + 1;
            CDLL = 0;

            if(CDSL == DMEM_LATENCY)
               begin
                  if(SIZE == 2'b00)
                     begin
                        DATA_Dmem[Daddr]   = DDT[BIT_WIDTH-1:BIT_WIDTH-8];
                        DATA_Dmem[Daddr+1] = DDT[BIT_WIDTH-9:BIT_WIDTH-16];
                        DATA_Dmem[Daddr+2] = DDT[BIT_WIDTH-17:BIT_WIDTH-24];
                        DATA_Dmem[Daddr+3] = DDT[BIT_WIDTH-25:BIT_WIDTH-32];
                     end
                  else if(SIZE == 2'b01)
                     begin
                        DATA_Dmem[{Daddr[BIT_WIDTH-1:2],2'b10} - Daddr[1:0]] = DDT[BIT_WIDTH-17:BIT_WIDTH-24];
                        DATA_Dmem[{Daddr[BIT_WIDTH-1:2],2'b10} - Daddr[1:0] + 1] = DDT[BIT_WIDTH-25:BIT_WIDTH-32];
                     end
                  else
                     begin
                        if (Daddr == STDOUT_ADDR)
                        begin
                           $write("%c", DDT[BIT_WIDTH-25:BIT_WIDTH-32]);
                        end
                        else
                        begin
                           DATA_Dmem[{Daddr[BIT_WIDTH-1:2],2'b11} - Daddr[1:0]] = DDT[BIT_WIDTH-25:BIT_WIDTH-32];
                        end
                     end // else: !if(SIZE == 2'b01)
                  
                  ACKD_n = 1'b0;
                  CDSL = 0;

               end // if (CDSL == DMEM_LATENCY)
            else
               begin
                  ACKD_n = 1'b1;
               end // else: !if(CDSL == DMEM_LATENCY)
         end // if (u_top_1.MREQ && u_top_1.WRITE)             
      end
   endtask // store_task1

   task dump_task1;
      begin
      // Imem_data = $fopen("./Imem_out.dat");
      Imem_data = $fopen("./single/test/log/Imem_out.dat");
      for (i = IMEM_START; i <= IMEM_START + IMEM_SIZE; i = i+4)  // output data memory to Dmem_data (Dmem_out.dat)
         begin
            $fwrite(Imem_data, "%h :%h %h %h %h\n", i, DATA_Imem[i], DATA_Imem[i+1], DATA_Imem[i+2], DATA_Imem[i+3]);
         end
      $fclose(Imem_data);

      // Dmem_data = $fopen("./Dmem_out.dat");
      Dmem_data = $fopen("./single/test/log/Dmem_out.dat");
      for (i = DMEM_START; i <= DMEM_START + DMEM_SIZE; i = i+4)  // output data memory to Dmem_data (Dmem_out.dat)
         begin
            $fwrite(Dmem_data, "%h :%h %h %h %h\n", i, DATA_Dmem[i], DATA_Dmem[i+1], DATA_Dmem[i+2], DATA_Dmem[i+3]);
         end
      $fclose(Dmem_data);
      
      // mine
      info_registers_task;

      // Reg_data = $fopen("./Reg_out.dat");
      // Reg_data = $fopen("./test/log/Reg_out.dat");
      // for (i =0; i < 32; i = i+1)  // output register to Reg_data (Reg_out.dat)
      //    begin
      //       Reg_temp = u_top_1.id_stage.regfile.u_DW_ram_2r_w_s_dff.mem >> (BIT_WIDTH * i);
      //       $fwrite(Reg_data, "%d:%h\n", i, Reg_temp);
      //    end
      // $fclose(Reg_data);
      end
   endtask // dump_task1

endmodule // top_test
