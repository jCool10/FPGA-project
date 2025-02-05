`timescale 1ns / 1ps

module top(
    input clk_100MHz,       // from Basys 3
    input reset,            // btnC on Basys 3
    input BtnU, BtnL, BtnD, BtnR,  
    output hsync,           // to VGA connector
    output vsync,           // to VGA connector
    output [11:0] rgb       // to DAC, 3 RGB bits to VGA connector
    );
    parameter X_DELTA_INIT = 10'd2, Y_DELTA_INIT = 10'd2;
    
    wire w_video_on, w_p_tick, w_refresh_tick, clk_1Hz;
    wire [9:0] w_x, w_y;
    
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    reg [5:0] num_sq;
    wire [5:0] num_sq_next;
    
    reg status;
    wire status_next;
    
    reg [15:0] score;
    wire [15:0] score_next;
    
    reg [659:0] position;
    wire [19:0] sq_next;
    wire [639:0] position_next;
    
    clock_generator cg(.clk(clk_100MHz), .reset(reset), .clk_1Hz(clk_1Hz));
    vga_controller vc(.clk_100MHz(clk_100MHz), .reset(reset), .video_on(w_video_on), 
                      .hsync(hsync), .vsync(vsync), 
                      .p_tick(w_p_tick), .refresh_tick(w_refresh_tick),
                      .x(w_x), .y(w_y));
    square_controller sc(.clk(clk_100MHz), .reset(reset), 
                         .btnU(BtnU), .btnL(BtnL), .btnD(BtnD), .btnR(BtnR), .status(status),
                         .refresh_tick(w_refresh_tick), .position(position[659:640]), 
                         .position_next(sq_next));
    random_square rs(.clk(clk_100MHz), .reset(reset), .refresh_tick(w_refresh_tick),
                     .status(status), .num_squares(num_sq), .position(position[639:0]), 
                     .position_next(position_next));
    game_status gs(.clk(clk_100MHz), .reset(reset), .clk_1Hz(clk_1Hz),
                   .refresh_tick(w_refresh_tick), .position(position),
                   .status(status_next), .num_squares(num_sq_next), .score(score_next));
    pixel_generation pg(.clk(clk_100MHz), .reset(reset), 
                        .x(w_x), .y(w_y), /* .status(status), */ 
                        .video_on(w_video_on), .position(position),
                        .rgb(rgb_next));
    
    
////    generate
//    genvar i;
//        for (i = 0; i < 16; i = i + 1) begin : init_position
//            always @(posedge clk_100MHz or posedge reset) begin
//                if (reset) begin
//                    position[i * 40 + 39: i * 40] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, i * 40};
//                end
//            end
//        end
////    endgenerate
    
    always @(posedge clk_100MHz or posedge reset) begin
        if(reset) begin
            status <= 1;
            score <= 0;
//            position[659:640] <= {10'd220, 10'd300};  
//            position[639:600] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd600}; 
//            position[599:560] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd560};
//            position[559:520] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd520};
//            position[519:480] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd480};
//            position[479:440] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd440};
//            position[439:400] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd400};
//            position[399:360] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd360};
//            position[359:320] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd320};
//            position[319:280] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd280};
//            position[279:240] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd240};
//            position[239:200] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd200};
//            position[199:160] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd160};
//            position[159:120] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd120};
//            position[119:80] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd80};
//            position[79:40] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd40};
//            position[39:0] <= { Y_DELTA_INIT, X_DELTA_INIT, 10'd0, 10'd0};
        end
        else if(w_p_tick) begin
            rgb_reg <= rgb_next;
//        end
//        if(w_refresh_tick) begin
            position[659:640] <= sq_next;
            position[639:0] <= position_next;
            status <= status_next;
            score <= score_next;
            num_sq = num_sq_next;
        end
    end 
            
    assign rgb = rgb_reg;
    
endmodule