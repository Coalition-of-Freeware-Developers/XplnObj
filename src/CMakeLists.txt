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
# Modern XplnObj Library Target

# Collect source files
file(GLOB_RECURSE XPLNOBJ_SOURCES 
    CONFIGURE_DEPENDS
    "*.cpp"
    "*.h"
)

file(GLOB_RECURSE XPLNOBJ_HEADERS 
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/../include/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/../include/*.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/../include/*.inl"
)

# Create the library target
add_library(${ProjectId} ${XPLNOBJ_SOURCES} ${XPLNOBJ_HEADERS})
add_library(steptosky::XplnObj ALIAS ${ProjectId})

# Set target properties
set_target_properties(${ProjectId} PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    VERSION ${PROJECT_VERSION}
    SOVERSION ${ProjectVersionMajor}
    OUTPUT_NAME "XplnObj"
)

# Configure include directories
target_include_directories(${ProjectId}
    PRIVATE 
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
    PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)

# Require C++17 for consumers
target_compile_features(${ProjectId} PUBLIC cxx_std_17)

# Group files for IDE organization
include(StsGroupFiles)
groupFiles("${XPLNOBJ_SOURCES};${XPLNOBJ_HEADERS}")

#----------------------------------------------------------------------------------#
# Compiler Configuration

# Precompiled headers for MSVC
if(MSVC)
    set_source_files_properties(stdafx.cpp
        PROPERTIES COMPILE_FLAGS "/Yc"
    )
    
    target_precompile_headers(${ProjectId} PRIVATE stdafx.h)
endif()

# Compiler-specific options
target_compile_options(${ProjectId} PRIVATE
    # MSVC specific options
    $<$<CXX_COMPILER_ID:MSVC>:
        /W4         # Warning level 4
        /WX         # Treat warnings as errors
        /MP         # Multi-processor compilation
        /permissive- # Strict conformance
        /Zc:__cplusplus # Correct __cplusplus macro
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

# Define macros for export/import
if(BUILD_SHARED_LIBS)
    target_compile_definitions(${ProjectId} 
        PRIVATE XPLN_OBJ_EXPORTS
        INTERFACE XPLN_OBJ_SHARED
    )
else()
    target_compile_definitions(${ProjectId} 
        PUBLIC XPLN_OBJ_STATIC_COMPILATION
    )
endif()

# Enable IPO/LTO for Release builds if supported and requested
if(IPO_SUPPORTED AND XPLNOBJ_ENABLE_IPO AND CMAKE_BUILD_TYPE STREQUAL "Release")
    set_target_properties(${ProjectId} PROPERTIES
        INTERPROCEDURAL_OPTIMIZATION TRUE
    )
    message(STATUS "IPO/LTO enabled for ${ProjectId}")
endif()

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# Export Header Generation

include(GenerateExportHeader)
generate_export_header(${ProjectId} 
    EXPORT_MACRO_NAME "XpObjLib"
    EXPORT_FILE_NAME "${CMAKE_CURRENT_SOURCE_DIR}/../include/xpln/Export.h"
    DEPRECATED_MACRO_NAME "XpObjLibDeprecated"
    STATIC_DEFINE "XPLN_OBJ_STATIC_COMPILATION"
)

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# Installation

if(XPLNOBJ_INSTALL)
    # Install headers
    install(
        DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../include/"
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
        FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.inl"
    )

    # Install library
    install(
        TARGETS ${ProjectId}
        EXPORT XplnObjTargets
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    )

    # Install export targets
    install(
        EXPORT XplnObjTargets
        FILE XplnObjTargets.cmake
        NAMESPACE steptosky::
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
    )
endif()