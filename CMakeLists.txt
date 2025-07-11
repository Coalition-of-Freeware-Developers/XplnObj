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
# Modern CMake Configuration (Updated 2025)

cmake_minimum_required(VERSION 3.21)

# Set policies for modern CMake
if(POLICY CMP0135)
    cmake_policy(SET CMP0135 NEW) # FetchContent timestamp handling
endif()
if(POLICY CMP0144)
    cmake_policy(SET CMP0144 NEW) # find_package improvements
endif()
if(POLICY CMP0148)
    cmake_policy(SET CMP0148 NEW) # find_package variable improvements  
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# Project Definition

include(StsProjectDesc)
project(${ProjectId} 
    VERSION ${ProjectVersion}
    DESCRIPTION "${ProjectDescription}"
    HOMEPAGE_URL "${ProjectWebLink}"
    LANGUAGES CXX
)

# Modern CMake features
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Set C++ standard - Updated to C++17 for 2025
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable IPO/LTO if supported
include(CheckIPOSupported)
check_ipo_supported(RESULT IPO_SUPPORTED OUTPUT IPO_ERROR)
if(IPO_SUPPORTED)
    message(STATUS "IPO/LTO is supported and will be enabled for Release builds")
endif()

# Generate Info header
include(StsInfoFilesGenerator)
genInfoFile(StsProjectDesc "${CMAKE_CURRENT_SOURCE_DIR}/include/xpln/Info.h")

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# Options - Modernized for 2025

option(BUILD_SHARED_LIBS "Build shared libraries" OFF)
option(BUILD_TESTING "Build tests" OFF)
option(XPLNOBJ_INSTALL "Generate install target" ON)
option(XPLNOBJ_ENABLE_IPO "Enable IPO/LTO for Release builds" ON)

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Modern testing report directory
if(NOT TESTING_REPORT_DIR)
    set(TESTING_REPORT_DIR "${CMAKE_CURRENT_BINARY_DIR}/test-reports")
endif()

message(STATUS "==============================================")
message(STATUS "XplnObj Configuration (Modernized 2025):")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Build testing: ${BUILD_TESTING}")
message(STATUS "  Shared libraries: ${BUILD_SHARED_LIBS}")
message(STATUS "  Install target: ${XPLNOBJ_INSTALL}")
message(STATUS "  IPO/LTO enabled: ${XPLNOBJ_ENABLE_IPO}")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Installation prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  Testing report dir: ${TESTING_REPORT_DIR}")
message(STATUS "==============================================")

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# Dependencies - No external dependencies for core library

# This library is self-contained and doesn't require external dependencies
# Testing dependencies are handled via FetchContent in src-test/CMakeLists.txt

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# Subdirectories

add_subdirectory(src)

if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(src-test)
endif()

# Add example if available
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/example/CMakeLists.txt")
    option(XPLNOBJ_BUILD_EXAMPLES "Build examples" OFF)
    if(XPLNOBJ_BUILD_EXAMPLES)
        add_subdirectory(example)
    endif()
endif()

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
# Package Configuration

if(XPLNOBJ_INSTALL)
    # Create package config files
    set(CONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
    set(PROJECT_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake")
    set(VERSION_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake")

    # Create package version file
    write_basic_package_version_file(
        "${VERSION_CONFIG_FILE}"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    # Create package config file
    configure_package_config_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/XplnObjConfig.cmake.in"
        "${PROJECT_CONFIG_FILE}"
        INSTALL_DESTINATION "${CONFIG_INSTALL_DIR}"
    )

    # Install package config files
    install(
        FILES "${PROJECT_CONFIG_FILE}" "${VERSION_CONFIG_FILE}"
        DESTINATION "${CONFIG_INSTALL_DIR}"
    )
endif()

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
