# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.5

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/zhz/CLionProjects/debugger

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/zhz/CLionProjects/debugger/build

# Include any dependencies generated for this target.
include CMakeFiles/unwinding.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/unwinding.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/unwinding.dir/flags.make

CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o: CMakeFiles/unwinding.dir/flags.make
CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o: ../examples/stack_unwinding.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/zhz/CLionProjects/debugger/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o -c /home/zhz/CLionProjects/debugger/examples/stack_unwinding.cpp

CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/zhz/CLionProjects/debugger/examples/stack_unwinding.cpp > CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.i

CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/zhz/CLionProjects/debugger/examples/stack_unwinding.cpp -o CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.s

CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o.requires:

.PHONY : CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o.requires

CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o.provides: CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o.requires
	$(MAKE) -f CMakeFiles/unwinding.dir/build.make CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o.provides.build
.PHONY : CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o.provides

CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o.provides.build: CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o


# Object files for target unwinding
unwinding_OBJECTS = \
"CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o"

# External object files for target unwinding
unwinding_EXTERNAL_OBJECTS =

unwinding: CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o
unwinding: CMakeFiles/unwinding.dir/build.make
unwinding: CMakeFiles/unwinding.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/zhz/CLionProjects/debugger/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable unwinding"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/unwinding.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/unwinding.dir/build: unwinding

.PHONY : CMakeFiles/unwinding.dir/build

CMakeFiles/unwinding.dir/requires: CMakeFiles/unwinding.dir/examples/stack_unwinding.cpp.o.requires

.PHONY : CMakeFiles/unwinding.dir/requires

CMakeFiles/unwinding.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/unwinding.dir/cmake_clean.cmake
.PHONY : CMakeFiles/unwinding.dir/clean

CMakeFiles/unwinding.dir/depend:
	cd /home/zhz/CLionProjects/debugger/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/zhz/CLionProjects/debugger /home/zhz/CLionProjects/debugger /home/zhz/CLionProjects/debugger/build /home/zhz/CLionProjects/debugger/build /home/zhz/CLionProjects/debugger/build/CMakeFiles/unwinding.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/unwinding.dir/depend

