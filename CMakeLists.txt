cmake_minimum_required(VERSION 3.10)

project(testcpp)

SET(CMAKE_INSTALL_FULL_INCLUDEDIR ${CMAKE_CURRENT_SOURCE_DIR}/build/include)
SET(CMAKE_INSTALL_FULL_LIBDIR ${CMAKE_CURRENT_SOURCE_DIR}/build/lib)

SET(BOOST_ROOT $ENV{HOME}/opt/boost)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/libraries/fc/CMakeModules)
include(SetupTargetMacros)
include(FindBoost)

FIND_PACKAGE(Boost 1.67 REQUIRED COMPONENTS
    thread
    date_time
    filesystem
    system
    program_options
    signals
    serialization
    chrono
    unit_test_framework
    context
    locale
    iostreams)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/libraries/fc/include)
add_subdirectory(libraries)

add_executable(testcpp src/main.cpp)
target_link_libraries(testcpp fc)
target_compile_features(testcpp PRIVATE cxx_std_17)
