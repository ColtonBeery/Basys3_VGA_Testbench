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
    reg [3:0] counter1, counter2;
    reg [0:15] block_exists;
    always @(posedge clk) begin
        case (mode)
            0: begin
                for (counter1 = 0; counter1 < 8; counter1 = counter1 + 1) begin //Vivado lets me use a for loop here but not below? 
                    if ((x < MAX_X) & (x > 0) & (y < MAX_Y) | (y > 0))
                        block_exists[counter1] <= ((x > ((MAX_X/8)*counter1)) & (y > 0) & (x <= ((MAX_X/8)*(counter1+1))) & (y < 480)) ? 1 : 0;
                    else 
                        block_exists[counter1] <= 0;
                end 
                block_exists[8:15] <= 0;
            end
            1: begin
                counter1 <= 0;
                repeat (16) begin //16 blocks. Why won't Vivado let me use a for loop? 
                    if ((x < MAX_X) & (x > 0) & (y < MAX_Y) | (y > 0))
                        block_exists[counter1] <= ((x > ((MAX_X/16)*counter1)) & (y > 0) & (x <= ((MAX_X/16)*(counter1+1))) & (y < 480)) ? 1 : 0;
                    else 
                        block_exists[counter1] <= 0;
                    counter1 <= counter1 + 1;
                end
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
                counter2 <= 0;
                repeat (16) begin //16 blocks. Why won't Vivado let me use a for loop? 
                    if (block_exists[counter2]) begin // black square
                        VGA_Red <= counter2;
                        VGA_Green <= counter2;
                        VGA_Blue <= counter2;
                    end
                    counter2 <= counter2 + 1;
                end
            end //end black and white bars
            default: begin //if error, whole screen white
                VGA_Red <= 15;
                VGA_Green <= 15;
                VGA_Blue <= 15;
            end
        endcase
        
        if ( (x <= 0) | (x >= MAX_X) | (y <= 0) | (y >= MAX_Y) ) begin
            VGA_Red <= 0;
            VGA_Green <= 0;
            VGA_Blue <= 0;
        end
    end 
endmodule
