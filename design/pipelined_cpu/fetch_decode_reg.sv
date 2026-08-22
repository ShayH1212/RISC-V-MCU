/*
This is a register that stores the data of the fetch to be used even when the program counter moves on.
This is necessary as the instructions are still necessary even when we need to fetch a new instruction. 
*/

module fetch_decode_register (
    input logic clk,
    input logic reset,
    input logic [31:0] pc_in,
    input logic [31:0] instruction_in,
    output logic [31:0] pc_out,
    output logic [31:0] instruction_out
);

always_ff @(posedge clk) begin
    if(reset) begin // when a reset is called we set everything to zero
        pc_out <= 32'b0;
        instruction_out <= 32'b0;
    end
    else begin // if not then we save the fetch instruction
        pc_out <= pc_in;
        instruction_out <= instruction_in;
    end
end
endmodule
