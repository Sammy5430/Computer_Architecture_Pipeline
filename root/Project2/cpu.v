module cpu (output reg[3:0] OP, output reg [1:0] Sm, Mm, output reg ID_load_instr, ID_B, ID_RF, ID_RW, ID_Data, ID_shift_imm, input [31:0] IR); 
	always @ (IR) 
		if (IR[31:0] == 32'h00000000)//NOP
			begin
				OP <= 4'b0000;
				Sm <= 2'b00;
				Mm <= 2'b00;
				ID_load_instr <= 1'b0; 
				ID_B <= 1'b0;
				ID_RF <= 1'b0; 
				ID_RW <= 1'b0; 
				ID_Data <= 1'b0;
				ID_shift_imm <= 1'b0;
			end
		else if (IR[27:26]== 2'b00) // Data Processing		
			if(IR[25]== 1'b0) // Immidiate shifts
				if(IR[11:4]== 8'h00) //No Shifts
					begin
						OP <= IR[24:21];
						Sm <= 2'b01;
						Mm <= 2'b00;
						ID_load_instr <= 1'b0; 
						ID_B <= 1'b0;
						ID_RF <= 1'b1; 
						ID_RW <= 1'b0; 
						ID_Data <= 1'b0;
						ID_shift_imm <= 1'b0;
					end
				else begin //Shifts Register
						OP <= IR[24:21];
						Sm <= 2'b01;
						Mm <= 2'b00;
						ID_load_instr <= 1'b0; 
						ID_B <= 1'b0;
						ID_RF <= 1'b1; 
						ID_RW <= 1'b0; 
						ID_Data <= 1'b0;
						ID_shift_imm <= 1'b1;
					end
			else //Immidiate
				begin
					OP <= IR[24:21];
					Sm <= 2'b00;
					Mm <= 2'b00;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b0;
					ID_shift_imm <= 1'b1;
				end
		else if (IR[27:26] == 2'b01) //Load/Store
			//if(Immidiate/Scaled register && SUB/ADD && Word/Byte && Store/Load)
			if(IR[25]==1'b0&&IR[23:22]==2'b00&&IR[20]==1'b0)//(I/S/W/S)
				begin
					OP <= 4'b0010;
					Sm <= 2'b10;
					Mm <= 2'b10;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b00&&IR[20]==1'b1)//(I/S/W/L)
				begin
					OP <= 4'b0010;
					Sm <= 2'b10;
					Mm <= 2'b10;
					ID_load_instr <= 1'b1; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b1;
					ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b01&&IR[20]==1'b0)//(I/S/B/S)
				begin
					OP <= 4'b0010;
					Sm <= 2'b10;
					Mm <= 2'b00;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b01&&IR[20]==1'b1)//(I/S/B/L)
				begin
					OP <= 4'b0010;
					Sm <= 2'b10;
					Mm <= 2'b00;
					ID_load_instr <= 1'b1; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b1;
					ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b10&&IR[20]==1'b0)//(I/A/W/S)
				begin
					OP <= 4'b0100;
					Sm <= 2'b10;
					Mm <= 2'b10;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b10&&IR[20]==1'b1)//(I/A/W/L)
				begin
					OP <= 4'b0100;
					Sm <= 2'b10;
					Mm <= 2'b10;
					ID_load_instr <= 1'b1; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b1;
					ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b11&&IR[20]==1'b0)//(I/A/B/S)
				begin
					OP <= 4'b0100;
					Sm <= 2'b10;
					Mm <= 2'b00;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b0&&IR[23:22]==2'b11&&IR[20]==1'b1)//(I/A/B/L)
				begin
					OP <= 4'b0100;
					Sm <= 2'b10;
					Mm <= 2'b00;
					ID_load_instr <= 1'b1; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b1;
					ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b00&&IR[20]==1'b0)//(S/S/W/S)
				begin
					OP <= 4'b0010;
					Sm <= 2'b10;
					Mm <= 2'b10;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b00&&IR[20]==1'b1)//(S/S/W/L)
				begin
					OP <= 4'b0010;
					Sm <= 2'b10;
					Mm <= 2'b10;
					ID_load_instr <= 1'b1; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b01&&IR[20]==1'b0)//(S/S/B/S)
				begin
					OP <= 4'b0010;
					Sm <= 2'b10;
					Mm <= 2'b00;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b01&&IR[20]==1'b1)//(S/S/B/L)
				begin
					OP <= 4'b0010;
					Sm <= 2'b10;
					Mm <= 2'b00;
					ID_load_instr <= 1'b1; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b10&&IR[20]==1'b0)//(S/A/W/S)
				begin
					OP <= 4'b0100;
					Sm <= 2'b10;
					Mm <= 2'b10;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b10&&IR[20]==1'b1)//(S/A/W/L)
				begin
					OP <= 4'b0100;
					Sm <= 2'b10;
					Mm <= 2'b10;
					ID_load_instr <= 1'b1; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b11&&IR[20]==1'b0)//(S/A/B/S)
				begin
					OP <= 4'b0100;
					Sm <= 2'b10;
					Mm <= 2'b00;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b11&&IR[20]==1'b1)//(S/A/B/L)
				begin
					OP <= 4'b0100;
					Sm <= 2'b11;
					Mm <= 2'b00;
					ID_load_instr <= 1'b1; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
				end
		//Load/Store end
		else if(IR[27:25] == 3'b101) //Branch
			begin 
				OP <= 4'b0000;
				Sm <= 2'b00;
				Mm <= 2'b00;
				ID_load_instr <= 1'b0; 
				ID_B <= 1'b1;
				ID_RF <= 1'b0; 
				ID_RW <= 1'b0; 
				ID_Data <= 1'b0;
				ID_shift_imm <= 1'b0;
			end	
		else //Instruction not found
			begin
				OP <= 4'b0000;
				Sm <= 2'b00;
				Mm <= 2'b00;
				ID_load_instr <= 1'b0; 
				ID_B <= 1'b0;
				ID_RF <= 1'b0; 
				ID_RW <= 1'b0; 
				ID_Data <= 1'b0;
				ID_shift_imm <= 1'b0;
			end
endmodule			