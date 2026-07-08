`timescale 1ns/1ps
module cordic #(
    parameter N = 16            // number of CORDIC iterations
)(
    input  wire              clk,
    input  wire              rst,
    input  wire              en,
    input  wire signed [15:0] angle,   // angle in Q1.15 radians
    output reg  signed [15:0] cos_out,
    output reg  signed [15:0] sin_out,
    output reg  signed [31:0] tan_out, // wider: tan can exceed ±1
    output reg               valid
);

    
    // Arc-tangent look-up table: atan(2^-i) scaled to Q1.15
    //   arctan[i] = round( atan(2^-i) * 2^15 )
    
    wire signed [15:0] arctan [0:15];
    assign arctan[0]  = 16'd25736;   // atan(2^0)  = 45.000°
    assign arctan[1]  = 16'd15193;   // atan(2^-1) = 26.565°
    assign arctan[2]  = 16'd8027;    // atan(2^-2) = 14.036°
    assign arctan[3]  = 16'd4075;    // atan(2^-3) =  7.125°
    assign arctan[4]  = 16'd2040;    // atan(2^-4) =  3.576°
    assign arctan[5]  = 16'd1021;    // atan(2^-5) =  1.790°
    assign arctan[6]  = 16'd511;     // atan(2^-6) =  0.895°
    assign arctan[7]  = 16'd255;     // atan(2^-7) =  0.448°
    assign arctan[8]  = 16'd128;     // atan(2^-8) =  0.224°
    assign arctan[9]  = 16'd64;      // atan(2^-9) =  0.112°
    assign arctan[10] = 16'd32;      // atan(2^-10)=  0.056°
    assign arctan[11] = 16'd16;      // atan(2^-11)=  0.028°
    assign arctan[12] = 16'd8;       // atan(2^-12)=  0.014°
    assign arctan[13] = 16'd4;       // atan(2^-13)=  0.007°
    assign arctan[14] = 16'd2;       // atan(2^-14)=  0.003°
    assign arctan[15] = 16'd1;       // atan(2^-15)=  0.002°

    // CORDIC gain: K = ∏ sqrt(1 + 2^(-2i))  →  1/K ≈ 0.6073
    // 0.6073 × 32768 = 19897  (Q1.15 representation)
    localparam signed [15:0] GAIN = 16'd19897;

  
    // State registers

    reg [4:0]  i;                    // iteration counter (0 – N)
    reg signed [15:0] x, y, z;      // CORDIC state vector
    reg busy;

    reg signed [15:0] x_next, y_next, z_next;

    // Temporaries for tan computation (combinational)
    reg signed [31:0] y_ext;
    reg signed [31:0] tan_div;

   
    // Main sequential logic
  
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x       <= 0;
            y       <= 0;
            z       <= 0;
            i       <= 0;
            busy    <= 0;
            valid   <= 0;
            cos_out <= 0;
            sin_out <= 0;
            tan_out <= 0;
            x_next  <= 0;
            y_next  <= 0;
            z_next  <= 0;
        end
        else begin
            valid <= 0;   // default: de-assert each cycle

           
            // IDLE: accept new angle when en is pulsed
         
            if (en && !busy) begin
                x    <= GAIN;   // X₀ = 1/K  (pre-scaled for CORDIC gain)
                y    <= 0;      // Y₀ = 0
                z    <= angle;  // Z₀ = input angle
                i    <= 0;
                busy <= 1;
            end

          
            // BUSY: iterate N CORDIC steps
          
            else if (busy) begin
                if (i < N) begin
                    // Rotation direction is determined by sign of Z
                    if (z >= 0) begin
                        x_next = x - (y >>> i);   // rotate counter-clockwise
                        y_next = y + (x >>> i);
                        z_next = z - arctan[i];
                    end else begin
                        x_next = x + (y >>> i);   // rotate clockwise
                        y_next = y - (x >>> i);
                        z_next = z + arctan[i];
                    end

                    x <= x_next;
                    y <= y_next;
                    z <= z_next;
                    i <= i + 1;
                end
                else begin
                 
                    // DONE: latch outputs after N iterations
                  
                    cos_out <= x;
                    sin_out <= y;

                    // tan = sin / cos, computed in wider arithmetic to avoid
                    // overflow.  Left-shift y by 15 (×32768) then divide by x
                    // to keep result in Q2.15 format.
                    if (x == 0) begin
                        // Handle cos = 0 (90° / 270°): saturate to ±MAX
                        tan_out <= (y > 0) ? 32'sh7FFFFFFF : 32'sh80000000;
                    end else begin
                        y_ext   = {{16{y[15]}}, y};      // sign-extend to 32 b
                        tan_div = (y_ext <<< 15) / x;    // Q2.15 signed divide
                        tan_out <= tan_div;
                    end

                    valid <= 1;
                    busy  <= 0;
                end
            end
        end
    end

endmodule
