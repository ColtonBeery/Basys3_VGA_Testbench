// FPGA VGA Graphics Part 1: Top Module (static squares)
// (C)2017-2018 Will Green - Licensed under the MIT License
// Learn more at https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

`default_nettype none

module top(
    input wire clk,             // board clock: 100 MHz on Arty/Basys3/Nexys
    input wire IO_BTN_C,         // reset button
    output wire VGA_Hsync,       // horizontal sync output
    output wire VGA_Vsync,       // vertical sync output
    output wire [3:0] VGA_Red,    // 4-bit VGA red output
    output wire [3:0] VGA_Green,    // 4-bit VGA green output
    output wire [3:0] VGA_Blue     // 4-bit VGA blue output
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

    // Four overlapping squares
    wire sq_a, sq_b, sq_c, sq_d;
    assign sq_a = ((x > 120) & (y >  40) & (x < 280) & (y < 200)) ? 1 : 0;
    assign sq_b = ((x > 200) & (y > 120) & (x < 360) & (y < 280)) ? 1 : 0;
    assign sq_c = ((x > 280) & (y > 200) & (x < 440) & (y < 360)) ? 1 : 0;
    assign sq_d = ((x > 360) & (y > 280) & (x < 520) & (y < 440)) ? 1 : 0;

    assign VGA_Red[3] = sq_b;         // square b is red
    assign VGA_Green[3] = sq_a | sq_d;  // squares a and d are green
    assign VGA_Blue[3] = sq_c;         // square c is blue
endmodule
