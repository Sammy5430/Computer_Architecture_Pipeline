module shifter (output reg[31:0] OUT, output reg shifter_carry_out, input [31:0] IR, RM, input C_in);
    reg [31:0] temp;
    always @ (IR, RM)
        // Addressing Mode 1: Data processing
        if((IR[27:25] == 3'b001) || (IR[27:25] == 3'b000 && IR[4] == 1'b0))
            // Immediate - ARM Manual A5.1.3
            if(IR[25] == 1'b1)
                begin
                    {temp} = IR[7:0];
                    {OUT} = {temp, temp} >> (2 * IR[11:8]);
                    // Update shifter_carry_out
                    if(IR[11:8] == 4'b0000) 
                        shifter_carry_out = C_in;
                    else
                        shifter_carry_out = OUT[31];
                end
            // Shift by Immediate Shifter
            else if(IR[25] == 1'b0 && IR[4] == 1'b0)
                // IR[11:7] = shift_imm.
                // IR[6:5] = shift:= LSL | LSR | ASR | ROR
                case(IR[6:5])
                    // LSL = Logical Shift Left - ARM Manual A5.1.5
                    // shifter_operand = Rm logically shifted to the left 'shift_imm' times.
                    2'b00:  if(IR[11:7] == 5'b00000)// Operand Register - ARM Manual A5.1.4
                                begin
                                    {OUT} <= RM;
                                    shifter_carry_out <= C_in;
                                end
                            else
                                begin
                                    {OUT} <= RM << IR[11:7];
                                    shifter_carry_out <= RM[32-{IR[11:7]}];
                                end
                    // LSR = Logical Shift Right - ARM Manual A5.1.7
                    // shifter_operand = Rm logically shifted to the right 'shift_imm' times.
                    2'b01:  if(IR[11:7] == 5'b00000)
                                begin
                                    {OUT} <= 32'b0;
                                    shifter_carry_out <= RM[31];
                                end
                            else
                                begin
                                    {OUT} <= RM >> IR[11:7];
                                    shifter_carry_out <= RM[{IR[11:7]}-1];
                                end
                    2'b10:  if(IR[11:7] == 5'b00000)
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
                                    {OUT} <= $signed(RM) >>> IR[11:7];
                                    shifter_carry_out <= RM[{IR[11:7]}-1];
                                end
                    // ROR = Rotate Right - ARM Manual A5.1.11
                    // shifter_operand = Rm rotated to the right 'shift_imm' times.
                    2'b11:  if(IR[11:7] == 5'b00000) // (Rotate right with extend - ARM Manual A5.1.13)
                                begin
                                    {OUT} <= (C_in << 31) | (RM >> 1);
                                    shifter_carry_out <= RM[0];
                                end
                            else
                                begin
                                    {OUT} <= {RM, RM} >> IR[11:7];
                                    shifter_carry_out <= RM[{IR[11:7]}-1];
                                end
                endcase
            // Error: Shift by Register Is not and will not be implemented!
            else
                $display("Error: Shift by Register Is not implemented!");
        // Addressing Mode 2: Load Store
        else if(IR[27:26] == 2'b01)
            // Immediate
            if(IR[25] == 1'b0)
                // offset = offset_12 => IR[11:0]
                {OUT} <= IR[11:0];
            // Register
            else
                // offset = content of register IR[3:0] => RM
                {OUT} <= RM;
        // Addressing Mode 3: Load Store Miscellaneous
        else if(IR[27:25] == 3'b000 && IR[4] == 1'b1)
            // Immediate
            if(IR[22] == 1'b1)
                // IR[11:8] = ImmedH
                // IR[3:0] = ImmedL
                // offset = {ImmedH, ImmedL} = offset_8
                {OUT} <= {IR[11:8], IR[3:0]};
            // Register
            else
                // offset = content of register IR[3:0] => RM
                {OUT} <= RM;
        // Addressing Mode 4: Load Store Multiple (TODO)
        // else if()
        // Addressing Mode 5: Branch and Branch & Link
        else if(IR[27:25] == 3'b101)
            {OUT} <= {{8{IR[23]}},IR[23:0]} << 2;
        // Error: Unexpected instruction
        else
            $display("Error: Unexpected instruction");

endmodule