module mcu_top (
    input logic clk,
    input logic reset
);


logic data_write_enable;
logic [31:0] data_address;
logic [31:0] data_write_data;
logic [31:0] data_read_data;
logic [31:0] instruction_address;
logic [31:0] instruction_data;


/*<><<><><><><><><>
      CPU CORE
<<><<><><><><><><>*/
pipelined_cpu_core cpu (
    .clk(clk),
    .reset(reset),
    .data_write_enable(data_write_enable),
    .data_address(data_address),
    .data_write_data(data_write_data),
    .data_read_data(data_read_data),
    .instruction_address(instruction_address),
    .instruction_data(instruction_data)
);


/*<><<><><><><><><>
    DATA MEMORY
<<><<><><><><><><>*/
data_mem data_memory (
    .clk(clk),
    .mem_write(data_write_enable),
    .address(data_address),
    .write_data(data_write_data),
    .read_data(data_read_data)
);


/*<><<><><><><><><><><>
    INSTRUCTION MEMORY
<<><<><><><><><><><><>*/
instruction_mem instruction_memory (
    .address(instruction_address),
    .instruction(instruction_data)
);



endmodule