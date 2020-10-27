module instRAM256x8 (output reg [31:0] DataOut, input[31:0] Address);
    reg[7:0] Mem[0:255];
    always@(Address)
            DataOut = Mem[Address];
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

module mux2x1 (output reg [31:0] DataOut, input s,  input [31:0] A, B);
    always @(s, A, B)
        case(s)
            1'b0:  DataOut = A;
            1'b1:  DataOut = B;
        endcase
endmodule

module adder (output reg [31:0] DataOut, input [31:0] pc, n, input clk);
    always@(pc, n, posedge clk)
        DataOut = pc + n;
endmodule

//mux2x1_7 should be changed to mux2x1_13

module pipelinePU
/////////////////////
//Instruction Fetch//
///////////////////// 
    reg [31:0] I_Address;
    wire [31:0] mux1_out;
    wire [31:0] adder1_out;
    wire [31:0] ramI_out;
    
    mux2x1 mux1();

    adder adder1();
    // output to register
    // output to previous mux
    instRAM256x8 ramI(ramI_out, I_Address);
    // instruction RAM
    //     output to register

endmodule




/* Instruction Decode Phase
register file
    output to previous phase instruction RAM
    output to mux1
    output to mux2
    output to mux3
mux1 4*1
    output to register
mux2 4*1
    output to register
mux3 4*1
    output to register
sign extender
    output to adder
        output to previous phase mux
*/


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