cmake_minimum_required(VERSION 3.16)
project(rocksdb_example)

set(CMAKE_CXX_STANDARD 17)

option(ROCKSDB_BUILD_SHARED OFF)
option(WITH_TESTS OFF)
option(WITH_BENCHMARK_TOOLS OFF)
option(WITH_CORE_TOOLS OFF)
option(WITH_TOOLS OFF)

include(FetchContent)

message(STATUS "Fetching rocksdb...")
FetchContent_Declare(rocksdb
  GIT_REPOSITORY https://github.com/facebook/rocksdb
  GIT_TAG        4d57a393a8f1563c0dff1ff468756c23d89e3601)

FetchContent_GetProperties(rocksdb)
if(NOT rocksdb_POPULATED)
  FetchContent_Populate(rocksdb)
  message(STATUS "Configuring rocksdb...")
  add_subdirectory(${rocksdb_SOURCE_DIR})
endif()

add_executable(rocksdb-example src/rocksdb-example.cpp)
target_include_directories(rocksdb-example PUBLIC ${rocksdb_SOURCE_DIR}/include)
target_link_libraries(rocksdb-example rocksdb)
