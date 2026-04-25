# quickshell/services/Bluetooth/CMakeLists.txt


target_sources(elyseanshell-services PRIVATE
    Bluetooth.hpp
    Bluetooth.cpp
)
 
target_include_directories(elyseanshell-services PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)
