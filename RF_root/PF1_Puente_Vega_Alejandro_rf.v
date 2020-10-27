//This the code for a register adder of 1 input and 3 adders.

// Falta implementar el PC + 4; Also fix el print para cada ciclo del clock



//Register Module:
module registers(output reg [31:0] out, input [31:0] in, input lde, clk, clr );
//lde = loadEnable

always@ (posedge clk, negedge clr)
begin
if (!clr) out <= 32'h00000000; 
else if (lde) out = in;

// $display("Input: %h", in);
// $display("output: %h", out);

end
endmodule

//=======================================================================================================================//
//testing register woorks!!!
// module testingresgister;
//   wire [31:0] out ;
//   reg [31:0] in;
//   reg lde, clk , clr;
  
//   registers testing_reg (out, in, lde, clk, clr);
  
// initial begin

//   repeat (2) #1 clk = ~clk;

  
//   in = 32'h00000001;
  
//   clk = 1'b1;
//   lde = 1'b1;
//   clr = 1'b1;
  
//   #1;
   
//   $display("Input: %h", in);
//   $display("output: %h", out);

//   $display("Load: %h", lde);

// end
// endmodule

//=================================================================================================================================//



//16to1Multiplecer Module:
module mux16to1 (output reg [31:0] O ,input [3:0] s, input [31:0] A, B, C , D , E , F , G , H , I , J , K , L , N , M , P , Q );
//rdata [15:0]
always @(s, A, B, C , D , E , F , G , H , I , J , K , L , N , M , P , Q)
//Evaluates the 4bits of the select line and chooses from what register the data will enter to the output.
case (s)
      4'b0000: O = A;
      4'b0001: O = B;
      4'b0010: O = C;
      4'b0011: O = D;
      4'b0100: O = E;
      4'b0101: O = F;
      4'b0110: O = G;
      4'b0111: O = H;
      4'b1000: O = I;
      4'b1001: O = J;
      4'b1010: O = K;
      4'b1011: O = L;
      4'b1100: O = N;
      4'b1101: O = M;
      4'b1110: O = P;
      4'b1111: O = Q;
endcase
endmodule

//Binary Decoder Module:
module binaryDecoder (output reg[15:0] activate, input ld , input [3:0] choose);
//module binaryDecoder (output reg activate0, activate1, activate2, activate3, activate4, activate5, activate6, activate7, activate8,activate9,activate10,activate11,activate12,activate13,activate14,activate15, input ld , input [3:0] choose);
always@(ld, choose)
//Evaluates the 4bits that enter and enables the correct register. 
  begin
    case (choose)
      4'b0000: activate = 16'b1000000000000000;
      4'b0001: activate = 16'b0100000000000000;
      4'b0010: activate = 16'b0010000000000000;
      4'b0011: activate = 16'b0001000000000000;
      4'b0100: activate = 16'b0000100000000000;
      4'b0101: activate = 16'b0000010000000000;
      4'b0110: activate = 16'b0000001000000000;
      4'b0111: activate = 16'b0000000100000000;
      4'b1000: activate = 16'b0000000010000000;
      4'b1001: activate = 16'b0000000001000000;
      4'b1010: activate = 16'b0000000000100000;
      4'b1011: activate = 16'b0000000000010000;
      4'b1100: activate = 16'b0000000000001000;
      4'b1101: activate = 16'b0000000000000100;
      4'b1110: activate = 16'b0000000000000010;
      4'b1111: activate = 16'b0000000000000001;
      // 4'b0000: activate0 = 1'b1;
      // //16'b1000000000000000;
      // 4'b0001: activate1 = 16'b0100000000000000;
      // 4'b0010: activate2 = 16'b0010000000000000;
      // 4'b0011: activate3 = 16'b0001000000000000;
      // 4'b0100: activate4 = 16'b0000100000000000;
      // 4'b0101: activate5 = 16'b0000010000000000;
      // 4'b0110: activate6 = 16'b0000001000000000;
      // 4'b0111: activate7 = 16'b0000000100000000;
      // 4'b1000: activate8 = 16'b0000000010000000;
      // 4'b1001: activate9 = 16'b0000000001000000;
      // 4'b1010: activate10 = 16'b0000000000100000;
      // 4'b1011: activate11 = 16'b0000000000010000;
      // 4'b1100: activate12 = 16'b0000000000001000;
      // 4'b1101: activate13 = 16'b0000000000000100;
      // 4'b1110: activate14 = 16'b0000000000000010;
      // 4'b1111: activate15 = 16'b0000000000000001;
    endcase
  end
endmodule

