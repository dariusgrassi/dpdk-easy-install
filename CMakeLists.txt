project(basic_dpdk)
cmake_minimum_required(VERSION 2.8)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Options exposed to the user
option(PERF "Compile for performance" OFF)

# Parse the build type
if(PERF)
  message(STATUS "Compilation optimized for performance.")
  message(STATUS "Debugging is disabled.")
  set(CMAKE_BUILD_TYPE RelWithDebInfo)
  set(TESTING OFF)
else(PERF)
  message(STATUS "Compilation not optimized for performance.")
  message(STATUS "Debugging is enabled. Perf will be low.")
  set(CMAKE_BUILD_TYPE Debug)
  SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")
endif(PERF)

add_definitions(-std=c++11 -Wall -Wextra -Werror -pedantic -march=native -g)
add_definitions(-Wsign-conversion -Wold-style-cast)
add_definitions(-Wno-unused-function -Wno-address-of-packed-member)

# Parse the build type
if(NOT CMAKE_BUILD_TYPE)
  message(STATUS "CMAKE_BUILD_TYPE not defined. Using RelWithDebInfo by default.")
  set(CMAKE_BUILD_TYPE RelWithDebInfo)
endif()

if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
  message(STATUS "Using C flags ${CMAKE_C_FLAGS_DEBUG}")
elseif("${CMAKE_BUILD_TYPE}" STREQUAL "RelWithDebInfo")
  set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O3 -g -DNDEBUG")
  message(STATUS "Using C flags ${CMAKE_C_FLAGS_RELWITHDEBINFO}")
else()
  message(STATUS "Using C flags that are not pre-defined.")
endif()

if(NOT DEFINED ENV{RTE_SDK})
  message(WARNING "RTE_SDK not defined, assuming a system-wide install exists")
else()
  if(NOT DEFINED ENV{RTE_TARGET})
    message(WARNING "RTE_TARGET not defined, assuming x86_64-native-linux-gcc")
    set(ENV{RTE_TARGET} "x86_64-native-linux-gcc")
  endif()
  link_directories(BEFORE "$ENV{RTE_SDK}/$ENV{RTE_TARGET}/lib")
  include_directories(BEFORE SYSTEM "$ENV{RTE_SDK}/$ENV{RTE_TARGET}/include")
endif()

execute_process(
  COMMAND bash -c "PKG_CONFIG_PATH=$ENV{RTE_SDK}/$ENV{RTE_TARGET}/lib/x86_64-linux-gnu/pkgconfig/ pkg-config --cflags-only-I libdpdk"
  OUTPUT_VARIABLE LIBDPDK_CFLAGS)
execute_process(
  COMMAND bash -c "PKG_CONFIG_PATH=$ENV{RTE_SDK}/$ENV{RTE_TARGET}/lib/x86_64-linux-gnu/pkgconfig/ pkg-config --libs libdpdk"
  OUTPUT_VARIABLE LIBDPDK_LDFLAGS)

add_executable(example src/example.cpp)

separate_arguments(LIBDPDK_CFLAGS UNIX_COMMAND ${LIBDPDK_CFLAGS})
target_compile_options(example PRIVATE ${LIBDPDK_CFLAGS})
separate_arguments(LIBDPDK_LDFLAGS UNIX_COMMAND ${LIBDPDK_LDFLAGS})
target_link_libraries(example 
  "-Wl,--whole-archive -Wl,--no-whole-archive"
  pthread
  dl
  ${LIBDPDK_LDFLAGS}
  rt
  numa 
  mlx5 
  ibverbs
)
