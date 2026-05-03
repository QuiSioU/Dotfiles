# quickshell/services/Network/CMakeLists.txt



target_sources(elyseanshell-services PRIVATE
    ScreenFrameItem.hpp
    ScreenFrameItem.cpp
)
 
target_include_directories(elyseanshell-services PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(elyseanshell-services PRIVATE Qt6::Gui)

