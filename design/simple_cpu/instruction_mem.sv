/*
THis is the instruction memmory
This is a read only storage block and will surfice for out single cycle CPU 
*/

module instruction_mem (

    input  logic [31:0] address,
    output logic [31:0] instruction

);

    logic [31:0] memory [0:255];

// Type instructions here
initial begin

    memory[0]  = 32'h00500093; // addi x1, x0, 5
    memory[1]  = 32'h00300113; // addi x2, x0, 3
    memory[2]  = 32'h402081B3; // sub  x3, x1, x2   
    memory[3]  = 32'h0020F233; // and  x4, x1, x2   
    memory[4]  = 32'h0020E2B3; // or   x5, x1, x2  
    memory[5]  = 32'h00209333; // sll  x6, x1, x2  
    memory[6]  = 32'h002353B3; // srl  x7, x6, x2  
    memory[7]  = 32'h0020C433; // xor  x8,  x1, x2 
    memory[8]  = 32'h001124B3; // slt  x9,  x2, x1 
    memory[9]  = 32'h0020B533; // sltu x10, x1, x2 
    memory[10] = 32'hFF000593; // addi x11, x0, -16
    memory[11] = 32'h00200613; // addi x12, x0, 2
    memory[12] = 32'h40C5D6B3; // sra  x13, x11, x12 
    memory[13] = 32'h02A00713; // addi x14, x0, 42
    memory[14] = 32'h00E02023; // sw   x14, 0(x0)
    memory[15] = 32'h00002783; // lw   x15, 0(x0)
    
    memory[16] = 32'h00000C13; // addi x24, x0, 0
    memory[17] = 32'h00108463; // beq  x1, x1, +8
    memory[18] = 32'h06300C13; // addi x24, x0, 99   SHOULD SKIP
    memory[19] = 32'h00100813; // addi x16, x0, 1

    memory[20] = 32'h00000C93; // addi x25, x0, 0
    memory[21] = 32'h00209463; // bne  x1, x2, +8
    memory[22] = 32'h06300C93; // addi x25, x0, 99   SHOULD SKIP
    memory[23] = 32'h00200893; // addi x17, x0, 2

    memory[24] = 32'h00000D13; // addi x26, x0, 0
    memory[25] = 32'h00114463; // blt  x2, x1, +8
    memory[26] = 32'h06300D13; // addi x26, x0, 99   SHOULD SKIP
    memory[27] = 32'h00300913; // addi x18, x0, 3

    memory[28] = 32'h00000D93; // addi x27, x0, 0
    memory[29] = 32'h0020D463; // bge  x1, x2, +8
    memory[30] = 32'h06300D93; // addi x27, x0, 99   SHOULD SKIP
    memory[31] = 32'h00400993; // addi x19, x0, 4

    memory[32] = 32'h00000E13; // addi x28, x0, 0
    memory[33] = 32'h00116463; // bltu x2, x1, +8
    memory[34] = 32'h06300E13; // addi x28, x0, 99   SHOULD SKIP
    memory[35] = 32'h00500A13; // addi x20, x0, 5

    memory[36] = 32'h00000E93; // addi x29, x0, 0
    memory[37] = 32'h0020F463; // bgeu x1, x2, +8
    memory[38] = 32'h06300E93; // addi x29, x0, 99   SHOULD SKIP
    memory[39] = 32'h00600A93; // addi x21, x0, 6

    memory[40] = 32'h00000F13; // addi x30, x0, 0
    memory[41] = 32'h00800B6F; // jal  x22, +8
    memory[42] = 32'h06300F13; // addi x30, x0, 99   SHOULD SKIP
    memory[43] = 32'h00700B93; // addi x23, x0, 7

end    
    

    assign instruction = memory[address[9:2]];

endmodule