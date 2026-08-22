/*
This module is a comparator
This will be used to handle all types of branch instructions

000 -> BEQ
001 -> BNE
100 -> BLT
101 -> BGE
110 -> BLTU
111 -> BGEU
*/

module comp (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [2:0] funct3,
    input logic branch,

    output logic branch_successful
);

    always_comb begin
        
        branch_successful = 1'b0;

        if (branch) begin

            case (funct3)

            3'b000:
            branch_successful = (a == b);

            3'b001:
            branch_successful = (a != b);

            3'b100:
            branch_successful = ($signed(a) < $signed(b));

            3'b101:
            branch_successful = ($signed(a) >= $signed(b));

            3'b110:
            branch_successful = (a < b);

            
            3'b111:
            branch_successful = (a >= b);

            default:
            branch_successful = 1'b0;

            endcase
        end

    end

endmodule