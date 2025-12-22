#pragma once

#include <QString>
#include <QVersionNumber>

namespace mrs_sdk
{

class BuildInfo
{
public:
    static QVersionNumber sdkVersion();
    static QString targetDevice();
    static QString targetOs();

    static void print();
};

} // namespace mrs_sdk
