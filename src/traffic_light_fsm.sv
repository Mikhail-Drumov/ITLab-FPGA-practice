module traffic_light_fsm #(parameter DIV_LIMIT_1S = 50_000_000) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       btn_ped,
    output logic [2:0] cars_lights, // {RED, YELLOW, GREEN}
    output logic [1:0] ped_lights,  // {RED, GREEN}
    output logic [3:0] time_left,
    output logic [1:0] fsm_state
);

   
    typedef enum logic [1:0] {
        S_CARS   = 2'b00,
        S_CHANGE = 2'b01,
        S_PED    = 2'b10
    } state_t;
    
    state_t current_state, next_state;

    logic       cars_done;
    logic       change_done;
    logic       ped_done;
    
    logic [3:0] timer_cars;
    logic [3:0] timer_change;
    logic [3:0] timer_ped;
    
    logic       rst_ped_timer;
    logic       rst_change_timer;
    logic       rst_cars_timer;
    
    logic       blink;

    // cars timer
    phase_timer #(.SECONDS(12), .DIV_LIMIT_1S(DIV_LIMIT_1S)) timer_cars_inst (
        .clk(clk),
        .rst_n(rst_cars_timer & rst_n),
        .timer_done(cars_done),
        .time_left(timer_cars)
    );

    // switch timer
    phase_timer #(.SECONDS(3), .DIV_LIMIT_1S(DIV_LIMIT_1S)) timer_change_inst (
        .clk(clk),
        .rst_n(rst_change_timer & rst_n),
        .timer_done(change_done),
        .time_left(timer_change)
    );

    // ped timer
    phase_timer #(.SECONDS(10), .DIV_LIMIT_1S(DIV_LIMIT_1S)) timer_ped_inst (
        .clk(clk),
        .rst_n(rst_ped_timer & rst_n),
        .timer_done(ped_done),
        .time_left(timer_ped)
    );

    blink_gen #(.HALF_PERIOD(DIV_LIMIT_1S / 4)) blink_inst (
        .clk(clk),
        .rst_n(rst_n),
        .blink(blink)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S_CARS;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = current_state;
        
        case (current_state)
            S_CARS:
                if (btn_ped || cars_done) 
                    next_state = S_CHANGE;
            S_CHANGE:
                if (change_done)
                    next_state = S_PED;
            S_PED:
                if (ped_done)
                    next_state = S_CARS;
            default: next_state = S_CARS;
        endcase
    end

    always_comb begin
        cars_lights = 3'b000; // {RED, YELLOW, GREEN}
        ped_lights  = 2'b00;  // {RED, GREEN}
        time_left   = 4'd0;
        fsm_state   = current_state;     
        
		  /* verilator lint_off CASEINCOMPLETE */
        case (current_state)
            S_CARS: begin
                cars_lights = 3'b001; // GREEN
                ped_lights  = 2'b10;  // RED
                time_left   = timer_cars + 3;
            end
            
            S_CHANGE: begin
                cars_lights = {1'b0, blink, 1'b0}; // blink YELLOW
                ped_lights  = 2'b10;               // RED
                time_left   = timer_change;
            end
            
            S_PED: begin
                cars_lights = 3'b100; // RED
                ped_lights  = 2'b01;  // GREEN
                time_left   = timer_ped;
            end
        endcase
		  /* verilator lint_on CASEINCOMPLETE */
    end
    
    assign rst_cars_timer   = ~(current_state != S_CARS);
    assign rst_change_timer = ~(current_state != S_CHANGE);
    assign rst_ped_timer    = ~(current_state != S_PED);

endmodule