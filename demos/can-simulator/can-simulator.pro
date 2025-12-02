TEMPLATE = app

CONFIG += c++11 console

QT = core

MRS_SDK_QT_ROOT = "$$(HOME)/mrs-sdk-qt"
include("$$MRS_SDK_QT_ROOT/current/lib/qmake/mrs-sdk-qt/config.pri")

SOURCES += main.cpp

!isEmpty(target.path): INSTALLS += target
