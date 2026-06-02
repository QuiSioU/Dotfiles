# quickshell/modules/Blobs/CMakeLists.txt


qt_add_library(elysianshell-blobs SHARED)

qt_add_qml_module(elysianshell-blobs
    URI ElysianShell.Blobs
    VERSION 1.0
)

qt_add_shaders(elysianshell-blobs "blob_shaders"
    BATCHABLE OPTIMIZED NOHLSL NOMSL
    GLSL "300es,330"
    PREFIX "/"
    FILES
        shaders/blob.frag
        shaders/blob.vert
)

target_sources(elysianshell-blobs PRIVATE
    blobgroup.cpp
    blobshape.cpp
    blobrect.cpp
    blobinvertedrect.cpp
    blobmaterial.cpp
    screenframeitem.cpp
)

target_include_directories(elysianshell-blobs PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(elysianshell-blobs PRIVATE
    Qt6::Quick
)
