# quickshell/CMakeLists.txt


cmake_minimum_required(VERSION 3.20)
project(ElysianShell)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")

find_package(Qt6 REQUIRED COMPONENTS Core Quick DBus ShaderTools)

add_subdirectory(modules/Blobs)
add_subdirectory(modules/Services)
add_subdirectory(modules/Themes)
