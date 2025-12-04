#include <QDebug>

#include "BuildInfo.hpp"

int main(int argc, char *argv[])
{
    Q_UNUSED(argc)
    Q_UNUSED(argv)

    mrs_sdk::BuildInfo sdkInfo;
    qDebug().noquote() << "MRS SDK version:" << sdkInfo.sdkVersion().toString();
    qDebug().noquote() << "Device target:" << sdkInfo.targetDevice();
    qDebug().noquote() << "OS target:" << sdkInfo.targetOs();
}
