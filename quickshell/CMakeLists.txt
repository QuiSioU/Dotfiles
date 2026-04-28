# quickshell/CMakeLists.txt


cmake_minimum_required(VERSION 3.20)
project(ElyseanShell)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick DBus)

# ── Single shared library that backs the ElyseanShell.Services QML module ──
#
#   services/
#     Bluetooth/          add_subdirectory → Bluetooth.hpp / .cpp
#     CursorPosition/     add_subdirectory → CursorPosition.hpp / .cpp
#     Network/            add_subdirectory → Network.hpp / .cpp
#     Notification/       QML-only — no C++, no subdirectory needed
#
qt_add_library(elyseanshell-services SHARED)
qt_add_qml_module(elyseanshell-services
    URI ElyseanShell.Services
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/ElyseanShell/Services
)

set_source_files_properties(themes/ActiveTheme.qml
    PROPERTIES
        QT_RESOURCE_ALIAS ActiveTheme.qml
        QT_QML_SINGLETON_TYPE TRUE
)

qt_add_library(elyseanshell-themes SHARED)
qt_add_qml_module(elyseanshell-themes
    URI ElyseanShell.Themes
    VERSION 1.0
    QML_FILES
        themes/ActiveTheme.qml
    OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/ElyseanShell/Themes
)

# ── Per-service subdirectories ─────────────────────────────────────────────
add_subdirectory(services/Bluetooth)
add_subdirectory(services/CursorPosition)
add_subdirectory(services/Network)


# ── Link dependencies ──────────────────────────────────────────────────────
target_link_libraries(elyseanshell-services PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::DBus
)

target_link_libraries(elyseanshell-themes PRIVATE
    Qt6::Core
    Qt6::Quick
)
