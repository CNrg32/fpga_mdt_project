`timescale 1ns / 1ps


module uart_receiver(
    input clk,
    input reset,
    input rx,
    output reg [119:0] data,
    output reg valid
);
    // UART al?c? mant??? burada yer alacak
    // Al?nan veriyi 'data' sinyaline atay?n ve 'valid' sinyalini yüksek yap?n
    // Al?c? mant???n? internetteki referanslardan faydalanarak ekleyebilirsiniz

    // ?çeride kullan?lan registerlar ve sinyaller
    reg [3:0] bit_count;
    reg [7:0] byte_data;
    reg [3:0] byte_count;
    reg [119:0] temp_data;
    reg receiving;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data <= 120'b0;
            valid <= 0;
            bit_count <= 4'b0;
            byte_data <= 8'b0;
            byte_count <= 4'b0;
            temp_data <= 120'b0;
            receiving <= 0;
        end else begin
            // UART veri alma mant??? burada olacak
            if (rx == 0 && !receiving) begin
                receiving <= 1;
                bit_count <= 0;
                byte_data <= 0;
                byte_count <= 0;
            end

            if (receiving) begin
                if (bit_count < 8) begin
                    byte_data[bit_count] <= rx;
                    bit_count <= bit_count + 1;
                end else begin
                    bit_count <= 0;
                    temp_data <= {temp_data[111:0], byte_data};  // En yeni byte'? temp_data'ya ekle
                    byte_count <= byte_count + 1;
                end

                if (byte_count == 15) begin
                    data <= temp_data;
                    valid <= 1;
                    receiving <= 0;
                end else begin
                    valid <= 0;
                end
            end
        end
    end
endmodule
