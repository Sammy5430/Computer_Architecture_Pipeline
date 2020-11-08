module mux2x1_13 (output reg [12:0] DataOut, input s,  input [12:0] A, input[3:0] OP, input[1:0] Sm, Mm, input ID_shift, load, ID_RF, Data, RW);
    always @(s, A, OP, Sm, Mm, ID_shift, load, ID_RF, Data, RW)
        case(s)
            1'b0:  DataOut = A;
            1'b1:  DataOut = {ID_shift,OP,load, ID_RF, Data, RW, Mm, Sm};
        endcase
endmodule