//=========================================================================================================================//
//test decoder work!!!!!
// module testingDecoder;

// reg [3:0] choose;
// reg ld;

// wire [15:0] activate;

// binaryDecoder testing_decoder(activate, ld, choose);

// initial begin

//   choose = 4'b1111;
//   ld = 1'b1;
//   //repeat (15) #10 choose = choose + 4'b0001;

// end
// initial begin
  
//  #1;

//   $display("choosingsignal: %b", choose);
//   $display("ld: %b", ld);
//   $display("Out: %b", activate);


// end
// endmodule


//===========================================================================================================================//

//Adder for the pc+4 Module:
module adder4 (output reg [31:0] pc4, input [31:0] pc, n, input clk);
always@(pc, n, posedge clk)
    pc4 = pc + n;
endmodule

//Mux for PC------------------ arreglar en el codigo original
module mux2x1 (output reg [31:0] O, input s,  input [31:0] A, B );
always @(s, A, B)
    case(s)
      1'b0:  O = A;
      1'b1:  O = B;
endcase
endmodule


//Register File module
//All the modules will be implemented here and connected in the correct way except for the Adder
module registerfile (output [31:0] O1, O2, O3, PCout, input clk, lde, clr, LE_PC, input [3:0] s1,s2,s3, ddata, input [31:0] datain, PCIN);

//Stating the wires
wire [31:0] data [15:0];// data register output to connect to the multiplexers 
wire [15:0] enables; // transfering the activation from the decoder to the registers
wire [31:0] addedPCin; //from adder to mux2x1
wire [31:0] chosenData;//mux to register 15

// wire [31:0] data0, data1, data2, data3, data4, data5, data6, data7, data8, data9, data10, data11, data12, data13, data14, data15;
// wire en0, en1, en2, en3, en4, en5, en6, en7, en8, en9, en10, en11, en12, en13, en14, en15;

//Connecting the Modules
binaryDecoder Bdecoder(enables, lde, ddata);//Binary decoder
//binaryDecoder Bdecoder(en0, en1, en2, en3, en4, en5, en6, en7, en8, en9, en10, en11, en12, en13, en14, en15, lde, ddata);//Binary decoder

//15 registers
registers R0 (data[0], datain, enables[15-0], clk, clr);
registers R1 (data[1], datain, enables[15-1], clk, clr);
registers R2 (data[2], datain, enables[15-2], clk, clr);
registers R3 (data[3], datain, enables[15-3], clk, clr);
registers R4 (data[4], datain, enables[15-4], clk, clr);
registers R5 (data[5], datain, enables[15-5], clk, clr);
registers R6 (data[6], datain, enables[15-6], clk, clr);
registers R7 (data[7], datain, enables[15-7], clk, clr);
registers R8 (data[8], datain, enables[15-8], clk, clr);
registers R9 (data[9], datain, enables[15-9], clk, clr);
registers R10 (data[10], datain, enables[15-10], clk, clr);
registers R11 (data[11], datain, enables[15-11], clk, clr);
registers R12 (data[12], datain, enables[15-12], clk, clr);
registers R13 (data[13], datain, enables[15-13], clk, clr);
registers R14 (data[14], datain, enables[15-14], clk, clr);

