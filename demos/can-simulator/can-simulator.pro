TEMPLATE = app

CONFIG += c++11 console

QT = core

include("$$(HOME)/MRS-SDK-Qt/builder/mrs-sdk-qt.pri")

SOURCES += $$files(*.cpp, true)

!isEmpty(target.path): INSTALLS += target
