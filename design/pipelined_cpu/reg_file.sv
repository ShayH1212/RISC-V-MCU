/*
This is the code for my register file. The register file is where all to the registers are stored. These registers can be accessed to do computation on and can aso be written into.
If write enable is on and the destination register isnt zero then yiou write into the register
If rs1 and rs2 are not zero then we can read these registers.
*/

module reg_file (
    input  logic clk,
    input  logic write_enable,

    input  logic [4:0]  rs1, // this is the code assignment for the first register
    input  logic [4:0]  rs2, // this is the code assignment for the second register
    input  logic [4:0]  rd, // this is the code assignment for the result register
    input  logic [31:0] write_reg, // data being written into the RF

    output logic [31:0] read_reg1, // data being read from the RF
    output logic [31:0] read_reg2  // data being read from the RF
);

logic [31:0] registers [0:31]; // 32 registers, each 32 bits wide

always_ff @(posedge clk) begin // everything done on rising edge

    if (write_enable && rd != 5'b00000) // if writing is enabled and rd is not zero then store write_reg in it
        registers[rd] <= write_reg;

end

/* 
NOTE: A failed test revealed a same cycle read/write hazard

If a reg is being written into in WB in the same cycle that 
it is being read in ID the reg might return an old value

We use the write_reg directly to get the newest value
*/

always_comb begin
        if (rs1 == 5'b00000) begin// read the value in rs1 unless it equals zero
            read_reg1 = 32'b0;
    end    
        else if (write_enable && (rd != 5'b00000) && (rd == rs1)) begin
            read_reg1 = write_reg;
    end
    else begin
        read_reg1 = registers[rs1];
    end
end    


always_comb begin

    if (rs2 == 5'b00000) begin // read the value in rs1 unless it equals zero
        read_reg2 = 32'b0;
    end    
        else if (write_enable && (rd != 5'b00000) && (rd == rs2)) begin
            read_reg2 = write_reg;
    end
    else begin
        read_reg2 = registers[rs2];
    end
end    


endmodule