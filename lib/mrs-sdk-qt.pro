# We want to build a static library, not a shared library.
# This is better than a shared library because we utilize cross-compilation.
# It's much easier to manage dependencies from the compiler host than an actual target device.
TEMPLATE = lib
CONFIG += staticlib
# C++11 is used because that is the baseline for Qt 5.9.1, the oldest Qt version supported by this SDK.
CONFIG += c++11

# Import all Qt modules necessary for compilation of the SDK.
QT += core

# All .hpp files in this project are added as headers, and all .cpp files as sources.
# This is much quicker than manually listing each file.
HEADERS += $$files(*.hpp, true)
SOURCES += $$files(*.cpp, true)

# Configure the build target.
TARGET = mrs-sdk-qt

# Configure the include directories.
INCLUDEPATH += include
DEPENDPATH += include

# The .pri file is where environment-specific macros and other necessary configurations are determined.
# Things are split this way because those configurations need to be available to applications using the SDK,
# not just during compilation.
include(mrs-sdk-qt.pri)
