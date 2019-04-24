// FPGA VGA Graphics Part 1: Top Module (static squares)
// (C)2017-2018 Will Green - Licensed under the MIT License
// Learn more at https://timetoexplore.net/blog/arty-fpga-vga-verilog-01

`default_nettype none

module top(
    input wire clk,             // board clock: 100 MHz on Arty/Basys3/Nexys
    input wire IO_BTN_C,         // reset button
    input wire [0:0] IO_SWITCH,  // mode select   
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
    localparam MAX_X = 640;
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511
    localparam MAX_Y = 480;

    vga640x480 display (
        .i_clk(clk),
        .i_pix_stb(pix_stb),
        .i_rst(rst),
        .o_hs(VGA_Hsync), 
        .o_vs(VGA_Vsync), 
        .o_x(x), 
        .o_y(y)
    );
    
    reg mode = 0;
    
    //block existence
    reg [3:0] counter;
    reg [0:15] block_exists;
    always @(posedge clk) begin
        case (mode)
            0: begin
                for (counter = 0; counter < 8; counter = counter + 1) begin
                    block_exists[counter] <= ((x > ((MAX_X/8)*counter)) & (y > 0) & (x <= ((MAX_X/8)*(counter+1))) & (y < 480)) ? 1 : 0;
                end 
                block_exists[8:15] <= 0;
            end
            1: begin
                // I really want to use for loops here, like I did above, but vivado won't let me.  
                block_exists[0] <= ((x > 0) & (y > 0) & (x <= (MAX_X/16)) & (y < 480)) ? 1 : 0;
                block_exists[1] <= ((x > (MAX_X/16)) & (y > 0) & (x <= ((MAX_X/16)*2)) & (y < 480)) ? 1 : 0;
                block_exists[2] <= ((x > ((MAX_X/16)*2)) & (y > 0) & (x <= ((MAX_X/16)*3)) & (y < 480)) ? 1 : 0;
                block_exists[3] <= ((x > ((MAX_X/16)*3)) & (y > 0) & (x <= ((MAX_X/16)*4)) & (y < 480)) ? 1 : 0;
                block_exists[4] <= ((x > ((MAX_X/16)*4)) & (y > 0) & (x <= ((MAX_X/16)*5)) & (y < 480)) ? 1 : 0;
                block_exists[5] <= ((x > ((MAX_X/16)*5)) & (y > 0) & (x <= ((MAX_X/16)*6)) & (y < 480)) ? 1 : 0;
                block_exists[6] <= ((x > ((MAX_X/16)*6)) & (y > 0) & (x <= ((MAX_X/16)*7)) & (y < 480)) ? 1 : 0;
                block_exists[7] <= ((x > ((MAX_X/16)*7)) & (y > 0) & (x <= ((MAX_X/16)*8)) & (y < 480)) ? 1 : 0;
                block_exists[8] <= ((x > ((MAX_X/16)*8)) & (y > 0) & (x <= ((MAX_X/16)*9)) & (y < 480)) ? 1 : 0;
                block_exists[9] <= ((x > ((MAX_X/16)*9)) & (y > 0) & (x <= ((MAX_X/16)*10)) & (y < 480)) ? 1 : 0;
                block_exists[10] <= ((x > ((MAX_X/16)*10)) & (y > 0) & (x <= ((MAX_X/16)*11)) & (y < 480)) ? 1 : 0;
                block_exists[11] <= ((x > ((MAX_X/16)*11)) & (y > 0) & (x <= ((MAX_X/16)*12)) & (y < 480)) ? 1 : 0;
                block_exists[12] <= ((x > ((MAX_X/16)*12)) & (y > 0) & (x <= ((MAX_X/16)*13)) & (y < 480)) ? 1 : 0;
                block_exists[13] <= ((x > ((MAX_X/16)*13)) & (y > 0) & (x <= ((MAX_X/16)*14)) & (y < 480)) ? 1 : 0;
                block_exists[14] <= ((x > ((MAX_X/16)*14)) & (y > 0) & (x <= ((MAX_X/16)*15)) & (y < 480)) ? 1 : 0;
                block_exists[15] <= ((x > ((MAX_X/16)*15)) & (y > 0) & (x < MAX_X) & (y < 480)) ? 1 : 0;
                /*counter <= 0;
                repeat (14) begin
                    block_exists[counter] <= ((x > ((MAX_X/16)*counter)) & (y > 0) & (x <= ((MAX_X/16)*(counter+1))) & (y < 480)) ? 1 : 0;
                    counter <= counter + 1;
                end
                block_exists[15] <= ((x > ((MAX_X/16)*15)) & (y > 0) & (x < MAX_X) & (y < 480)) ? 1 : 0;*/
            end
        endcase
    end
    
    // color the display
    always @(posedge clk) begin
        mode <= IO_SWITCH[0];
        case(mode)
            0: begin//full color bars
                if (block_exists[0]) begin //white square
                    VGA_Red <= 15;
                    VGA_Green <= 15;
                    VGA_Blue <= 15;
                end //end white square
                if (block_exists[1]) begin //yellow square
                    VGA_Red <= 14;
                    VGA_Green <= 14;
                    VGA_Blue <= 1;
                end //end yellow square
                if (block_exists[2]) begin //light blue square
                    VGA_Red <= 6;
                    VGA_Green <= 12;
                    VGA_Blue <= 13;
                end //end light blue square
                if (block_exists[3]) begin //green square
                    VGA_Red <= 6;
                    VGA_Green <= 11;
                    VGA_Blue <= 3;
                end //end green square
                if (block_exists[4]) begin //purple square
                    VGA_Red <= 11;
                    VGA_Green <= 4;
                    VGA_Blue <= 9;
                end //end purple square
                if (block_exists[5]) begin //pink square
                    VGA_Red <= 14;
                    VGA_Green <= 1;
                    VGA_Blue <= 1;
                end //end pink square
                if (block_exists[6]) begin //dark blue square
                    VGA_Red <= 3;
                    VGA_Green <= 4;
                    VGA_Blue <= 9;
                end //end dark blue square
                if (block_exists[7]) begin // black square
                    VGA_Red <= 0;
                    VGA_Green <= 0;
                    VGA_Blue <= 0;
                end //end black square
            end //end full color bars
            1: begin//black and white bars
                if (block_exists[0]) begin //black square
                    VGA_Red <= 0;
                    VGA_Green <= 0;
                    VGA_Blue <= 0;
                end //end black square
                if (block_exists[1]) begin 
                    VGA_Red <= 1;
                    VGA_Green <= 1;
                    VGA_Blue <= 1;
                end 
                if (block_exists[2]) begin
                    VGA_Red <= 2;
                    VGA_Green <= 2;
                    VGA_Blue <= 2;
                end 
                if (block_exists[3]) begin
                    VGA_Red <= 3;
                    VGA_Green <= 3;
                    VGA_Blue <= 3;
                end 
                if (block_exists[4]) begin 
                    VGA_Red <= 4;
                    VGA_Green <= 4;
                    VGA_Blue <= 4;
                end 
                if (block_exists[5]) begin
                    VGA_Red <= 5;
                    VGA_Green <= 5;
                    VGA_Blue <= 5;
                end //end pink square
                if (block_exists[6]) begin
                    VGA_Red <= 6;
                    VGA_Green <= 6;
                    VGA_Blue <= 6;
                end 
                if (block_exists[7]) begin
                    VGA_Red <= 7;
                    VGA_Green <= 7;
                    VGA_Blue <= 7;
                end
                if (block_exists[8]) begin
                    VGA_Red <= 8;
                    VGA_Green <= 8;
                    VGA_Blue <= 8;
                end
                if (block_exists[9]) begin
                    VGA_Red <= 9;
                    VGA_Green <= 9;
                    VGA_Blue <= 9;
                end
                if (block_exists[10]) begin
                    VGA_Red <= 10;
                    VGA_Green <= 10;
                    VGA_Blue <= 10;
                end
                if (block_exists[11]) begin
                    VGA_Red <= 11;
                    VGA_Green <= 11;
                    VGA_Blue <= 11;
                end
                if (block_exists[12]) begin
                    VGA_Red <= 12;
                    VGA_Green <= 12;
                    VGA_Blue <= 12;
                end
                if (block_exists[13]) begin
                    VGA_Red <= 13;
                    VGA_Green <= 13;
                    VGA_Blue <= 13;
                end
                if (block_exists[14]) begin
                    VGA_Red <= 14;
                    VGA_Green <= 14;
                    VGA_Blue <= 14;
                end
                if (block_exists[15]) begin
                    VGA_Red <= 15;
                    VGA_Green <= 15;
                    VGA_Blue <= 15;
                end
            end //end black and white bars
            default: begin //if error, whole screen white
                VGA_Red <= 15;
                VGA_Green <= 15;
                VGA_Blue <= 15;
            end
        endcase
    end
endmodule
