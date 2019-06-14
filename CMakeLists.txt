cmake_minimum_required(VERSION 3.10)

project(testcpp)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/libraries/fc/CMakeModules)

SET(CMAKE_INSTALL_FULL_INCLUDEDIR ${CMAKE_CURRENT_SOURCE_DIR}/build/include)
SET(CMAKE_INSTALL_FULL_LIBDIR ${CMAKE_CURRENT_SOURCE_DIR}/build/lib)

#SET(BOOST_ROOT $ENV{HOME}/opt/boost)
SET(BOOST_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/libraries/boost)

include(SetupTargetMacros)
include(FindBoost)

FIND_PACKAGE(Boost 1.70 REQUIRED COMPONENTS
    date_time
    filesystem
    system
    program_options
    chrono
    unit_test_framework
    iostreams)

add_subdirectory(libraries)

add_executable(testcpp src/main.cpp)
target_link_libraries(testcpp fc)
target_compile_features(testcpp PRIVATE cxx_std_17)
