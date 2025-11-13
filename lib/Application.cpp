#include "Application.hpp"

#include <QDebug>

Application::Application() {}

void Application::announce() const
{
#ifdef MRS_SDK_QT_TEST_MACRO
    qDebug() << "THIS IS FROM A STATIC LIBRARY!! WOWWW";
    qDebug() << "Lib version:" << MRS_SDK_LIB_VERSION;
#endif
}
