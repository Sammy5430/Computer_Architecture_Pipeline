# Computer_Architecture_Pipeline
Computer Architecture UPRM Course Project (Fall 2020)

Added Mode channel for access type when reading:
    00: Read Byte
    01: Read Halfword
    10: Read Word
    11: Read Doubleword

To execute:
    Navigate to project directory on a terminal
    Compile with: 
        iverilog -o <name> <filename>
    Execute with:
        vvp <name>
    Output will be printed on terminal