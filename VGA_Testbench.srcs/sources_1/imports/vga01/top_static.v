// FPGA VGA Graphics Part 1: Top Module (static squares)
// (C)2017-2018 Will Green - Licensed under the MIT License
// Learn more at https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

`default_nettype none

module top(
    input wire clk,             // board clock: 100 MHz on Arty/Basys3/Nexys
    input wire IO_BTN_C,         // reset button
    output wire VGA_Hsync,       // horizontal sync output
    output wire VGA_Vsync,       // vertical sync output
    output reg [3:0] VGA_Red,    // 4-bit VGA red output
    output reg [3:0] VGA_Green,    // 4-bit VGA green output
    output reg [3:0] VGA_Blue     // 4-bit VGA blue output
    );

    //wire rst = ~IO_BTN_C;    // reset is active low on Arty & Nexys Video
    wire rst = IO_BTN_C;  // reset is active high on Basys3 (BTNC)

    // generate a 25 MHz pixel strobe
    reg [15:0] cnt;
    reg pix_stb;
    always @(posedge clk)
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide by 4: (2^16)/4 = 0x4000

    wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511

    vga640x480 display (
        .i_clk(clk),
        .i_pix_stb(pix_stb),
        .i_rst(rst),
        .o_hs(VGA_Hsync), 
        .o_vs(VGA_Vsync), 
        .o_x(x), 
        .o_y(y)
    );

    wire sq_a, sq_b, sq_c, sq_d, sq_e, sq_f, sq_g, sq_h;
    assign sq_a = ((x > 0) & (y > 0) & (x <= 80) & (y < 480)) ? 1 : 0;
    assign sq_b = ((x > 80) & (y > 0) & (x <= 160) & (y < 480)) ? 1 : 0;
    assign sq_c = ((x > 160) & (y > 0) & (x <= 240) & (y < 480)) ? 1 : 0;
    assign sq_d = ((x > 240) & (y > 0) & (x <= 320) & (y < 480)) ? 1 : 0;
    assign sq_e = ((x > 320) & (y > 0) & (x <= 400) & (y < 480)) ? 1 : 0;
    assign sq_f = ((x > 400) & (y > 0) & (x <= 480) & (y < 480)) ? 1 : 0;
    assign sq_g = ((x > 480) & (y > 0) & (x <= 560) & (y < 480)) ? 1 : 0;
    assign sq_h = ((x > 560) & (y > 0) & (x <= 640) & (y < 480)) ? 1 : 0;
    
//    assign VGA_Red[3] = sq_a | sq_d | sq_g;
//    assign VGA_Green[3] = sq_a | sq_b | sq_e;
//    assign VGA_Blue[3] = sq_a | sq_c | sq_f;
    always @(posedge clk) begin
        if (sq_a) begin //white square
            VGA_Red <= 15;
            VGA_Green <= 15;
            VGA_Blue <= 15;
        end
        if (sq_b) begin //yellow square
            VGA_Red <= 15;
            VGA_Green <= 15;
            VGA_Blue <= 0;
        end
        if (sq_c) begin //light blue square
            VGA_Red <= 11;
            VGA_Green <= 11;
            VGA_Blue <= 15;
        end
        if (sq_d) begin //green square
            VGA_Red <= 0;
            VGA_Green <= 10;
            VGA_Blue <= 0;
        end
        if (sq_e) begin //purple square
            VGA_Red <= 12;
            VGA_Green <= 0;
            VGA_Blue <= 12;
        end
        if (sq_f) begin //pink square
            VGA_Red <= 15;
            VGA_Green <= 10;
            VGA_Blue <= 10;
        end
        if (sq_g) begin //dark blue square
            VGA_Red <= 0;
            VGA_Green <= 0;
            VGA_Blue <= 12;
        end
        if (sq_h) begin // black square
            VGA_Red <= 0;
            VGA_Green <= 0;
            VGA_Blue <= 0;
        end
    end
endmodule
