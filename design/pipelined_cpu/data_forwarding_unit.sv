/*
Forwarding Unit

This unit detects data hazards between the instruction in the Execute stage
and instructions in the Memory or Writeback stages.

It eseencially stops the CPU from using an outdated register values when newer
values has already been calculated but has not yet reached the register file.

*/

module forwarding_unit (
    input logic [4:0] rs1_execute,
    input logic [4:0] rs2_execute,
    input logic [4:0] rd_memory,
    input logic [1:0] result_src_memory,
    input logic [4:0] rd_writeback,
    output logic [1:0] forward_a,
    output logic [1:0] forward_b,
    input logic reg_write_writeback,
    input logic reg_write_memory
);

always_comb begin


    // Forwarding for rs1
    if 
    (reg_write_memory
    && (rd_memory != 5'b0) // checks if the destination reg isnt x0
    && (rd_memory == rs1_execute) // checks if register to be changed is the same as the register needed for the execute
    && (result_src_memory != 2'b01)) // checks if it is not a load

    begin
        forward_a = 2'b10; // forward rs1 from memory
    end

    else if 
    (reg_write_writeback
    && (rd_writeback != 5'b0)  // checks that it is not x0
    &&(rd_writeback == rs1_execute)) //checks if the writeback stage is the register needed in exicute

    begin
        forward_a = 2'b01; // forward rs1 from writeback     
    end

    else begin
        forward_a = 2'b00; // else do not forward
    end    

    // Forward for rs2
    if    
    (reg_write_memory
    && (rd_memory != 5'b0) // checks that it isnt x0
    && (rd_memory == rs2_execute) // checks if the memory reg is needed for execute
    && (result_src_memory != 2'b01)) // ensures it is not a load

    begin
        forward_b = 2'b10; // forward from memory stage
    end

    else if 
    (reg_write_writeback 
    && (rd_writeback != 5'b0) // checks that it isnt x0
    && (rd_writeback == rs2_execute)) //checks that writeback is  the same as exicute

    begin
        forward_b = 2'b01; // forward rs2 from writeback stage
    end
    
    else begin
        forward_b = 2'b00; // no need to forward
    end

end
        
endmodule
