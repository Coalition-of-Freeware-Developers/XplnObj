#----------------------------------------------------------------------------------#
# Example usage of XplnObj library
#----------------------------------------------------------------------------------#

cmake_minimum_required(VERSION 3.21)
project(XplnObjExample VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Option 1: Use find_package if XplnObj is installed
# find_package(XplnObj REQUIRED)

# Option 2: Add as subdirectory if you have the source
add_subdirectory(path/to/XplnObj)

# Create your executable
add_executable(example main.cpp)

# Link with XplnObj
target_link_libraries(example PRIVATE steptosky::XplnObj)

# Example main.cpp content:
# #include <xpln/obj/ObjMain.h>
# int main() {
#     // Use XplnObj library here
#     return 0;
# }
