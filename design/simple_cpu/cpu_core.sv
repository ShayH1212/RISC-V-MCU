module cpu_core (
    input logic clk,
    input logic reset
);

// instiantiate the alu signals
logic [31:0] alu_b;
logic [31:0] alu_result;
logic zero;
logic [31:0] immediate;

// instiantiate the internal signals
logic [31:0] next_pc;
logic [31:0] pc;
logic [31:0] instruction;
logic [6:0] opcode;
logic [4:0] rd;
logic [2:0] funct3;
logic [4:0] rs1;
logic [4:0] rs2;
logic [6:0] funct7;

// declare the decoder I/O
logic reg_write;
logic mem_write;
logic val_sec;
logic branch;
logic jump;
logic [1:0] result_src;
logic [3:0] alu_op;

// declare the RF signals
logic [31:0] read_reg1;
logic [31:0] read_reg2;
logic [31:0] write_reg;

// declare the comparator signals
logic branch_successful;

// slpit the instruction into its different parts
assign opcode = instruction[6:0];
assign rd = instruction[11:7];
assign funct3 = instruction[14:12];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign funct7 = instruction[31:25];

// data mamory
logic [31:0] read_data;

// call the program counter module
prog_count program_counter (
    .clk(clk),
    .reset(reset),
    .pc_next(next_pc), 
    .pc(pc)
);

// instiantiate the instruction memory
instruction_mem instruction_memory (
    .address(pc),
    .instruction(instruction)
);

// instiantiate the RF
reg_file register_file (
    .clk(clk),
    .write_enable(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_reg(write_reg),
    .read_reg1(read_reg1),
    .read_reg2(read_reg2)
);

// instantiate the decoder
decoder control_unit (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .reg_write(reg_write),
    .mem_write(mem_write),
    .val_sec(val_sec),
    .branch(branch),
    .jump(jump),
    .result_src(result_src),
    .alu_op(alu_op)
);

// instantiate the comparator

comp branch_comparator (
    .a(read_reg1),
    .b(read_reg2),
    .funct3(funct3),
    .branch(branch),
    .branch_successful(branch_successful)
);

// instiantiate the data memory
data_mem data_memory (
    .clk(clk),
    .mem_write(mem_write),
    .address(alu_result),
    .write_data(read_reg2),
    .read_data(read_data)
);

// instantiate the immediate generator
immediate_gen immediate_generator (
    .instruction(instruction),
    .immediate(immediate)
);

// instantiate the alu
alu alu_unit (
    .a(read_reg1),
    .b(alu_b),
    .alu_opp(alu_op),
    .result(alu_result),
    .zero(zero)
);

// determine next pc
pc_next next_prog_counter (
    .pc(pc),
    .immediate(immediate),
    .jump(jump),
    .branch_successful(branch_successful),
    .pc_next(next_pc)
);

always_comb begin // selecr ALU second input
    if (val_sec)
        alu_b = immediate;
    else
        alu_b = read_reg2;
end

// select value to be written into RF
always_comb begin
    if (result_src == 2'b00)
        write_reg = alu_result;
    else if (result_src == 2'b01)
        write_reg = read_data;
    else if (result_src == 2'b10)
        write_reg = pc + 32'd4;
    else
        write_reg = 32'b0;
end

endmodule