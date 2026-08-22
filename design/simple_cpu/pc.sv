/*
This is code for the program counter
The program counter stores the adress of the instriction the CPU is currently excicuting.
On every e=rising edge of the clock it loads the value of the next pc value
In a normal operation the value of the next pc will be pc + 4
*/

module prog_count (
    input logic clk,
    input logic reset,
    input logic [31:0] pc_next,
    output logic [31:0] pc
);
    always_ff @(posedge clk) begin // everything on the rising edge
        if(reset) // if reset is 1 then set to 0
        pc <= 32'b0;
        else // if reset is 0 then set pc pc_next (usually will be pc + 4)
        pc <= pc_next;
    end
endmodule
