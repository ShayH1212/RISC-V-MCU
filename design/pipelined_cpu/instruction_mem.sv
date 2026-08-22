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

    // Independent instructions - no data hazards
    memory[0] = 32'h00500093; // addi x1, x0, 5
    memory[1] = 32'h00300113; // addi x2, x0, 3
    memory[2] = 32'h00700193; // addi x3, x0, 7
    memory[3] = 32'h00900213; // addi x4, x0, 9
    memory[4] = 32'h00B00293; // addi x5, x0, 11
    memory[5] = 32'h00D00313; // addi x6, x0, 13

    // x1 and x2 have now had plenty of time to reach writeback
    memory[6] = 32'h002083B3; // add x7, x1, x2   -> 8

    memory[7] = 32'h00000013; // nop

end
    

    assign instruction = memory[address[9:2]];

endmodule