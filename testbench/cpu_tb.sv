module cpu_tb;

logic clk;
logic reset;

cpu_core dut (
    .clk(clk),
    .reset(reset)
);

// clock
always begin
    #5 clk = ~clk;
end

initial begin

    clk = 1'b0;
    reset = 1'b1;

    #10;
    reset = 1'b0;

    // Allow CPU to execute instructions
    #500;

$display("x1 = %0d", dut.register_file.registers[1]);
$display("x2 = %0d", dut.register_file.registers[2]);
$display("x3 = %0d", dut.register_file.registers[3]);
$display("x4 = %0d", dut.register_file.registers[4]);
$display("x5 = %0d", dut.register_file.registers[5]);
$display("x6 = %0d", dut.register_file.registers[6]);
$display("x7 = %0d", dut.register_file.registers[7]);
$display("x8  = %0d", dut.register_file.registers[8]);
$display("x9  = %0d", dut.register_file.registers[9]);
$display("x10 = %0d", dut.register_file.registers[10]);
$display("x11 = %0d", $signed(dut.register_file.registers[11]));
$display("x12 = %0d", dut.register_file.registers[12]);
$display("x13 = %0d", $signed(dut.register_file.registers[13]));
$display("x14 = %0d", dut.register_file.registers[14]);
$display("x15 = %0d", dut.register_file.registers[15]);
$display("memory[0] = %0d", dut.data_memory.memory[0]);
$display("x16 = %0d", dut.register_file.registers[16]);
$display("x17 = %0d", dut.register_file.registers[17]);
$display("x18 = %0d", dut.register_file.registers[18]);
$display("x19 = %0d", dut.register_file.registers[19]);
$display("x20 = %0d", dut.register_file.registers[20]);
$display("x21 = %0d", dut.register_file.registers[21]);
$display("x22 = %0d", dut.register_file.registers[22]);
$display("x23 = %0d", dut.register_file.registers[23]);
$display("x24 = %0d", dut.register_file.registers[24]);
$display("x25 = %0d", dut.register_file.registers[25]);
$display("x26 = %0d", dut.register_file.registers[26]);
$display("x27 = %0d", dut.register_file.registers[27]);
$display("x28 = %0d", dut.register_file.registers[28]);
$display("x29 = %0d", dut.register_file.registers[29]);
$display("x30 = %0d", dut.register_file.registers[30]);

    $finish;

end

endmodule