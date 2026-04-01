cmake_minimum_required(VERSION 3.20)
project(ElyseanShell)

find_package(Qt6 REQUIRED COMPONENTS Core Quick)
find_package(Quickshell REQUIRED)

qt_add_executable(elyseanshell main.cpp)

# target_sources(elyseanshell PRIVATE
#     services/AudioService.cpp
#     services/HyprlandIpc.cpp
#     services/BatteryService.cpp
# )

quickshell_target(elyseanshell
    MAIN shell.qml
    QML_DIRS widgets themes utils
)

target_link_libraries(elyseanshell PRIVATE Qt6::Core Qt6::Quick)
