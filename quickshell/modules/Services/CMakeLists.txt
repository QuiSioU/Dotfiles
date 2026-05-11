# quickshell/modules/Services/CMakeLists.txt


qt_add_library(elyseanshell-services SHARED)

qt_add_qml_module(elyseanshell-services
    URI ElyseanShell.Services
    VERSION 1.0
)

add_subdirectory(Notification)
add_subdirectory(Bluetooth)
add_subdirectory(CursorPosition)
add_subdirectory(Network)

target_link_libraries(elyseanshell-services PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::DBus
)
