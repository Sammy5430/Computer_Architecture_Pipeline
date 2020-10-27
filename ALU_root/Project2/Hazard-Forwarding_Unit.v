module hazard_forwarding_unit(output reg[1:0] Data_Forw_PA, Data_Forw_PB, Data_Forw_PD, 
output reg NOP, LE_IF_ID, LE_PC, 
input[3:0] ID_Rn, ID_Rm, EX_Rd, MEM_Rd, WB_Rd, 
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