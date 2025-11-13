# All paths in this file are predicated upon the assumption that the SDK is installed at
# the path $HOME/MRS-SDK-Qt.

# Everything in this block is only applied in the context of applications using the SDK.
if(NOT CMAKE_PROJECT_NAME STREQUAL "mrs-sdk-qt")
    # Set the SDK's compiled libraries and include paths.
    set(MRS_SDK_QT_LIBRARY_DIRS "$ENV{HOME}/MRS-SDK-Qt/lib")
    set(MRS_SDK_QT_LIB_NAME mrs-sdk-qt)
    set(MRS_SDK_QT_INCLUDE_DIRS "$ENV{HOME}/MRS-SDK-Qt/include")

    # Try to automatically link the SDK's compiled libraries, if there is an app target.
    # This helps reduce boilerplate in applications' CMake configurations.
    if(TARGET ${CMAKE_PROJECT_NAME})
        find_library(MRS_SDK_QT_LIBS 
            NAMES ${MRS_SDK_QT_LIB_NAME}
            PATHS ${MRS_SDK_QT_LIBRARY_DIRS}
            NO_DEFAULT_PATH
        )
        if(MRS_SDK_QT_LIBS)
            target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ${MRS_SDK_QT_LIBS})
            target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${MRS_SDK_QT_INCLUDE_DIRS})
        endif()
    endif()
endif()

# Define macros.
# Note that these are available both during compilation and for applications using the SDK.
add_definitions(-DMRS_SDK_QT_TEST_MACRO)
