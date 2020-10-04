cmake_minimum_required(VERSION 3.5.1)
project(debugger)

set(CMAKE_CXX_STANDARD 14)

include_directories(/home/zhz/libelfin /home/zhz/linenoise include)
add_executable(debugger main.cpp debugger.h ext/linenoise/linenoise.c breakpoint.h registers.h)

add_executable(hello examples/hello.cpp)
set_target_properties(hello
        PROPERTIES COMPILE_FLAGS "-g -O0")

add_executable(variable examples/variable.cpp)
set_target_properties(variable
        PROPERTIES COMPILE_FLAGS "-gdwarf-2 -O0")

add_executable(unwinding examples/stack_unwinding.cpp)
set_target_properties(unwinding
        PROPERTIES COMPILE_FLAGS "-g -O0")

add_custom_target(
        libelfin
        COMMAND make
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/ext/libelfin
)
target_link_libraries(debugger
        ${PROJECT_SOURCE_DIR}/ext/libelfin/dwarf/libdwarf++.so
        ${PROJECT_SOURCE_DIR}/ext/libelfin/elf/libelf++.so)
add_dependencies(debugger libelfin)