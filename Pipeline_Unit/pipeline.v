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

module registerfile (output [31:0] O1, O2, O3, PCout, input clk, lde, clr, LE_PC, input [3:0] s1,s2,s3, ddata, input [31:0] datain, PCIN);
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
        case(M)
            // Immediate - ARM Manual A5.1.3
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
            2'b01:	begin
                // L[11:7] = shift_imm.
                // L[6:5] = shift:= LSL | LSR | ASR | ROR
                case(L[6:5])
                    // LSL = Logical Shift Left - ARM Manual A5.1.5
                    // shifter_operand = Rm logically shifted to the left 'shift_imm' times.
                    2'b00:  if(L[11:7] == 5'b00000)// Operand Register - ARM Manual A5.1.4
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
                    2'b01:  if(L[11:7] == 5'b00000)
                                begin
                                    {OUT} <= 32'b0;
                                    shifter_carry_out <= RM[31];
                                end
                            else
                                begin
                                    {OUT} <= RM >> L[11:7];
                                    shifter_carry_out <= RM[{L[11:7]}-1];
                                end
                    2'b10:  if(L[11:7] == 5'b00000)
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
                    2'b11:  if(L[11:7] == 5'b00000) // (Rotate right with extend - ARM Manual A5.1.13)
                                begin
                                    {OUT} <= (C_in << 31) | (RM >> 1);
                                    shifter_carry_out <= RM[0];
                                end
                            else
                                begin
                                    {OUT} <= {RM, RM} >> L[11:7];
                                    shifter_carry_out <= RM[{L[11:7]}-1];
                                end
                endcase
            
        // Addressing Mode 2: Load Store
		//Immidiate Offset
			2'b10:	begin
						{OUT} = L;
					end
			2'b11:	begin//Register Offset
						{OUT} <= RM;
					end
		endcase
endmodule

