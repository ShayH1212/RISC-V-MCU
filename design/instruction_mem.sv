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

    assign instruction = memory[address[9:2]];

endmodule