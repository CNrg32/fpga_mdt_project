`timescale 1ns / 1ps

module seven_segment_display(
    input clk,
    input [3:0] hours,
    input [3:0] minutes,
    output reg [3:0] an,
    output reg [6:0] seg
);
    reg [1:0] digit_select;
    reg [3:0] current_digit;

    always @(posedge clk) begin
        digit_select <= digit_select + 1;

        case (digit_select)
            2'b00: begin
                an <= 4'b1110;
                current_digit <= hours[3:0];
            end
            2'b01: begin
                an <= 4'b1101;
                current_digit <= hours[7:4];
            end
            2'b10: begin
                an <= 4'b1011;
                current_digit <= minutes[3:0];
            end
            2'b11: begin
                an <= 4'b0111;
                current_digit <= minutes[7:4];
            end
        endcase
    end

    always @(*) begin
        case (current_digit)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end
endmodule

