# quickshell/modules/Services/CMakeLists.txt


qt_add_library(elyseanshell-services SHARED)

set_source_files_properties(Notification/NotificationService.qml
    PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(elyseanshell-services
    URI ElyseanShell.Services
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/ElyseanShell/Services
    QML_FILES
        Notification/NotificationService.qml
)

add_subdirectory(Bluetooth)
add_subdirectory(CursorPosition)
add_subdirectory(Network)

target_link_libraries(elyseanshell-services PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::DBus
)
