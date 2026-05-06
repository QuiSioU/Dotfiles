# quickshell/modules/Themes/CMakeLists.txt


qt_add_library(elyseanshell-themes SHARED)

set_source_files_properties(ActiveTheme.qml
    PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(elyseanshell-themes
    URI ElyseanShell.Themes
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/ElyseanShell/Themes
    QML_FILES
        ActiveTheme.qml
)

target_link_libraries(elyseanshell-themes PRIVATE
    Qt6::Core
    Qt6::Quick
)