module alu (output reg [31:0] O, output reg [3:0] Flags, CPSR, input [31:0] A, B, input [3:0] OP, input C_in, shifter_carry_out, S);
    // A = Rn
    // B = shifter_operand
    // O = Rd
    // Flag[0] = V(Overflow)
    // Flag[1] = C(Carry)
    // Flag[2] = Z(Zero)
    // Flag[3] = N(Negative)
	// Flags ARM Manual Section A2.5.2
    always@(OP, A, B)
        case(OP)
                                                        //                                   Status Flags  ARM Manual
                                                        //                                    N  Z  C  V    Section
            4'b0000: begin                             // AND - Logical AND                  *  *  /  -    A4.1.4
                      O = A & B;                        // Save Operation
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                      Flags[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b0001: begin                             // EOR - Logical Exclusive OR         *  *  /  -    A4.1.18
                      O = A ^ B;                        // Save Operation
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                      Flags[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b0010: begin                             // SUB - Subtract                     *  *  *  *    A4.1.106
                      {Flags[1], O} = A - B;            // Save Subtraction, C Flag Update
                      Flags[0] = (A[31] != B[31])       // V Flag Update
                                  && (O[31] == B[31]);
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                    end
            4'b0011: begin                             // RSB - Reverse Subtract             *  *  *  *    A4.1.60
                      {Flags[1], O} = B - A;            // Save Subtraction, C Flag Update
                      Flags[0] = (A[31] != B[31])       // V Flag Update
                                  && (O[31] == A[31]);
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                    end
            4'b0100: begin                             // ADD - Addition                     *  *  *  *    A4.1.3
                      {Flags[1], O} = A + B;            // Save Addition, C Flag Update
                      Flags[0] = (A[31] == B[31])       // V Flag Update
                                && (A[31] != O[31]);
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                    end
            4'b0101: begin                             // ADC - Addition with Carry          *  *  *  *    A4.1.2
                      {Flags[1], O} = A + B + C_in;     // Save Addition, C Flag Update
                      Flags[0] = ((A[31] == B[31])      // V Flag Update
                                && A[31] != O[31]);
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                    end
            4'b0110: begin                             // SBC - Subtract with Carry          *  *  *  *    A4.1.65
                      {Flags[1], O} = A - B - ~C_in;    // Save Subtraction, C Flag Update
                      Flags[0] = (A[31] != B[31])       // V Flag Update
                                  && (O[31] == B[31]);
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                    end
            4'b0111: begin                             // RSC - Reverse Subtract with Carry  *  *  *  *    A4.1.61
                      {Flags[1], O} = B - A - ~C_in;    // Save Subtraction, C Flag Update
                      Flags[0] = (A[31] != B[31])       // V Flag Update
                                  && (O[31] == A[31]);
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                    end
            4'b1000: begin                             // TST - Test             (AND)       *  *  /  -    A4.1.117
                      O = A & B;
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                      Flags[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b1001: begin                             // TEQ - Test Equivalence (EOR)       *  *  /  -    A4.1.116
                      O = A ^ B;
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                      Flags[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b1010: begin                             // CMP - Compare          (SUB)       *  *  *  *    A4.1.15
                      {Flags[1], O} = A - B;            // Save Subtraction, C Flag Update
                      Flags[0] = (A[31] != B[31])       // V Flag Update
                                  && (O[31] == B[31]);
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                    end
            4'b1011: begin                             // CMN - Compare Negated  (ADD)       *  *  *  *    A4.1.14
                      {Flags[1], O} = A + B;            // Save Addition, C Flag Update
                      Flags[0] = (A[31] == B[31])       // V Flag Update
                                && (A[31] != O[31]);
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                    end
            4'b1100: begin                             // ORR - Logical OR                   *  *  /  -    A4.1.42
                      O = A | B;                        // Save Operation
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                      Flags[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b1101: begin                             // MOV - Move                         *  *  /  -    A4.1.35
                      O = B;                            // Save Operation
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                      Flags[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b1110: begin                             // BIC - Bit Clear                    *  *  /  -    A4.1.6
                      O = A & ~B;                       // Save Operation
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                      Flags[1] = shifter_carry_out;     // C Flag Update
                    end
            4'b1111: begin                             // MVN - Move Not                     *  *  /  -    A4.1.41
                      O = ~B;                           // Save Operation
                      Flags[3] = O[31];                 // N Flag Update
                      Flags[2] = !O;                    // Z Flag Update
                      Flags[1] = shifter_carry_out;     // C Flag Update
                    end
        endcase
		if(S)		begin
						$monitor("CPSR has been changed to: %b",Flags);
						CPSR <= Flags;
						$monitor("Output: %b \nFlags: %b \nCode: %b",O,Flags,{OP,S});
					end
		//$monitor("Output: %b \nFlags: %b \nCode: %b",O,Flags,{OP,S});	
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
//EXE variables
    wire [31:0] mux6_out;
    wire mux7_out;
    wire [31:0] shifter1_out;
    wire shifter1_carry_out;
    wire [31:0] alu1_out;
//MEM variables
    wire[31:0] ramD_out;
    wire[31:0] mux8_out;
//WB variables
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
//Execution
    shifter shifter1();
        //output to muxes
    mux2x1_32 mux6(mux6_out, /*FROM REG(ID_shift_imm)*/, /*FROM REG*/, shifter1_out);

    mux2x1_1 mux7(mux7_out, /*FROM REG (ID_shift_imm)*/, 1'b0, shifter1_carry_out);
    alu alu1(alu1_out,);
        //output to register 
        //cc to flag register
    //flag register here plis
//Memory   module dataRAM256x8 (output reg [31:0] DataOut, input Enable, ReadWrite, input[31:0] Address, input [31:0] DataIn, input [1:0] Mode);
    dataRAM256x8 ramD(ramD_out, /*FROM REG*/, /*FROM REG*/, /*FROM REG*/, /*FROM REG*/, /*FROM REG*/,);
        //output to register
    mux2x1_32 mux8(mux8_out, );
    output to mux1 mux2 mux3

endmodule






/* Writeback Phase
mux 2*1
*/
