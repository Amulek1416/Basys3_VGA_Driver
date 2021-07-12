`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2021 11:14:40 AM
// Design Name: 
// Module Name: shapes
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * Color Values: Used to specify the color of various objects to be drawn
 */
 `define WHITE  12'hFFF
 `define BLACK  12'h000
 `define RED    12'hF00
 `define GREEN  12'h0F0
 `define BLUE   12'h00F
 
/**
 * Shape Settings: Used to set various settings for a shape
 */
`define HORZ    8'h0
`define VERT    8'h1
`define FILL    8'h0
`define NO_FILL 8'h1

/**
 *  Add logic to draw different shapes and other desired objects
 */
module DRAW #(
    parameter X_BIT_SIZE = 10, // Used to define the size of the screen in the x direction
    parameter Y_BIT_SIZE = 9   // Used to define the size of the screen in the y direction
)(
    input clk,
    input [X_BIT_SIZE-1:0] x,
    input [Y_BIT_SIZE-1:0] y,
    output [3:0] R, G, B
);

    wire [11:0] colors [0:7];
    
    ASCII_LETTER #(
        .COLOR(`WHITE),
        .X_OFFSET(250),
        .Y_OFFSET(200),
        .X_BIT_SIZE(X_BIT_SIZE),
        .Y_BIT_SIZE(Y_BIT_SIZE)
    ) LETTER_0 (
        .draw_en(1'b1),
        .letter("H"),
        .clk(clk),
        .x(x),
        .y(y),
        .draw_flag(),
        .color(colors[0])
    );
    ASCII_LETTER #(
        .COLOR(`WHITE),
        .X_OFFSET(260),
        .Y_OFFSET(200),
        .X_BIT_SIZE(X_BIT_SIZE),
        .Y_BIT_SIZE(Y_BIT_SIZE)
    ) LETTER_1 (
        .draw_en(1'b1),
        .letter("E"),
        .clk(clk),
        .x(x),
        .y(y),
        .draw_flag(),
        .color(colors[1])
    );
    ASCII_LETTER #(
        .COLOR(`WHITE),
        .X_OFFSET(270),
        .Y_OFFSET(200),
        .X_BIT_SIZE(X_BIT_SIZE),
        .Y_BIT_SIZE(Y_BIT_SIZE)
    ) LETTER_2 (
        .draw_en(1'b1),
        .letter("L"),
        .clk(clk),
        .x(x),
        .y(y),
        .draw_flag(),
        .color(colors[2])
    );
    ASCII_LETTER #(
        .COLOR(`WHITE),
        .X_OFFSET(280),
        .Y_OFFSET(200),
        .X_BIT_SIZE(X_BIT_SIZE),
        .Y_BIT_SIZE(Y_BIT_SIZE)
    ) LETTER_3 (
        .draw_en(1'b1),
        .letter("L"),
        .clk(clk),
        .x(x),
        .y(y),
        .draw_flag(),
        .color(colors[3])
    );
    ASCII_LETTER #(
        .COLOR(`WHITE),
        .X_OFFSET(290),
        .Y_OFFSET(200),
        .X_BIT_SIZE(X_BIT_SIZE),
        .Y_BIT_SIZE(Y_BIT_SIZE)
    ) LETTER_4 (
        .draw_en(1'b1),
        .letter("O"),
        .clk(clk),
        .x(x),
        .y(y),
        .draw_flag(),
        .color(colors[4])
    );

    RECTANGLE #(
        .COLOR(`RED),
        .X_OFFSET(50),
        .Y_OFFSET(100),
        .HEIGHT(50),
        .WIDTH(100),
        .X_BIT_SIZE(X_BIT_SIZE),
        .Y_BIT_SIZE(Y_BIT_SIZE)
    ) RECTANGLE_0 (
        .draw_en(1'b1),
        .x(x),
        .y(y),
        .draw_flag(),
        .color(colors[5])
    ); 
    
    LINE #(
        .COLOR(`GREEN),
        .DIR(`HORZ),
        .X_OFFSET(300),
        .Y_OFFSET(50),
        .LENGTH(100),
        .THICKNESS(1),
        .X_BIT_SIZE(X_BIT_SIZE),
        .Y_BIT_SIZE(Y_BIT_SIZE)
    ) LINE_0 (
        .draw_en(1'b1),
        .x(x),
        .y(y),
        .draw_flag(),
        .color(colors[6])
    ); 
    
    LINE #(
        .COLOR(`BLUE),
        .DIR(`VERT),
        .X_OFFSET(300),
        .Y_OFFSET(50),
        .LENGTH(100),
        .THICKNESS(1),
        .X_BIT_SIZE(X_BIT_SIZE),
        .Y_BIT_SIZE(Y_BIT_SIZE)
    ) LINE_1 (
        .draw_en(1'b1),
        .x(x),
        .y(y),
        .draw_flag(),
        .color(colors[7])
    ); 

    assign {R, G, B} = colors[0] | colors[1] | colors[2] | colors[3] | colors[4] | colors[5] | colors[6] | colors[7];

endmodule

/**
 * Module is used to draw a letter on a screen. The letter has a size of 8x16 pixels. 
 * Change the parameters to suit your needs when you instantiate the module.
 */
module ASCII_LETTER #(
    parameter COLOR = `WHITE,  // The color of the letter
    parameter X_OFFSET = 100,  // X location for the top left corner of the letter
    parameter Y_OFFSET = 100,  // Y location for the top left corner of the letter
    parameter X_BIT_SIZE = 10, // Size of the x counter
    parameter Y_BIT_SIZE = 9   // Size of the Y counter
)(
    input draw_en, clk,
    input [6:0] letter,
    input [X_BIT_SIZE-1:0] x,
    input [Y_BIT_SIZE-1:0] y,
    output draw_flag,
    output [11:0] color
);

    wire [127:0] bit_map, rev_bit_map;
    wire [7:0] bit_map_arr [0:15];

    reg draw_letter;
    reg [7:0] pixels_to_draw;
    
    genvar i, j, k;
    
    // The bit map comes out flipped accross the x-axis
    BITMAP_ROM ROM (
          .clka(clk),    // input wire clka
          .addra(letter),  // input wire [6 : 0] addra
          .douta(rev_bit_map)  // output wire [127 : 0] douta
    );
    
    // Since it is flipped, we need to flip it back
    for(k = 0; k < 128; k = k + 1)
    begin
       assign bit_map[k] = rev_bit_map[127-k]; 
    end
    
    for(i = 0; i < 16; i = i + 1)
    begin
        assign bit_map_arr[i] = bit_map[(i*8+7):(i*8)];
    end
    
    always@(x, y)
    begin
        if(
            (x >= X_OFFSET && x < X_OFFSET + 8) && 
            (y >= Y_OFFSET && y < Y_OFFSET + 16)
        ) begin
            draw_letter = 1'b1; 
            pixels_to_draw = bit_map_arr[y-Y_OFFSET];
        end
        else begin
            draw_letter = 1'b0;
        end
    end

    assign draw_flag = draw_en ? draw_letter : 1'b0;
    assign color = COLOR & {12{draw_letter & draw_en & pixels_to_draw[x-X_OFFSET]}};
//    assign color = COLOR & {12{bit_map_arr[y][x]}};

endmodule

/**
 *  Draws a rectangle. Modify parameters to change size, shape, color, ect
 */
module RECTANGLE #(
    parameter WIDTH = 100,
    parameter HEIGHT = WIDTH,
    parameter BORDER_SIZE = 2,
    parameter COLOR = `WHITE,
    parameter X_OFFSET = 100,
    parameter Y_OFFSET = X_OFFSET,
    parameter X_BIT_SIZE = 10,
    parameter Y_BIT_SIZE = 9
)(
    input draw_en,
    input [X_BIT_SIZE-1:0] x,
    input [Y_BIT_SIZE-1:0] y,
    output draw_flag,
    output [11:0] color
);

    reg draw_shape;
    
    always@(x,y)
    begin
        if( (x >= X_OFFSET && x < X_OFFSET + WIDTH) &&
            (y >= Y_OFFSET && y < Y_OFFSET + HEIGHT)
        ) begin
            draw_shape = 1'b1;
        end
        else begin
            draw_shape = 1'b0;
        end
    end

    assign draw_flag = draw_en ? draw_shape : 1'b0;
    assign color = COLOR & {12{draw_shape & draw_en}};

