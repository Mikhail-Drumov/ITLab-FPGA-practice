module traffic_light_top (
    input  logic       CLOCK_50,
    input  logic [1:0] KEY,      // KEY[0] - reset, KEY[1] - btn_ped
    output logic [2:0] LEDR,     // {RED, YELLOW, GREEN}
    output logic [1:0] LEDG,     // {PED_RED, PED_GREEN}
    output logic [6:0] HEX0,     //  1s secs
    output logic [6:0] HEX1      // 10s secs
);

    logic [2:0] cars_lights;
    logic [1:0] ped_lights;
    logic [3:0] time_left;
    logic [1:0] fsm_state;

    logic rst_n;
    logic btn_ped;
    
    assign rst_n = KEY[0];
    assign btn_ped = ~KEY[1];

    traffic_light_fsm fsm_inst (
        .clk        (CLOCK_50),
        .rst_n      (rst_n),
        .btn_ped    (btn_ped),
        .cars_lights(cars_lights),
        .ped_lights (ped_lights),
        .time_left  (time_left),
        .fsm_state  (fsm_state)
    );

    assign LEDR = cars_lights;
    assign LEDG = ped_lights;

    logic [3:0] seconds_tens;
    logic [3:0] seconds_ones;

    assign seconds_tens = time_left / 10;
    assign seconds_ones = time_left % 10;

    hex7seg_decoder hex0_inst (
        .dec(seconds_ones),
        .seg(HEX0)
    );

    hex7seg_decoder hex1_inst (
        .dec(seconds_tens),
        .seg(HEX1)
    );

endmodule