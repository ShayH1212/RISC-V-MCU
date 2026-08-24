/*
This module is used to detect a hazard that the forwarding unit cannot

It detects when if the next instruction needs data that is not ready yet
If the data is still being loaded from memory then the unit tells the CPU to pause for one cycle
This gives enough time to get the correct value
*/

module hazard_detection_unit(
    input logic [4:0] rs1_decode,
    input logic [4:0] rs2_decode,
    input logic [4:0] rd_execute,
    input logic [1:0] result_src_execute,
    output logic stall
);

always_comb begin
    if
    ((result_src_execute == 2'b01) // If the instruction in exicute is a load
    && (rd_execute != 5'b00000) // if the reg is not x0
    && ((rd_execute == rs1_decode) //if the loaded reg is needed as rs1
    || (rd_execute == rs2_decode)))//if the loaded reg is needed as rs2
    begin
        stall = 1'b1; // stall the pipeline
    end
    else begin
        stall = 1'b0; // do not stall
    end
end
endmodule