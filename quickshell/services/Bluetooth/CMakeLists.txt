# quickshell/services/Bluetooth/CMakeLists.txt


target_sources(elyseanshell-services PRIVATE
    BluetoothService.hpp
    BluetoothService.cpp
)

target_include_directories(elyseanshell-services PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

