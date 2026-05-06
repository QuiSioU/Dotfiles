# quickshell/services/Network/CMakeLists.txt


target_sources(elyseanshell-services PRIVATE
    NetworkService.hpp
    NetworkService.cpp
)

target_include_directories(elyseanshell-services PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

