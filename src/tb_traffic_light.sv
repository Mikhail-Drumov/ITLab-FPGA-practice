`timescale 1ns/1ps

module tb_traffic_light;

    // Сигналы
    logic       clk;
    logic       rst_n;
    logic       btn_ped;
    logic [2:0] cars_lights;
    logic [1:0] ped_lights;
    logic [3:0] time_left;
    logic [1:0] fsm_state;

    // Параметр для ускорения симуляции: 1 "секунда" = 5 тактов клока
    localparam int DIV_LIMIT_1S = 5;

    // Инстанцирование автомата с параметром
    traffic_light_fsm #(
        .DIV_LIMIT_1S(DIV_LIMIT_1S)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .btn_ped(btn_ped),
        .cars_lights(cars_lights),
        .ped_lights(ped_lights),
        .time_left(time_left),
        .fsm_state(fsm_state)
    );

    // Генератор клока (период 10 нс)
    always #5 clk = ~clk;

    // Задача для нажатия кнопки
    task press_btn();
        btn_ped = 1;
        #20; // Держим нажатой 20 нс
        btn_ped = 0;
        #20; // Отпускаем
    endtask

    initial begin
        // Инициализация
        clk = 0;
        rst_n = 0;
        btn_ped = 0;

        // Дамп-файл для GTKWave / Surfer
        $dumpfile("tb_traffic_light.vcd");
        $dumpvars(0, tb_traffic_light);

        // Мониторинг изменений
        $monitor("Time=%0t | rst_n=%b | State=%0d | Cars=%b | Ped=%b | TimeLeft=%0d", 
                 $time, rst_n, fsm_state, cars_lights, ped_lights, time_left);

        // 1. Сброс схемы
        #25 rst_n = 1;
        #10;

        $display("\n=== TEST 1: Base mode (Green -> Yellow -> Ped Green) ===");
        
        // Ждем, пока не закончится фаза GREEN (12 секунд)
        // В нашем случае 1 секунда = 5 * 10 нс = 50 нс. 12 секунд = 600 нс.
        wait(fsm_state == 2'b01); // Ждем перехода в CHANGE
        $display("-> Transitioned to CHANGE (Yellow). Cars=%b, Ped=%b", cars_lights, ped_lights);
        
        // Проверяем, что желтый мигает (в какой-то момент времени он 0, в какой-то 1)
        #100; 
        
        wait(fsm_state == 2'b10); // Ждем перехода в PED
        $display("-> Transitioned to PED (Red/Green). Cars=%b, Ped=%b", cars_lights, ped_lights);
        if (cars_lights !== 3'b100) $error("Cars light is not RED in PED state!");
        if (ped_lights !== 2'b01)   $error("Ped light is not GREEN in PED state!");

        // Ждем возврата в CARS
        wait(fsm_state == 2'b00);
        $display("-> Returned to CARS (Green).");

        $display("\n=== TEST 2: Pedestrian button press ===");
        // Ждем немного, чтобы таймер ушел вперед
        #150; 
        
        $display("-> Pressing pedestrian button...");
        press_btn();

        // После нажатия кнопки автомат должен перейти в CHANGE (пропустив оставшееся время)
        #10;
        if (fsm_state !== 2'b01) $error("Button press did not trigger CHANGE state!");
        else $display("-> Button press triggered immediate transition to CHANGE. OK!");

        // Завершаем симуляцию
        #500;
        $display("\n=== All tests finished ===");
        $finish;
    end

endmodule