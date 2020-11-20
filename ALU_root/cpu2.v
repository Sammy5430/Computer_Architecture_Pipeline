module cpu (output reg[12:0] IS, output reg ID_B, ID_RF_clear, input [31:0] IR, input Cond); 
	/*IS[12]=ID_shift
	IS[11:8]=OP
	IS[7]=load
	IS[6]=ID_RF
	IS[5]=Data
	IS[4]=RW
	IS[3:2]=Mm
	IS[1:0]=Sm
	*/
	reg [3:0] OP;
	reg [1:0] Sm;
	reg [1:0] Mm;
	reg ID_load_instr;
	reg ID_RF;
    reg	ID_RW;
	reg ID_Data;
	reg ID_shift_imm;
	always @ (IR)
		begin
		if (IR[31:0] == 32'h00000000||!Cond)//NOP
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
				ID_RF_clear<=1'b0;
			end
		else if (IR[27:26]== 2'b00&&(IR[25]==1'b1||IR[4]==1'b0)) // Data Processing	
			begin
			if(IR[25]== 1'b0) // Immidiate Register shifts
				begin
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
						ID_RF_clear<=1'b1;
					end
				else if(IR[4]==1'b0)
					begin //Shifts Register
						OP <= IR[24:21];
						Sm <= 2'b01;
						Mm <= 2'b00;
						ID_load_instr <= 1'b0; 
						ID_B <= 1'b0;
						ID_RF <= 1'b1; 
						ID_RW <= 1'b0; 
						ID_Data <= 1'b0;
						ID_shift_imm <= 1'b1;
						ID_RF_clear<=1'b1;
					end
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
					ID_RF_clear<=1'b1;
				end
			end
		else if (IR[27:26] == 2'b01&&IR[24]==1'b1&&IR[21]==1'b0&&(IR[25]==1'b0||IR[4]==1'b0)) //Load/Store
			//if(Immidiate/Scaled register && SUB/ADD && Word/Byte && Store/Load)
			begin
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
					ID_RF_clear<=1'b1;
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
					ID_RF_clear<=1'b1;
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
					ID_RF_clear<=1'b1;
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
					ID_RF_clear<=1'b1;
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
					ID_RF_clear<=1'b1;
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
					ID_RF_clear<=1'b1;
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
					ID_RF_clear<=1'b1;
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
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b00&&IR[20]==1'b0&&IR[4]==1'b0)//(S/S/W/S)
				begin
					OP <= 4'b0010;
					Sm <= 2'b11;
					Mm <= 2'b10;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b00&&IR[20]==1'b1&&IR[4]==1'b0)//(S/S/W/L)
				begin
					OP <= 4'b0010;
					Sm <= 2'b11;
					Mm <= 2'b10;
					ID_load_instr <= 1'b1; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b01&&IR[20]==1'b0&&IR[4]==1'b0)//(S/S/B/S)
				begin
					OP <= 4'b0010;
					Sm <= 2'b11;
					Mm <= 2'b00;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b01&&IR[20]==1'b1&&IR[4]==1'b0)//(S/S/B/L)
				begin
					OP <= 4'b0010;
					Sm <= 2'b11;
					Mm <= 2'b00;
					ID_load_instr <= 1'b1; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b10&&IR[20]==1'b0&&IR[4]==1'b0)//(S/A/W/S)
				begin
					OP <= 4'b0100;
					Sm <= 2'b11;
					Mm <= 2'b10;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b10&&IR[20]==1'b1&&IR[4]==1'b0)//(S/A/W/L)
				begin
					OP <= 4'b0100;
					Sm <= 2'b11;
					Mm <= 2'b10;
					ID_load_instr <= 1'b1; 
					ID_B <= 1'b0;
					ID_RF <= 1'b1; 
					ID_RW <= 1'b0; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b11&&IR[20]==1'b0&&IR[4]==1'b0)//(S/A/B/S)
				begin
					OP <= 4'b0100;
					Sm <= 2'b11;
					Mm <= 2'b00;
					ID_load_instr <= 1'b0; 
					ID_B <= 1'b0;
					ID_RF <= 1'b0; 
					ID_RW <= 1'b1; 
					ID_Data <= 1'b1;
					if(IR[11:4]==8'h00)ID_shift_imm <= 1'b0;
					else ID_shift_imm <= 1'b1;
					ID_RF_clear<=1'b1;
				end
			else if(IR[25]==1'b1&&IR[23:22]==2'b11&&IR[20]==1'b1&&IR[4]==1'b0)//(S/A/B/L)
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
					ID_RF_clear<=1'b1;
				end
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
				ID_RF_clear<=1'b0;
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
				ID_RF_clear<=1'b0;
			end
		IS<={ID_shift_imm, OP, ID_load_instr, ID_RF, ID_Data, ID_RW, Mm, Sm};
		end
endmodule			