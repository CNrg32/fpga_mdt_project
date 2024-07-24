`timescale 1ns / 1ps


module clock_divider(
    input clk,
    input reset,
    input speed_switch,
    output reg div_clk
);
    reg [25:0] counter;
    wire [25:0] threshold;

    assign threshold = speed_switch ? 26'd5000000 : 26'd50000000;  // H?za göre e?ik de?eri

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            div_clk <= 0;
        end else if (counter == threshold) begin
            counter <= 0;
            div_clk <= ~div_clk;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule
