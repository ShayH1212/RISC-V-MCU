module pipelined_cpu_tb;

logic clk;
logic reset;
integer pass_counter;
integer fail_counter;
integer stall_counter;
localparam logic [31:0] no_op = 32'h00000013; // this makes it so you can esaily do a no operation  



initial begin
    clk = 1'b0;
    pass_counter = 0;
    fail_counter = 0;
end


pipelined_cpu_core cpu_design (
    .clk(clk),
    .reset(reset)
);


always begin
    #5 clk = ~clk;
end

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
                        STALL COUNTER
    1. This counts how many times a stall is done
    2. This helps show if the hazard detection logic is working
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/    

always @(posedge clk)begin
    if(reset) begin
        stall_counter = 0;
    end
    else if(cpu_design.stall) begin
        stall_counter = stall_counter + 1;
    end
end

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><>
                       TEST SETUP
    1. This will set up every test before it begins
    2. It resets all the values from the previous tests
<><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/    

//NOTE: in .sv task is a reuseable block of procedural code
task automatic test_setup;
integer i;
begin
    reset = 1'b1;
    @(posedge clk);
    #1; // small buffer
    // Clear register file
        for (i = 0; i < 32; i = i + 1) begin
        cpu_design.register_file.registers[i] = 32'b0;
    end
    // Fill the instruction memory with no_op instructions
    for(i = 0; i < 256; i = i + 1)begin
        cpu_design.instruction_memory.memory[i] = no_op;
    end
    //Clear data memory
    for(i = 0; i < 512; i = i + 1) begin
        cpu_design.data_memory.memory[i] = 32'b0;
    end
end

endtask

task automatic run_cpu(input integer cycles);

begin
    reset = 1'b0;
    repeat(cycles) begin
        @(posedge clk);
    end
    #1;
end

endtask



/*<><><><><><><><><><><><><><><><><><><><><><><><><><>
                    REGISTER CHECK
    1. Checks a register after a test
    2. Compares the actual value to the expected value
<><><><><><><><><><><><><><><><><><><><><><><><><><>*/

task automatic reg_checker(
input integer reg_num,
input logic [31:0] expected
);

begin
    if (cpu_design.register_file.registers[reg_num] === expected) begin
        // NOTE: "===" checks for equality including with (x) and (z) values
        $display("PASS: x%0d = %0d", reg_num, expected);
        pass_counter = pass_counter + 1;
    end
    else begin
        $display("FAIL: x%0d expected %0d, got %0d", reg_num, expected, cpu_design.register_file.registers[reg_num]);
        fail_counter = fail_counter + 1;
    end
end

endtask

/*<><><><><><><><><><><><><><><><><><><><><><><><><><>
                    MEMORY CHECK
    1. Checks a memory after a test
    2. Compares the actual value to the expected value
<><><><><><><><><><><><><><><><><><><><><><><><><><>*/

task automatic memory_checker(
    input integer memory_location,
    input logic [31:0] expected
);

begin
    if (cpu_design.data_memory.memory[memory_location] === expected) begin
        $display("PASS: memory[%0d] = %0d", memory_location, expected);
        pass_counter = pass_counter + 1;
    end
    else begin
        $display("FAIL: memory[%0d] expected %0d, got %0d", memory_location,  expected, cpu_design.data_memory.memory[memory_location]);
        fail_counter = fail_counter + 1;
    end
end

endtask


/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
                     STALL CHECK
    1. Checks how many stalls occurred during a test
    2. Compares the number of stalls to the expected amount
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

task automatic stall_checker(
    input integer expected_stalls
);

begin
    if (stall_counter === expected_stalls) begin
        $display("PASS: stalls = %0d", stall_counter);
        pass_counter = pass_counter + 1;
    end
    else begin
        $display("FAIL: expected %0d stalls, got %0d",expected_stalls, stall_counter);
        fail_counter = fail_counter + 1;
    end
end

endtask


