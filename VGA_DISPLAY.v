`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2021 10:16:27 AM
// Design Name: 
// Module Name: VGA_DISPLAY
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


module VGA_DISPLAY (
    input clk,
    input reset,
    output v_sync, h_sync, /*horizontal and vertical sync*/
    output [9:0] x,
    output [8:0] y
);

    reg [15:0] cnt;
    reg pix_strobe;
    
    VGA_DRIVER U1(
        .clk(clk), 
        .pix_strobe(pix_strobe), 
        .reset(reset), 
        .h_sync(h_sync), 
        .v_sync(v_sync), 
        .x(x), 
        .y(y),
        .active(), 
        .screenend(), 
        .animate(), 
        .blanking()
    );
    
    always@(posedge clk, posedge reset)
    begin
        if(reset)
            {pix_strobe, cnt} <= 16'd0 + 16'h4000;
        else
            {pix_strobe, cnt} <= cnt + 16'h4000;
    end
    

endmodule

module VGA_DRIVER (
    input clk/*base clk*/, pix_strobe/*pixel clk strobe*/,  
    input reset/*reset: restarts frame*/,
    output h_sync/*horizontal sync*/, v_sync/*vertical sync*/,
    output blanking/*high during blanking interval*/,
    output active/*high during active pixel drawing*/,
    output screenend/*high for one tick at the end of screen*/,
    output animate/*high for one tick at end of active drawing*/,
    output [9:0]x/*current pixel x position*/, 
    output [8:0]y/*current pixel y position*/
    );
    
    localparam HS_STA = 16; //horizontal sync start
    localparam HS_END = 16 + 96; //horizontal sync end
    localparam HA_STA = 16 + 96 + 48; // horizontal active pixel
    localparam VS_STA = 480 + 10; //vertical active start
    localparam VS_END = 480 + 10 + 2; //vertical sync end
    localparam VA_END = 480; //vertical active pixel end
    localparam LINE = 800; //complete line (pixels)
    localparam SCREEN = 525; //complete screen (lines)
    
    reg [9:0] h_count; //line position
    reg [9:0] v_count; //screen position
    
    //generate sync signals (active low for 640x480)
    assign h_sync = ~((h_count >= HS_STA) & (h_count < HS_END));
    assign v_sync = ~((v_count >= VS_STA) & (v_count < VS_END));
    
    //keep x and y bound within the blanking period
    assign x = (h_count < HA_STA) ? 0 : (h_count - HA_STA);
    assign y = (v_count >= VA_END) ? (VA_END - 1) : (v_count);
    
    //blanking: high within the blanking period
    assign blanking = ((h_count < HA_STA) | (v_count > VA_END - 1));
    
    //active: high during active pixel drawing
    assign active = ~((h_count < HA_STA) | (v_count > VA_END - 1));
    
    //screenend: high for one tick at the end of the screen
    assign screenend = ((v_count == SCREEN - 1) & (h_count == LINE));
    
    //animate: high for one tick at the end of the final active pixel line
    assign animate = ((v_count == VA_END - 1) & (h_count == LINE));
   
    always@(posedge clk)
    begin
        if (reset) //reset to start of frame
        begin
            h_count <= 10'h000;
            v_count <= 10'h000;
        end
        if (pix_strobe) //once per pixel
        begin
            if (h_count == LINE) //end of line
            begin
                h_count <= 0;
                v_count <= v_count + 1;
            end
            else
                h_count <= h_count + 1;
            
            if (v_count == SCREEN) //end of screen
                v_count <= 0;
        end
    end
endmodule
