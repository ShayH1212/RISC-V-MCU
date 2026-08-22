/*
This module will be for updating the program counter
The program counter will normally be updated by 4
However, there are some special cases that need to be handeled
if branch : pc = pc + imm
if jump  : pc = pc + imm
*/

module pc_next (
    input logic [31:0] pc,
    input logic [31:0] immediate,
    input logic jump,
    input logic branch_successful,

    output logic [31:0] pc_next
);

always_comb begin

    pc_next = pc + 32'd4; // regular behaviour

    if (branch_successful) // this allows for branches
    pc_next = pc + immediate;

    if (jump)
    pc_next = pc + immediate;

end

endmodule