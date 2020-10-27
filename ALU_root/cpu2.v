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