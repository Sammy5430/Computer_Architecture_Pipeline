module instRAM256x8 (output reg [31:0] DataOut, input Enable, 
input[31:0] Address, input [7:0] DataIn);
    reg[7:0] Mem[0:255];
    always@(Enable) 
        if(Enable)
            Mem[Address] = DataIn;  //write  
endmodule


module dataRAM256x8 (output reg [31:0] DataOut, input Enable, ReadWrite,
input[31:0] Address, input [7:0] DataIn, input [1:0] Mode);
    reg[7:0] Mem[0:255];
    always@(Enable, ReadWrite)
        if(Enable)
            if(ReadWrite)//read
                case(Mode)
                    2'b00:  //Access Byte
                        DataOut = Mem[Address];
                    2'b01:  //Access Halfword: 2 bytes
                        begin
                            DataOut = Mem[Address];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+1];
                        end
                    2'b10:  //Access Word: 4 bytes
                        begin
                            DataOut = Mem[Address];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+1];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+2];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+3];
                        end
                    2'b11:  //Access Doubleword: 2 * 4 bytes
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
                            #3 DataOut = Mem[Address+4];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+5];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+6];
                            DataOut = DataOut << 8;
                            DataOut = DataOut + Mem[Address+7];
                        end
                endcase
        else//write
            Mem[Address] = DataIn;
endmodule


module prechargeInstRAM;
integer inFile, code;
    reg Enable;
    reg [7:0] DataIn;
    reg [31:0] Address;
    wire [31:0] DataOut;
    instRAM256x8 ramI(DataOut, Enable, Address, DataIn);
    initial
        begin
            inFile = $fopen("PF1_Gonzalez_Ortiz_Samuel_ramintr.txt","r");
            Address = 32'b0;
            $display("");
            $display("Instruction RAM was precharged with the following data:");
            $display("        Address   Data");
            #10; //give time for initialization on first enable cycle
            while(!$feof(inFile))
                begin
                    #1 code = $fscanf(inFile, "%b", DataIn); //pass read value through DataIn
                    #7 $display("%d        %b", Address, ramI.Mem[Address]); //print value on Mem to confire that the value was stored
                    #2 Address = Address + 1; 
                end
            $fclose(inFile);
        end
    initial
        begin
            Enable = 1'b0;
            repeat (40)
                begin
                    #5 Enable = 1'b1;
                    #5 Enable = 1'b0;
                end
            $finish;
        end        
endmodule


module prechargeDataRAM;
    integer inFile, code;
    reg Enable, ReadWrite;
    reg[1:0] Mode;
    reg [7:0] DataIn;
    reg [31:0] Address;
    wire [31:0] DataOut;
    dataRAM256x8 ramD(DataOut, Enable, ReadWrite, Address, DataIn, Mode);
    initial
        begin
            #200; //give time for Instruction RAM Initialization to end
            inFile = $fopen("PF1_Gonzalez_Ortiz_Samuel_ramdata.txt","r");
            Address = 32'b0;
            $display("");
            $display("Data RAM was precharged with the following data:");
            $display("        Address   Data");
            #10; //give time for initialization on first enable cycle
            while(!$feof(inFile))
                begin
                    #1 code = $fscanf(inFile, "%b", DataIn);
                    #7 $display("%d        %b", Address, ramD.Mem[Address]);
                    #2 Address = Address + 1; 
                end
            $fclose(inFile);
        end
    initial
        begin
            #200; //give time for Instruction RAM Initialization to end
            Enable = 1'b0;
            ReadWrite = 1'b0;
            repeat (20)
                begin
                    #5 Enable = 1'b1;
                    #5 Enable = 1'b0;
                end
            $finish;
        end        
endmodule

module testInstRAM;
endmodule

