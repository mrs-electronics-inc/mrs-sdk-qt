#include "Application.hpp"

#include <QDebug>

Application::Application() {}

void Application::announce() const
{
    qDebug() << "THIS IS FROM A STATIC LIBRARY!! WOWWW";
    qDebug() << "Target device:" << MRS_SDK_QT_TARGET_DEVICE;
    qDebug() << "Target OS:" << MRS_SDK_QT_TARGET_OS;
}
