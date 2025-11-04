---
title: MVP Overview
description: This page outlines the benefits, goals, and features required for the MVP.
---

This document outlines the benefits, goals, and general technical requirements for the Minimum Viable Product (MVP) of the MRS Qt SDK.

<details><summary>Revision History</summary>

| Version | Date | Author | Comments |
| --- | --- | --- | --- |
| 1.0 | 10/30/2025 | Bennett Moore | Initial version |

</details>

## 1 Benefits

This SDK will greatly simplify the development process for software/firmware applications that target MRS Electronics hardware platforms.

New and existing customers for any and all of our products will be able to quickly get started developing their own custom applications with well-built Qt-based utilities that provide drop-in functionality for such tasks as GPIO and CAN interfaces, Spoke.Zone/MQTT integration, and management of connected CAN modules.

## 2 Goals

This section defines the major goals for the SDK.

### 2.1 Supported Environments

The SDK must be compatible with a variety of products, OS architectures, and compilation toolchains.

- **MRS Products:** NeuralPlex, MConn, FUSION
- **OS Architectures:** Yocto, Buildroot
- **Qt Versions:**
  - *5.9.1:* MConn/FUSION Buildroot toolchain
  - *5.12.9:* MConn/FUSION Yocto toolchain
  - *5.15.0:* Qt5 desktop toolchain
  - *6.8.1* Neuralplex toolchain

### 2.2 Documentation

The SDK will need to be documented at an in-depth level to enable its effective use by developers.

Documentation will come in 2 forms:

- Extensive comments in the header files in the code to explain what the code does on a function-by-function basis
- Detailed pages in the external documentation site for reference outside the code

If possible, the documentation in the website will contain auto-generated web versions of the comments in the code.

## 3 Features

### 3.1 Build System

The SDK must support a wide range of different [environments](#supported-environments). To accomplish this, a small custom build system will be required.

This system needs to be compatible with both QMake and CMake. However, we encourage using CMake, especially for NeuralPlex projects that use Qt6. Qt moved to CMake as its main build system with Qt6 and is not actively developing QMake anymore; support for QMake is required mostly to better support projects using older Qt versions.

The build system should be easy to configure from the developer side, and provide the following:

- Macros for dynamic compilation to different environments
  - Example: an `MRS_NEURALPLEX` macro to enable NeuralPlex-specific code
- Automatic configuration of build targets
  - Example: MConn Yocto requires app executables to follow the naming format `normal.app.<short-name>` or `early.app.<short-name>`

### 3.2 Spoke.Zone Client

The SDK will include a full-featured client for the [Spoke.Zone](https://spoke.zone/) platform.

Connected devices interact with Spoke.Zone in a variety of ways. Here are a few:

- Sending live dashboard data via MQTT
- Uploading various types of data files
- OTA software updates
- Triggering alerts

The SDK's client will provide a convenient interface for all of these features.

See https://docs.spoke.zone/ for more information about the platform.

#### 3.2.1 MQTT Connectivity

The SDK will implement an MQTT client using the [`mosquitto`](https://mosquitto.org/api/files/mosquitto-h.html) library.

Necessary features:

- Simple API for applications to connect, disconnect, and reconnect the client
- Simple but comprehensive configuration of the client: host, port, keepalive, username/password, etc
- Simple API for publishing MQTT messages
  - Only require QOS of `0` for now, but higher levels may be supported in the future
- Ability for apps to monitor the current status of the client
  - Apps should be able to dynamically receive status updates via Qt signal-slot connections

The MQTT implementation must support both statically and dynamically linked `mosquitto` libraries according to the environment defined in the [build system](#build-system).

#### 3.2.2 Spoke.Zone API Client

The SDK will also provide a robust client for integrating with the Spoke.Zone API. This client will be accessible to applications and implemented in a way that minimizes the amount of boilerplate required by apps while still providing full functionality.

##### 3.2.2.1 Data File Uploads

Devices can upload data files of various types to Spoke.Zone using the process documented [here](https://docs.spoke.zone/developers/device-integration/data-file-uploads/).

This process is somewhat complicated, simply because of the asynchronous back-and-forth that goes on between the device and Spoke.Zone. Because of this, the SDK's Spoke.Zone client will aim to abstract as much of the process as possible to make things simpler for applications.

The client will include code that handles all of the sequential API requests and processing of responses required for the data file upload process. Its API should only require applications to specify the path of the file to be uploaded and then do the rest of the work with no more input from the app.

Applications should be able to dynamically configure the following:

- Delay time between upload attempts
- Number of attempts to make for each file before failing and moving to another file

The client should provide status updates to applications; specifically, it should provide detailed error information if an error is encountered.

##### 3.2.2.2 OTA Release Downloads

##### 3.2.2.3 Device Token Management

Devices are authenticated with the Spoke.Zone platform via [access tokens](https://docs.spoke.zone/developers/device-integration/device-token-renewal/).

The SDK's Spoke.Zone client will manage the device's access token without requiring any interaction from the main application.

- Read the current token from the configuration file stored on the device
- Determine its expiration date via the JWT-encoded payload
- Refresh the token as the device gets closer to the expiration date via an API request
  - Requires determining the device's CPU ID, which will need to work with all supported MRS products
- Store the new token in the config file

#### 3.2.3 Alerts

The client will provide full support for the [Spoke.Zone alerts feature](https://docs.spoke.zone/reference/alert/).

- Parse and save a device's alerts configuration based on MQTT message from Spoke.Zone
- Cache all MQTT messages during runtime
- Use message cache to monitor the status of each alert, and trigger an alert when all of its conditions are met
  - Should support all condition configurations
- Send alerts to S.Z via MQTT
- Notify apps that an alert was triggered

The monitoring of alerts is a somewhat intensive process, since each alert must be checked every time a new MQTT message is sent. The algorithm's implementation should be as streamlined as possible. If necessary, the alerts algorithm should be moved to its own worker thread to avoid blocking the main application.

### 3.3 CAN Bus

The CAN protocol is a core focus of MRS products, and thus it will be a core feature of the SDK.

Qt provides a [basic API for CAN](https://doc.qt.io/qt-6/qtcanbus-backends.html) that will be used as the backbone of the SDK's CAN API.

The SDK will implement a proxy interface for CAN buses...

### 3.4 Digital I/O

### 3.5 CAN Module Flasher

The SDK will implement MRS's proprietary protocol for flashing connected CAN modules.

The flasher implementation will require integration with a CAN bus proxy interface via Qt signal-slot connections.

The flasher API will be simple:

- The `scan` method will scan the connected CAN bus for MRS modules
  - Results will be returned as a list of objects containing all the relevant data about the modules
- The `select` method will tell one of the selected modules to prepare for flashing
- The `flash` method will read the given S19 package file and flash it to the module
  - Download progress will be incrementally reported back to the app

The flasher will be responsible for notifying the app of the results of each operation and providing robust error handling and output for any issues that occur.

### 3.6 Utilities

Threading helpers, singletons, display brightness control, general Qt helpers...

### 3.7 Tooling

Package generation (IPK, DEB)

CAN code generator?

### 3.8 Future Features

for after MVP (?): modem, GPS, IMU, trace files, network management, co-processor interface, PWM, QTimer alternative, modular compilation targets
