# quickshell/modules/Themes/CMakeLists.txt


qt_add_qml_module(elyseanshell-themes
    URI ElyseanShell.Themes
    VERSION 1.0
    QML_FILES
        ActiveTheme.qml
)

set_source_files_properties(ActiveTheme.qml
    PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
)
