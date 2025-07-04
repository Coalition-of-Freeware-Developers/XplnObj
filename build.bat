@echo off
REM Modern build script for XplnObj (2025)
REM Windows batch version using CMake presets

setlocal enabledelayedexpansion

REM Default values
set "PRESET=release"
set "CLEAN=false"
set "RUN_TESTS=false"
set "INSTALL=false"

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :done_parsing
if /i "%~1"=="debug" (
    set "PRESET=debug"
    shift
    goto :parse_args
)
if /i "%~1"=="release" (
    set "PRESET=release"
    shift
    goto :parse_args
)
if /i "%~1"=="release-tests" (
    set "PRESET=release-tests"
    shift
    goto :parse_args
)
if /i "%~1"=="vs2022" (
    set "PRESET=vs2022"
    shift
    goto :parse_args
)
if /i "%~1"=="--clean" (
    set "CLEAN=true"
    shift
    goto :parse_args
)
if /i "%~1"=="--test" (
    set "RUN_TESTS=true"
    shift
    goto :parse_args
)
if /i "%~1"=="--install" (
    set "INSTALL=true"
    shift
    goto :parse_args
)
if /i "%~1"=="--help" (
    goto :show_usage
)
echo [ERROR] Unknown option: %~1
goto :show_usage

:done_parsing

REM Map presets
if /i "%PRESET%"=="release-tests" (
    set "CMAKE_PRESET=release-with-tests"
    set "BUILD_PRESET=release-with-tests"
    set "TEST_PRESET=release-with-tests"
) else (
    set "CMAKE_PRESET=%PRESET%"
    set "BUILD_PRESET=%PRESET%"
    set "TEST_PRESET=%PRESET%"
)

echo [INFO] Starting XplnObj build with preset: %PRESET%

REM Check if CMake is available
cmake --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] CMake not found. Please install CMake 3.21 or higher.
    exit /b 1
)

REM Get CMake version
for /f "tokens=3" %%i in ('cmake --version ^| findstr /r "cmake version"') do set CMAKE_VERSION=%%i
echo [INFO] Using CMake version: %CMAKE_VERSION%

REM Clean if requested
if /i "%CLEAN%"=="true" (
    echo [INFO] Cleaning build directory...
    if exist "build" (
        rmdir /s /q "build"
        echo [SUCCESS] Build directory cleaned
    )
)

REM Configure
echo [INFO] Configuring with preset: %CMAKE_PRESET%
cmake --preset "%CMAKE_PRESET%"
if errorlevel 1 (
    echo [ERROR] Configuration failed
    exit /b 1
)
echo [SUCCESS] Configuration completed

REM Build (skip for VS project generation)
if /i not "%PRESET%"=="vs2022" (
    echo [INFO] Building with preset: %BUILD_PRESET%
    cmake --build --preset "%BUILD_PRESET%"
    if errorlevel 1 (
        echo [ERROR] Build failed
        exit /b 1
    )
    echo [SUCCESS] Build completed

    REM Test if requested and available
    if /i "%RUN_TESTS%"=="true" (
        echo [INFO] Running tests with preset: %TEST_PRESET%
        ctest --preset "%TEST_PRESET%"
        if errorlevel 1 (
            echo [WARNING] Some tests failed
        ) else (
            echo [SUCCESS] All tests passed
        )
    ) else if /i "%PRESET%"=="debug" (
        echo [INFO] Running tests with preset: %TEST_PRESET%
        ctest --preset "%TEST_PRESET%"
        if errorlevel 1 (
            echo [WARNING] Some tests failed
        ) else (
            echo [SUCCESS] All tests passed
        )
    ) else if /i "%PRESET%"=="release-tests" (
        echo [INFO] Running tests with preset: %TEST_PRESET%
        ctest --preset "%TEST_PRESET%"
        if errorlevel 1 (
            echo [WARNING] Some tests failed
        ) else (
            echo [SUCCESS] All tests passed
        )
    )

    REM Install if requested
    if /i "%INSTALL%"=="true" (
        echo [INFO] Installing...
        cmake --install "build/%CMAKE_PRESET%"
        if errorlevel 1 (
            echo [ERROR] Installation failed
            exit /b 1
        )
        echo [SUCCESS] Installation completed
    )
) else (
    echo [SUCCESS] Visual Studio 2022 project generated in build/vs2022
    echo [INFO] Open the solution file in Visual Studio to continue development
)

echo [SUCCESS] Build script completed successfully!
goto :eof

:show_usage
echo Usage: %~nx0 [PRESET] [OPTIONS]
echo.
echo PRESETS:
echo   debug            - Debug build with tests
echo   release          - Release build without tests
echo   release-tests    - Release build with tests
echo   vs2022          - Visual Studio 2022 project generation
echo.
echo OPTIONS:
echo   --clean         - Clean build directory before building
echo   --test          - Run tests after building
echo   --install       - Install after building
echo   --help          - Show this help
echo.
echo Examples:
echo   %~nx0 debug --clean --test
echo   %~nx0 release --install
echo   %~nx0 vs2022
exit /b 0
