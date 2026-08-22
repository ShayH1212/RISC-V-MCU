/*
This is the memory writeback register.
It stores the outputs of the memory stage that are still needed by the writeback stage for the next clock cycle.
The values will be rewritten and so they need to be saved.

The top level module will contain a always block that will select which writeback value will be needed and stored in writeback_value
This is why it seems as though I have less signals than necessary
*/

module memory_writeback_reg (
    // Data input
    input logic [31:0] writeback_value_in,
    // Register address input
    input logic [4:0] rd_in,
    // Control  input
    input logic reg_write_in,
    // Data output
    output logic [31:0] writeback_value_out,
    // Register address output
    output logic [4:0] rd_out,
    // Control output
    output logic reg_write_out,
    input logic clk,
    input logic reset
);

always_ff @(posedge clk) begin

    if (reset) begin // if reset is active everything becomes 0

        writeback_value_out <= 32'b0;
        rd_out <= 5'b0;
        reg_write_out <= 1'b0;

    end

    else begin // store memory values
        writeback_value_out <= writeback_value_in;
        rd_out <= rd_in;
        reg_write_out <= reg_write_in;

    end

end

endmodule