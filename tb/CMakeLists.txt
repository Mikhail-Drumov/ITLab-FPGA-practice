#[[
add_executable(test_xxxx test_xxxx.cpp)
verilate(test_xxxx SOURCES
    ${CMAKE_SOURCE_DIR}/src/xxxx_component_1.sv
    ${CMAKE_SOURCE_DIR}/src/xxxx_component_2.sv
    ${CMAKE_SOURCE_DIR}/src/xxxx_component_3.sv
    TRACE
)
target_link_libraries(test_xxxx PRIVATE GTest::gtest_main)
add_test(NAME XxxxTest COMMAND test_xxxx)
]]