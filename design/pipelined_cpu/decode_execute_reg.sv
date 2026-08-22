/*
This is th edecode exicute register 
It stores the outputs of the decode stage so that they can be used by the exicute stage in the new cycle
The next clock cycle the decode values are rewritten so the register saves the values to be used when needed
For this first pipelined CPU extra signals ar ecarried through to help debugging
This includes
pc
read_reg1
read_reg2
immediate
rs1
rs2
rd
funct3
alu_op
val_sec
reg_write
mem_write
result_src
branch
jump
*/

module decode_execute_reg (
    // Data 
    input logic [31:0] pc_in,
    input logic [31:0] read_reg1_in,
    input logic [31:0] read_reg2_in,
    input logic [31:0] immediate_in,
    // Instruction 
    input logic [2:0] funct3_in,
    // Register addresses
    input logic [4:0] rs1_in,
    input logic [4:0] rs2_in,
    input logic [4:0] rd_in,
    // Control signals
    input logic [3:0] alu_op_in,
    input logic val_sec_in,
    input logic reg_write_in,
    input logic mem_write_in,
    input logic [1:0] result_src_in,
    input logic branch_in,
    input logic jump_in,

    input logic clk,
    input logic reset,

    // Data outputs
    output logic [31:0] pc_out,
    output logic [31:0] read_reg1_out,
    output logic [31:0] read_reg2_out,
    output logic [31:0] immediate_out,
    // Instruction output
    output logic [2:0] funct3_out,
    // Register address outputs
    output logic [4:0] rs1_out,
    output logic [4:0] rs2_out,
    output logic [4:0] rd_out,
    // Control outputs
    output logic [3:0] alu_op_out,
    output logic val_sec_out,
    output logic reg_write_out,
    output logic mem_write_out,
    output logic [1:0] result_src_out,
    output logic branch_out,
    output logic jump_out
);

always_ff @(posedge clk) begin

    if (reset) begin // if reset is active everything becomes 0

        pc_out <= 32'b0;
        read_reg1_out <= 32'b0;
        read_reg2_out <= 32'b0;
        immediate_out <= 32'b0;
        funct3_out <= 3'b0;
        rs1_out <= 5'b0;
        rs2_out <= 5'b0;
        rd_out <= 5'b0;
        alu_op_out <= 4'b0;
        val_sec_out <= 1'b0;
        reg_write_out <= 1'b0;
        mem_write_out <= 1'b0;
        result_src_out <= 2'b0;
        branch_out <= 1'b0;
        jump_out <= 1'b0;
        end

        else begin // if reset is off store all values
        pc_out <= pc_in;
        read_reg1_out <= read_reg1_in;
        read_reg2_out <= read_reg2_in;
        immediate_out <= immediate_in;
        funct3_out <= funct3_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;
        alu_op_out <= alu_op_in;
        val_sec_out <= val_sec_in;
        reg_write_out <= reg_write_in;
        mem_write_out <= mem_write_in;
        result_src_out <= result_src_in;
        branch_out <= branch_in;
        jump_out <= jump_in;
        end
end

endmodule

