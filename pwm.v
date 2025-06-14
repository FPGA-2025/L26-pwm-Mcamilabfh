module PWM (
    input wire clk,
    input wire rst_n, //Ativo em 0
    input wire [15:0] duty_cycle, // duty_cycle = period * duty_porcent, 0 <= duty_porcent <= 1
    input wire [15:0] period, // clk_freq / pwm_freq = period
    output reg pwm_out
);

reg [15:0] counter;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter  <= 16'd1;
        pwm_out  <= 1'b0;
    end else begin
        if (counter == period)
            counter <= 16'd1;
        else
            counter <= counter + 1;

        if (counter <= duty_cycle)
            pwm_out <= 1'b1;
        else
            pwm_out <= 1'b0;
    end
end

endmodule
