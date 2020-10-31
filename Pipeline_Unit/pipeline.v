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

module registerfile (output [31:0] O1, O2, O3, PCout, input clk, lde, clr, LE_PC, input [3:0] s1,s2,s3, ddata, 
input [31:0] datain, PCIN);
    //Stating the wires
    wire [31:0] data [15:0];// data register output to connect to the multiplexers 
    wire [15:0] enables; // transfering the activation from the decoder to the registers
    wire [31:0] addedPCin; //from adder to mux2x1
    wire [31:0] chosenData;//mux to register 15

    //Connecting the Modules
    binaryDecoder Bdecoder(enables, lde, ddata);//Binary decoder

    //15 registers
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

    //PC
    adder4 pcadder(addedPCin, PCIN, 32'd4, clk);
    mux2x1 pcmux(chosenData, LE_PC, datain, addedPCin);

    registers R15 (data[15], chosenData, enables[15-15],clk, clr);// decision done

    // //Multiplexers
    mux16to1 muxO1(O1, s1, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);
    mux16to1 muxO2(O2, s2, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);
    mux16to1 muxO3(O3, s3, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);
endmodule

module flagregister(output reg [3:0] CC_out, output reg C_in, input [3:0] CC_in, input s);
    always@ (s)
        begin
            if (s) 
                begin
                CC_out = CC_in;
                C_in <= CC_in;
                end
            $display("Input: %h", CC_in);
            $display("output: %h", CC_out);
        end
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

module mux2x1_1 (output reg DataOut, input s, A, B);
    always @(s, A, B)
        case(s)
            1'b0:  DataOut = A;
            1'b1:  DataOut = B;
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

module shifter (output reg[31:0] OUT, output reg shifter_carry_out, input [31:0] RM, input[11:0] L, input[1:0] M, input C_in);
    reg [31:0] temp;
    always @ (L, RM)
        // Addressing Mode 1: Data processing
        // Immediate - ARM Manual A5.1.3
		case(M)
            2'b00:	begin
						{temp} = L[7:0];
						{OUT} = {temp, temp} >> (2 * L[11:8]);
						// Update shifter_carry_out
                    	if(L[11:8] == 4'b0000) 
							shifter_carry_out = C_in;
						else
							shifter_carry_out = OUT[31];
					end
            // Shift by Immediate Shifter
            2'b01:
                // L[11:7] = shift_imm.
                // L[6:5] = shift:= LSL | LSR | ASR | ROR
                    // LSL = Logical Shift Left - ARM Manual A5.1.5
                    // shifter_operand = Rm logically shifted to the left 'shift_imm' times.
                    if(L[6:5]==2'b00)  
							if(L[11:7] == 5'b00000)// Operand Register - ARM Manual A5.1.4
                                begin
                                    {OUT} <= RM;
                                    shifter_carry_out <= C_in;
                                end
                            else
                                begin
                                    {OUT} <= RM << L[11:7];
                                    shifter_carry_out <= RM[32-{L[11:7]}];
                                end
                    // LSR = Logical Shift Right - ARM Manual A5.1.7
                    // shifter_operand = Rm logically shifted to the right 'shift_imm' times.
                    else if(L[6:5]==2'b01)
							if(L[11:7] == 5'b00000)
                                begin
                                    {OUT} <= 32'b0;
                                    shifter_carry_out <= RM[31];
                                end
                            else
                                begin
                                    {OUT} <= RM >> L[11:7];
                                    shifter_carry_out <= RM[{L[11:7]}-1];
                                end
					// ASR = Arithmetic Shift Right - ARM Manual A5.1.9			
                    else if(L[6:5]==2'b10)  
							if(L[11:7] == 5'b00000)
                                if(RM[31] == 1'b0)
                                    begin
                                        {OUT} <= 32'b0;
                                        shifter_carry_out <= RM[31];
                                    end
                                else
                                    begin
                                        {OUT} <= 32'hFFFFFFFF;
                                        shifter_carry_out <= RM[31];
                                    end
                            else
                                begin
                                    {OUT} <= $signed(RM) >>> L[11:7];
                                    shifter_carry_out <= RM[{L[11:7]}-1];
                                end
                    // ROR = Rotate Right - ARM Manual A5.1.11
                    // shifter_operand = Rm rotated to the right 'shift_imm' times.
                    else
							if(L[11:7] == 5'b00000) // (Rotate right with extend - ARM Manual A5.1.13)
                                begin
                                    {OUT} <= (C_in << 31) | (RM >> 1);
                                    shifter_carry_out <= RM[0];
                                end
                            else
                                begin
                                    {OUT} <= {RM, RM} >> L[11:7];
                                    shifter_carry_out <= RM[{L[11:7]}-1];
                                end
			// Addressing Mode 2: Load Store
			//Immidiate Offset
			2'b10:  begin
						{OUT} <= L[11:0];
					end
			2'b11:	begin
						if(L[11:5]==7'b0)//Register Offset
							begin
							{OUT} <= RM;
							end
						else if(L[6:5]==2'b00)//LSL
							{OUT} <= RM << L[11:7];
						else if(L[6:5]==2'b01)//LSR
							begin
								if(L[11:7]==5'b00000)
									{OUT} <= 32'b0;
								else 
									{OUT} <= RM >> L[11:7];
							end
						else if(L[6:5]==2'b10)//ASR
							begin
								if(L[11:7] == 5'b00000)
									if(RM[31] == 1'b0)
											{OUT} <= 32'b0;
									else
										{OUT} <= 32'hFFFFFFFF;
								else
									{OUT} <= $signed(RM) >>> L[11:7];
							end
						else//ROR/RRX
							begin 
								if(L[11:7] == 5'b00000) 
                                    {OUT} <= (C_in << 31) | (RM >> 1);
								else
									{OUT} <= {RM, RM} >> L[11:7];
							end
					end
		endcase
endmodule

module alu (output reg [31:0] O, output reg [3:0] CondCode, input [31:0] A, B, input [3:0] OP, input C_in, shifter_carry_out);
    // A = Rn
    // B = shifter_operand
    // O = Rd
    // Flag[0] = V(Overflow)
    // Flag[1] = C(Carry)
    // Flag[2] = Z(Zero)
    // Flag[3] = N(Negative)
	// CondCode ARM Manual Section A2.5.2
    always@(OP, A, B)
        case(OP)
                                                        //                                   Status CondCode  ARM Manual
                                                        //                                    N  Z  C  V    Section
            4'b0000: begin                             // AND - Logical AND                  *  *  /  -    A4.1.4
                      O = A & B;                        // Save Operation
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                      CondCode[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b0001: begin                             // EOR - Logical Exclusive OR         *  *  /  -    A4.1.18
                      O = A ^ B;                        // Save Operation
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                      CondCode[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b0010: begin                             // SUB - Subtract                     *  *  *  *    A4.1.106
                      {CondCode[1], O} = A - B;            // Save Subtraction, C Flag Update
                      CondCode[0] = (A[31] != B[31])       // V Flag Update
                                  && (O[31] == B[31]);
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                    end
            4'b0011: begin                             // RSB - Reverse Subtract             *  *  *  *    A4.1.60
                      {CondCode[1], O} = B - A;            // Save Subtraction, C Flag Update
                      CondCode[0] = (A[31] != B[31])       // V Flag Update
                                  && (O[31] == A[31]);
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                    end
            4'b0100: begin                             // ADD - Addition                     *  *  *  *    A4.1.3
                      {CondCode[1], O} = A + B;            // Save Addition, C Flag Update
                      CondCode[0] = (A[31] == B[31])       // V Flag Update
                                && (A[31] != O[31]);
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                    end
            4'b0101: begin                             // ADC - Addition with Carry          *  *  *  *    A4.1.2
                      {CondCode[1], O} = A + B + C_in;     // Save Addition, C Flag Update
                      CondCode[0] = ((A[31] == B[31])      // V Flag Update
                                && A[31] != O[31]);
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                    end
            4'b0110: begin                             // SBC - Subtract with Carry          *  *  *  *    A4.1.65
                      {CondCode[1], O} = A - B - ~C_in;    // Save Subtraction, C Flag Update
                      CondCode[0] = (A[31] != B[31])       // V Flag Update
                                  && (O[31] == B[31]);
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                    end
            4'b0111: begin                             // RSC - Reverse Subtract with Carry  *  *  *  *    A4.1.61
                      {CondCode[1], O} = B - A - ~C_in;    // Save Subtraction, C Flag Update
                      CondCode[0] = (A[31] != B[31])       // V Flag Update
                                  && (O[31] == A[31]);
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                    end
            4'b1000: begin                             // TST - Test             (AND)       *  *  /  -    A4.1.117
                      O = A & B;
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                      CondCode[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b1001: begin                             // TEQ - Test Equivalence (EOR)       *  *  /  -    A4.1.116
                      O = A ^ B;
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                      CondCode[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b1010: begin                             // CMP - Compare          (SUB)       *  *  *  *    A4.1.15
                      {CondCode[1], O} = A - B;            // Save Subtraction, C Flag Update
                      CondCode[0] = (A[31] != B[31])       // V Flag Update
                                  && (O[31] == B[31]);
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                    end
            4'b1011: begin                             // CMN - Compare Negated  (ADD)       *  *  *  *    A4.1.14
                      {CondCode[1], O} = A + B;            // Save Addition, C Flag Update
                      CondCode[0] = (A[31] == B[31])       // V Flag Update
                                && (A[31] != O[31]);
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                    end
            4'b1100: begin                             // ORR - Logical OR                   *  *  /  -    A4.1.42
                      O = A | B;                        // Save Operation
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                      CondCode[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b1101: begin                             // MOV - Move                         *  *  /  -    A4.1.35
                      O = B;                            // Save Operation
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                      CondCode[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b1110: begin                             // BIC - Bit Clear                    *  *  /  -    A4.1.6
                      O = A & ~B;                       // Save Operation
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                      CondCode[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b1111: begin                             // MVN - Move Not                     *  *  /  -    A4.1.41
                      O = ~B;                           // Save Operation
                      CondCode[3] = O[31];                 // N Flag Update
                      CondCode[2] = !O;                    // Z Flag Update
                      CondCode[1] = shifter_carry_out;     // C Flag Update
                    end
        endcase
endmodule

module cpu (output reg[12:0] IS, output reg ID_B, ID_RF_clear, input [31:0] IR, input Cond); 
	always @ (IR) 
		if (IR[31:0] == 32'h00000000||!Cond)//NOP
			begin
				IS[11:8] <= 4'b0000;
				IS[1:0] <= 2'b00;
				IS[3:2] <= 2'b00;
				IS[7] <= 1'b0; 
				ID_B <= 1'b0;
				IS[6] <= 1'b0; 
				IS[4] <= 1'b0; 
				IS[5] <= 1'b0;
				IS[12] <= 1'b0;
				ID_RF_clear<=1'b0;
			end
		else if (IR[27:26]== 2'b00) // Data Processing		
			if(IR[25]== 1'b0) // Immidiate Register shifts
				if(IR[11:4]== 8'h00) //No Shifts
					begin
						IS[11:8] <= IR[24:21];
						IS[1:0] <= 2'b01;
						IS[3:2] <= 2'b00;
						IS[7] <= 1'b0; 
						ID_B <= 1'b0;
						IS[6] <= 1'b1; 
						IS[4] <= 1'b0; 
						IS[5] <= 1'b0;
						IS[12] <= 1'b0;
						ID_RF_clear<=1'b1;
					end
				else begin //Shifts Register
						IS[11:8] <= IR[24:21];
						IS[1:0] <= 2'b01;
						IS[3:2] <= 2'b00;
						IS[7] <= 1'b0; 
						ID_B <= 1'b0;
						IS[6] <= 1'b1; 
						IS[4] <= 1'b0; 
						IS[5] <= 1'b0;
						IS[12] <= 1'b1;
						ID_RF_clear<=1'b1;
					end
			else //Immidiate
				begin
					IS[11:8] <= IR[24:21];
					IS[1:0] <= 2'b00;
					IS[3:2] <= 2'b00;
					IS[7] <= 1'b0; 
					ID_B <= 1'b0;
					IS[6] <= 1'b1; 
					IS[4] <= 1'b0; 
					IS[5] <= 1'b0;
					IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
		else if (IR[27:26] == 2'b01) //Load/Store
			//if(Immidiate/Scaled register && SUB/ADD && Word/Byte && Store/Load)
			if(IR[25]==1'b0&&IR[23:22]==2'b00&&IR[20]==1'b0)//(I/S/W/S)
				begin
					IS[11:8] <= 4'b0010;
					IS[1:0] <= 2'b10;
					IS[3:2] <= 2'b10;
					IS[7] <= 1'b0; 
					ID_B <= 1'b0;
					IS[6] <= 1'b0; 
					IS[4] <= 1'b1; 
					IS[5] <= 1'b1;
					IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b00&&IR[20]==1'b1)//(I/S/W/L)
				begin
					IS[11:8] <= 4'b0010;
					IS[1:0] <= 2'b10;
					IS[3:2] <= 2'b10;
					IS[7] <= 1'b1; 
					ID_B <= 1'b0;
					IS[6] <= 1'b1; 
					IS[4] <= 1'b0; 
					IS[5] <= 1'b1;
					IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b01&&IR[20]==1'b0)//(I/S/B/S)
				begin
					IS[11:8] <= 4'b0010;
					IS[1:0] <= 2'b10;
					IS[3:2] <= 2'b00;
					IS[7] <= 1'b0; 
					ID_B <= 1'b0;
					IS[6] <= 1'b0; 
					IS[4] <= 1'b1; 
					IS[5] <= 1'b1;
					IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b01&&IR[20]==1'b1)//(I/S/B/L)
				begin
					IS[11:8] <= 4'b0010;
					IS[1:0] <= 2'b10;
					IS[3:2] <= 2'b00;
					IS[7] <= 1'b1; 
					ID_B <= 1'b0;
					IS[6] <= 1'b1; 
					IS[4] <= 1'b0; 
					IS[5] <= 1'b1;
					IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b10&&IR[20]==1'b0)//(I/A/W/S)
				begin
					IS[11:8] <= 4'b0100;
					IS[1:0] <= 2'b10;
					IS[3:2] <= 2'b10;
					IS[7] <= 1'b0; 
					ID_B <= 1'b0;
					IS[6] <= 1'b0; 
					IS[4] <= 1'b1; 
					IS[5] <= 1'b1;
					IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b10&&IR[20]==1'b1)//(I/A/W/L)
				begin
					IS[11:8] <= 4'b0100;
					IS[1:0] <= 2'b10;
					IS[3:2] <= 2'b10;
					IS[7] <= 1'b1; 
					ID_B <= 1'b0;
					IS[6] <= 1'b1; 
					IS[4] <= 1'b0; 
					IS[5] <= 1'b1;
					IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b11&&IR[20]==1'b0)//(I/A/B/S)
				begin
					IS[11:8] <= 4'b0100;
					IS[1:0] <= 2'b10;
					IS[3:2] <= 2'b00;
					IS[7] <= 1'b0; 
					ID_B <= 1'b0;
					IS[6] <= 1'b0; 
					IS[4] <= 1'b1; 
					IS[5] <= 1'b1;
					IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b11&&IR[20]==1'b1)//(I/A/B/L)
				begin
					IS[11:8] <= 4'b0100;
					IS[1:0] <= 2'b10;
					IS[3:2] <= 2'b00;
					IS[7] <= 1'b1; 
					ID_B <= 1'b0;
					IS[6] <= 1'b1; 
					IS[4] <= 1'b0; 
					IS[5] <= 1'b1;
					IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b00&&IR[20]==1'b0)//(S/S/W/S)
				begin
					IS[11:8] <= 4'b0010;
					IS[1:0] <= 2'b11;
					IS[3:2] <= 2'b10;
					IS[7] <= 1'b0; 
					ID_B <= 1'b0;
					IS[6] <= 1'b0; 
					IS[4] <= 1'b1; 
					IS[5] <= 1'b1;
					if(IR[11:4]==8'h00)IS[12] <= 1'b0;
					else IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b00&&IR[20]==1'b1)//(S/S/W/L)
				begin
					IS[11:8] <= 4'b0010;
					IS[1:0] <= 2'b11;
					IS[3:2] <= 2'b10;
					IS[7] <= 1'b1; 
					ID_B <= 1'b0;
					IS[6] <= 1'b1; 
					IS[4] <= 1'b0; 
					IS[5] <= 1'b1;
					if(IR[11:4]==8'h00)IS[12] <= 1'b0;
					else IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b01&&IR[20]==1'b0)//(S/S/B/S)
				begin
					IS[11:8] <= 4'b0010;
					IS[1:0] <= 2'b11;
					IS[3:2] <= 2'b00;
					IS[7] <= 1'b0; 
					ID_B <= 1'b0;
					IS[6] <= 1'b0; 
					IS[4] <= 1'b1; 
					IS[5] <= 1'b1;
					if(IR[11:4]==8'h00)IS[12] <= 1'b0;
					else IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b01&&IR[20]==1'b1)//(S/S/B/L)
				begin
					IS[11:8] <= 4'b0010;
					IS[1:0] <= 2'b11;
					IS[3:2] <= 2'b00;
					IS[7] <= 1'b1; 
					ID_B <= 1'b0;
					IS[6] <= 1'b1; 
					IS[4] <= 1'b0; 
					IS[5] <= 1'b1;
					if(IR[11:4]==8'h00)IS[12] <= 1'b0;
					else IS[12] <= 1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b10&&IR[20]==1'b0)//(S/A/W/S)
				begin
					IS[11:8] <= 4'b0100;
					IS[1:0] <= 2'b11;
					IS[3:2] <= 2'b10;
					IS[7] <= 1'b0; 
					ID_B <= 1'b0;
					IS[6] <= 1'b0; 
					IS[4] <= 1'b1; 
					IS[5] <= 1'b1;
					if(IR[11:4]==8'h00)IS[12] <= 1'b0;
					else IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b10&&IR[20]==1'b1)//(S/A/W/L)
				begin
					IS[11:8] <= 4'b0100;
					IS[1:0] <= 2'b11;
					IS[3:2] <= 2'b10;
					IS[7] <= 1'b1; 
					ID_B <= 1'b0;
					IS[6] <= 1'b1; 
					IS[4] <= 1'b0; 
					IS[5] <= 1'b1;
					if(IR[11:4]==8'h00)IS[12] <= 1'b0;
					else IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b11&&IR[20]==1'b0)//(S/A/B/S)
				begin
					IS[11:8] <= 4'b0100;
					IS[1:0] <= 2'b11;
					IS[3:2] <= 2'b00;
					IS[7] <= 1'b0; 
					ID_B <= 1'b0;
					IS[6] <= 1'b0; 
					IS[4] <= 1'b1; 
					IS[5] <= 1'b1;
					if(IR[11:4]==8'h00)IS[12] <= 1'b0;
					else IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b11&&IR[20]==1'b1)//(S/A/B/L)
				begin
					IS[11:8] <= 4'b0100;
					IS[1:0] <= 2'b11;
					IS[3:2] <= 2'b00;
					IS[7] <= 1'b1; 
					ID_B <= 1'b0;
					IS[6] <= 1'b1; 
					IS[4] <= 1'b0; 
					IS[5] <= 1'b1;
					if(IR[11:4]==8'h00)IS[12] <= 1'b0;
					else IS[12] <= 1'b1;
					ID_RF_clear<=1'b1;
				end
		//Load/Store end
		else if(IR[27:25] == 3'b101) //Branch
			begin 
				IS[11:8] <= 4'b0000;
				IS[1:0] <= 2'b00;
				IS[3:2] <= 2'b00;
				IS[7] <= 1'b0; 
				ID_B <= 1'b1;
				IS[6] <= 1'b0; 
				IS[4] <= 1'b0; 
				IS[5] <= 1'b0;
				IS[12] <= 1'b0;
				ID_RF_clear<=1'b0;
			end	
		else //Instruction not found
			begin
				IS[11:8] <= 4'b0000;
				IS[1:0] <= 2'b00;
				IS[3:2] <= 2'b00;
				IS[7] <= 1'b0; 
				ID_B <= 1'b0;
				IS[6] <= 1'b0; 
				IS[4] <= 1'b0; 
				IS[5] <= 1'b0;
				IS[12] <= 1'b0;
				ID_RF_clear<=1'b0;
			end
endmodule

module condition_handler(output reg Cond_true, B, L, input[3:0] CC, CI, input ID_B, IR_L);
	always @ (ID_B,IR_L,CC,CI)
		begin
		case(CI)
			4'b0000:
				begin
					Cond_true<=CC[2];//Z
					if(ID_B)B<=CC[2];
					else B<=0;
					if(IR_L)L<=CC[2];
					else L<=0;
				end
			4'b0001:
				begin
					Cond_true<=CC[2];//Z
					if(ID_B)B<=CC[2];
					else B<=0;
					if(IR_L)L<=CC[2];
					else L<=0;
				end
			4'b0010:
				begin
					Cond_true<=CC[1];//C
					if(ID_B)B<=CC[1];
					else B<=0;
					if(IR_L)L<=CC[1];
					else L<=0;
				end
			4'b0011:
				begin
					Cond_true<=!CC[1];//~C
					if(ID_B)B<=!CC[1];
					else B<=0;
					if(IR_L)L<=!CC[1];
					else L<=0;
				end
			4'b0100:
				begin
					Cond_true<=CC[3];//N
					if(ID_B)B<=CC[3];
					else B<=0;
					if(IR_L)L<=CC[3];
					else L<=0;
				end
			4'b0101:
				begin
					Cond_true<=!CC[3];//~N
					if(ID_B)B<=!CC[3];
					else B<=0;
					if(IR_L)L<=!CC[3];
					else L<=0;
				end
			4'b0110:
				begin
					Cond_true<=CC[0];//V
					if(ID_B)B<=CC[0];
					else B<=0;
					if(IR_L)L<=CC[0];
					else L<=0;
				end
			4'b0111:
				begin
					Cond_true<=!CC[0];//~V
					if(ID_B)B<=!CC[0];
					else B<=0;
					if(IR_L)L<=!CC[0];
					else L<=0;
				end
			4'b1000:
				begin
					Cond_true<=CC[1]&&(!CC[2]);//C&&~Z
					if(ID_B)B<=CC[1]&&(!CC[2]);
					else B<=0;
					if(IR_L)L<=CC[1]&&(!CC[2]);
					else L<=0;
				end
			4'b1001:
				begin
					Cond_true<=(!CC[1])||CC[2];//~C||Z
					if(ID_B)B<=(!CC[1])||CC[2];
					else B<=0;
					if(IR_L)L<=(!CC[1])||CC[2];
					else L<=0;
				end
			4'b1010:
				begin
					Cond_true<=CC[3]==CC[0];//N=V
					if(ID_B)B<=CC[3]==CC[0];
					else B<=0;
					if(IR_L)L<=CC[3]==CC[0];
					else L<=0;
				end
			4'b1011:
				begin
					Cond_true<=CC[3]!=CC[0];//N~=V
					if(ID_B)B<=CC[3]!=CC[0];
					else B<=0;
					if(IR_L)L<=CC[3]!=CC[0];
					else L<=0;
				end
			4'b1100:
				begin
					Cond_true<=(!CC[2])&&(CC[3]==CC[0]);//(~Z)&&N=V
					if(ID_B)B<=(!CC[2])&&(CC[3]==CC[0]);
					else B<=0;
					if(IR_L)L<=(!CC[2])&&(CC[3]==CC[0]);
					else L<=0;
				end
			4'b1101:
				begin
					Cond_true<=(CC[2])||(CC[3]!=CC[0]);//(Z)||N!=V
					if(ID_B)B<=(CC[2])||(CC[3]!=CC[0]);
					else B<=0;
					if(IR_L)L<=(CC[2])||(CC[3]!=CC[0]);
					else L<=0;
				end
			4'b1110:
				begin
					Cond_true<=1;
					if(ID_B)B<=1;
					else B<=0;
					if(IR_L)L<=1;
					else L<=0;
				end
			4'b1111:
				begin
					Cond_true<=0;
					B<=0;
					L<=0;
				end
		endcase
		end
endmodule		

module hazard_fwd_unit(output reg[1:0] Data_Forw_PA, Data_Forw_PB, Data_Forw_PD, 
output reg NOP, LE_IF_ID, LE_PC, input[3:0] ID_Rn, ID_Rm, EX_Rd, MEM_Rd, WB_Rd, 
input EX_RF_enable,MEM_RF_enable,WB_RF_enable, EX_load_instr);
	always @ (ID_Rn, ID_Rm, EX_Rd, MEM_Rd, WB_Rd, EX_RF_enable,MEM_RF_enable,WB_Rd, EX_RF_enable,MEM_RF_enable,WB_RF_enable, EX_load_instr)
	begin
		if(EX_RF_enable&&(ID_Rn==EX_Rd||ID_Rm==EX_Rd))
			begin
				if(ID_Rn==EX_Rd&&ID_Rm==EX_Rd) 
					begin
						Data_Forw_PA<=2'b01;
						Data_Forw_PB<=2'b01;
						Data_Forw_PD<=2'b00;
					end
				else if(ID_Rn==EX_Rd) 
					begin
						Data_Forw_PA<=2'b01;
						Data_Forw_PB<=2'b00;
						Data_Forw_PD<=2'b00;
					end
				else if(ID_Rm==EX_Rd) 
					begin
						Data_Forw_PA<=2'b00;
						Data_Forw_PB<=2'b01;
						Data_Forw_PD<=2'b00;
					end
			end
		else if(MEM_RF_enable&&(ID_Rn==MEM_Rd||ID_Rm==MEM_Rd))
			begin
				if(ID_Rn==MEM_Rd&&ID_Rm==MEM_Rd) 
					begin
						Data_Forw_PA<=2'b10;
						Data_Forw_PB<=2'b10;
						Data_Forw_PD<=2'b00;
					end
				else if(ID_Rn==MEM_Rd) 
					begin
						Data_Forw_PA<=2'b10;
						Data_Forw_PB<=2'b00;
						Data_Forw_PD<=2'b00;
					end
				else if(ID_Rm==MEM_Rd) 
					begin
						Data_Forw_PA<=2'b00;
						Data_Forw_PB<=2'b10;
						Data_Forw_PD<=2'b00;
					end
			end
		else if(WB_RF_enable&&(ID_Rn==WB_Rd||ID_Rm==WB_Rd))
			begin
				if(ID_Rn==WB_Rd&&ID_Rm==WB_Rd) 
					begin
						Data_Forw_PA<=2'b11;
						Data_Forw_PB<=2'b11;
						Data_Forw_PD<=2'b00;
					end
				else if(ID_Rn==WB_Rd) 
					begin
						Data_Forw_PA<=2'b11;
						Data_Forw_PB<=2'b00;
						Data_Forw_PD<=2'b00;
					end
				else if(ID_Rm==WB_Rd) 
					begin
						Data_Forw_PA<=2'b00;
						Data_Forw_PB<=2'b11;
						Data_Forw_PD<=2'b00;
					end
			end
		else
			begin
				Data_Forw_PA<=2'b00;
				Data_Forw_PB<=2'b00;
				Data_Forw_PD<=2'b00;
			end
		if(EX_load_instr&&(ID_Rn==EX_Rd||ID_Rn==EX_Rd))
			begin
				NOP<=1'b0;
				LE_IF_ID<=1'b0;
				LE_PC<=1'b0;
			end
		else
			begin
				NOP<=1'b1;
				LE_IF_ID<=1'b1;
				LE_PC<=1'b1;
			end
	end
endmodule

//IF/ID register
module pipeline_registers_1 (output reg [31:0] PCAdressOut, PCNextout ,toCPU, output reg [3:0] toConditionH, 
output reg [23:0] toSignextender, output reg bitToCondition, output reg [3:0] RA, output reg [3:0] RB, output reg [3:0] RD, 
output reg LinkOut, output reg [11:0] directTonextregister, output reg oneBitToNextRegister, input clk, LD, LinkIn, 
input [31:0] InInstructionMEM, InPCAdress, INNextPC);
  // reg [3:0] toConditionH;
  // reg [23:0] toSignextender;
  // reg bitToCondition;
  // reg [3:0] RA;
  // reg [3:0] RB;
  // reg [3:0] RD;
  // reg [11:0] directTonextregister;
  // reg oneBitToNextRegister;
  // reg [31:0] toCPU;

  reg [31:0] temp;

  always @ (posedge clk, LD)
  begin
  PCNextout = INNextPC;
  PCAdressOut = InPCAdress;
  LinkOut = LinkIn;

  temp = InInstructionMEM & 32'b11110000000000000000000000000000;
  toConditionH = temp >> 28;

  temp = InInstructionMEM & 32'b00000000111111111111111111111111;
  toSignextender = temp;

  temp = InInstructionMEM & 32'b00000001000000000000000000000000;
  bitToCondition = temp >> 24;

  temp = InInstructionMEM & 32'b00000000000011110000000000000000;
  RA = temp >> 16;

  temp = InInstructionMEM & 32'b00000000000000000000000000001111;
  RB = temp;

  temp = InInstructionMEM & 32'b00000000000000001111000000000000;
  RD = temp >> 12;

  temp = InInstructionMEM & 32'b00000000000000000000111111111111;
  directTonextregister = temp;

  temp = InInstructionMEM & 32'b00000000000100000000000000000000;
  oneBitToNextRegister = temp >> 20;


  end
endmodule

//ID/EX register
module pipeline_registers_2(output reg [31:0] directRegister, aluConnection, shiftExtender, output reg [11:0] LelevenShift, 
output reg singleBitOut, shift_imm,EXloadInst, EXRFEnable, NextReg1, NextReg2,  output reg [3:0] outRDBits, OP, 
input [11:0] bitsFromPRegister, output reg [1:0] NextReg2Bit, Msignal,  input [3:0] RDBits, input clk, singleBit, 
input [31:0] outMux1, outMux2, outMux3, input [12:0] muxSignals);

    // reg shift_imm;
    // reg [3:0] OP;
    // reg EXloadInst;
    // reg EXRFEnable;
    // reg NextReg1;
    // reg NextReg2;
    // reg [1:0] NextReg2Bit;
    // reg [1:0] Msignal;

    /////////////////////////////////13bits son los que se estan separando, se pueden usar 13 en vez de 32?
    //temp variable
    reg [31:0] temp;
    always @(posedge clk)
    begin
    directRegister = outMux1;
    aluConnection = outMux2;
    shiftExtender = outMux3;
    singleBitOut = singleBit;
    outRDBits = RDBits;
    LelevenShift = bitsFromPRegister;

    temp = muxSignals & 32'b00000000000000000001000000000000;
    shift_imm = temp >> 12;

    temp = muxSignals & 32'b00000000000000000000111100000000;
    OP = temp >> 8 ;
    
    temp = muxSignals & 32'b00000000000000000000000010000000;
    EXloadInst = temp >> 7;

    temp = muxSignals & 32'b00000000000000000000000001000000;
    EXRFEnable = temp >> 6;

    temp = muxSignals & 32'b00000000000000000000000000100000;
    NextReg1 = temp >> 5;

    temp = muxSignals & 32'b00000000000000000000000000010000;
    NextReg2 = temp >> 4;

    temp = muxSignals & 32'b00000000000000000000000000001100;
    NextReg2Bit = temp >> 2;

    temp = muxSignals & 32'b00000000000000000000000000000011;
    Msignal = temp;

    end
endmodule

//EX/MEM register
module pipeline_registers_3(output reg [31:0] outAluSignal, data_Mem, output reg [3:0] RDSignalOut, 
output reg [1:0] AccessModeDataMemory, output reg EXloadInst2, EXRFEnable2, Data_Mem_EN, Data_MEM_R_W, 
input clk, input [31:0] aluOut, pastReg, input [3:0] RDSignal ,input [5:0] previousregister);
    // reg EXloadInst2;
    // reg EXRFEnable2;
    // reg Data_Mem_EN;
    // reg Data_MEM_R_W;
    // reg [1:0] AccessModeDataMemory;

    reg [31:0] temp;
    always @ (posedge clk)
    begin
    outAluSignal = aluOut;
    data_Mem = pastReg;
    RDSignalOut = RDSignal;


    temp = previousregister & 32'b00000000000000000000000000100000;
    EXloadInst2 = temp >> 5;

    temp = previousregister & 32'b00000000000000000000000000010000;
    EXRFEnable2 = temp >> 4;

    temp = previousregister & 32'b00000000000000000000000000001000;
    Data_Mem_EN = temp >> 3;

    temp = previousregister & 32'b00000000000000000000000000000100;
    Data_MEM_R_W = temp >> 2;

    temp = previousregister & 32'b00000000000000000000000000000011;
    AccessModeDataMemory = temp;

    end
endmodule

//MEM/WB register
module pipeline_registers_4(output reg [31:0] Data_mem_to_mux, SignalFromEX, output reg [3:0] LastRDSignal, 
output reg EXloadInst3, EXRFEnable3, input clk, input [31:0]Data_mem_out,signalFormEXIN, input [3:0] lAstRDsignalIn, 
input [1:0] Enablers);
    // reg EXloadInst3;
    // reg EXRFEnable3;

    reg [31:0] temp;

    always @ (posedge clk)
    begin
    Data_mem_to_mux = Data_mem_out;
    SignalFromEX = signalFormEXIN;
    LastRDSignal = lAstRDsignalIn;

    temp = Enablers & 32'b00000000000000000000000000000010;
    EXloadInst3 = temp >> 1;

    temp = Enablers & 32'b00000000000000000000000000000001;
    EXRFEnable3 = temp;
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
    //System Variables
        reg global_clk;
    //IF variables
        wire [31:0] mux1_out;
        wire [31:0] adder1_out;
        wire [31:0] ramI_out;
    //IF-ID Reg Variables
        wire [31:0] pplr1_out;
        wire [31:0] pplr1_pc_out;
        wire [31:0] pplr1_cpu_sig;
        wire [3:0] pplr1_cond_in;
        wire [23:0] pplr1_extender_in;
        wire pplr1_linkout;
        wire pplr1_cond_IR_L;
        wire [3:0] pplr1_RA;
        wire [3:0] pplr1_RB;
        wire [3:0] pplr1_RD;
        wire [11:0] pplr1_shifter_L;
        wire pplr1_flag_reg_S;
    //ID variables
        wire [31:0] adder2_out;
        wire [31:0] mux2_out;
        wire [31:0] mux3_out;
        wire [31:0] mux4_out;
        wire [12:0] mux5_out;
        wire [31:0] signExt1_out;
        wire [31:0] regfile_out_1;
        wire [31:0] regfile_out_2;
        wire [31:0] regfile_out_3;
        wire [31:0] regfile_pc_out;
    //ID-EXE variables
        wire [31:0] pplr2_ramD_data;
        wire [31:0] pplr2_alu_A;
        wire [31:0] pplr2_shift_RM;
        wire [11:0] pplr2_shifter_L;
        wire pplr2_flag_reg_S;
        wire [3:0] pplr2_RD;
        wire pplr2_shift_imm;
        wire [3:0] pplr2_ALU_op;
        wire pplr2_load_inst;
        wire pplr2_RF_enable;
        wire pplr2_ramD_enable;
        wire pplr2_ramD_RW;
        wire [1:0] pplr2_ramD_mode;
        wire [1:0] pplr2_shift_mode;
    //EXE variables
        wire [31:0] mux6_out;
        wire mux7_out;
        wire [31:0] shifter1_out;
        wire shifter1_carry_out;
        wire [31:0] alu1_out;
        wire [3:0] alu1_cc;
        wire [3:0] flag_reg1_out;
        wire flag_reg1_c_in;  
    //EXE-MEM variables
        wire [31:0] pplr3_ramD_address;
        wire [31:0] pplr3_ramD_data;
        wire [3:0] pplr3_RD;
        wire [1:0] pplr3_ramD_mode;
        wire pplr3_load_inst;
        wire pplr3_RF_enable;
        wire pplr3_ramD_enable;
        wire pplr3_ramD_RW;
    //MEM variables
        wire[31:0] ramD_out;
        wire[31:0] mux8_out;
    //MEM-WB variables
        wire [31:0] pplr4_ramD_address;
        wire [31:0] pplr4_ramD_out;
        wire [3:0] pplr4_RD;
        wire pplr4_load_inst;
        wire pplr4_RF_enable;
    //WB variables
        wire[31:0] mux9_out;
    //Condition Handling variables
        wire cond_handler_cond;
        wire cond_handler_B;
        wire cond_handler_L;
    //Hazard/Forwarding variables
        wire hzd_fwd_LE_IF;
        wire hzd_fwd_LE_PC;
        wire hzd_fwd_NOP;
        wire[1:0] hzd_fwd_fwd_PA;
        wire[1:0] hzd_fwd_fwd_PB;
        wire[1:0] hzd_fwd_fwd_PD;
    //Control Unit variables
        wire [12:0] cpu_out;
        wire cpu_ID_B_out;
        wire cpu_ID_RF_clear;
//=================================================================================//
    //Instruction Fetch
        mux2x1_32 mux1(mux1_out, cond_handler_B, adder2_out, adder1_out);
        adder adder1(adder1_out, regfile_pc_out, 32'h04, global_clk);
        instRAM256x8 ramI(ramI_out, regfile_pc_out);
        pipeline_registers_1 pplr1(pplr1_out, pplr1_pc_out, pplr1_cpu_sig, pplr1_cond_in, pplr1_extender_in,
        pplr1_cond_IR_L, pplr1_RA, pplr1_RB, pplr1_RD, pplr1_linkout, pplr1_shifter_L, pplr1_flag_reg_S, global_clk, 
        hzd_fwd_LE_IF, cond_handler_L, ramI_out, mux1_out, adder1_out);
        
    //Instruction Decode
        registerfile rf1(regfile_out_1, regfile_out_2, regfile_out_3, regfile_pc_out, global_clk, pplr4_RF_enable, 
        cpu_ID_RF_clear, hzd_fwd_LE_PC, pplr1_RA, pplr1_RB, pplr1_RD, pplr4_RD, mux9_out, pplr1_out);
        mux4x1_32 mux2(mux2_out, hzd_fwd_fwd_PA, regfile_out_1, alu1_out, mux8_out, mux9_out);
        mux4x1_32 mux3(mux3_out, hzd_fwd_fwd_PB, regfile_out_2, alu1_out, mux8_out, mux9_out);
        mux4x1_32 mux4(mux4_out, hzd_fwd_fwd_PD, regfile_out_3, alu1_out, mux8_out, mux9_out);
        sign_ext signExt1(signExt1_out, pplr1_extender_in);
        adder adder2(adder2_out, signExt1_out, pplr1_pc_out);
        mux2x1_13 mux5(mux5_out, hzd_fwd_NOP, 13'h0, cpu_out);      //mux5_out contains control signals
        pipeline_registers_2 pplr2(pplr2_ramD_data, pplr2_alu_A, pplr2_shift_RM, pplr2_shifter_L, pplr2_flag_reg_S,
        pplr2_shift_imm, pplr2_load_inst, pplr2_RF_enable, pplr2_ramD_enable, pplr2_ramD_RW, pplr2_RD, pplr2_ALU_op,
        pplr2_shifter_L, pplr2_ramD_mode, pplr2_shift_mode, pplr1_RD, global_clk, pplr1_flag_reg_S,
        mux2_out, mux3_out, mux4_out, mux5_out); 

    //Execution
        shifter shifter1(shifter1_out, shifter1_carry_out, pplr2_shift_RM, pplr2_shifter_L, pplr2_shift_mode, flag_reg1_c_in);        
        mux2x1_32 mux6(mux6_out, pplr2_shift_imm, pplr2_shift_RM, shifter1_out);
        mux2x1_1 mux7(mux7_out, pplr2_shift_imm, 1'b0, shifter1_carry_out);
        alu alu1(alu1_out, alu1_cc, pplr2_alu_A, mux6_out, pplr2_ALU_op, flag_reg1_c_in, shifter1_carry_out);
        flagregister flag_reg1(flag_reg1_out, flag_reg1_c_in, alu1_cc, pplr2_flag_reg_S);

        pipeline_registers_3 pplr3(pplr3_ramD_address, pplr3_ramD_data, pplr3_RD, pplr3_ramD_mode, pplr3_load_inst,
        pplr3_RF_enable, pplr3_ramD_enable, pplr3_ramD_RW, global_clk, alu1_out, pplr2_ramD_data, pplr2_RD,
        /*needs correction to receive 5 separate signals*/);

    //Memory 
        dataRAM256x8 ramD(ramD_out, pplr3_RF_enable, pplr3_ramD_RW, pplr3_ramD_address, pplr3_ramD_data, pplr3_ramD_mode);
        mux2x1_32 mux8(mux8_out, pplr3_load_inst, ramD_out, pplr3_ramD_address);
        pipeline_registers_4 pplr4(pplr4_ramD_out, pplr4_ramD_address, pplr4_RD, pplr4_load_inst, pplr4_RF_enable, global_clk,
        ramD_out, pplr3_ramD_address, pplr3_RD, /*needs correction to receive 2 separate signals*/);

    //Writeback
        mux2x1_32 mux9(mux9_out, pplr4_load_inst, pplr4_ramD_out, pplr4_ramD_address);

    //Condition Handling
        condition_handler cond_handler1(cond_handler_cond, cond_handler_B, cond_handler_L, flag_reg1_out, pplr1_cond_in, 
        cpu_ID_B_out, pplr1_cond_IR_L);

    //Hazard/Forwarding
        hazard_fwd_unit hzd_fwd_u1(hzd_fwd_fwd_PA, hzd_fwd_fwd_PB, hzd_fwd_fwd_PD, hzd_fwd_NOP, hzd_fwd_LE_IF, hzd_fwd_LE_PC,
        pplr1_RA, pplr1_RB, /*needs correction to handle pplr1_RD*/, pplr2_RD, pplr3_RD, pplr4_RD, pplr2_RF_enable, 
        pplr3_RF_enable, pplr4_RF_enable, pplr2_load_inst);

    //Control Unit
        cpu controlUnit1(cpu_out, cpu_ID_B_out, cpu_ID_RF_clear, pplr1_cpu_sig, cond_handler_cond);
        (output reg[12:0] IS, output reg ID_B, ID_RF_clear, input [31:0] IR, input Cond);
endmodule

