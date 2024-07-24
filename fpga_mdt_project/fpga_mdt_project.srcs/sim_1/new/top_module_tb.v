`timescale 1ns / 1ps

module top_module_tb;

    // Testbench sinyalleri
    reg clk;
    reg reset;
    reg [1:0] hour_buttons;
    reg [1:0] min_buttons;
    reg [5:0] sec_switches;
    reg pause_button;
    reg speed_switch;
    reg rx;
    wire [3:0] an;
    wire [6:0] seg;
    wire [5:0] leds;

    // top_module instantiate
    top_module uut (
        .clk(clk),
        .reset(reset),
        .hour_buttons(hour_buttons),
        .min_buttons(min_buttons),
        .sec_switches(sec_switches),
        .pause_button(pause_button),
        .speed_switch(speed_switch),
        .rx(rx),
        .an(an),
        .seg(seg),
        .leds(leds)
    );

    // Clock üretimi
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns periyot, 100MHz saat sinyali
    end

    // Test senaryolar?
    initial begin
        // Ba?lang?ç durumu
        reset = 1;
        hour_buttons = 2'b00;
        min_buttons = 2'b00;
        sec_switches = 6'b000000;
        pause_button = 0;
        speed_switch = 0;
        rx = 1;
        #10;
        reset = 0;

        // 1. Test: Saati ve dakikay? ayarla
        hour_buttons = 2'b01; // 1 saat art?r
        #10;
        hour_buttons = 2'b00;
        min_buttons = 2'b01; // 1 dakika art?r
        #10;
        min_buttons = 2'b00;

        // 2. Test: Pause ve Resume
        pause_button = 1;
        #10;
        pause_button = 0;
        #50;
        pause_button = 1;
        #10;
        pause_button = 0;

        // 3. Test: UART üzerinden tarih ve saat ayarlama
        // UART veri gönderimini simüle etme (örne?in, "K15082024153008")
        // Burada UART verisini bit bit göndermek için bir fonksiyon olu?turulabilir
        uart_send(8'h4B); // 'K'
        uart_send(8'h31); // '1'
        uart_send(8'h35); // '5'
        uart_send(8'h30); // '0'
        uart_send(8'h38); // '8'
        uart_send(8'h32); // '2'
        uart_send(8'h30); // '0'
        uart_send(8'h32); // '2'
        uart_send(8'h34); // '4'
        uart_send(8'h31); // '1'
        uart_send(8'h35); // '5'
        uart_send(8'h33); // '3'
        uart_send(8'h30); // '0'
        uart_send(8'h30); // '0'
        uart_send(8'h38); // '8'

        // Bekleme süresi
        #100;

        // Test sona erdi
        $finish;
    end

    // UART veri gönderimi
    task uart_send(input [7:0] data);
        integer i;
        begin
            // Start bit (0)
            rx = 0;
            #104167; // 9600 baud rate için bir bit süresi

            // Data bits (8 bits)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #104167; // 9600 baud rate için bir bit süresi
            end

            // Stop bit (1)
            rx = 1;
            #104167; // 9600 baud rate için bir bit süresi
        end
    endtask

endmodule
