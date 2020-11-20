//Input address is always even and a multiple of four, therefore
//the two least significant bits must be converted to 00

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


module testInstRAM;
//////////////
//Pre-charge//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    integer I_inFile, I_code;
    // reg I_Enable;
    reg [7:0] data;
    reg [31:0] I_Address;
    wire [31:0] I_DataOut;
    instRAM256x8 ramI(I_DataOut, I_Address);
    initial
        begin
            I_inFile = $fopen("PF1_Gonzalez_Ortiz_Samuel_ramintr.txt","r");
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
    // initial
    //     begin
    //         I_Enable = 1'b0;
    //         repeat (16)
    //             begin
    //                 #5 I_Enable = 1'b1;
    //                 #5 I_Enable = 1'b0;
    //             end
    //     end  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////
//Test// FIX: print out words, not bytes
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    initial
        begin
            #400;
            $display("");
            $display("Testing Instruction RAM:");
            $display("        Address   Data");
            // I_Enable = 1'b0;
            I_Address = 32'b0;
            repeat (16)
                begin
                    #5 //I_Enable = 1'b1;
                    #5 //I_Enable = 1'b0;
                    $display("%d        %h", I_Address, I_DataOut);
                    I_Address = I_Address + 1;
                end
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////      
endmodule


module testDataRAM;
//////////////
//Pre-charge//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    integer D_inFile, D_code;
    reg D_Enable, D_ReadWrite;
    reg[1:0] D_Mode;
    reg [31:0] D_DataIn;
    reg [31:0] D_DataOutprev; //stores most significant bit data for doublewords
    reg [31:0] D_Address;
    wire [31:0] D_DataOut;
    dataRAM256x8 ramD(D_DataOut, D_Enable, D_ReadWrite, D_Address, D_DataIn, D_Mode);
    initial
        begin
            #200; //wait for Instruction RAM Initialization to end (used only for precharge prints)
            D_inFile = $fopen("PF1_Gonzalez_Ortiz_Samuel_ramdata.txt","r");
            D_Address = 32'b0;
            $display("");
            $display("Data RAM was precharged with the following data:");
            $display("        Address   Data");
            while(!$feof(D_inFile))
                begin
                    #1 D_code = $fscanf(D_inFile, "%b", D_DataIn);
                    #7 $display("%d        %b", D_Address, ramD.Mem[D_Address]);
                    #2 D_Address = D_Address + 1; 
                end
            $fclose(D_inFile);
        end
    initial
        begin
            #200; //wait for Instruction RAM Initialization to end (used only for precharge prints)
            D_Enable = 1'b0;
            D_Mode = 2'b0;
            D_ReadWrite = 1'b1;
            repeat (16)
                begin
                    #5 D_Enable = 1'b1;
                    #5 D_Enable = 1'b0;
                end
        end  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////
//Test//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    initial //test case 1
        begin 
            #600;
            $display("");
            $display("Testing Data RAM (case 1):");
            $display("        Address   R/W   Data In   Data Out");

            D_Enable = 1'b0;
            D_ReadWrite = 1'b0;
            D_Mode = 2'b10;
            D_Address = 32'b0;
            repeat (4)
                begin
                    #5 D_Enable = 1'b1;
                    #5 D_Enable = 1'b0;
                    $display("%d        %b     %h        %h", D_Address, D_ReadWrite, D_DataIn, D_DataOut);
                    D_Address = D_Address + 4;
                end
        end

    initial //test case 2
        begin
            #650
            $display("");
            $display("Testing Data RAM (case 2):");
            $display("        Address   R/W   Data In   Data Out");
            D_Enable = 1'b0;
            D_ReadWrite = 1'b0;
            D_Mode = 2'b00;
            D_Address = 32'b0;
                #5 D_Enable = 1'b1;
                #5 D_Enable = 1'b0;
                $display("%d        %b     %h        %h", D_Address, D_ReadWrite, D_DataIn, D_DataOut);
            D_Mode = 2'b01;
            D_Address = 32'b10;
                #5 D_Enable = 1'b1;
                #5 D_Enable = 1'b0;
                $display("%d        %b     %h        %h", D_Address, D_ReadWrite, D_DataIn, D_DataOut);
            D_Address = 32'b100;
                #5 D_Enable = 1'b1;
                #5 D_Enable = 1'b0;
                $display("%d        %b     %h        %h", D_Address, D_ReadWrite, D_DataIn, D_DataOut);
        end

    initial //test case 3
        begin
            #700
            $display("");
            $display("Testing Data RAM (case 3):");
            $display("        Address   R/W   Data In   Data Out");
            D_Enable = 1'b0;
            D_ReadWrite = 1'b1;
            D_Mode = 2'b00;
            D_Address = 32'b0;
                D_DataIn = 32'haa;
                #5 D_Enable = 1'b1;
                #5 D_Enable = 1'b0;
                $display("%d        %b     %h        %h", D_Address, D_ReadWrite, D_DataIn, D_DataOut);
            D_Mode = 2'b01;
            D_Address = 32'b10;
                D_DataIn = 32'haaaa;
                #5 D_Enable = 1'b1;
                #5 D_Enable = 1'b0;
                $display("%d        %b     %h        %h", D_Address, D_ReadWrite, D_DataIn, D_DataOut);
            D_Mode = 2'b01;
            D_Address = 32'b100;
                D_DataIn = 32'haaaa;
                #5 D_Enable = 1'b1;
                #5 D_Enable = 1'b0;
                $display("%d        %b     %h        %h", D_Address, D_ReadWrite, D_DataIn, D_DataOut);
            D_Mode = 2'b10;
            D_Address = 32'b1000;
                D_DataIn = 32'haaaaaaaa;
                #5 D_Enable = 1'b1;
                #5 D_Enable = 1'b0;
                $display("%d        %b     %h        %h", D_Address, D_ReadWrite, D_DataIn, D_DataOut);
        end

    initial //test case 4
        begin
            #750
            $display("");
            $display("Testing Data RAM (case 4):");
            $display("        Address   R/W   Data In   Data Out");
            D_Enable = 1'b0;
            D_ReadWrite = 1'b0;
            D_Mode = 2'b10;
            D_Address = 32'b00;
                #5 D_Enable = 1'b1;
                #5 D_Enable = 1'b0;
                $display("%d        %b     %h        %h", D_Address, D_ReadWrite, D_DataIn, D_DataOut);
            D_Address = 32'b100;
                #5 D_Enable = 1'b1;
                #5 D_Enable = 1'b0;
                $display("%d        %b     %h        %h", D_Address, D_ReadWrite, D_DataIn, D_DataOut);
        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule
