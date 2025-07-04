#!/bin/bash
# Modern build script for XplnObj (2025)
# Cross-platform build script using CMake presets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [PRESET] [OPTIONS]"
    echo ""
    echo "PRESETS:"
    echo "  debug            - Debug build with tests"
    echo "  release          - Release build without tests"
    echo "  release-tests    - Release build with tests"
    echo "  vs2022          - Visual Studio 2022 project generation"
    echo ""
    echo "OPTIONS:"
    echo "  --clean         - Clean build directory before building"
    echo "  --test          - Run tests after building"
    echo "  --install       - Install after building"
    echo "  --help          - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 debug --clean --test"
    echo "  $0 release --install"
    echo "  $0 vs2022"
}

# Default values
PRESET="release"
CLEAN=false
RUN_TESTS=false
INSTALL=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        debug|release|release-tests|vs2022)
            PRESET="$1"
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --test)
            RUN_TESTS=true
            shift
            ;;
        --install)
            INSTALL=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Map presets
case $PRESET in
    release-tests)
        CMAKE_PRESET="release-with-tests"
        BUILD_PRESET="release-with-tests"
        TEST_PRESET="release-with-tests"
        ;;
    *)
        CMAKE_PRESET="$PRESET"
        BUILD_PRESET="$PRESET"
        TEST_PRESET="$PRESET"
        ;;
esac

print_status "Starting XplnObj build with preset: $PRESET"

# Check if CMake is available
if ! command -v cmake &> /dev/null; then
    print_error "CMake not found. Please install CMake 3.21 or higher."
    exit 1
fi

# Check CMake version
CMAKE_VERSION=$(cmake --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
print_status "Using CMake version: $CMAKE_VERSION"

# Clean if requested
if [ "$CLEAN" = true ]; then
    print_status "Cleaning build directory..."
    if [ -d "build" ]; then
        rm -rf build
        print_success "Build directory cleaned"
    fi
fi

# Configure
print_status "Configuring with preset: $CMAKE_PRESET"
if ! cmake --preset "$CMAKE_PRESET"; then
    print_error "Configuration failed"
    exit 1
fi
print_success "Configuration completed"

# Build (skip for VS project generation)
if [ "$PRESET" != "vs2022" ]; then
    print_status "Building with preset: $BUILD_PRESET"
    if ! cmake --build --preset "$BUILD_PRESET"; then
        print_error "Build failed"
        exit 1
    fi
    print_success "Build completed"

    # Test if requested and available
    if [ "$RUN_TESTS" = true ] || [ "$PRESET" = "debug" ] || [ "$PRESET" = "release-tests" ]; then
        if [ -f "CMakePresets.json" ] && grep -q "\"$TEST_PRESET\"" CMakePresets.json; then
            print_status "Running tests with preset: $TEST_PRESET"
            if ! ctest --preset "$TEST_PRESET"; then
                print_warning "Some tests failed"
            else
                print_success "All tests passed"
            fi
        else
            print_warning "No test preset available for: $TEST_PRESET"
        fi
    fi

    # Install if requested
    if [ "$INSTALL" = true ]; then
        print_status "Installing..."
        if ! cmake --install "build/$CMAKE_PRESET"; then
            print_error "Installation failed"
            exit 1
        fi
        print_success "Installation completed"
    fi
else
    print_success "Visual Studio 2022 project generated in build/vs2022"
    print_status "Open the solution file in Visual Studio to continue development"
fi

print_success "Build script completed successfully!"