initial begin

    /*<><><><><><><><><><><><><><><><><><><><><><><><><>
            TEST 1: SIMPLE FORWARDING TEST

        addi x1, x0, 5
        add  x2, x1, x1

        Expected:
        x1 = 5
        x2 = 10
    <><><><><><><><><><><><><><><><><><><><><><><><><>*/

    test_setup();

    cpu_design.instruction_memory.memory[0] = 32'h00500093;
    cpu_design.instruction_memory.memory[1] = 32'h00108133;

    run_cpu(10);
    reg_checker(1, 32'd5);
    reg_checker(2, 32'd10);
    stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><><>
        TEST 2: RS1 FORWARDING TEST

    addi x1, x0, 5
    add  x2, x1, x0

    Expected:
    x1 = 5
    x2 = 5
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093;
cpu_design.instruction_memory.memory[1] = 32'h00008133;

run_cpu(10);
reg_checker(1, 32'd5);
reg_checker(2, 32'd5);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
         TEST 3: RS2 FORWARDING TEST

    addi x1, x0, 5
    add  x2, x0, x1

    Expected:
    x1 = 5
    x2 = 5
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093;
cpu_design.instruction_memory.memory[1] = 32'h00100133;

run_cpu(10);
reg_checker(1, 32'd5);
reg_checker(2, 32'd5);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><>
        TEST 4: LOAD HAZARD RS1

    lw  x1, 0(x0)
    add x2, x1, x0

    data_memory[0] = 21

    Expected:
    x1 = 21
    x2 = 21
    stalls = 1
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.data_memory.memory[0] = 32'd21;
cpu_design.instruction_memory.memory[0] = 32'h00002083;
cpu_design.instruction_memory.memory[1] = 32'h00008133;

run_cpu(10);
reg_checker(1, 32'd21);
reg_checker(2, 32'd21);
stall_checker(1);


/*<><><><><><><><><><><><><><><><><><><><><><>
        TEST 5: LOAD HAZARD RS2

    lw  x1, 0(x0)
    add x2, x0, x1

    data_memory[0] = 21

    Expected:
    x1 = 21
    x2 = 21
    stalls = 1
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.data_memory.memory[0] = 32'd21;
cpu_design.instruction_memory.memory[0] = 32'h00002083;
cpu_design.instruction_memory.memory[1] = 32'h00100133;

run_cpu(10);
reg_checker(1, 32'd21);
reg_checker(2, 32'd21);
stall_checker(1);


/*<><><><><><><><><><><><><><><><><><><><><><>
           TEST 6: X0 PROTECTION

    addi x0, x0, 10
    add  x1, x0, x0

    Expected:
    x0 = 0
    x1 = 0
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00A00013;
cpu_design.instruction_memory.memory[1] = 32'h000000B3;

run_cpu(10);
reg_checker(0, 32'd0);
reg_checker(1, 32'd0);
stall_checker(0);

/*<><><><><><><><><><><><><><><><><><><>
        TEST 7: WRITEBACK FORWARDING

    addi x1, x0, 5
    addi x6, x0, 20
    add  x2, x1, x1

    Expected:
    x1 = 5
    x6 = 20
    x2 = 10
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093;
cpu_design.instruction_memory.memory[1] = 32'h01400313;
cpu_design.instruction_memory.memory[2] = 32'h00108133;

run_cpu(10);
reg_checker(1, 32'd5);
reg_checker(6, 32'd20);
reg_checker(2, 32'd10);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><><>
       TEST 8: MEMORY FORWARDING PRIORITY

    addi x1, x0, 5
    addi x1, x1, 3
    add  x2, x1, x0

    Expected:
    x1 = 8
    x2 = 8
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093;
cpu_design.instruction_memory.memory[1] = 32'h00308093;
cpu_design.instruction_memory.memory[2] = 32'h00008133;

run_cpu(10);
reg_checker(1, 32'd8);
reg_checker(2, 32'd8);
stall_checker(0);

/*<><><><><><><><><><><><><><><><><><><><><>
        TEST 9: CHAINED FORWARDING

    addi x1, x0, 5
    addi x2, x1, 3
    addi x3, x2, 4
    addi x4, x3, 5

    Expected:
    x1 = 5
    x2 = 8
    x3 = 12
    x4 = 17
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093;
cpu_design.instruction_memory.memory[1] = 32'h00308113;
cpu_design.instruction_memory.memory[2] = 32'h00410193;
cpu_design.instruction_memory.memory[3] = 32'h00518213;

run_cpu(20);
reg_checker(1, 32'd5);
reg_checker(2, 32'd8);
reg_checker(3, 32'd12);
reg_checker(4, 32'd17);
stall_checker(0);

/*<><><><><><><><><><><><><><><><><><><><><><><><>
           TEST 10: SIMPLE LOAD

    lw   x1, 0(x0)
    no_op
    no_op
    add  x2, x1, x1

    data_memory[0] = 21

    Expected:
    x1 = 21
    x2 = 42
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.data_memory.memory[0] = 32'd21;
cpu_design.instruction_memory.memory[0] = 32'h00002083;
cpu_design.instruction_memory.memory[1] = no_op;
cpu_design.instruction_memory.memory[2] = no_op;
cpu_design.instruction_memory.memory[3] = 32'h00108133;

run_cpu(20);

reg_checker(1, 32'd21);
reg_checker(2, 32'd42);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
       TEST 11: LOAD WITH NO DEPENDENCY

    lw   x1, 0(x0)
    addi x2, x0, 7

    data_memory[0] = 21

    Expected:
    x1 = 21
    x2 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.data_memory.memory[0] = 32'd21;
cpu_design.instruction_memory.memory[0] = 32'h00002083;
cpu_design.instruction_memory.memory[1] = 32'h00700113;

run_cpu(10);
reg_checker(1, 32'd21);
reg_checker(2, 32'd7);
stall_checker(0);

/*<><><><><><><><><><><><><><><><><><><><><><><>
         TEST 12: STORE DATA FORWARDING

    addi x1, x0, 25
    sw   x1, 0(x0)
    no_op
    no_op
    lw   x2, 0(x0)

    Expected:
    memory[0] = 25
    x2 = 25
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h01900093;
cpu_design.instruction_memory.memory[1] = 32'h00102023;
cpu_design.instruction_memory.memory[2] = no_op;
cpu_design.instruction_memory.memory[3] = no_op;
cpu_design.instruction_memory.memory[4] = 32'h00002103;

run_cpu(20);
memory_checker(0, 32'd25);
reg_checker(2, 32'd25);
stall_checker(0);

/*<><><><><><><><><><><><><><><><><><><><><><><><>
              TEST 13: ALU REGRESSION

    addi x1,  x0, 8
    addi x2,  x0, 3

    add  x3,  x1, x2
    sub  x4,  x1, x2
    and  x5,  x1, x2
    or   x6,  x1, x2
    xor  x7,  x1, x2
    sll  x8,  x1, x2
    srl  x9,  x1, x2

    addi x10, x0, -8
    sra  x11, x10, x2
    slt  x12, x10, x2
    sltu x13, x10, x2

    Expected:
    x1  = 8
    x2  = 3
    x3  = 11
    x4  = 5
    x5  = 0
    x6  = 11
    x7  = 11
    x8  = 64
    x9  = 1
    x10 = -8
    x11 = -1
    x12 = 1
    x13 = 0
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

// Set up x1 = 8 and x2 = 3
cpu_design.instruction_memory.memory[0]  = 32'h00800093; // addi x1, x0, 8
cpu_design.instruction_memory.memory[1]  = 32'h00300113; // addi x2, x0, 3
// Basic arithmetic
cpu_design.instruction_memory.memory[2]  = 32'h002081B3; // add x3, x1, x2
cpu_design.instruction_memory.memory[3]  = 32'h40208233; // sub x4, x1, x2
// Bitwise operations
cpu_design.instruction_memory.memory[4]  = 32'h0020F2B3; // and x5, x1, x2
cpu_design.instruction_memory.memory[5]  = 32'h0020E333; // or x6, x1, x2
cpu_design.instruction_memory.memory[6]  = 32'h0020C3B3; // xor x7, x1, x2
// Shift operations
cpu_design.instruction_memory.memory[7]  = 32'h00209433; // sll x8, x1, x2
cpu_design.instruction_memory.memory[8]  = 32'h0020D4B3; // srl x9, x1, x2
// Negative value for signed tests
cpu_design.instruction_memory.memory[9]  = 32'hFF800513; // addi x10, x0, -8
// Signed shift and comparisons
cpu_design.instruction_memory.memory[10] = 32'h402555B3; // sra x11, x10, x2
cpu_design.instruction_memory.memory[11] = 32'h00252633; // slt x12, x10, x2
cpu_design.instruction_memory.memory[12] = 32'h002536B3; // sltu x13, x10, x2

run_cpu(30);
reg_checker(1,  32'd8);
reg_checker(2,  32'd3);
reg_checker(3,  32'd11);// ADD
reg_checker(4,  32'd5);// SUB
reg_checker(5,  32'd0);// AND
reg_checker(6,  32'd11);// OR
reg_checker(7,  32'd11);// XOR
reg_checker(8,  32'd64); // SLL
reg_checker(9,  32'd1); // SRL
reg_checker(10, -32'sd8);// -8
reg_checker(11, -32'sd1); // SRA: -8 >>> 3 = -1
reg_checker(12, 32'd1);// SLT:  -8 < 3 is true
reg_checker(13, 32'd0);// SLTU: unsigned(-8) < 3 is false
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
       TEST 14: BRANCH FORWARDING

    addi x1, x0, 5
    beq  x1, x0, +8
    addi x2, x0, 7

    Expected:
    x1 = 5
    x2 = 7
    stalls = 0

    The branch should NOT be taken.
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093; // addi x1, x0, 5
cpu_design.instruction_memory.memory[1] = 32'h00008463; // beq  x1, x0, +8
cpu_design.instruction_memory.memory[2] = 32'h00700113; // addi x2, x0, 7

run_cpu(20);
reg_checker(1, 32'd5);
reg_checker(2, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><><><>
        TEST 15: TAKEN BRANCH FLUSH

    addi x1, x0, 5
    beq  x1, x1, +12

    addi x3, x0, 99 wrong path
    addi x4, x0, 88 wrong path

    addi x5, x0, 7  branch target

    Expected:
    x1 = 5
    x3 = 0
    x4 = 0
    x5 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093; // addi x1, x0, 5
cpu_design.instruction_memory.memory[1] = 32'h00108663; // beq x1, x1, +12
cpu_design.instruction_memory.memory[2] = 32'h06300193; // addi x3, x0, 99
cpu_design.instruction_memory.memory[3] = 32'h05800213; // addi x4, x0, 88
cpu_design.instruction_memory.memory[4] = 32'h00700293; // addi x5, x0, 7

run_cpu(20);
reg_checker(1, 32'd5);
reg_checker(3, 32'd0);
reg_checker(4, 32'd0);
reg_checker(5, 32'd7);
stall_checker(0);

/*<><><><><><><><><><><><><><><><><><><><><><><>
            TEST 16: BNE TAKEN

    addi x1, x0, 5
    addi x2, x0, 3
    bne  x1, x2, +12

    addi x3, x0, 99  wrong path
    addi x4, x0, 88 wrong path

    addi x5, x0, 7 branch target

    Expected:
    x1 = 5
    x2 = 3
    x3 = 0
    x4 = 0
    x5 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093; // addi x1, x0, 5
cpu_design.instruction_memory.memory[1] = 32'h00300113; // addi x2, x0, 3
cpu_design.instruction_memory.memory[2] = 32'h00209663; // bne x1, x2, +12
cpu_design.instruction_memory.memory[3] = 32'h06300193; // addi x3, x0, 99
cpu_design.instruction_memory.memory[4] = 32'h05800213; // addi x4, x0, 88
cpu_design.instruction_memory.memory[5] = 32'h00700293; // addi x5, x0, 7

run_cpu(20);
reg_checker(1, 32'd5);
reg_checker(2, 32'd3);
reg_checker(3, 32'd0);
reg_checker(4, 32'd0);
reg_checker(5, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
            TEST 17: BLT TAKEN

    addi x1, x0, -5
    addi x2, x0, 3
    blt  x1, x2, +12

    addi x3, x0, 99 wrong path
    addi x4, x0, 88 wrong path

    addi x5, x0, 7 branch target

    Expected:
    x1 = -5
    x2 = 3
    x3 = 0
    x4 = 0
    x5 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'hFFB00093; // addi x1, x0, -5
cpu_design.instruction_memory.memory[1] = 32'h00300113; // addi x2, x0, 3
cpu_design.instruction_memory.memory[2] = 32'h0020C663; // blt x1, x2, +12
cpu_design.instruction_memory.memory[3] = 32'h06300193; // addi x3, x0, 99
cpu_design.instruction_memory.memory[4] = 32'h05800213; // addi x4, x0, 88
cpu_design.instruction_memory.memory[5] = 32'h00700293; // addi x5, x0, 7

run_cpu(20);
reg_checker(1, -32'sd5);
reg_checker(2, 32'd3);
reg_checker(3, 32'd0);
reg_checker(4, 32'd0);
reg_checker(5, 32'd7);
stall_checker(0);

/*<><><><><><><><><><><><><><><><><><><><><><><>
            TEST 18: BGE TAKEN

    addi x1, x0, 5
    addi x2, x0, 3
    bge  x1, x2, +12

    addi x3, x0, 99 wrong path
    addi x4, x0, 88  wrong path

    addi x5, x0, 7 branch target

    Expected:
    x1 = 5
    x2 = 3
    x3 = 0
    x4 = 0
    x5 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093; // addi x1, x0, 5
cpu_design.instruction_memory.memory[1] = 32'h00300113; // addi x2, x0, 3
cpu_design.instruction_memory.memory[2] = 32'h0020D663; // bge x1, x2, +12
cpu_design.instruction_memory.memory[3] = 32'h06300193; // addi x3, x0, 99
cpu_design.instruction_memory.memory[4] = 32'h05800213; // addi x4, x0, 88
cpu_design.instruction_memory.memory[5] = 32'h00700293; // addi x5, x0, 7

run_cpu(20);
reg_checker(1, 32'd5);
reg_checker(2, 32'd3);
reg_checker(3, 32'd0);
reg_checker(4, 32'd0);
reg_checker(5, 32'd7);
stall_checker(0);

/*<><><><><><><><><><><><><><><><><><><><><><>
            TEST 19: BLTU TAKEN

    addi x1, x0, 3
    addi x2, x0, -5
    bltu x1, x2, +12

    addi x3, x0, 99  wrong path
    addi x4, x0, 88  wrong path

    addi x5, x0, 7  target

    Expected:
    x1 = 3
    x2 = -5
    x3 = 0
    x4 = 0
    x5 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00300093;
cpu_design.instruction_memory.memory[1] = 32'hFFB00113;
cpu_design.instruction_memory.memory[2] = 32'h0020E663;
cpu_design.instruction_memory.memory[3] = 32'h06300193;
cpu_design.instruction_memory.memory[4] = 32'h05800213;
cpu_design.instruction_memory.memory[5] = 32'h00700293;

run_cpu(20);
reg_checker(1, 32'd3);
reg_checker(2, -32'sd5);
reg_checker(3, 32'd0);
reg_checker(4, 32'd0);
reg_checker(5, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><>
            TEST 20: BGEU TAKEN

    addi x1, x0, -5
    addi x2, x0, 3
    bgeu x1, x2, +12

    addi x3, x0, 99  wrong path
    addi x4, x0, 88 wrong path

    addi x5, x0, 7 target

    Expected:
    x1 = -5
    x2 = 3
    x3 = 0
    x4 = 0
    x5 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'hFFB00093;
cpu_design.instruction_memory.memory[1] = 32'h00300113;
cpu_design.instruction_memory.memory[2] = 32'h0020F663;
cpu_design.instruction_memory.memory[3] = 32'h06300193;
cpu_design.instruction_memory.memory[4] = 32'h05800213;
cpu_design.instruction_memory.memory[5] = 32'h00700293;

run_cpu(20);
reg_checker(1, -32'sd5);
reg_checker(2, 32'd3);
reg_checker(3, 32'd0);
reg_checker(4, 32'd0);
reg_checker(5, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
            TEST 21: BEQ NOT TAKEN

    addi x1, x0, 5
    addi x2, x0, 3
    beq  x1, x2, +8

    addi x3, x0, 99 must execute
    addi x4, x0, 7 branch target

    Expected:
    x1 = 5
    x2 = 3
    x3 = 99
    x4 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093;
cpu_design.instruction_memory.memory[1] = 32'h00300113;
cpu_design.instruction_memory.memory[2] = 32'h00208463;
cpu_design.instruction_memory.memory[3] = 32'h06300193;
cpu_design.instruction_memory.memory[4] = 32'h00700213;

run_cpu(20);

reg_checker(1, 32'd5);
reg_checker(2, 32'd3);
reg_checker(3, 32'd99);
reg_checker(4, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
            TEST 22: BNE NOT TAKEN

    addi x1, x0, 5
    addi x2, x0, 5
    bne  x1, x2, +8

    addi x3, x0, 99 must execute
    addi x4, x0, 7 branch target

    Expected:
    x1 = 5
    x2 = 5
    x3 = 99
    x4 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093;
cpu_design.instruction_memory.memory[1] = 32'h00500113;
cpu_design.instruction_memory.memory[2] = 32'h00209463;
cpu_design.instruction_memory.memory[3] = 32'h06300193;
cpu_design.instruction_memory.memory[4] = 32'h00700213;

run_cpu(20);

reg_checker(1, 32'd5);
reg_checker(2, 32'd5);
reg_checker(3, 32'd99);
reg_checker(4, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
            TEST 23: BLT NOT TAKEN

    addi x1, x0, 5
    addi x2, x0, 3
    blt  x1, x2, +8

    addi x3, x0, 99 must execute
    addi x4, x0, 7 branch target

    Expected:
    x1 = 5
    x2 = 3
    x3 = 99
    x4 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00500093;
cpu_design.instruction_memory.memory[1] = 32'h00300113;
cpu_design.instruction_memory.memory[2] = 32'h0020C463;
cpu_design.instruction_memory.memory[3] = 32'h06300193;
cpu_design.instruction_memory.memory[4] = 32'h00700213;

run_cpu(20);

reg_checker(1, 32'd5);
reg_checker(2, 32'd3);
reg_checker(3, 32'd99);
reg_checker(4, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
            TEST 24: BGE NOT TAKEN

    addi x1, x0, -5
    addi x2, x0, 3
    bge  x1, x2, +8

    addi x3, x0, 99  must execute
    addi x4, x0, 7 branch target

    Expected:
    x1 = -5
    x2 = 3
    x3 = 99
    x4 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'hFFB00093;
cpu_design.instruction_memory.memory[1] = 32'h00300113;
cpu_design.instruction_memory.memory[2] = 32'h0020D463;
cpu_design.instruction_memory.memory[3] = 32'h06300193;
cpu_design.instruction_memory.memory[4] = 32'h00700213;

run_cpu(20);

reg_checker(1, -32'sd5);
reg_checker(2, 32'd3);
reg_checker(3, 32'd99);
reg_checker(4, 32'd7);
stall_checker(0);

/*<><><><><><><><><><><><><><><><><><><><><><><>
            TEST 25: BLTU NOT TAKEN

    addi x1, x0, -5
    addi x2, x0, 3
    bltu x1, x2, +8

    addi x3, x0, 99 must execute
    addi x4, x0, 7 branch target

    Expected:
    x1 = -5
    x2 = 3
    x3 = 99
    x4 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'hFFB00093;
cpu_design.instruction_memory.memory[1] = 32'h00300113;
cpu_design.instruction_memory.memory[2] = 32'h0020E463;
cpu_design.instruction_memory.memory[3] = 32'h06300193;
cpu_design.instruction_memory.memory[4] = 32'h00700213;

run_cpu(20);

reg_checker(1, -32'sd5);
reg_checker(2, 32'd3);
reg_checker(3, 32'd99);
reg_checker(4, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
            TEST 26: BGEU NOT TAKEN

    addi x1, x0, 3
    addi x2, x0, -5
    bgeu x1, x2, +8

    addi x3, x0, 99 must execute
    addi x4, x0, 7 branch target

    Expected:
    x1 = 3
    x2 = -5
    x3 = 99
    x4 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00300093;
cpu_design.instruction_memory.memory[1] = 32'hFFB00113;
cpu_design.instruction_memory.memory[2] = 32'h0020F463;
cpu_design.instruction_memory.memory[3] = 32'h06300193;
cpu_design.instruction_memory.memory[4] = 32'h00700213;

run_cpu(20);

reg_checker(1, 32'd3);
reg_checker(2, -32'sd5);
reg_checker(3, 32'd99);
reg_checker(4, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
            TEST 27: JAL

    jal  x1, +12

    addi x3, x0, 99  wrong path
    addi x4, x0, 88  wrong path

    addi x5, x0, 7   jump target

    Expected:
    x1 = 4  : PC + 4
    x3 = 0
    x4 = 0
    x5 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00C000EF;
cpu_design.instruction_memory.memory[1] = 32'h06300193;
cpu_design.instruction_memory.memory[2] = 32'h05800213;
cpu_design.instruction_memory.memory[3] = 32'h00700293;

run_cpu(20);

reg_checker(1, 32'd4);
reg_checker(3, 32'd0);
reg_checker(4, 32'd0);
reg_checker(5, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
          TEST 28: JAL WITH X0

    jal  x0, +12

    addi x3, x0, 99 wrong path
    addi x4, x0, 88 wrong path

    addi x5, x0, 7 jump target

    Expected:
    x0 = 0
    x3 = 0
    x4 = 0
    x5 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h00C0006F;
cpu_design.instruction_memory.memory[1] = 32'h06300193;
cpu_design.instruction_memory.memory[2] = 32'h05800213;
cpu_design.instruction_memory.memory[3] = 32'h00700293;

run_cpu(20);

reg_checker(0, 32'd0);
reg_checker(3, 32'd0);
reg_checker(4, 32'd0);
reg_checker(5, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
            TEST 29: BASIC JALR

    addi x1, x0, 28
    no_op
    no_op
    no_op

    jalr x2, x1, 0

    addi x3, x0, 99 wrong path
    addi x4, x0, 88 wrong path

    addi x5, x0, 7  target at address 28

    Expected:
    x1 = 28
    x2 = 20 JALR PC = 16, so PC + 4 = 20
    x3 = 0
    x4 = 0
    x5 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h01C00093;
cpu_design.instruction_memory.memory[1] = no_op;
cpu_design.instruction_memory.memory[2] = no_op;
cpu_design.instruction_memory.memory[3] = no_op;
cpu_design.instruction_memory.memory[4] = 32'h00008167;
cpu_design.instruction_memory.memory[5] = 32'h06300193;
cpu_design.instruction_memory.memory[6] = 32'h05800213;
cpu_design.instruction_memory.memory[7] = 32'h00700293;

run_cpu(30);

reg_checker(1, 32'd28);
reg_checker(2, 32'd20);
reg_checker(3, 32'd0);
reg_checker(4, 32'd0);
reg_checker(5, 32'd7);
stall_checker(0);


/*<><><><><><><><><><><><><><><><><><><><><><><>
      TEST 30: JALR IMMEDIATE AND BIT 0 CLEAR

    addi x1, x0, 21
    no_op
    no_op
    no_op

    jalr x2, x1, 8

    addi x3, x0, 99 wrong path
    addi x4, x0, 88 wrong path

    addi x5, x0, 7 target at address 28

    Expected:
    x1 = 21
    x2 = 20
    x3 = 0
    x4 = 0
    x5 = 7
    stalls = 0

    JALR target:
    (21 + 8) & ~1 = 28
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h01500093;
cpu_design.instruction_memory.memory[1] = no_op;
cpu_design.instruction_memory.memory[2] = no_op;
cpu_design.instruction_memory.memory[3] = no_op;
cpu_design.instruction_memory.memory[4] = 32'h00808167;
cpu_design.instruction_memory.memory[5] = 32'h06300193;
cpu_design.instruction_memory.memory[6] = 32'h05800213;
cpu_design.instruction_memory.memory[7] = 32'h00700293;

run_cpu(30);

reg_checker(1, 32'd21);
reg_checker(2, 32'd20);
reg_checker(3, 32'd0);
reg_checker(4, 32'd0);
reg_checker(5, 32'd7);
stall_checker(0);

/*<><><><><><><><><><><><><><><><><><><><><><><>
       TEST 31: JALR WITH FORWARDING

    addi x1, x0, 16
    jalr x2, x1, 0

    addi x3, x0, 99 wrong path
    addi x4, x0, 88 wrong path

    addi x5, x0, 7  target at address 16

    Expected:
    x1 = 16
    x2 = 8 JALR is at PC = 4, so PC + 4 = 8
    x3 = 0
    x4 = 0
    x5 = 7
    stalls = 0
<><><><><><><><><><><><><><><><><><><><><><><>*/

test_setup();

cpu_design.instruction_memory.memory[0] = 32'h01000093; // addi x1, x0, 16
cpu_design.instruction_memory.memory[1] = 32'h00008167; // jalr x2, x1, 0
cpu_design.instruction_memory.memory[2] = 32'h06300193; // wrong path
cpu_design.instruction_memory.memory[3] = 32'h05800213; // wrong path
cpu_design.instruction_memory.memory[4] = 32'h00700293; // target

run_cpu(20);
reg_checker(1, 32'd16);
reg_checker(2, 32'd8);
reg_checker(3, 32'd0);
reg_checker(4, 32'd0);
reg_checker(5, 32'd7);
stall_checker(0);


$display("Tests Passed: %0d", pass_counter);
$display("Tests Failed: %0d", fail_counter);
$finish;


end



endmodule


