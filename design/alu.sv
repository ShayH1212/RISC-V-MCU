/*
The below module contains an ALU
This ALU has two inputs A and B and can perform 10 different opperations

ALU_ADD
OppCode: 0000
result = a + b

ALU_SUB
Opp_Code: 0001
result = a - b

ALU_AND
Opp_Code: 0010
result = a & b

ALU_OR
Opp_Code: 0011
result = a | b

ALU_XOR
Opp_Code: 0100
result = a ^ b

ALU_SLL
Opp_Code: 0101
the bits are moved to the left and new bits are replaced with 0's

ALU_SRL
Opp_Code: 0110
the bits are moved to the right and new bits are filled with 0

ALU_SRA
Opp_Code: 0111
the bits are moved to the right and the sign of the left most bit is preserved

ALU_SLT
Opp_Code: 1000
result = 1 if a < b signed

ALU_SLTU
Opp_Code: 1001
result = 1 if a < b unsigned

Zero flag is in place and will be 1 if the output is zero

*/

module alu (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] alu_opp, //Allows for 16 different OpCodes that determine what instruction is being asked for

    output logic [31:0] result,
    output logic zero
);
    // The below codes correspond to ALU actions
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;

    always_comb begin

        case (alu_opp) // based on the selected code a different opperation will be done

            ALU_ADD:
                result = a + b;

            ALU_SUB:
                result = a - b;

            ALU_AND:
                result = a & b;

            ALU_OR:
                result = a | b;

            ALU_XOR:
                result = a ^ b;

            ALU_SLL:
                result = a << b[4:0];

            ALU_SRL:
                result = a >> b[4:0];

            ALU_SRA: 
                result = $signed(a) >>> b[4:0];
                else

            ALU_SLT: 
            begin
                if ($signed(a) < $signed(b))
                    result = 32'd1;
                else
                    result = 32'd0;
            end

            ALU_SLTU: 
            begin
                if (a < b)
                    result = 32'd1;
                else
                    result = 32'd0;
            end

            default:
                result = 32'b0;

        endcase

    end

    assign zero = (result == 32'b0); // assigns it to 1 if result == 0 and 1 otherwise

endmodule