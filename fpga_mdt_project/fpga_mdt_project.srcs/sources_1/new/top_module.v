`timescale 1ns / 1ps


module top_module(
    input clk,                 // Ana saat sinyali giri?i
    input reset,               // Reset anahtar?
    input [1:0] hour_buttons,  // Saat ayarlama dü?meleri
    input [1:0] min_buttons,   // Dakika ayarlama dü?meleri
    input [5:0] sec_switches,  // Saniye ayarlama anahtarlar?
    input pause_button,        // Duraklatma/Devam ettirme dü?mesi
    input speed_switch,        // H?z kontrol anahtar?
    input rx,                  // UART al?c? sinyali
    output [3:0] an,           // 7-segment display anode sinyalleri
    output [6:0] seg,          // 7-segment display katot sinyalleri
    output [5:0] leds          // ?kili saniyeler için LED ç?k??lar?
);
    // ?ç sinyaller
    wire paused;
    wire [39:0] datetime;
    wire [3:0] hours, minutes;
    wire [5:0] seconds;
    wire [7:0] days, months;
    wire [15:0] years;
    wire [119:0] uart_data;
    wire uart_valid;

    // Clock divider instantiate edilir
    clock_divider clk_div (
        .clk(clk),
        .reset(reset),
        .speed_switch(speed_switch),
        .div_clk(div_clk)
    );

    // UART receiver instantiate edilir
    uart_receiver uart_rcv (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data(uart_data),
        .valid(uart_valid)
    );

    // Datetime control instantiate edilir
    datetime_control dt_ctrl (
        .clk(div_clk),
        .reset(reset),
        .hour_buttons(hour_buttons),
        .min_buttons(min_buttons),
        .sec_switches(sec_switches),
        .pause_button(pause_button),
        .uart_data(uart_data),
        .uart_valid(uart_valid),
        .datetime(datetime),
        .paused(paused)
    );

    // Extract datetime components
    assign years = datetime[39:24];
    assign months = datetime[23:20];
    assign days = datetime[19:15];
    assign hours = datetime[14:10];
    assign minutes = datetime[9:5];
    assign seconds = datetime[4:0];

    // 7-segment display module instantiate edilir
    seven_segment_display sseg (
        .clk(clk),
        .hours(hours),
        .minutes(minutes),
        .an(an),
        .seg(seg)
    );

    // LEDs for binary seconds
    assign leds = seconds;
endmodule
