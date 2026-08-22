/*
This is th exicute memory register 
It stores the outputs of the exicute stage so that they can be used by the memory stage in the new cycle
It is the same as the other two pipeline registers but this one saves the value from exicute to be iused in memory while exicute is overwritten
*/

module execute_memory_reg (
    // Data
    input logic [31:0] alu_result_in,
    input logic [31:0] read_reg2_in,
    input logic [31:0] pc_add4_in, //This means the the next pc follows the normal case of Pc = Pc + 4
    // Register address
    input logic [4:0] rd_in,
    // Control signals
    input logic mem_write_in,
    input logic reg_write_in,
    input logic [1:0] result_src_in,
    // Data outputs
    output logic [31:0] alu_result_out,
    output logic [31:0] read_reg2_out,
    output logic [31:0] pc_add4_out, //This means the the next pc follows the normal case of Pc = Pc + 4
    // Register address output
    output logic [4:0] rd_out,
    // Control outputs
    output logic mem_write_out,
    output logic reg_write_out,
    output logic [1:0] result_src_out,

    
    input logic clk,
    input logic reset
);


always_ff @ (posedge clk) begin

    if(reset) begin // if reset is active everything becomes 0

        alu_result_out <= 32'b0;
        read_reg2_out <= 32'b0;
        pc_add4_out <= 32'b0;
        rd_out <= 5'b0;
        mem_write_out <= 1'b0;
        reg_write_out <= 1'b0;
        result_src_out <= 2'b0;
    end

    else begin // store execute  values

        alu_result_out <= alu_result_in;
        read_reg2_out <= read_reg2_in;
        pc_add4_out <= pc_add4_in;
        rd_out <= rd_in;
        mem_write_out <= mem_write_in;
        reg_write_out <= reg_write_in;
        result_src_out <= result_src_in;

    end
end

endmodule


