cmake_minimum_required(VERSION 3.16)

project(spoke-zone-demo LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(SPOKE_ZONE_DEMO_SOURCES
    main.cpp
)

add_executable(spoke-zone-demo
    ${SPOKE_ZONE_DEMO_SOURCES}
)

set(MRS_SDK_QT_CONSUMER_TARGET "spoke-zone-demo")
include("$ENV{HOME}/.config/mrs-sdk-qt/global-config.cmake")
include("${MRS_SDK_QT_ROOT}/current/lib/cmake/mrs-sdk-qt/config.cmake")

include(GNUInstallDirs)
