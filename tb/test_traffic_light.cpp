#include <gtest/gtest.h>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtraffic_light_fsm.h"

class TrafficLightTest : public ::testing::Test {
protected:
    std::unique_ptr<Vtraffic_light_fsm> dut;
    std::unique_ptr<VerilatedVcdC> trace;
    vluint64_t sim_time;

    void SetUp() override {
        dut = std::make_unique<Vtraffic_light_fsm>();
        trace = std::make_unique<VerilatedVcdC>();
        Verilated::traceEverOn(true);
        
        const ::testing::TestInfo* const test_info = ::testing::UnitTest::GetInstance()->current_test_info();
        std::string vcd_name = std::string("dump_") + test_info->name() + ".vcd";
        dut->trace(trace.get(), 99);
        trace->open(vcd_name.c_str());
        
        // Инициализация входов
        dut->clk = 0;
        dut->rst_n = 0; // Активный сброс
        dut->btn_ped = 0;
        sim_time = 0;
    }

    void TearDown() override {
        trace->close();
    }

    // Симуляция одного такта
    void tick() {
        dut->clk = 0; dut->eval(); trace->dump(sim_time++);
        dut->clk = 1; dut->eval(); trace->dump(sim_time++);
    }

    // Нажатие кнопки пешехода
    void press_btn() {
        dut->btn_ped = 1;
        tick();
        tick();
        dut->btn_ped = 0;
    }
};

// ТЕСТ 1: Проверка базового цикла (Зеленый -> Желтый -> Пешеходам зеленый)
TEST_F(TrafficLightTest, BaseSequence) {
    // Снимаем сброс
    dut->rst_n = 1;
    tick();

    // 1. Проверяем, что стартовали с состояния CARS (0) и зеленого света
    EXPECT_EQ(dut->fsm_state, 0) << "Did not start in CARS state";
    EXPECT_EQ(dut->cars_lights, 0b001) << "Cars light is not GREEN";

    // Ждем, пока таймер автомобилей закончится (переход в CHANGE)
    int timeout = 1000; // Защита от зависания
    while (dut->fsm_state == 0 && timeout > 0) {
        tick();
        timeout--;
    }
    ASSERT_EQ(dut->fsm_state, 1) << "Timeout waiting for CHANGE state";

    // 2. Проверяем состояние CHANGE (желтый мигает)
    // Ждем 2 такта, чтобы увидеть мигание
    tick(); tick(); 
    EXPECT_TRUE(dut->cars_lights == 0b010 || dut->cars_lights == 0b000) 
        << "Yellow light should be active or blinking";

    // Ждем перехода в состояние PED
    timeout = 1000;
    while (dut->fsm_state == 1 && timeout > 0) {
        tick();
        timeout--;
    }
    ASSERT_EQ(dut->fsm_state, 2) << "Timeout waiting for PED state";

    // 3. Проверяем состояние PED
    EXPECT_EQ(dut->cars_lights, 0b100) << "Cars light is not RED";
    EXPECT_EQ(dut->ped_lights, 0b01)  << "Pedestrian light is not GREEN";

    // Ждем возврата в состояние CARS
    timeout = 1000;
    while (dut->fsm_state == 2 && timeout > 0) {
        tick();
        timeout--;
    }
    EXPECT_EQ(dut->fsm_state, 0) << "Did not return to CARS state";
}

// ТЕСТ 2: Проверка кнопки пешехода
TEST_F(TrafficLightTest, PedestrianButton) {
    // Снимаем сброс
    dut->rst_n = 1;
    tick();

    // Прокрутим несколько тактов, чтобы таймер ушел вперед
    for (int i = 0; i < 20; i++) tick();
    ASSERT_EQ(dut->fsm_state, 0) << "Should still be in CARS state";

    // Нажимаем кнопку
    press_btn();
    tick(); // Даем автомату время среагировать

    // Ожидаем, что автомат немедленно перескочит в CHANGE
    EXPECT_EQ(dut->fsm_state, 1) << "Button press did not trigger immediate transition to CHANGE";
}