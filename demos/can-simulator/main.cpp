#include <QtGlobal>
#include "Application.hpp"

int main(int argc, char *argv[])
{
    Q_UNUSED(argc)
    Q_UNUSED(argv)
    
    Application app;
    app.announce();
}
