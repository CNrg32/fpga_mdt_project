`timescale 1ns / 1ps

module datetime_control(
    input clk,
    input reset,
    input [1:0] hour_buttons,
    input [1:0] min_buttons,
    input [5:0] sec_switches,
    input pause_button,
    input [119:0] uart_data,    // UART üzerinden gelen veri (15 karakter, 120 bit)
    input uart_valid,           // UART verisinin geçerli oldu?unu gösterir
    output reg [39:0] datetime, // Tarih ve saat bilgisi (Y?l, Ay, Gün, Saat, Dakika, Saniye)
    output reg paused           // Duraklatma durumu
);
    reg [39:0] initial_datetime;  // Ba?lang?ç tarihi ve saati: 30.07.2024 18:30:00

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            datetime <= initial_datetime;
            paused <= 0;
        end else if (uart_valid) begin
            // UART üzerinden gelen veriyi i?leyerek tarih ve saati ayarla
            if (uart_data[119:112] == 8'h4B) begin // 'K' karakteri kontrolü
                datetime[39:32] <= (uart_data[111:104] - 8'h30) * 10 + (uart_data[103:96] - 8'h30);
                datetime[31:28] <= (uart_data[95:88] - 8'h30) * 10 + (uart_data[87:80] - 8'h30);
                datetime[27:23] <= (uart_data[79:72] - 8'h30) * 10 + (uart_data[71:64] - 8'h30);
                datetime[22:18] <= (uart_data[63:56] - 8'h30) * 10 + (uart_data[55:48] - 8'h30);
                datetime[17:12] <= (uart_data[47:40] - 8'h30) * 10 + (uart_data[39:32] - 8'h30);
                datetime[11:6] <= (uart_data[31:24] - 8'h30) * 10 + (uart_data[23:16] - 8'h30);
                datetime[5:0] <= (uart_data[15:8] - 8'h30) * 10 + (uart_data[7:0] - 8'h30);
            end
        end else if (pause_button) begin
            paused <= ~paused;
        end else if (!paused) begin
            datetime[5:0] <= sec_switches; // Saniyeler ayarlan?r
            if (datetime[5:0] == 6'd59) begin
                datetime[5:0] <= 0;
                if (datetime[11:6] == 6'd59) begin
                    datetime[11:6] <= 0;
                    if (datetime[16:12] == 5'd23) begin
                        datetime[16:12] <= 0;
                        if (datetime[21:17] == 5'd30) begin  // 30 gün üzerinden
                            datetime[21:17] <= 1;
                            if (datetime[25:22] == 4'd12) begin
                                datetime[25:22] <= 1;
                                datetime[33:26] <= datetime[33:26] + 1;
                            end else begin
                                datetime[25:22] <= datetime[25:22] + 1;
                            end
                        end else begin
                            datetime[21:17] <= datetime[21:17] + 1;
                        end
                    end else begin
                        datetime[16:12] <= datetime[16:12] + 1;
                    end
                end else begin
                    datetime[11:6] <= datetime[11:6] + 1;
                end
            end else begin
                datetime[5:0] <= datetime[5:0] + 1;
            end
        end

        // Saat ve dakika ayarlama mant???
        if (hour_buttons[0]) begin
            if (datetime[16:12] == 5'd23) begin
                datetime[16:12] <= 0;
            end else begin
                datetime[16:12] <= datetime[16:12] + 1;
            end
        end

        if (hour_buttons[1]) begin
            if (datetime[16:12] == 5'd0) begin
                datetime[16:12] <= 5'd23;
            end else begin
                datetime[16:12] <= datetime[16:12] - 1;
            end
        end

        if (min_buttons[0]) begin
            if (datetime[11:6] == 6'd59) begin
                datetime[11:6] <= 0;
            end else begin
                datetime[11:6] <= datetime[11:6] + 1;
            end
        end

        if (min_buttons[1]) begin
            if (datetime[11:6] == 6'd0) begin
                datetime[11:6] <= 6'd59;
            end else begin
                datetime[11:6] <= datetime[11:6] - 1;
            end
        end
    end
endmodule
