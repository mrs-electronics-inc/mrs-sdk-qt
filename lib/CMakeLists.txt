# Set the minimum required version of CMake.
cmake_minimum_required(VERSION 3.16)

# Set the project's name and language.
project(mrs-sdk-qt LANGUAGES CXX)
# C++11 is used because that is the baseline for Qt 5.9.1, the oldest Qt version supported by this SDK.
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# These settings are required for Qt compilation.
# QMake handles these internally.
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Define the lists of header and source files.
set(MRS_SDK_HEADERS
    include/Application.hpp
)
set(MRS_SDK_SOURCES
    src/Application.cpp
)

# Create the build target.
add_library(mrs-sdk-qt STATIC
    ${MRS_SDK_HEADERS}
    ${MRS_SDK_SOURCES}
)

# Define the directories to use for generated build files and final compiled artifacts.
set_target_properties(mrs-sdk-qt PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/artifacts"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/artifacts"
    AUTOGEN_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated_files"
)

# Configure the include directories.
target_include_directories(mrs-sdk-qt PUBLIC include)

# The main mrs-sdk-qt.cmake file is where environment-specific macros and other necessary configurations are determined.
# Things are split this way because those configurations need to be available to applications using the SDK,
# not just during compilation.
include(cmake/mrs-sdk-qt/config.cmake)

# Link the imported Qt modules into this library.
# QMake handles this internally.
if(Qt5Core_VERSION)
    target_link_libraries(mrs-sdk-qt PUBLIC Qt5::Core)
elseif(Qt6Core_VERSION)
    target_link_libraries(mrs-sdk-qt PUBLIC Qt6::Core)
endif()

# Define library version from the most recent Git tag.
# Default to "0.0.0" if Git doesn't have a version number.
execute_process(
    COMMAND git describe --tags --abbrev=0 --dirty
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_TAG
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
if (NOT GIT_TAG)
    set(GIT_TAG "0.0.0")
endif()
set_target_properties(mrs-sdk-qt PROPERTIES
    VERSION ${GIT_TAG}
)
# Output the library version number.
message(NOTICE "MRS SDK: library version: ${GIT_TAG}")
# Make the library version number available in the SDK sources.
target_compile_definitions(mrs-sdk-qt PRIVATE MRS_SDK_QT_LIB_VERSION=\"${GIT_TAG}\")

# The following define makes the compiler emit warnings if you use any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the deprecated API in order to know how to port your code away from it.
target_compile_definitions(mrs-sdk-qt PRIVATE QT_DEPRECATED_WARNINGS)

# Add all shared definitions imported from the .cmake file.
if(MRS_SDK_QT_SHARED_DEFINES)
    target_compile_definitions(mrs-sdk-qt PRIVATE ${MRS_SDK_QT_SHARED_DEFINES})
endif()
