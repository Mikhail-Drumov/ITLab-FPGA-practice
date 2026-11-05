add_executable(test_traffic_light test_traffic_light.cpp)
verilate(test_traffic_light
    SOURCES 
        ${CMAKE_SOURCE_DIR}/src/traffic_light_fsm.sv 
        ${CMAKE_SOURCE_DIR}/src/phase_timer.sv 
        ${CMAKE_SOURCE_DIR}/src/clk_divider.sv
        ${CMAKE_SOURCE_DIR}/src/blink_gen.sv
    TOP_MODULE traffic_light_fsm
    PREFIX Vtraffic_light_fsm
    OPTIONS "-GDIV_LIMIT_1S=20" # 1 секунду - 5 тактов (50 нс)
    TRACE
)
target_link_libraries(test_traffic_light PRIVATE GTest::gtest_main)
add_test(NAME test_traffic_light COMMAND test_traffic_light)