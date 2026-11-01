cmake_minimum_required(VERSION 3.20)

set(PROJECT_NAME hardware_verification)
project(${PROJECT_NAME})

set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Configs" FORCE)
set(CMAKE_CXX_STANDARD 17)

if (NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release)
endif()

find_package(verilator REQUIRED)
find_package(GTest REQUIRED)

enable_testing()

add_subdirectory(tb)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})