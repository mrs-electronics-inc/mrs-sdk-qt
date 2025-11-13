# All paths in this file are predicated upon the assumption that the SDK is installed at
# the path $HOME/MRS-SDK-Qt.

# Everything in this block is only applied in the context of applications using the SDK.
contains(TEMPLATE, app) {
    # Add the SDK's compiled libraries and include paths.
    # We can do this automatically to reduce boilerplate in applications' QMake configurations.
    LIBS += -L$$(HOME)/MRS-SDK-Qt/lib -lmrs-sdk-qt
    INCLUDEPATH += $$(HOME)/MRS-SDK-Qt/include
    DEPENDPATH += $$(HOME)/MRS-SDK-Qt/include
}

# Define macros.
# Note that these are available both during compilation and for applications using the SDK.
DEFINES += MRS_SDK_QT_TEST_MACRO
