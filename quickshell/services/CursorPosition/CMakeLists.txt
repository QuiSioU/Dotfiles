# quickshell/services/CursorPosition/CMakeLists.txt


target_sources(elyseanshell-services PRIVATE
    CursorPositionService.hpp
    CursorPositionService.cpp
)

target_include_directories(elyseanshell-services PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

