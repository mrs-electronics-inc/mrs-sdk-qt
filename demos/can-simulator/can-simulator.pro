TEMPLATE = app

CONFIG += c++11 console

QT = core

include("$$(QMAKE_TOOLCHAIN_FILE)")
include("$$(HOME)/.config/mrs-sdk-qt/global-config.pri")
include("$$MRS_SDK_QT_ROOT/current/lib/qmake/mrs-sdk-qt/config.pri")

SOURCES += main.cpp

!isEmpty(target.path): INSTALLS += target
