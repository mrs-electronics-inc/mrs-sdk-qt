# The paths in this file are dependent on the MRS_SDK_QT_ROOT variable.
# This can be configured from the downstream project. If not configured,
# the default will be $HOME/MRS-SDK-Qt.
if(NOT DEFINED MRS_SDK_QT_ROOT)
    set(MRS_SDK_QT_ROOT "$ENV{HOME}/MRS-SDK-Qt" CACHE PATH "Installation root directory of the MRS SDK Qt")
endif()

# Define macros. These will be available both during SDK compilation and for consumers.
target_compile_definitions(mrs-sdk-qt PUBLIC MRS_SDK_QT_TEST_MACRO)

# Everything in this block is only applied in the context of applications using the SDK.
if(NOT CMAKE_PROJECT_NAME STREQUAL "mrs-sdk-qt")
    # Set the SDK's compiled libraries and include paths.
    set(MRS_SDK_QT_LIBRARY_DIRS "${MRS_SDK_QT_ROOT}/lib")
    set(MRS_SDK_QT_LIB_NAME mrs-sdk-qt)
    set(MRS_SDK_QT_INCLUDE_DIRS "${MRS_SDK_QT_ROOT}/include")

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
