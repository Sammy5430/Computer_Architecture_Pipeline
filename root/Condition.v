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