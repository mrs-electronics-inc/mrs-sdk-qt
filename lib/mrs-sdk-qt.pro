# We want to build a static library, not a shared library.
# This is better than a shared library because we utilize cross-compilation.
# It's much easier to manage dependencies from the compiler host than an actual target device.
TEMPLATE = lib
CONFIG += staticlib
# C++11 is used because that is the baseline for Qt 5.9.1, the oldest Qt version supported by this SDK.
CONFIG += c++11

# Define a directory to store generated files during a build.
OBJECTS_DIR = generated_files
UI_DIR = generated_files
MOC_DIR = generated_files
RCC_DIR = generated_files

# Import all Qt modules necessary for compilation of the SDK.
QT += core

# All .hpp files in this project are added as headers, and all .cpp files as sources.
# This is much quicker than manually listing each file.
HEADERS += $$files(*.hpp, true)
SOURCES += $$files(*.cpp, true)

# Create the build target.
TARGET = mrs-sdk-qt

# Configure the include directories.
INCLUDEPATH += include
DEPENDPATH += include

# Define library version from the most recent Git tag. 
# Default to "0.0.0" if Git doesn't have a version number.
VERSION = $$system(git describe --tags --abbrev=0 --dirty 2>/dev/null)
isEmpty(VERSION) {
    VERSION = "0.0.0"
}
# Output the library version number.
message(Library version: $$VERSION)
# Make the library version number available in the SDK sources.
DEFINES += MRS_SDK_LIB_VERSION=\\\"$$VERSION\\\"

# The following define makes the compiler emit warnings if you use any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# The .pri file is where environment-specific macros and other necessary configurations are determined.
# Things are split this way because those configurations need to be available to applications using the SDK,
# not just during compilation.
include(mrs-sdk-qt.pri)
