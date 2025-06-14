module PWM_Control #(
    parameter CLK_FREQ = 25_000_000,
    parameter PWM_FREQ = 1_250
) (
    input  wire clk,
    input  wire rst_n,
    output wire [7:0] leds
);
    // Cálculo do período do PWM
    localparam [15:0] PWM_CLK_PERIOD = CLK_FREQ / PWM_FREQ;

    // Duty cycle inicial (em porcentagem)
    localparam integer PWM_DUTY_CYCLE = 2; // começa com 2% do período

    // Constantes de tempo
    localparam integer SECOND         = CLK_FREQ;
    localparam integer HALF_SECOND    = SECOND / 2;
    localparam integer QUARTER_SECOND = SECOND / 4;
    localparam integer EIGHTH_SECOND  = SECOND / 8;

    // Registradores internos
    reg [15:0] duty_cycle;
    reg        dir; // 1 = sobe, 0 = desce
    reg [23:0] fade_counter;
    wire       pwm_out;

    // Lógica de controle do fade
    always @(posedge clk) begin
        if (!rst_n) begin
            duty_cycle   <= (PWM_CLK_PERIOD * PWM_DUTY_CYCLE) / 100;
            dir          <= 1;
            fade_counter <= 0;
        end else begin
            fade_counter <= fade_counter + 1;

            if (fade_counter == QUARTER_SECOND) begin
                fade_counter <= 0;

                if (dir)
                    duty_cycle <= duty_cycle + 1;
                else
                    duty_cycle <= duty_cycle - 1;

                if (duty_cycle >= (PWM_CLK_PERIOD * 70) / 100)
                    dir <= 0;
                else if (duty_cycle <= 1)
                    dir <= 1;
            end
        end
    end

    // Instancia o gerador PWM
    PWM pwm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty_cycle),
        .period(PWM_CLK_PERIOD[15:0]),  // cast explícito para 16 bits
        .pwm_out(pwm_out)
    );

    // LEDs controlados pelo PWM
    assign leds = {8{pwm_out}};

endmodule
