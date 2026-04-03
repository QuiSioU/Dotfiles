cmake_minimum_required(VERSION 3.20)
project(ElyseanShell)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick DBus)

qt_add_library(elyseanshell-services SHARED)

qt_add_qml_module(elyseanshell-services
    URI ElyseanShell.Services
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/ElyseanShell/Services
    SOURCES
        services/Bluetooth.cpp
        services/Bluetooth.hpp
)

target_include_directories(elyseanshell-services PRIVATE
    ${CMAKE_SOURCE_DIR}/services
)

target_link_libraries(elyseanshell-services PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::DBus
)
