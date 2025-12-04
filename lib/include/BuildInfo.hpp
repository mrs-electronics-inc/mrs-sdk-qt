#pragma once

#include <QString>
#include <QVersionNumber>

namespace mrs_sdk {

class BuildInfo {
public:
    BuildInfo();

    QVersionNumber sdkVersion() const;
    QString targetDevice() const;
    QString targetOs() const;
};

}
