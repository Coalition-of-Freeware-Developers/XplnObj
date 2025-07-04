# XplnObj Library - Modernized Build System

This document describes the modernized CMake build system for the XplnObj library, updated for 2025 with modern CMake practices.

## Key Changes

### Removed Dependencies
- **Conan Package Manager**: Completely removed to eliminate external build dependencies
- **Python Build Scripts**: Simplified build process without Python requirements

### Modernized CMake
- **CMake Version**: Updated minimum requirement to 3.21 (from 3.15)
- **C++ Standard**: Updated to C++17 (from C++14)
- **Modern CMake Patterns**: Uses target-based configuration and generator expressions
- **FetchContent**: Google Test is now fetched automatically via CMake's FetchContent

### Improved Features
- **Better Cross-Platform Support**: Enhanced compiler detection and configuration
- **Modern Installation**: Uses GNUInstallDirs and proper target exports
- **Package Config**: Simplified package discovery for consuming projects
- **Precompiled Headers**: Modern PCH support for faster compilation

## Building the Library

### Prerequisites
- CMake 3.21 or higher
- C++17 compatible compiler (Visual Studio 2017+, GCC 7+, Clang 5+)

### Basic Build
```bash
# Configure
cmake -B build -S .

# Build
cmake --build build

# Install (optional)
cmake --install build --prefix ./install
```

### Build Options
```bash
# Build with testing
cmake -B build -S . -DBUILD_TESTING=ON

# Build shared libraries
cmake -B build -S . -DBUILD_SHARED_LIBS=ON

# Disable installation targets
cmake -B build -S . -DXPLNOBJ_INSTALL=OFF
```

### Visual Studio
```bash
# Generate Visual Studio solution
cmake -B build -S . -G "Visual Studio 17 2022"

# Open generated solution
start build/XplnObj.sln
```

## Using the Library

### CMake Integration
After installation, use the library in your CMake project:

```cmake
find_package(XplnObj REQUIRED)
target_link_libraries(your_target steptosky::XplnObj)
```

### Direct Integration
You can also include this project as a subdirectory:

```cmake
add_subdirectory(path/to/XplnObj)
target_link_libraries(your_target steptosky::XplnObj)
```

## Testing

The test suite uses Google Test, which is automatically downloaded via FetchContent when `BUILD_TESTING=ON`.

```bash
# Build with tests
cmake -B build -S . -DBUILD_TESTING=ON
cmake --build build

# Run tests
ctest --test-dir build --output-on-failure

# Or run the test executable directly
./build/src-test/test-XplnObj
```

## Migration Notes

If you were previously using this library with Conan:

1. Remove `conanfile.py` and `build.py` references from your build scripts
2. Update your CMake minimum version to 3.21
3. Ensure your compiler supports C++17
4. Use the new package name `steptosky::XplnObj` instead of the old target names

## Platform Support

- **Windows**: Visual Studio 2017+ (MSVC 14.1+)
- **Linux**: GCC 7+ or Clang 5+
- **macOS**: Xcode 9+ (Clang 5+)

The build system automatically detects the platform and applies appropriate compiler flags.
