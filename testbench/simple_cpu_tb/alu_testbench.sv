`timescale 1ns/1ps

module alu_testbench;
    
    logic [31:0] a;
    logic [31:0] b;
    logic [3:0] alu_opp;

    logic [31:0] result;
    logic zero;


    alu test_alu (
        .a(a),
        .b(b),
        .alu_opp(alu_opp),
        .result(result),
        .zero(zero)
    );

    initial begin

        /***=====================
                TEST ADD
        =====================***/
        a = 32'd10;
        b = 32'd5;
        alu_opp = 4'b0000;

        #10; //delay 10ns

        if (result == 32'd15)
            $display("ADD PASS");
        else
            $display("ADD FAIL : result = %d", result);


        /***=====================
                TEST SUB
        =====================***/
        a = 32'd10;
        b = 32'd5;
        alu_opp = 4'b0001;

        #10; //delay 10ns

        if (result == 32'd5)
            $display("SUB PASS");
        else
            $display("SUB FAIL : result = %d", result);


        /***=====================
                TEST AND
        =====================***/
        a = 32'b1100;
        b = 32'b1010;
        alu_opp = 4'b0010;

        #10; //delay 10ns

        if (result == 32'b1000)
            $display("AND PASS");
        else
            $display("AND FAIL : result = %b", result);


        /***=====================
                TEST OR
        =====================***/
        a = 32'b1100;
        b = 32'b1010;
        alu_opp = 4'b0011;

        #10; //delay 10ns

        if (result == 32'b1110)
            $display("OR PASS");
        else
            $display("OR FAIL : result = %b", result);


        /***=====================
                TEST XOR
        =====================***/
        a = 32'b1100;
        b = 32'b1010;
        alu_opp = 4'b0100;

        #10; //delay 10ns

        if (result == 32'b0110)
            $display("XOR PASS");
        else
            $display("XOR FAIL : result = %b", result);

        /***=====================
                TEST SLL
        =====================***/
        a = 32'd1;
        b = 32'd3;
        alu_opp = 4'b0101;

        #10; //delay 10ns

        if (result == 32'd8)
            $display("SLL PASS");
        else
            $display("SLL FAIL : result = %d", result);


        /***=====================
                TEST SRL
        =====================***/
        a = 32'd16;
        b = 32'd2;
        alu_opp = 4'b0110;

        #10; //delay 10ns

        if (result == 32'd4)
            $display("SRL PASS");
        else
            $display("SRL FAIL : result = %d", result);


        /***=====================
                TEST SRA
        =====================***/
        a = -32'sd8;
        b = 32'd1;
        alu_opp = 4'b0111;

        #10; //delay 10ns

        if ($signed(result) == -32'sd4)
            $display("SRA PASS");
        else
            $display("SRA FAIL : result = %d", $signed(result));


        /***=====================
                TEST SLT
        =====================***/
        a = -32'sd5;
        b = 32'd2;
        alu_opp = 4'b1000;

        #10; //delay 10ns

        if (result == 32'd1)
            $display("SLT PASS");
        else
            $display("SLT FAIL : result = %d", result);


        /***=====================
                TEST SLTU
        =====================***/
        a = -32'sd1;
        b = 32'd1;
        alu_opp = 4'b1001;

        #10;

        if (result == 32'd0)
            $display("SLTU PASS");
        else
            $display("SLTU FAIL : result = %d", result);


        /***=====================
              TEST ZERO FLAG
        =====================***/
        a = 32'd5;
        b = 32'd5;
        alu_opp = 4'b0001;

        #10; //delay 10ns

        if (result == 32'd0 && zero == 1'b1)
            $display("ZERO FLAG HIGH PASS");
        else
            $display("ZERO FLAG HIGH FAIL");


        /***==========================
              TEST ZERO FLAG Pt. 2
        ============================***/
        a = 32'd5;
        b = 32'd3;
        alu_opp = 4'b0000;

        #10; //delay 10ns

        if (result == 32'd8 && zero == 1'b0)
            $display("ZERO FLAG LOW PASS");
        else
            $display("ZERO FLAG LOW FAIL");


        /***==========================
            EDGE CASE: ADD WRAP
        ===========================***/
        a = 32'hFFFFFFFF;
        b = 32'd1;
        alu_opp = 4'b0000;

        #10;

        if (result == 32'd0)
            $display("ADD WRAP PASS");
        else
            $display("ADD WRAP FAIL : result = %h", result);


        /***==========================
            EDGE CASE: SUB WRAP
        ===========================***/
        a = 32'd0;
        b = 32'd1;
        alu_opp = 4'b0001;

        #10;

        if (result == 32'hFFFFFFFF)
            $display("SUB WRAP PASS");
        else
            $display("SUB WRAP FAIL : result = %h", result);


        /***==========================
            EDGE CASE: SHIFT BY 0
        ===========================***/
        a = 32'd15;
        b = 32'd0;
        alu_opp = 4'b0101;

        #10;

        if (result == 32'd15)
            $display("SHIFT BY 0 PASS");
        else
            $display("SHIFT BY 0 FAIL : result = %d", result);


        /***==========================
            EDGE CASE: SHIFT BY 31
        ===========================***/
        a = 32'd1;
        b = 32'd31;
        alu_opp = 4'b0101;

        #10;

        if (result == 32'h80000000)
            $display("SHIFT BY 31 PASS");
        else
            $display("SHIFT BY 31 FAIL : result = %h", result);


        /***==========================
            EDGE CASE: INVALID OP
        ===========================***/
        a = 32'd5;
        b = 32'd3;
        alu_opp = 4'b1111;

        #10;

        if (result == 32'd0 && zero == 1'b1)
            $display("DEFAULT OP PASS");
        else
            $display("DEFAULT OP FAIL : result = %d", result);
                $finish;

            end

        endmodule
