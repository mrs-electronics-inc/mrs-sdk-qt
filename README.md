# MRS Electronics, Inc. Qt SDK

Welcome to the official repository for the MRS Electronics, Inc. Qt Software Development Kit (SDK). This SDK provides developers with the tools, libraries, and documentation needed to create applications for MRS Electronics products using the Qt framework.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Overview

The MRS Electronics Qt SDK is designed to streamline the development process for applications targeting MRS Electronics hardware platforms. It includes pre-built Qt modules, device-specific plugins, and utilities that simplify integration with MRS Electronics products.

## Features

- Cross-platform development support
- Device-specific Qt modules and plugins
- Hardware abstraction layer for MRS Electronics products
- Comprehensive documentation and API reference
- Example applications and tutorials
- Integration with popular development environments

## Prerequisites

Before installing the MRS Electronics Qt SDK, ensure your system meets the following requirements:

- Qt 6.x or later
- C++17 compatible compiler
- CMake 3.16 or later
- Python 3.8 or later (for some tools)
- Platform-specific dependencies:
  - **Windows**: Visual Studio 2019 or later
  - **Linux**: GCC 9 or later
  - **macOS**: Xcode 12 or later

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/MRSElectronics/qt-sdk.git
   cd qt-sdk
   ```

2. Initialize submodules:
   ```bash
   git submodule update --init --recursive
   ```

3. Build the SDK:
   ```bash
   mkdir build && cd build
   cmake ..
   cmake --build .
   ```

4. Install the SDK (optional):
   ```bash
   cmake --install .
   ```

### Pre-built Packages

Pre-built packages are available for supported platforms. Visit the [MRS Electronics Developer Portal](https://developers.mrselectronics.com) to download the appropriate package for your platform.

## Getting Started

To create your first application with the MRS Electronics Qt SDK:

1. Create a new CMake project with the following `CMakeLists.txt`:
   ```cmake
   cmake_minimum_required(VERSION 3.16)
   project(MyApp)

   find_package(MRSQtSDK REQUIRED)

   add_executable(MyApp main.cpp)
   target_link_libraries(MyApp PRIVATE MRSQtSDK::Core)
   ```

2. Create a simple `main.cpp`:
   ```cpp
   #include <MRSQt/Core/Application>
   #include <MRSQt/Core/DeviceManager>
   
   int main(int argc, char *argv[])
   {
       MRSQt::Application app(argc, argv);
       
       // Initialize device manager
       MRSQt::DeviceManager manager;
       
       // Your application logic here
       
       return app.exec();
   }
   ```

3. Build and run your application:
   ```bash
   mkdir build && cd build
   cmake ..
   make
   ./MyApp
   ```

## Documentation

Comprehensive documentation is available in the `docs` directory and online at the [MRS Electronics Qt SDK Documentation Portal](https://docs.mrselectronics.com/qt-sdk).

To generate the documentation locally:

