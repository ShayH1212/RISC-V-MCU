`timescale 1ns/1ps

module reg_file_testbench;

    logic clk;
    logic write_enable;

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    logic [31:0] write_reg;

    logic [31:0] read_reg1;
    logic [31:0] read_reg2;


    // Instantiate register file
    reg_file test_reg_file (
        .clk(clk),
        .write_enable(write_enable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_reg(write_reg),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2)
    );


    // Create clock
    always #5 clk = ~clk;


    initial begin

        // Initial values
        clk = 1'b0;
        write_enable = 1'b0;
        rs1 = 5'd0;
        rs2 = 5'd0;
        rd = 5'd0;
        write_reg = 32'd0;


        /***========================
            TEST 1: WRITE x5
        ==========================***/
        rd = 5'd5;
        write_reg = 32'd25;
        write_enable = 1'b1;

        @(posedge clk);
        #1;

        rs1 = 5'd5;
        #1;

        if (read_reg1 == 32'd25)
            $display("WRITE x5 PASS");
        else
            $display("WRITE x5 FAIL : read_reg1 = %d", read_reg1);


        /***========================
            TEST 2: READ x5 FROM rs2
        ==========================***/
        write_enable = 1'b0;
        rs2 = 5'd5;

        #1;

        if (read_reg2 == 32'd25)
            $display("READ x5 THROUGH rs2 PASS");
        else
            $display("READ x5 THROUGH rs2 FAIL : read_reg2 = %d", read_reg2);


        /***========================
            TEST 3: WRITE x10
        ==========================***/
        rd = 5'd10;
        write_reg = 32'd100;
        write_enable = 1'b1;

        @(posedge clk);
        #1;

        rs1 = 5'd10;
        #1;

        if (read_reg1 == 32'd100)
            $display("WRITE x10 PASS");
        else
            $display("WRITE x10 FAIL : read_reg1 = %d", read_reg1);


        /***========================
            TEST 4: x5 STILL = 25
        ==========================***/
        write_enable = 1'b0;
        rs1 = 5'd5;

        #1;

        if (read_reg1 == 32'd25)
            $display("x5 PRESERVED PASS");
        else
            $display("x5 PRESERVED FAIL : read_reg1 = %d", read_reg1);


        /***========================
            TEST 5: x0 READS ZERO
        ==========================***/
        rs1 = 5'd0;

        #1;

        if (read_reg1 == 32'd0)
            $display("x0 READ ZERO PASS");
        else
            $display("x0 READ ZERO FAIL : read_reg1 = %d", read_reg1);


        /***========================
            TEST 6: TRY WRITE x0
        ==========================***/
        rd = 5'd0;
        write_reg = 32'd999;
        write_enable = 1'b1;

        @(posedge clk);
        #1;

        rs1 = 5'd0;
        #1;

        if (read_reg1 == 32'd0)
            $display("x0 WRITE PROTECTION PASS");
        else
            $display("x0 WRITE PROTECTION FAIL : read_reg1 = %d", read_reg1);


        /***========================
            TEST 7A: WRITE 20 TO x7
        ==========================***/
        rd = 5'd7;
        write_reg = 32'd20;
        write_enable = 1'b1;

        @(posedge clk);
        #1;

        rs1 = 5'd7;
        #1;

        if (read_reg1 == 32'd20)
            $display("INITIAL x7 WRITE PASS");
        else
            $display("INITIAL x7 WRITE FAIL : read_reg1 = %d", read_reg1);


        /***========================
            TEST 7B: DISABLE WRITE
        ==========================***/
        rd = 5'd7;
        write_reg = 32'd50;
        write_enable = 1'b0;

        @(posedge clk);
        #1;

        rs1 = 5'd7;
        #1;

        if (read_reg1 == 32'd20)
            $display("WRITE ENABLE OFF PASS");
        else
            $display("WRITE ENABLE OFF FAIL : read_reg1 = %d", read_reg1);


        $finish;

    end

endmodule