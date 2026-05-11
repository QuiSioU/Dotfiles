# quickshell/modules/Blobs/CMakeLists.txt


qt_add_library(elyseanshell-blobs SHARED)

file(GLOB_RECURSE BLOB_SOURCES CONFIGURE_DEPENDS src/*.cpp)

target_sources(elyseanshell-blobs PRIVATE ${BLOB_SOURCES})

qt_add_qml_module(elyseanshell-blobs
    URI ElyseanShell.Blobs
    VERSION 1.0
)

set_target_properties(elyseanshell-blobsplugin PROPERTIES 
    PREFIX ""
)

qt_add_shaders(elyseanshell-blobs "blob_shaders"
    BATCHABLE OPTIMIZED NOHLSL NOMSL
    GLSL "300es,330"
    PREFIX "/"
    FILES
        shaders/blob.frag
        shaders/blob.vert
)

target_include_directories(elyseanshell-blobs PRIVATE
    include
)

target_link_libraries(elyseanshell-blobs PRIVATE
    Qt6::Core
    Qt6::Quick
)
