# Simple CPU Design Overview

## Modules

1. ALU
   This is an arithmetic logic unit
   The ALU takes in commands as opcodes and performs actions based on these
   
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

The ALU also contains a zero flag : 1 when the outpot is 0
                                    0 otherwise

2.Register File
4. Program Counter
5. Program Counter -> next
6. Instruction Memory
7. Immediate Generator
8. Decoder
9. Branch Comparator
10. Data Memory
11. CPU Core