endmodule


/**
 *  Draws a line. Change parameters to modify the line
 */
module LINE #(
    parameter DIR = `HORZ,
    parameter LENGTH = 100,
    parameter THICKNESS = 2,
    parameter COLOR = `WHITE,
    parameter X_OFFSET = 100,
    parameter Y_OFFSET = X_OFFSET,
    parameter X_BIT_SIZE = 10,
    parameter Y_BIT_SIZE = 9
) (
    input draw_en,
    input [X_BIT_SIZE-1:0] x,
    input [Y_BIT_SIZE-1:0] y,
    output draw_flag,
    output [11:0] color
);
    
    reg draw_shape;
    
    always@(x, y) begin
        if(DIR == `HORZ) begin
            if( (x >= X_OFFSET && x < X_OFFSET + LENGTH) &&
                (y >= Y_OFFSET && y < Y_OFFSET + THICKNESS)
            ) begin
                draw_shape = 1'b1;
            end
            else begin
                draw_shape = 1'b0;
            end
        end
        else begin
            if( (x >= X_OFFSET && x < X_OFFSET + THICKNESS) &&
                (y >= Y_OFFSET && y < Y_OFFSET + LENGTH)
            ) begin
                draw_shape = 1'b1;
            end
            else begin
                draw_shape = 1'b0;
            end
        end
    end
    
    assign draw_flag = draw_en ? draw_shape : 1'b0;
    assign color = COLOR & {12{draw_shape & draw_en}};
    
endmodule

