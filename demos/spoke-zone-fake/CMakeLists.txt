cmake_minimum_required(VERSION 3.16)

project(spoke-zone-fake LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(SPOKE_ZONE_FAKE_SOURCES
    main.cpp
)

add_executable(spoke-zone-fake
    ${SPOKE_ZONE_FAKE_SOURCES}
)

set(MRS_SDK_QT_CONSUMER_TARGET "spoke-zone-fake")
include("$ENV{HOME}/.config/mrs-sdk-qt/global-config.cmake")
include("${MRS_SDK_QT_ROOT}/current/lib/cmake/mrs-sdk-qt/config.cmake")

include(GNUInstallDirs)
install(TARGETS spoke-zone-fake
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
