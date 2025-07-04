# XplnObj Modernization (2025)

This document describes the modernization changes made to the XplnObj library to bring it up to 2025 standards.

## Major Changes

### 1. Removed Conan Dependency
- Completely removed Conan package manager dependency
- The library is now self-contained with no external dependencies for the core library
- Testing dependencies (Google Test) are now managed via CMake's FetchContent

### 2. Modern CMake (3.21+)
- Updated minimum CMake version to 3.21
- Added modern CMake policies for better compatibility
- Implemented proper target-based configuration
- Added IPO/LTO support for optimized release builds
- Used modern CMake features like `target_compile_features()`

### 3. C++17 Standard
- Updated from C++14 to C++17 (appropriate for 2025)
- Maintains backward compatibility while enabling modern C++ features

### 4. CMake Presets
- Added `CMakePresets.json` for standardized build configurations
- Provides presets for debug, release, and Visual Studio builds
- Enables better IDE integration and consistent builds across environments

### 5. Modern Build Scripts
- Created cross-platform build scripts (`build.sh` and `build.bat`)
- Replaced old Conan-based build workflows
- Support for multiple build configurations and automated testing

### 6. Enhanced Project Structure
- Improved file organization and separation of concerns
- Better IDE support with proper file grouping
- Enhanced installation and packaging configuration

## Building the Library

### Prerequisites
- CMake 3.21 or higher
- C++17 compatible compiler
- Git (for fetching test dependencies)

### Quick Start

#### Using CMake Presets (Recommended)
```bash
# Debug build with tests
cmake --preset debug
cmake --build --preset debug
ctest --preset debug

# Release build
cmake --preset release  
cmake --build --preset release

# Visual Studio 2022 project generation
cmake --preset vs2022
```

#### Using Build Scripts
```bash
# Linux/macOS
./build.sh debug --clean --test
./build.sh release --install

# Windows
build.bat debug --clean --test
build.bat release --install
```

#### Manual CMake
```bash
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON
cmake --build .
ctest
cmake --install . --prefix ../install
```

## Configuration Options

- `BUILD_SHARED_LIBS` - Build shared libraries (default: OFF)
- `BUILD_TESTING` - Build unit tests (default: OFF)
- `XPLNOBJ_INSTALL` - Generate install target (default: ON)
- `XPLNOBJ_ENABLE_IPO` - Enable IPO/LTO for Release builds (default: ON)
- `XPLNOBJ_BUILD_EXAMPLES` - Build examples if available (default: OFF)

## Migration from Conan

If you were previously using this library with Conan:

1. Remove conan dependencies from your project
2. Use CMake's `find_package()` or add as subdirectory:

```cmake
# Option 1: find_package (if installed)
find_package(XplnObj REQUIRED)
target_link_libraries(your_target steptosky::XplnObj)

# Option 2: add_subdirectory
add_subdirectory(path/to/XplnObj)
target_link_libraries(your_target steptosky::XplnObj)
```

## IDE Integration

### Visual Studio Code
The project includes CMake presets which provide excellent VS Code integration:
- Install the CMake Tools extension
- Select a kit and preset
- Build and test directly from the IDE

### Visual Studio 2022
Generate a Visual Studio solution:
```bash
cmake --preset vs2022
```
Then open `build/vs2022/XplnObj.sln`

### CLion
CLion has native support for CMake presets. Simply open the project folder.

## Continuous Integration

The modernized project is ready for modern CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Configure CMake
  run: cmake --preset release

- name: Build
  run: cmake --build --preset release

- name: Test
  run: ctest --preset release-with-tests
```

## Backwards Compatibility

The library API remains unchanged. Only the build system has been modernized.
Existing code using the library will continue to work without modifications.
