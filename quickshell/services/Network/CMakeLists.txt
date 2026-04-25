# quickshell/services/Network/CMakeLists.txt


target_sources(elyseanshell-services PRIVATE
    Network.hpp
    Network.cpp
)
 
target_include_directories(elyseanshell-services PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)
