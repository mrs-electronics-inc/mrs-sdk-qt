#include "BuildInfo.hpp"

int main(int argc, char* argv[])
{
    Q_UNUSED(argc)
    Q_UNUSED(argv)

    mrs_sdk::BuildInfo::print();
}
