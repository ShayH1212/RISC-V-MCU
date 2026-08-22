/*
This is code for a immediate generator
The immediate generator has to be able to fetch immediates in 5 different cases
Immediates can be encoded in different locations determined by which type of instruction is being called
This code will determine what type of instruction is being called and locate the immediated needed for the instruction to be called
*/ 

module immediate_gen(
    input  logic [31:0] instruction,
    output logic [31:0] immediate
);

logic [6:0] opcode;

assign opcode = instruction[6:0];

always_comb begin

    case(opcode)

    //I Type
    // Immediate encoded in 31:20
    7'b0010011, 7'b0000011, 7'b1100111:
    immediate = {{20{instruction[31]}}, instruction[31:20]};


    // S-type
    // Immediate encoded in {31:25, 11:7}
    7'b0100011:
    immediate = {{20{instruction[31]}},instruction[31:25], instruction[11:7]};



    // B-type
    // Immediate encoded in {31, 7, 30:25, 11:8}
    7'b1100011:
    immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};

    

    // U-type
    // Immediate encoded in {31:12}
    7'b0110111, 7'b0010111:
    immediate = {instruction[31:12], 12'b0};


    // J-type
    // Immediate encoded in {30:21, 19:12, 20,}
    7'b1101111:
    immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};


    default: immediate = 32'b0;

        endcase

    end

endmodule
