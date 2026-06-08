TEMPLATE = app

CONFIG += c++11 console

QT = core

MRS_SDK_QT_CONSUMER_TARGET = "can-simulator"
include("mrs-sdk-qt/toolchain.pri")
include("mrs-sdk-qt/project.pri")

SOURCES += main.cpp

!isEmpty(target.path): INSTALLS += target
