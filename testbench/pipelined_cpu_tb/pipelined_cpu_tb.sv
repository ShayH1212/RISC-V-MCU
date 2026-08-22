module pipelined_cpu_tb;

logic clk;
logic reset;
pipelined_cpu_core dut (
    .clk(clk),
    .reset(reset)
);

always begin // create clock signal
    #5 clk = ~clk;
end

initial begin

    clk = 1'b0;
    reset = 1'b1;
    #10;
    reset = 1'b0;
    #500; // wait for cpu to generate results

    $display("x1 = %0d", dut.register_file.registers[1]);
    $display("x2 = %0d", dut.register_file.registers[2]);
    $display("x3 = %0d", dut.register_file.registers[3]);
    $display("x4 = %0d", dut.register_file.registers[4]);
    $display("x5 = %0d", dut.register_file.registers[5]);
    $display("x6 = %0d", dut.register_file.registers[6]);
    $display("x7 = %0d", dut.register_file.registers[7]);

    $finish;

end

endmodule