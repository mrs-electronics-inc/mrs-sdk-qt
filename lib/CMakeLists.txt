# Set the minimum required version of CMake.
cmake_minimum_required(VERSION 3.16)

# Set the project's name and language.
project(mrs-sdk-qt LANGUAGES CXX)
# C++11 is used because that is the baseline for Qt 5.9.1, the oldest Qt version supported by this SDK.
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# These settings are required for Qt compilation.
# QMake handles this internally.
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Import all Qt modules necessary for compilation of the SDK.
find_package(Qt5 REQUIRED COMPONENTS Core)

# All .hpp files in this project are added as headers, and all .cpp files as sources.
# This is much quicker than manually listing each file.
file(GLOB_RECURSE MRS_SDK_HEADERS "*.hpp")
file(GLOB_RECURSE MRS_SDK_SOURCES "*.cpp")

# Configure the build target.
add_library(mrs-sdk-qt STATIC
  ${MRS_SDK_SOURCES}
)

# Link the imported Qt modules into this library.
# QMake handles this internally.
target_link_libraries(mrs-sdk-qt PRIVATE Qt5::Core)

# Configure the include directories.
target_include_directories(mrs-sdk-qt PUBLIC include)

# The .cmake file is where environment-specific macros and other necessary configurations are determined.
# Things are split this way because those configurations need to be available to applications using the SDK,
# not just during compilation.
include(mrs-sdk-qt.cmake)
