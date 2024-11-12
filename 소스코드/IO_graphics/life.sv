`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/07 19:42:50
// Design Name: 
// Module Name: life
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


module life(
    input wire [11:0] i_x,
    input wire [11:0] i_y,
    input wire pix_clk,

    input wire miss,

    output reg [7:0] o_red,
    output reg [7:0] o_green,
    output reg [7:0] o_blue,
    output reg o_life_hit,
    output reg [1:0] life
    );
    
    reg [11:0] sprite_x     = 10'd1000;
    reg [11:0] sprite_y     = 10'd500;
    wire sprite_hit_x, sprite_hit_y;
    wire [3:0] sprite_render_x;
    wire [3:0] sprite_render_y;
    reg [1:0] life_r =3;
    //reg play; 
   
    localparam [0:3][2:0][7:0] palette_colors =  {
        8'h00, 8'h00, 8'h00,
        8'hFF, 8'h00, 8'h00,
        8'hFF, 8'hFF, 8'hFF,
        8'h21, 8'h21, 8'hFF
    };
   
    localparam [0:15][0:15][3:0] life_data_0 = {
   //0
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0
   };
   localparam [0:15][0:15][3:0] life_data_1 = {     //1
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0
    };
    localparam [0:15][0:15][3:0] life_data_2 = {     
    //2
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0
   };
   
   
    localparam [0:15][0:15][3:0] life_data_3 = {     
    //3
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd0,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0,
       4'd0,4'd0,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd1,4'd0,4'd0
   };

    assign sprite_hit_x = (i_x >= sprite_x) && (i_x < sprite_x + 64);
    assign sprite_hit_y = (i_y >= sprite_y) && (i_y < sprite_y + 64);
    assign sprite_render_x = (i_x - sprite_x)>>2;
    assign sprite_render_y = (i_y - sprite_y)>>2;


    reg [1:0] selected_palette;

    assign o_life_hit = (sprite_hit_y & sprite_hit_x) && (selected_palette != 2'd0);
    assign o_red = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][2] : 8'hXX;
    assign o_green = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][1] : 8'hXX;
    assign o_blue = (sprite_hit_x && sprite_hit_y) ? palette_colors[selected_palette][0] : 8'hXX;
    
    
   
    
    always@(*) begin
        case(life_r)   
            2 : begin
                selected_palette <= life_data_2[sprite_render_y][sprite_render_x];
            end
        
            1 : begin
                selected_palette <= life_data_1[sprite_render_y][sprite_render_x];
            end
       
            0: begin
                 selected_palette <= life_data_0[sprite_render_y][sprite_render_x];
            end
            //초기 상태는 life ==3 
            default: begin
                selected_palette <= life_data_3[sprite_render_y][sprite_render_x];
            end 
       endcase 
       
    end 
    
    always@(posedge pix_clk) begin
       if(miss) begin
           life_r <= life_r-1;
       end
    end
    
    assign life = life_r;
     
endmodule
