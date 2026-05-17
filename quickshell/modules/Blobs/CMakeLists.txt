# quickshell/modules/Blobs/CMakeLists.txt


qt_add_library(elyseanshell-blobs SHARED)

qt_add_qml_module(elyseanshell-blobs
    URI ElyseanShell.Blobs
    VERSION 1.0
)

qt_add_shaders(elyseanshell-blobs "blob_shaders"
    BATCHABLE OPTIMIZED NOHLSL NOMSL
    GLSL "300es,330"
    PREFIX "/"
    FILES
        shaders/blob.frag
        shaders/blob.vert
)

target_sources(elyseanshell-blobs PRIVATE
    blobgroup.cpp
    blobshape.cpp
    blobrect.cpp
    blobinvertedrect.cpp
    blobmaterial.cpp
    screenframeitem.cpp
)

target_include_directories(elyseanshell-blobs PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(elyseanshell-blobs PRIVATE
    Qt6::Quick
)
