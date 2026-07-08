`timescale 1ns/1ps
module tb_cordic();

    // DUT port declarations
    reg         clk, rst, en;
    reg  signed [15:0] angle;
    wire signed [15:0] cos_out, sin_out;
    wire signed [31:0] tan_out;
    wire               valid;

  
    // Instantiate DUT

    cordic uut (
        .clk    (clk),
        .rst    (rst),
        .en     (en),
        .angle  (angle),
        .cos_out(cos_out),
        .sin_out(sin_out),
        .tan_out(tan_out),
        .valid  (valid)
    );

 
    // 100 MHz clock
    
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst   = 1;
        en    = 0;
        angle = 0;

        // Release reset after 2 clock cycles
        #20 rst = 0;
        #10;

        // ======================================================================
        // Test 1: 0 degrees  (angle = 0  →  cos=1, sin=0, tan=0)
        // ======================================================================
        $display("\n=== Test 1: 0 degrees ===");
        angle = 16'd0;
        en = 1;  #10  en = 0;
        wait(valid == 1);  #10;
        $display("cos = %6d  (expected ~32767)", cos_out);
        $display("sin = %6d  (expected ~0)",     sin_out);
        $display("tan = %6d  (expected ~0)",     tan_out);

        // ======================================================================
        // Test 2: 45 degrees  (π/4 rad → Q1.15 = 25736)
        // ======================================================================
        #50;
        $display("\n=== Test 2: 45 degrees ===");
        angle = 16'd25736;        // pi/4 × 2^15
        en = 1;  #10  en = 0;
        wait(valid == 1);  #10;
        $display("cos = %6d  (expected ~23170)", cos_out);
        $display("sin = %6d  (expected ~23170)", sin_out);
        $display("tan = %6d  (expected ~32768)", tan_out);

        // ======================================================================
        // Test 3: 30 degrees  (π/6 rad → Q1.15 = 17157)
        // ======================================================================
        #50;
        $display("\n=== Test 3: 30 degrees ===");
        angle = 16'd17157;        // pi/6 × 2^15
        en = 1;  #10  en = 0;
        wait(valid == 1);  #10;
        $display("cos = %6d  (expected ~28378)", cos_out);
        $display("sin = %6d  (expected ~16384)", sin_out);
        $display("tan = %6d  (expected ~18918)", tan_out);

        // ======================================================================
        // Test 4: 89 degrees  (1.5533 rad → Q1.15 = 32157)
        // Note: true 90° exceeds signed Q1.15 range; 89° is the practical limit.
        // ======================================================================
        #50;
        $display("\n=== Test 4: 89 degrees ===");
        angle = 16'd32157;        // 89° × π/180 × 2^15
        en = 1;  #10  en = 0;
        wait(valid == 1);  #10;
        $display("cos = %6d  (expected ~572)",        cos_out);
        $display("sin = %6d  (expected ~32762)",      sin_out);
        $display("tan = %6d  (expected very large)",  tan_out);

        // ======================================================================
        // Test 5: -45 degrees  (−π/4 rad → Q1.15 = −25736)
        // ======================================================================
        #50;
        $display("\n=== Test 5: -45 degrees ===");
        angle = -16'd25736;
        en = 1;  #10  en = 0;
        wait(valid == 1);  #10;
        $display("cos = %6d  (expected ~23170)",  cos_out);
        $display("sin = %6d  (expected ~-23170)",  sin_out);
        $display("tan = %6d  (expected ~-32768)",  tan_out);

        #100;
        $display("\n=== Simulation Complete ===");
        $finish;
    end

endmodule
