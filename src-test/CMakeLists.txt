#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
#
#  Copyright (C) 2018, StepToSky
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#  1.Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#  2.Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and / or other materials provided with the distribution.
#  3.Neither the name of StepToSky nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED.IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#  Contacts: www.steptosky.com
#
#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# Modern Test Configuration

# Collect test source files
file(GLOB_RECURSE TEST_SOURCES 
    CONFIGURE_DEPENDS
    "*.cpp"
    "*.h"
)

#----------------------------------------------------------------------------------#
# Google Test Integration

include(FetchContent)

# Fetch Google Test
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        v1.14.0
    GIT_SHALLOW    TRUE
)

# Configure Google Test
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
set(BUILD_GMOCK ON CACHE BOOL "" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(googletest)

#----------------------------------------------------------------------------------#
# Test Target

set(TEST_TARGET test-${ProjectId})

add_executable(${TEST_TARGET} ${TEST_SOURCES})

# Set C++ standard
set_target_properties(${TEST_TARGET} PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)

# Include directories
target_include_directories(${TEST_TARGET} PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/../include"
    "${CMAKE_CURRENT_SOURCE_DIR}/../src"
    "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Link libraries
target_link_libraries(${TEST_TARGET} PRIVATE
    ${ProjectId}
    gtest
    gtest_main
    gmock
    gmock_main
)

# Compile definitions
target_compile_definitions(${TEST_TARGET} PRIVATE TESTING)

# Group files for IDE
include(StsGroupFiles)
groupFiles("${TEST_SOURCES}")

#----------------------------------------------------------------------------------#
# Compiler Configuration

# Precompiled headers for MSVC (if test PCH exists)
if(MSVC AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/ph/stdafx.cpp")
    set_source_files_properties(ph/stdafx.cpp
        PROPERTIES COMPILE_FLAGS "/Yc"
    )
    target_precompile_headers(${TEST_TARGET} PRIVATE ph/stdafx.h)
endif()

# Compiler-specific options
target_compile_options(${TEST_TARGET} PRIVATE
    # MSVC specific options
    $<$<CXX_COMPILER_ID:MSVC>:
        /W4         # Warning level 4
        /WX         # Treat warnings as errors  
        /MP         # Multi-processor compilation
        /permissive- # Strict conformance
        /D_CRT_SECURE_NO_WARNINGS
    >
    
    # GCC/Clang options
    $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>>:
        -Wall
        -Wextra
        -Werror
        -pedantic
        -Wno-unknown-pragmas
    >
)

#----------------------------------------------------------------------------------#
# Test Registration

include(GoogleTest)
gtest_discover_tests(${TEST_TARGET}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Add a custom target to run tests
add_custom_target(run_tests
    COMMAND ${TEST_TARGET}
    DEPENDS ${TEST_TARGET}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running unit tests"
)
