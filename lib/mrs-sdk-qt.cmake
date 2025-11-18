# The paths in this file are dependent on the MRS_SDK_QT_ROOT variable.
# This can be configured from the downstream project. If not configured,
# the default will be $HOME/MRS-SDK-Qt.
if(NOT DEFINED MRS_SDK_QT_ROOT)
    set(MRS_SDK_QT_ROOT "$ENV{HOME}/MRS-SDK-Qt" CACHE PATH "Installation root directory of the MRS SDK Qt")
endif()

# Export the list of definitions that the SDK target and its consumers share.
set(MRS_SDK_QT_SHARED_DEFINES MRS_SDK_QT_TEST_MACRO)
# Export definitions that should only reach consumer targets via the imported target.
set(MRS_SDK_QT_CONSUMER_ONLY_DEFINES "")

# Everything below handles wiring the prebuilt SDK library into consumer projects.
# When a downstream target sets MRS_SDK_QT_CONSUMER_TARGET, we locate the built artifacts,
# publish them via an imported target, and link the consumer target against it.
if(DEFINED MRS_SDK_QT_CONSUMER_TARGET)
    # Resolve the canonical library and include paths for the installed SDK.
    set(MRS_SDK_QT_LIBRARY_DIRS "${MRS_SDK_QT_ROOT}/lib")
    set(MRS_SDK_QT_LIB_NAME mrs-sdk-qt)
    set(MRS_SDK_QT_INCLUDE_DIRS "${MRS_SDK_QT_ROOT}/include")

    if(TARGET ${MRS_SDK_QT_CONSUMER_TARGET})
        find_library(MRS_SDK_QT_LIBS 
            NAMES ${MRS_SDK_QT_LIB_NAME}
            PATHS ${MRS_SDK_QT_LIBRARY_DIRS}
            NO_DEFAULT_PATH
        )
        if(MRS_SDK_QT_LIBS)
            # Create or configure an imported target pointing at the installed library.
            if(NOT TARGET ${MRS_SDK_QT_LIB_NAME})
                add_library(${MRS_SDK_QT_LIB_NAME} UNKNOWN IMPORTED)
            endif()
            set_target_properties(${MRS_SDK_QT_LIB_NAME} PROPERTIES
                IMPORTED_LOCATION ${MRS_SDK_QT_LIBS}
                INTERFACE_INCLUDE_DIRECTORIES ${MRS_SDK_QT_INCLUDE_DIRS}
            )
            if(MRS_SDK_QT_SHARED_DEFINES)
                set_property(TARGET ${MRS_SDK_QT_LIB_NAME} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS ${MRS_SDK_QT_SHARED_DEFINES})
            endif()
            if(MRS_SDK_QT_CONSUMER_ONLY_DEFINES)
                set_property(TARGET ${MRS_SDK_QT_LIB_NAME} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS ${MRS_SDK_QT_CONSUMER_ONLY_DEFINES})
            endif()
            target_link_libraries(${MRS_SDK_QT_CONSUMER_TARGET} PRIVATE ${MRS_SDK_QT_LIB_NAME})
            target_include_directories(${MRS_SDK_QT_CONSUMER_TARGET} PRIVATE ${MRS_SDK_QT_INCLUDE_DIRS})
        endif()
    endif()
endif()
