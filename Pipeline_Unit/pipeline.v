module binaryDecoder (output reg[15:0] activate, input ld , input [3:0] sel);
  always@(ld, sel)
    begin
      case (sel)
        4'b0000: activate = 16'b1000000000000000;
        4'b0001: activate = 16'b0100000000000000;
        4'b0010: activate = 16'b0010000000000000;
        4'b0011: activate = 16'b0001000000000000;
        4'b0100: activate = 16'b0000100000000000;
        4'b0101: activate = 16'b0000010000000000;
        4'b0110: activate = 16'b0000001000000000;
        4'b0111: activate = 16'b0000000100000000;
        4'b1000: activate = 16'b0000000010000000;
        4'b1001: activate = 16'b0000000001000000;
        4'b1010: activate = 16'b0000000000100000;
        4'b1011: activate = 16'b0000000000010000;
        4'b1100: activate = 16'b0000000000001000;
        4'b1101: activate = 16'b0000000000000100;
        4'b1110: activate = 16'b0000000000000010;
        4'b1111: activate = 16'b0000000000000001;
      endcase
    end
endmodule

module mux16x1 (output reg [31:0] DataOut,input [3:0] s, input [31:0] A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P);
  always @(s, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P)
  case (s)
        4'b0000: DataOut = A;
        4'b0001: DataOut = B;
        4'b0010: DataOut = C;
        4'b0011: DataOut = D;
        4'b0100: DataOut = E;
        4'b0101: DataOut = F;
        4'b0110: DataOut = G;
        4'b0111: DataOut = H;
        4'b1000: DataOut = I;
        4'b1001: DataOut = J;
        4'b1010: DataOut = K;
        4'b1011: DataOut = L;
        4'b1100: DataOut = M;
        4'b1101: DataOut = N;
        4'b1110: DataOut = O;
        4'b1111: DataOut = P;
  endcase
endmodule

module registerfile (output [31:0] O1, O2, O3, PCout, input clk, lde, clr, input [3:0] s1,s2,s3, ddata, input [31:0] datain, PCIN);
  wire [31:0] data [15:0];// data register output to connect to the multiplexers 
  wire [15:0] enables; // transfering the activation from the decoder to the registers

  binaryDecoder Bdecoder(enables, lde, ddata);//Binary decoder

  registers R0 (data[0], datain, enables[15-0], clk, clr);
  registers R1 (data[1], datain, enables[15-1], clk, clr);
  registers R2 (data[2], datain, enables[15-2], clk, clr);
  registers R3 (data[3], datain, enables[15-3], clk, clr);
  registers R4 (data[4], datain, enables[15-4], clk, clr);
  registers R5 (data[5], datain, enables[15-5], clk, clr);
  registers R6 (data[6], datain, enables[15-6], clk, clr);
  registers R7 (data[7], datain, enables[15-7], clk, clr);
  registers R8 (data[8], datain, enables[15-8], clk, clr);
  registers R9 (data[9], datain, enables[15-9], clk, clr);
  registers R10 (data[10], datain, enables[15-10], clk, clr);
  registers R11 (data[11], datain, enables[15-11], clk, clr);
  registers R12 (data[12], datain, enables[15-12], clk, clr);
  registers R13 (data[13], datain, enables[15-13], clk, clr);
  registers R14 (data[14], datain, enables[15-14], clk, clr);

  registers R15 (data[15], datain, enables[15-15],clk, clr);// needs to be pc? must find a way to add 4 but also have the data that is passing through

  // //Multiplexers
  mux16to1 muxO1(O1, s1, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);
  mux16to1 muxO2(O2, s2, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);
  mux16to1 muxO3(O3, s3, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);

endmodule

module instRAM256x8 (output reg [31:0] DataOut, input[31:0] Address);
    reg[7:0] Mem[0:255];
    reg[31:0] temp;
    always@(Address)
        begin
            if(Address > 255)
                $display("Invalid address. Address must be between 0 and 255.");
            else
                begin
                    temp = Address & 32'hfffffffc;
                    DataOut = Mem[temp];
                    DataOut = DataOut << 8;
                    DataOut = DataOut + Mem[temp+1];
                    DataOut = DataOut << 8;
                    DataOut = DataOut + Mem[temp+2];
                    DataOut = DataOut << 8;
                    DataOut = DataOut + Mem[temp+3];
                end
        end
endmodule

