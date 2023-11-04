// NOTE: In this 2nd version, inputs/outputs match the ones from Step 7 in the chip submission manual.
module tt_um_seanvenadas (
    input wire [7:0] ui_in,  // Merge inputs into ui_in
    output wire [7:0] uo_out,  // Merge outputs into uo_out
    input wire [7:0] uio_in,  // Merge outputs into uio_in
    output wire [7:0] uio_out,  // Merge outputs into uio_out
    output wire [7:0] uio_oe,  // Merge outputs into uio_oe
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

assign uio_out = 8'b00000000; // Didn't use
assign uio_oe = 8'b00000000; //

reg [7:0] uo_out_temp;
wire [7:0] unused;
    assign unused = {7'b0000000, ena} & uio_in;

parameter WINDOW_SIZE = 4;  // Choose the size of the moving average window

reg [1:0] x_reg [0:WINDOW_SIZE-1];
reg [1:0] y_reg [0:WINDOW_SIZE-1];
reg [1:0] t_reg [0:WINDOW_SIZE-1];
reg [1:0] sum_x;
reg [1:0] sum_y;
reg [1:0] sum_t;
reg [3:0] count;

always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        for (int i = 0; i < WINDOW_SIZE; i = i + 1) begin
            x_reg[i] = 2'b00;
            y_reg[i] = 2'b00;
            t_reg[i] = 2'b00;
        end
        sum_x <= 2'b00;
        sum_y <= 2'b00;
        sum_t <= 2'b00;
        count <= 4'b0000;
    end else begin
        // Shift input data into the shift registers
        for (int i = 0; i < WINDOW_SIZE - 1; i = i + 1) begin
            x_reg[i] <= x_reg[i + 1];
            y_reg[i] <= y_reg[i + 1];
            t_reg[i] <= t_reg[i + 1];
        end
        x_reg[WINDOW_SIZE - 1] <= ui_in[1:0];  // Extract x from ui_in
        y_reg[WINDOW_SIZE - 1] <= ui_in[3:2];  // Extract y from ui_in
        t_reg[WINDOW_SIZE - 1] <= ui_in[5:4];  // Extract t from ui_in

        // Calculate the sum of the window for each signal
        sum_x <= sum_x + ui_in[1:0] - x_reg[0];  // Extract x from ui_in
        sum_y <= sum_y + ui_in[3:2] - y_reg[0];  // Extract y from ui_in
        sum_t <= sum_t + ui_in[5:4] - t_reg[0];  // Extract t from ui_in

        // Increment the count, making sure it doesn't exceed the window size
        if (count < WINDOW_SIZE)
            count <= count + 1;
    end
end

always @* begin
    // Only output non-zero values if 'p' is high
    if (ui_in[7:6] == 2'b11) begin  // Extract p from ui_in
        uo_out_temp[1:0] = (count == 4'b0000) ? 2'b00 : sum_x;
        uo_out_temp[3:2] = (count == 4'b0000) ? 2'b00 : sum_y;
        uo_out_temp[5:4] = (count == 4'b0000) ? 2'b00 : sum_t;
        uo_out_temp[7:6] = 2'b00;  // Set the unused bits to '00'
    end else begin
        // 'p' is not high, so output zeros
        uo_out_temp[7:0] = 8'b00000000 & unused;
    end
end

assign uo_out = uo_out_temp;

endmodule
