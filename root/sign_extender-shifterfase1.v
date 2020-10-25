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