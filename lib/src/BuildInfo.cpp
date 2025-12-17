#include "BuildInfo.hpp"

#include <QDebug>

namespace mrs_sdk {

QVersionNumber BuildInfo::sdkVersion()
{
    return QVersionNumber::fromString(MRS_SDK_QT_LIB_VERSION);
}

QString BuildInfo::targetDevice()
{
    return QString(MRS_SDK_QT_TARGET_DEVICE);
}

QString BuildInfo::targetOs()
{
    return QString(MRS_SDK_QT_TARGET_OS);
}

void BuildInfo::print()
{
    qInfo().noquote() << QString("MRS SDK Info: version %1, targeting device/OS %2/%3").arg(sdkVersion().toString(), targetDevice(), targetOs());
}

}
