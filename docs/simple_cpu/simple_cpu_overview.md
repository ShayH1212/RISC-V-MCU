# Simple CPU Design Overview

## Modules

### ALU

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
   
### Register File
   
   The register file stores the processor’s general purpose registers. In the RV32I architecture, there are 32 registers, each 32 bits wide : identified as x0 through x31.
   
   The register file supports two simultaneous read operations and one write operation. 
   
   The rs1 and rs2 fields from the instruction select the two registers to be read, while rd selects the destination register for a write.
   
   Register x0 is permanently fixed to a value of zero. Any attempt to write to x0 is ignored, and any read from x0 returns zero.
   
   Writes occur on the rising edge of the clock when reg_write is enabled and rd is not zero. The two read outputs are combinational, meaning the selected register values are available immediately when rs1 or rs2 changes.


   4. Program Counter
   5. Program Counter -> next
   6. Instruction Memory
   7. Immediate Generator
   8. Decoder
   9. Branch Comparator
   10. Data Memory
   11. CPU Core
