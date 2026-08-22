/*
This module is for the data memmory
The data memmory stores the values that your program is working with
we will have 512 locatons for memory each of which are 32 bits wide

clk : controls when a write happens
mem_write : 1 - write to memory
            0 - dont write
adress : what location we want to write to
write_data : the value to be stored
read_data : value stores at an address
*/

module data_mem (
    input  logic clk,
    input  logic mem_write,
    input  logic [31:0] address,
    input  logic [31:0] write_data,

    output logic [31:0] read_data
);

logic [31:0] memory [0:511];

assign read_data = memory[address[10:2]]; // always display the contents of the selected address

always_ff @(posedge clk) begin // on the rising edge of the clock
    if (mem_write) // as long as we want to write data
        memory[address[10:2]] <= write_data; // then change the spot in memory to the data to be written
end

endmodule