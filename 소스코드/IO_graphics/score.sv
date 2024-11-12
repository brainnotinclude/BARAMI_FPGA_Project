`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/07 19:01:05
// Design Name: 
// Module Name: score
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


module score(
    input wire [11:0] i_x,
    input wire [11:0] i_y,
    input wire pix_clk,
    input wire meet_note,
    input wire finish,
    
    output wire [7:0] o_red,
    output wire [7:0] o_green,
    output wire [7:0] o_blue,
    output wire o_score_hit
    );
    
    wire [7:0] score_1_red;
    wire [7:0] score_1_green;
    wire [7:0] score_1_blue;
    wire [7:0] score_10_red;
    wire [7:0] score_10_green;
    wire [7:0] score_10_blue;
    
    wire score_1_hit;
    wire score_10_hit;
    
    reg [11:0] sprite_x_1 = 12'd160;
    reg [11:0] sprite_y_1 = 12'd80;
    logic [2:0] sprite_render_ratio_1 = 3'd2;
    reg [11:0] sprite_x_10 = 12'd100;
    reg [11:0] sprite_y_10 = 12'd80;
    logic [2:0] sprite_render_ratio_10 = 3'd2;
    
    reg [7:0] score = 0;
    
    assign o_score_hit = score_10_hit | score_1_hit;
    assign o_red = score_1_hit ? score_1_red : (score_10_hit ? score_10_red : 8'hXX);
    assign o_green = score_1_hit ? score_1_green : (score_10_hit ? score_10_green : 8'hXX);
    assign o_blue = score_1_hit ? score_1_blue : (score_10_hit ? score_10_blue : 8'hXX);
    
    
    score_display_1 score_display_1 ( ///老狼 磊府 
        .i_x (i_x),
        .i_y(i_y),
        .score(score),
        .sprite_x(sprite_x_1),
        .sprite_y(sprite_y_1),
        .sprite_render_ratio(sprite_render_ratio_1),
      
        .o_red (score_1_red),
        .o_green(score_1_green),
        .o_blue(score_1_blue),
        .o_score_1_hit (score_1_hit)
    
    );
    
     score_display_10 score_display_10 ( ///老狼 磊府 
        .i_x (i_x),
        .i_y(i_y),
        .score(score),
        .sprite_x(sprite_x_10),
        .sprite_y(sprite_y_10),
        .sprite_render_ratio(sprite_render_ratio_10),

        .o_red (score_10_red),
        .o_green(score_10_green),
        .o_blue(score_10_blue),
        .o_score_10_hit (score_10_hit)
    );
    
    always@(posedge pix_clk) begin 
        if(meet_note) begin
            score <= score+1;
        end
        
        if(finish) begin
            sprite_x_1 <= 10'd680;    
            sprite_y_1 <= 10'd320;
            sprite_x_10 <= 10'd600;
            sprite_y_10 <= 10'd320;
            sprite_render_ratio_1 <= 3'd4;
            sprite_render_ratio_10 <= 3'd4;
        end
    end
    
    
endmodule
