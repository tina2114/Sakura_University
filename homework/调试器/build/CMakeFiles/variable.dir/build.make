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
include CMakeFiles/variable.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/variable.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/variable.dir/flags.make

CMakeFiles/variable.dir/examples/variable.cpp.o: CMakeFiles/variable.dir/flags.make
CMakeFiles/variable.dir/examples/variable.cpp.o: ../examples/variable.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/zhz/CLionProjects/debugger/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/variable.dir/examples/variable.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/variable.dir/examples/variable.cpp.o -c /home/zhz/CLionProjects/debugger/examples/variable.cpp

CMakeFiles/variable.dir/examples/variable.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/variable.dir/examples/variable.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/zhz/CLionProjects/debugger/examples/variable.cpp > CMakeFiles/variable.dir/examples/variable.cpp.i

CMakeFiles/variable.dir/examples/variable.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/variable.dir/examples/variable.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/zhz/CLionProjects/debugger/examples/variable.cpp -o CMakeFiles/variable.dir/examples/variable.cpp.s

CMakeFiles/variable.dir/examples/variable.cpp.o.requires:

.PHONY : CMakeFiles/variable.dir/examples/variable.cpp.o.requires

CMakeFiles/variable.dir/examples/variable.cpp.o.provides: CMakeFiles/variable.dir/examples/variable.cpp.o.requires
	$(MAKE) -f CMakeFiles/variable.dir/build.make CMakeFiles/variable.dir/examples/variable.cpp.o.provides.build
.PHONY : CMakeFiles/variable.dir/examples/variable.cpp.o.provides

CMakeFiles/variable.dir/examples/variable.cpp.o.provides.build: CMakeFiles/variable.dir/examples/variable.cpp.o


# Object files for target variable
variable_OBJECTS = \
"CMakeFiles/variable.dir/examples/variable.cpp.o"

# External object files for target variable
variable_EXTERNAL_OBJECTS =

variable: CMakeFiles/variable.dir/examples/variable.cpp.o
variable: CMakeFiles/variable.dir/build.make
variable: CMakeFiles/variable.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/zhz/CLionProjects/debugger/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable variable"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/variable.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/variable.dir/build: variable

.PHONY : CMakeFiles/variable.dir/build

CMakeFiles/variable.dir/requires: CMakeFiles/variable.dir/examples/variable.cpp.o.requires

.PHONY : CMakeFiles/variable.dir/requires

CMakeFiles/variable.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/variable.dir/cmake_clean.cmake
.PHONY : CMakeFiles/variable.dir/clean

CMakeFiles/variable.dir/depend:
	cd /home/zhz/CLionProjects/debugger/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/zhz/CLionProjects/debugger /home/zhz/CLionProjects/debugger /home/zhz/CLionProjects/debugger/build /home/zhz/CLionProjects/debugger/build /home/zhz/CLionProjects/debugger/build/CMakeFiles/variable.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/variable.dir/depend