module dataRAM256x8 (output reg [31:0] DataOut, input Enable, ReadWrite,
input[31:0] Address, input [31:0] DataIn, input [1:0] Mode);
    reg[7:0] Mem[0:255];
    reg[31:0] temp;
    //FIX: Declare DataIn Address, and other inputs
    always@(Enable, ReadWrite)
        if(Enable)
            if(!ReadWrite)//read
                case(Mode)
                    2'b00:  //Read Byte
                        DataOut = Mem[Address];
                    2'b01:  //Read Halfword: 2 bytes
                        begin
                            DataOut = Mem[Address];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+1];
                        end
                    2'b10:  //Read Word: 4 bytes
                        begin
                            DataOut = Mem[Address];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+1];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+2];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+3];
                        end
                    2'b11:  //Read Doubleword: 2 * 4 bytes
                        begin
                            //first word
                            DataOut = Mem[Address];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+1];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+2];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+3];
                            //second word
                            #6 DataOut = Mem[Address+4];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+5];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+6];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+7];
                        end
                endcase
            else//write
                case(Mode)
                    2'b00:  //Write Byte
                        Mem[Address] = DataIn;
                    2'b01:  //Write Halfword: 2 bytes
                        begin
                            temp = DataIn & 32'hff00;
                            temp = temp >> 8;
                            Mem[Address] = temp;
                            temp = DataIn & 32'hff;
                            Mem[Address+1] = temp;
                        end
                    2'b10:  //Write Word: 4 bytes
                        begin
                            temp = DataIn & 32'hff000000;
                            temp = temp >> 24;
                            Mem[Address] = temp;
                            temp = DataIn & 32'hff0000;
                            temp = temp >> 16;
                            Mem[Address+1] = temp;
                            temp = DataIn & 32'hff00;
                            temp = temp >> 8;
                            Mem[Address+2] = temp;
                            temp = DataIn & 32'hff;
                            Mem[Address+3] = temp;
                        end
                    2'b11:  //Write Doubleword: 2 * 4 bytes
                        begin
                            //do nothing
                        end
                endcase
endmodule

module mux2x1_13 (output reg [12:0] DataOut, input s,  input [12:0] A, B);
    always @(s, A, B)
        case(s)
            1'b0:  DataOut = A;
            1'b1:  DataOut = B;
        endcase
endmodule

module mux2x1_32 (output reg [31:0] DataOut, input s,  input [31:0] A, B);
    always @(s, A, B)
        case(s)
            1'b0:  DataOut = A;
            1'b1:  DataOut = B;
        endcase
endmodule

module mux4x1_32_32 (output reg [31:0] DataOut ,input [1:0] s, input [31:0] A, B, C, D);
  always @(s, A, B, C , D)
    case (s)
          2'b00: DataOut = A;
          2'b01: DataOut = B;
          2'b10: DataOut = C;
          2'b11: DataOut = D;
    endcase
endmodule

module adder (output reg [31:0] DataOut, input [31:0] pc, n, input clk);
    always@(pc, n, posedge clk)
        DataOut = pc + n;
endmodule

module sign_ext (output reg[31:0] TA, input[23:0] base);
	reg [25:0] ext;
	reg [31:0] temp;
	always @ (base)
		begin
			if(base[23]==1'b1)
				begin
					{ext}=~base+24'h000001;
					ext=ext*3'b100;
					{temp}=ext;
					TA=0-temp;
				end
			else
				begin
					{ext}=base;
					ext=ext*3'b100;
					{TA}=0-ext;
				end
		end
endmodule

module pipelinePU;
//precharge Instruction RAM *TESTED*
    integer I_inFile, I_code;
    reg [7:0] data;
    reg [31:0] I_Address;
    wire [31:0] I_DataOut;
    instRAM256x8 ramI(I_DataOut, I_Address);
    initial
        begin
            I_inFile = $fopen("ramintr.txt","r");
            I_Address = 32'b0;
            $display("");
            $display("Instruction RAM was precharged with the following data:");
            $display("        Address   Data");
            while(!$feof(I_inFile))
                begin
                    #1 I_code = $fscanf(I_inFile, "%b", data);
                    ramI.Mem[I_Address] = data;
                    #7 $display("%d        %b", I_Address, data);
                    #2 I_Address = I_Address + 1; 
                end
            $fclose(I_inFile);
        end
//
//System Variables
    reg global_clk;
//IF variables
    wire [31:0] mux1_out;
    wire mux1_sel;
    wire [31:0] adder1_out;
    wire [31:0] ramI_out;
//ID variables
    wire [31:0] adder2_out;
    wire [31:0] pc_out;
    wire [31:0] mux2_out;
    wire [31:0] mux3_out;
    wire [31:0] mux4_out;
    wire [12:0] mux5_out;
    wire [31:0] signExt1_out;
//Instruction Fetch
    mux2x1_32 mux1(mux1_out, mux1_sel, adder2_out, adder1_out);
        //output to register
    adder adder1(adder1_out, pc_out, 32'h04, global_clk);
        // output to register
        // output to previous mux *DONE*
    instRAM256x8 ramI(ramI_out, pc_out);
        // output to register

//Instruction Decode
    //register file
        //output to previous phase instruction RAM
        //output to mux1
        //output to mux2
        //output to mux3
    mux4x1_32 mux2(mux2_out);
        //output to register
    mux4x1_32 mux3(mux3_out);
        //output to register
    mux4x1_32 mux4(mux4_out);
        //output to register
    sign_ext signExt1(signExt1_out, /*FROM REG*/);
        //output to adder2
        //output to previous phase mux
    adder adder2(adder2_out, signExt1_out, /*FROM REG*/);
    mux2x1_13 mux5(mux5_out, 13'h0, /*FROM CPU*/);
//Execution Phase
mux 2*1
    output to ALU
sign extender
    output to previous mux
mux 2*1
    output to ALU
ALU
    output to register
*/
endmodule

/* Execution Phase
mux 2*1
    output to ALU
sign extender
    output to previous mux
mux 2*1
    output to ALU
ALU
    output to register
*/


/* Memory Phase
data memory
    output to register
mux2x1
    output to mux1 mux2 mux3
*/


/* Writeback Phase
mux 2*1
*/