//PC
adder4 pcadder(addedPCin, PCIN, 32'd4, clk);
mux2x1 pcmux(chosenData, LE_PC, datain, addedPCin);

registers R15 (data[15], chosenData, enables[15-15],clk, clr);// decision done


// registers R0 (data0, datain, en0, clk, clr);
// registers R1 (data1, datain, en1, clk, clr);
// registers R2 (data2, datain, en2, clk, clr);
// registers R3 (data3, datain, en3, clk, clr);
// registers R4 (data4, datain, en4, clk, clr);
// registers R5 (data5, datain, en5, clk, clr);
// registers R6 (data6, datain, en6, clk, clr);
// registers R7 (data7, datain, en7, clk, clr);
// registers R8 (data8, datain, en8, clk, clr);
// registers R9 (data9, datain, en9, clk, clr);
// registers R10 (data10, datain, en10, clk, clr);
// registers R11 (data11, datain, en11, clk, clr);
// registers R12 (data12, datain, en12, clk, clr);
// registers R13 (data13, datain, en13, clk, clr);
// registers R14 (data14, datain, en14, clk, clr);

// registers R15 (data15, datain, en15,clk, clr);// needs to be pc? must find a way to add 4 but also have the data that is passing through


// mux16to1 muxO1(O1, s1, data0, data1, data2, data3, data4, data5, data6, data7, data8, data9, data10, data11, data12, data13, data14, data15);
// mux16to1 muxO2(O2, s2, data0, data1, data2, data3, data4, data5, data6, data7, data8, data9, data10, data11, data12, data13, data14, data15);
// mux16to1 muxO3(O3, s3, data0, data1, data2, data3, data4, data5, data6, data7, data8, data9, data10, data11, data12, data13, data14, data15);





// //Multiplexers
mux16to1 muxO1(O1, s1, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);
mux16to1 muxO2(O2, s2, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);
mux16to1 muxO3(O3, s3, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);

endmodule

//====================================================================================================================//
//Testing & Demostration code:
module test;

//input:
reg [3:0] s1, s2, s3, ddata;
reg[31:0] datain, PCIN;
reg clr, clk, lde;

//Output:
wire [31:0] O1, O2, O3, PCout;

//registerfiel module
registerfile register_file(O1, O2, O3, PCout ,clk, clr, lde, LE_PC, s1, s2, s3, ddata, datain, PCIN);


initial begin

//R0
PCIN = 32'd0;
//Load enable
lde = 1'b1;
//Decoder Data
ddata = 4'b1010;
//Entering Data
datain = 32'h000A0000;
//Select lines for mux
s1 = 4'b1010;
s2 = 4'b1010;
s3 = 4'b1010;
//Clock and clear
clr = 1'b1;
//clk = 1'b1;

#20;
//datain = 32'h000A00ff;




end

//Starting up the variables
initial begin

clk = 1'b0;
repeat (16) #5 clk = ~clk;
end
  
// //R0
// PCIN = 32'd0;
// //Load enable
// lde = 1'b1;
// //Decoder Data
// ddata = 4'b0000;
// //Entering Data
// datain = 32'h00000001;
// //Select lines for mux
// s1 = 4'b0000;
// s2 = 4'b0001;
// s3 = 4'b0010;
// //Clock and clear
// clr = 1'b1;
// clk = 1'b1;

//#10;

//Debugging
// $display("this is enable[0]: %b" , register_file.en0);
// $display("this is enable[0]: %b" , register_file.en1);
// $display("this is enable[0]: %b" , register_file.en2);
// $display("this is enable[0]: %b" , register_file.en3);
// $display("this is enable[0]: %b" , register_file.en4);
// $display("this is enable[0]: %b" , register_file.en5);
// $display("this is enable[0]: %b" , register_file.en6);
// $display("this is enable[0]: %b" , register_file.en7);
// $display("this is enable[0]: %b" , register_file.en8);
// $display("this is enable[0]: %b" , register_file.en9);
// $display("this is enable[0]: %b" , register_file.en10);
// $display("this is enable[0]: %b" , register_file.en11);
// $display("this is enable[0]: %b" , register_file.en12);
// $display("this is enable[0]: %b" , register_file.en13);
// $display("this is enable[0]: %b" , register_file.en14);
// $display("this is enable[0]: %b" , register_file.en15);


// $display("this is register info out: %h", register_file.data0);
// $display("this is register info out: %h", register_file.data1);
// $display("this is register info out: %h", register_file.data2);
// $display("this is register info out: %h", register_file.data3);
// $display("this is register info out: %h", register_file.data4);
// $display("this is register info out: %h", register_file.data5);
// $display("this is register info out: %h", register_file.data6);
// $display("this is register info out: %h", register_file.data7);
// $display("this is register info out: %h", register_file.data8);
// $display("this is register info out: %h", register_file.data9);
// $display("this is register info out: %h", register_file.data10);
// $display("this is register info out: %h", register_file.data11);
// $display("this is register info out: %h", register_file.data12);
// $display("this is register info out: %h", register_file.data13);
// $display("this is register info out: %h", register_file.data14);
// $display("this is register info out: %h", register_file.data15);


//$display("this is data[0]: %b" , register_file.data[0]);
// $display("this is register info out: %h", register_file.data0);
// $display("this is register info in: %h", register_file.datain);
// // // $display("this is register clk info: %b", register_file.clk);
// // $display("this is register info decoder data: %b", register_file.ddata);
// //$display("this is register clk info: %b", register_file);
initial begin
// $display("R");
// $display("Input Data: %h", datain);
// $display("DecoderDataSelector %b", ddata);
// $display("select1M: %b", s1);
// $display("select2M: %b", s2);
// $display("select3M: %b", s3);
// $monitor("Output1: %h", O1);
// $monitor("Output2 %h", O2);
// $monitor("Output3 %h", O3);

// $display("");
// $display("R2");
// repeat (15) #10 $display("Input Data: %h", datain+32'h00000001);
// $display("DecoderDataSelector %b", ddata+4'b0001);
// $display("select1M: %b", s1+4'b0001);
// // $display("select2M: %b", s2);
// // $display("select3M: %b", s3);
// $display("Output1: %h", O1);




// $display("Load enable %b", lde);
// $display("This is the value of PCIN: %d", PCIN);
// //$display("clear %b", clr);
// //$display("clock %b", clk);





end
endmodule

//==============================================================================================================//
//Tesing adder works!!!
// module testadder;

// reg [31:0] pc, four;
// reg clk;
// wire [31:0] out;

// adder4 testadder (out, pc, four, clk);

// initial begin
//   repeat (2) #1 clk = ~clk;

//   clk = 1'b1;
//   pc = 32'd0;
//   four = 32'd4;
  
//   #1;
  
//   $display("result: %d", out);

// end
// endmodule

//==========================================================================================================//

// testing Mux works!!!!!
//module test2();
//testing mux
// reg [3:0] s;
// reg [31:0] A, B, C , D , E , F , G , H , I , J , K , L , N , M , P , Q;

// wire [31:0] O;

// mux16to1 testmux(O, s, A, B, C , D , E , F , G , H , I , J , K , L , N , M , P , Q);

// initial begin

// s = 4'b0000;
// A = 32'h00000001;
// B = 32'hdd11dd00;

// #1;

// $display("=============================MuxTesting=======================");
// $display("Out: %h, Ins: %b, data: %h ", O, s, A);
// end
// endmodule


module Flagregister(output reg [31:0] CC_out, output reg C_in, input [31:0] CC_in, input s);
//lde = loadEnable

always@ (s)
begin
  if (s) CC_out = CC_in;

$display("Input: %h", CC_in);
$display("output: %h", CC_out);

end
endmodule

//testing flag register woorks!!!
// module testingflagresgister;
//   wire [3:0] out ;
//   reg [3:0] in;
//   reg lde;
  
//   Flagregister testing_flag (out, in, lde);
  
// initial begin

//  // repeat (2) #1 clk = ~clk;

  
//   in = 4'b0001;
  
//   lde = 1'b1;
 
//   #1;
   
//   $display("Input: %h", in);
//   $display("output: %h", out);

//   $display("Load: %h", lde);

// end
// endmodule


module mux4to1 (output reg [31:0] O ,input [1:0] s, input [31:0] A, B, C , D);

always @(s, A, B, C , D)

case (s)

      2'b00: O = A;
      2'b01: O = B;
      2'b10: O = C;
      2'b11: O = D;

endcase
endmodule


module mux2x1_7 (output reg [6:0] O, input s,  input [6:0] A, B );
always @(s, A, B)
    case(s)
      1'b0:  O = A;
      1'b1:  O = B;
endcase
endmodule

module mux2x1_1 (output reg O, input s,  input A, B );
always @(s, A, B)
    case(s)
      1'b0:  O = A;
      1'b1:  O = B;
endcase
endmodule

//IF/ID register
// module pipeline_registers_1(output reg [31:0] PCAdressOut, PCNextout output reg LinkOut, input clk, LD, LinkIn input [31:0] InInstructionMEM, InPCAdress, INNextPC);
// wire [4:0] toConditionH;
// wire [23:0] toSignextender;
// wire bitToCondition;
// wire [3:0] RA;
// wire [3:0] RB;
// wire [3:0] RD;
// wire [11:0] directTonextregister;
// wire oneBitToNextRegister;
// wire [31:0] toCPU;

// reg [31:0] temp;
// always @ (posedge clk, LD);
//  PCNextout = INNextPC;
//  PCAdressOut = InPCAdress;
//  LinkOut = LinkOut

//  temp = InInstructionMEM & 32'b






//  endmodule
//son diferentes caaca uno de los pipeline registers. El de instruction fetch y decoder tienen lde los demas no. Crear la base y spread a los demas. 

// //ID/EX register
// module pipeline_registers_2(output reg [31:0] out1, output reg [3:0] out2, output reg [23:0] out3, input clk, input [31:0] InInstructionMEM, InPCAdress, INNextPC);
// always @ (posedge clk);
// begin
//   if(LD)   ;
// end
// endmodule

// //EX/MEM register
// module pipeline_registers_2(output reg [31:0] out, input clk, input [31:0] indata);
// always @ (posedge clk);
// begin
//   if(LD)   ;
// end
// endmodule

// //MEM/WB register
// module pipeline_registers_2(output reg [31:0] out, input clk, input [31:0] indata);
// always @ (posedge clk);
// begin
//   if(LD)   ;
// end
// endmodule