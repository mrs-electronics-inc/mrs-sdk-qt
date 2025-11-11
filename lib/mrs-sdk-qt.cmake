# All paths in this file are predicated upon the assumption that the SDK is installed at
# the path $HOME/MRS-SDK-Qt.

# Everything in this block is only applied in the context of applications using the SDK.
if(NOT CMAKE_PROJECT_NAME STREQUAL "mrs-sdk-qt")
    # Add the SDK's include paths and compiled libraries.
    set(MRS_SDK_QT_INCLUDE_DIRS "$ENV{HOME}/MRS-SDK-Qt/include" PARENT_SCOPE)
    set(MRS_SDK_QT_LIBRARY_DIRS "$ENV{HOME}/MRS-SDK-Qt/lib" PARENT_SCOPE)
    set(MRS_SDK_QT_LIBRARIES mrs-sdk-qt PARENT_SCOPE)
endif()

# Define macros.
# Note that these are available both during compilation and for applications using the SDK.
add_definitions(-DMRS_SDK_QT_TEST_MACRO)
