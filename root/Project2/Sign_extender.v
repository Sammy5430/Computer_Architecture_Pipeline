module sign_extender (output reg[31:0] TA, input[23:0] base);
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
			
			