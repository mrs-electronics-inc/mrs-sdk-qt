# The paths in this file are dependent on the MRS_SDK_QT_ROOT variable.
# This can be configured from the downstream project. If not configured,
# the default will be $HOME/MRS-SDK-Qt.

!defined(MRS_SDK_QT_ROOT) {
    MRS_SDK_QT_ROOT = $$(HOME)/MRS-SDK-Qt
}

# Define macros. These will be available both during SDK compilation and for consumers.
DEFINES += MRS_SDK_QT_TEST_MACRO

# Everything in this block is only applied in the context of applications using the SDK.
contains(TEMPLATE, app) {
    # Add the SDK's compiled libraries and include paths.
    # We can do this automatically to reduce boilerplate in applications' QMake configurations.
    LIBS += -L$$(MRS_SDK_QT_ROOT)/lib -lmrs-sdk-qt
    INCLUDEPATH += $$(MRS_SDK_QT_ROOT)/include
    DEPENDPATH += $$(MRS_SDK_QT_ROOT)/include
}