module testDataRAM;
    initial
        begin
            #400;
            $display("");
            $display("Testing Data RAM:");
            $display("        Address   Data");
            $display("%d        %b     %h        %h", Address, ReadWrite, DataIn, DataOut);
            Enable = 1'b0;
            ReadWrite = 1'b1;
            prechargeDataRAM.ramD.Mode = 2'b10;
            #1 Address = 32'b0;
            repeat (16/Mode)
                begin
                    #5 Enable = 1'b1;
                    #5 Enable = 1'b0;
                    Address = Address+Mode+1;
                end
            $finish;
        end

        always @ (posedge Enable)
            begin
                #1;
                case(Mode)
                    2'b11:  //Access Doubleword: 2 * 4 bytes
                        begin
                            DataOutprev <= DataOut;
                            #4;
                            $display("%d        %b     %h        %h %h", Address, ReadWrite, DataIn, DataOutprev, DataOut);
                        end
                    default:
                        $display("%d        %b     %h        %h", Address, ReadWrite, DataIn, DataOut);
                endcase
            end

        //read word (Mode 10) from 0,4,8,12
        //read Mode 00 from 0, Mode o1 from 2, Mode 01 from 4, Mode 10 from 8
        //read Mode 10 from 4,8
        //$display("");
        //$display("Data RAM Testing:");
        //$display("        Address   R/W   Data In   Data Out");
        //$display("%d        %b     %h        %h", Address, ReadWrite, DataIn, DataOut)
endmodule

/*
module prechargeDataRAMref;
    integer inFile, outFile, code;
    reg Enable, ReadWrite;
    reg [1:0] Mode;
    reg [7:0] data;
    reg [7:0] DataIn;
    reg [31:0] Address;
    reg [31:0] DataOutprev;    //for use with doubleword
    wire [31:0] DataOut;
    dataRAM256x8 ramD(DataOut, Enable, ReadWrite, Address, DataIn, Mode);
    initial
        begin
            inFile = $fopen("PF1_Gonzalez_Ortiz_Samuel_ramdata.txt","r");
            Address = 32'b0;
            while(!$feof(inFile))
                begin
                   code = $fscanf(inFile, "%b", data);
                   ramD.Mem[Address] = data;
                   Address = Address + 1; 
                end
            $fclose(inFile);
        end
    initial
        begin
            outFile = $fopen("PF1_Gonzalez_Ortiz_Samuel_output.txt", "w");
            $fdisplay(outFile, "Data RAM precharged with the following:");
            $fdisplay(outFile, "        Address   R/W   Data In   Data Out");
            Enable = 1'b0;
            ReadWrite = 1'b1;
            Mode = 2'b10;
            #1 Address = 32'b0;
            repeat (16/Mode)
                begin
                    #5 Enable = 1'b1;
                    #5 Enable = 1'b0;
                    Address = Address+Mode;
                end
            $finish;
        end
    always @ (posedge Enable)
        begin
            #1;
            case(Mode)
                2'b11:  //Access Doubleword: 2 * 4 bytes
                    begin
                        DataOutprev <= DataOut;
                        #4;
                        $fdisplay(outFile, "%d        %b     %h        %h %h", Address, ReadWrite, DataIn, DataOutprev, DataOut);
                    end
                default:
                    $fdisplay(outFile, "%d        %b     %h        %h", Address, ReadWrite, DataIn, DataOut);
            endcase
        end
endmodule
*/

/*
module prechargeInstRAMref;
    integer inFile, outFile, code;
    reg Enable;
    reg [7:0] data;
    reg [7:0] DataIn;
    reg [31:0] Address;
    wire [31:0] DataOut;
    instRAM256x8 ramI(DataOut, Enable, Address, DataIn);
    initial
        begin
            inFile = $fopen("PF1_Gonzalez_Ortiz_Samuel_ramintr.txt","r");
            Address = 32'b0;
            while(!$feof(inFile))
                begin
                   code = $fscanf(inFile, "%b", data);
                   ramI.Mem[Address] = data;
                   Address = Address + 1; 
                end
            $fclose(inFile);
        end
    initial
        begin
            outFile = $fopen("PF1_Gonzalez_Ortiz_Samuel_output.txt", "w");
            $fdisplay(outFile, "Address   Data Out");
            Enable = 1'b0;
            Address = 32'b0;
            repeat (16)
                begin
                    #5 Enable = 1'b1;
                    #5 Enable = 1'b0;
                    Address = Address+1;
                end
            $finish;
            
        end
    always @ (posedge Enable)
        begin
            #1;
            $fdisplay(outFile, "%d   %h", Address, DataOut);
        end
endmodule
*/