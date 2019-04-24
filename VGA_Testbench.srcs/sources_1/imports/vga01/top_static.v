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

    wire [0:7] block_exists;
    assign block_exists[0] = ((x > 0) & (y > 0) & (x <= 80) & (y < 480)) ? 1 : 0;
    assign block_exists[1] = ((x > 80) & (y > 0) & (x <= 160) & (y < 480)) ? 1 : 0;
    assign block_exists[2] = ((x > 160) & (y > 0) & (x <= 240) & (y < 480)) ? 1 : 0;
    assign block_exists[3] = ((x > 240) & (y > 0) & (x <= 320) & (y < 480)) ? 1 : 0;
    assign block_exists[4] = ((x > 320) & (y > 0) & (x <= 400) & (y < 480)) ? 1 : 0;
    assign block_exists[5] = ((x > 400) & (y > 0) & (x <= 480) & (y < 480)) ? 1 : 0;
    assign block_exists[6] = ((x > 480) & (y > 0) & (x <= 560) & (y < 480)) ? 1 : 0;
    assign block_exists[7] = ((x > 560) & (y > 0) & (x <= 640) & (y < 480)) ? 1 : 0;
    
    always @(posedge clk) begin
        if (block_exists[0]) begin //white square
            VGA_Red <= 15;
            VGA_Green <= 15;
            VGA_Blue <= 15;
        end
        if (block_exists[1]) begin //yellow square
            VGA_Red <= 15;
            VGA_Green <= 15;
            VGA_Blue <= 0;
        end
        if (block_exists[2]) begin //light blue square
            VGA_Red <= 11;
            VGA_Green <= 11;
            VGA_Blue <= 15;
        end
        if (block_exists[3]) begin //green square
            VGA_Red <= 0;
            VGA_Green <= 10;
            VGA_Blue <= 0;
        end
        if (block_exists[4]) begin //purple square
            VGA_Red <= 12;
            VGA_Green <= 0;
            VGA_Blue <= 12;
        end
        if (block_exists[5]) begin //pink square
            VGA_Red <= 15;
            VGA_Green <= 10;
            VGA_Blue <= 10;
        end
        if (block_exists[6]) begin //dark blue square
            VGA_Red <= 0;
            VGA_Green <= 0;
            VGA_Blue <= 12;
        end
        if (block_exists[7]) begin // black square
            VGA_Red <= 0;
            VGA_Green <= 0;
            VGA_Blue <= 0;
        end
    end
endmodule
