`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/07 20:12:52
// Design Name: 
// Module Name: note
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


module note(
    input wire [11:0] i_x,
    input wire [11:0] i_y,
    input wire pix_clk,
    input wire trigger_note,
    input wire touch,
    
    output reg [7:0] o_red,
    output reg [7:0] o_green,
    output reg [7:0] o_blue,
    output wire o_note_hit,
    output reg miss,
    output reg meet_note
    );
    
    reg [11:0] sprite_x     = 12'd600;
    reg [11:0] sprite_y     = 12'd1000; 
    
    reg sprite_hit_x, sprite_hit_y;
    reg [9:0] sprite_render_x;
    reg [9:0] sprite_render_y;
    

    localparam [0:3][2:0][7:0] palette_colors =  {
        8'h00, 8'h00, 8'h00,
        8'hFF, 8'h00, 8'h00,
        8'hFF, 8'hFF, 8'hFF,
        8'h21, 8'h21, 8'hFF
    };
   
    localparam [0:15][0:15][3:0] sprite_data = {
        4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
        4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,
        4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
        4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,
        4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,
        4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
        4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
        4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
        4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
        4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
        4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,
        4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,
        4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,
        4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
        4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,
        4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0
    };   
    
    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + 64);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 64);
    assign sprite_render_x = (i_x - sprite_x)>>2;
    assign sprite_render_y = (i_y - sprite_y)>>2;

    reg [1:0] selected_palette;

    assign selected_palette = sprite_data[sprite_render_y][sprite_render_x];
                                                                         
    assign o_red    = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][2] : 8'hXX;
    assign o_green  = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][1] : 8'hXX;
    assign o_blue   = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][0] : 8'hXX;
    assign o_note_hit = (sprite_hit_y & sprite_hit_x) && (selected_palette != 2'd0);
   

    always@(posedge pix_clk) begin
        if(trigger_note) begin
            sprite_x<=12'd600;
            sprite_y<=12'd0;
        end
        else begin
            if(sprite_y <900 && (i_x>1279 && i_x <1289) && i_y==719) begin
	           sprite_y <= sprite_y + 1;
	        end
        end
        
        if(touch && (sprite_y > 534) && (sprite_y < 611)) begin
            meet_note <= 1;
            sprite_y <=1000;
        end 
        else begin
            meet_note <= 0;
        end
        
        if (sprite_y == 675) begin
            miss <=1;
            sprite_y <= 1000;
        end
        else begin
            miss <= 0;
        end
    end
    
endmodule
