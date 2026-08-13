/*
This module is a decoder
The decoder will read the instruction code and edit output  to perform actions

How to read instructions:

The 7 bit opcode is used to determine the type of instruction that needs to be done

func 3 and func 7 are used to further narrow down what command must be done

The important outputs are:

reg_write : 1 -> write something into rd

mem_write : 1 -> write to data memory

val_sec: 0 -> ALU gets B from rs2
         1 -> ALU gets B from immediate generator

alu_op : tells your ALU what calculation to perform

branch : tells next-PC logic this is a branch

jump : tells next-PC logic this is a jump

result_src : 00 -> write ALU result to rd
             01 -> write memory data to rd
             10 -> write PC + 4 to rd
*/

module decoder (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic reg_write,
    output logic mem_write,
    output logic val_sec,
    output logic branch,
    output logic jump,
    output logic [1:0] result_src,
    output logic [3:0] alu_op
);

    //ALU codes to be sent to the alu
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR = 4'b0011;
    localparam ALU_XOR = 4'b0100;
    localparam ALU_SLL = 4'b0101;
    localparam ALU_SRL = 4'b0110;
    localparam ALU_SRA = 4'b0111;
    localparam ALU_SLT = 4'b1000;
    localparam ALU_SLTU = 4'b1001;


    always_comb begin

        // Default values chosen as they "do nothing"
        reg_write = 1'b0;
        mem_write = 1'b0;
        val_sec = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        result_src = 2'b00;
        alu_op = ALU_ADD;


   case (opcode)

        // R-TYPE
        7'b0110011: begin 

            reg_write = 1'b1;
            val_sec   = 1'b0;

            case (funct3)

                3'b000: begin

                    if (funct7 == 7'b0100000)
                        alu_op = ALU_SUB;
                    else
                        alu_op = ALU_ADD;

                end


                3'b001:
                    alu_op = ALU_SLL;


                3'b010:
                    alu_op = ALU_SLT;


                3'b011:
                    alu_op = ALU_SLTU;


                3'b100:
                    alu_op = ALU_XOR;


                3'b101: begin

                    if (funct7 == 7'b0100000)
                        alu_op = ALU_SRA;
                    else
                        alu_op = ALU_SRL;

                end


                3'b110:
                    alu_op = ALU_OR;


                3'b111:
                    alu_op = ALU_AND;


                default:
                    alu_op = ALU_ADD;

            endcase

        end


        // I-TYPE 
        7'b0010011: begin

            reg_write = 1'b1;
            val_sec   = 1'b1;

            case (funct3)

                3'b000:
                    alu_op = ALU_ADD;   // ADDI

                3'b001:
                    alu_op = ALU_SLL;   // SLLI

                3'b010:
                    alu_op = ALU_SLT;   // SLTI

                3'b011:
                    alu_op = ALU_SLTU;  // SLTIU

                3'b100:
                    alu_op = ALU_XOR;   // XORI

                3'b101: begin

                    if (funct7 == 7'b0100000)
                        alu_op = ALU_SRA;   // SRAI
                    else
                        alu_op = ALU_SRL;   // SRLI

                end

                3'b110:
                    alu_op = ALU_OR;    // ORI

                3'b111:
                    alu_op = ALU_AND;   // ANDI

                default:
                    alu_op = ALU_ADD;

            endcase

        end


        // LOAD 
        7'b0000011: begin

            reg_write = 1'b1;
            val_sec = 1'b1;
            alu_op = ALU_ADD; // add function is used when loading

            // Register gets its value from memory
            result_src = 2'b01;

        end


        // STORE
        7'b0100011: begin

            mem_write = 1'b1;
            val_sec   = 1'b1;
            alu_op    = ALU_ADD; // add function is used when storing

        end


        // BRANCH
        7'b1100011: begin

            branch  = 1'b1;
            val_sec = 1'b0;
            alu_op  = ALU_SUB; // sub function is used when branching

        end


        // JAL
        7'b1101111: begin

            reg_write  = 1'b1;
            jump       = 1'b1;

            // rd receives PC + 4
            result_src = 2'b10;

        end


        default: begin

            reg_write  = 1'b0;
            mem_write  = 1'b0;
            val_sec    = 1'b0;
            branch     = 1'b0;
            jump       = 1'b0;
            result_src = 2'b00;
            alu_op     = ALU_ADD;

        end

    endcase

end

endmodule

