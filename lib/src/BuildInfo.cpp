#include "BuildInfo.hpp"

using namespace mrs_sdk;

BuildInfo::BuildInfo() {}

QVersionNumber BuildInfo::sdkVersion() const
{
    return QVersionNumber::fromString(MRS_SDK_QT_LIB_VERSION);
}

QString BuildInfo::targetDevice() const
{
    return QString(MRS_SDK_QT_TARGET_DEVICE);
}

QString BuildInfo::targetOs() const
{
    return QString(MRS_SDK_QT_TARGET_OS);
}
