---
title: MVP Overview
description: This page outlines the benefits, goals, and features required for the MVP.
---

This document outlines the benefits, goals, and general technical requirements for the Minimum Viable Product (MVP) of the MRS Qt SDK.

<details><summary>Revision History</summary>

| Version | Date | Author | Comments |
| --- | --- | --- | --- |
| 1.0 | 2025-11-06 | @bambam955 | Initial version (#32) |

</details>

## 1 Benefits

This SDK will greatly simplify the development process for software/firmware applications that target MRS Electronics hardware platforms.

New and existing customers for any and all of our products will be able to quickly get started developing their own custom applications with well-built Qt-based utilities that provide **drop-in functionality** for such tasks as **GPIO and CAN interfaces, Spoke.Zone API/MQTT integration, and management of connected CAN modules.**

## 2 Goals

This section defines the major goals for the SDK.

### 2.1 Supported Environments

The SDK must be compatible with a variety of MRS products, OS architectures, and cross-compilation toolchains.

- **MRS Products:** NeuralPlex, MConn, FUSION
- **OS Architectures:** Yocto, Buildroot
- **Qt Versions:**
  - *5.9.1:* MConn/FUSION Buildroot toolchain
  - *5.12.9:* MConn/FUSION Yocto toolchain
  - *5.15.0:* Qt5 desktop toolchain
  - *6.8.1:* Neuralplex toolchain

### 2.2 Documentation

The SDK will be documented at an in-depth level to enable its effective use by developers.

Documentation will come in 2 forms:

- **Extensive comments in the code** to explain all the features of the SDK on a function-by-function basis
- **Detailed external documentation** hosted in a public docs website for reference outside the code

If possible, the documentation in the website will contain auto-generated web versions of the comments in the code.

### 2.3 Automated Testing

A detailed suite of **unit tests** will be implemented for the SDK to make the codebase as stable as possible.

Full test coverage is not necessary for MVP; however, that should be a long-term goal, and the MVP must get as close to full coverage as reasonably possible.

The unit tests will be **run automatically using CI/CD jobs**.

## 3 Features

### 3.1 Build System

The SDK must support a wide range of different [environments](#21-supported-environments). To accomplish this, a small **custom build system** will be required.

This system needs to be **compatible with both QMake and CMake**. However, we encourage using CMake, especially for NeuralPlex projects that use Qt6. Qt moved to CMake as its main build system with Qt6 and is not actively developing QMake anymore; support for QMake is required mostly to better support projects using older Qt versions.

The build system will be easy to configure from the developer side and provide the following:

- **Macros** for dynamic compilation to different environments
  - Example: an `MRS_DEVICE_NEURALPLEX` macro to enable NeuralPlex-specific code
- Automatic configuration of **build targets**
  - Example: MConn Yocto requires app executables to follow the naming format `normal.app.<short-name>` or `early.app.<short-name>`
- Out-of-the-box support for linking the `mosquitto` and CAN flasher libraries when required by parts of the SDK

### 3.2 Spoke.Zone Client

The SDK will include a **full-featured client for the [Spoke.Zone](https://spoke.zone/) platform**.

Connected devices interact with Spoke.Zone in a variety of ways. Here are a few:

- Sending live dashboard data via MQTT
- Uploading various types of data files
- OTA software updates
- Triggering alerts

The SDK's client will provide a convenient interface for all of these features.

See https://docs.spoke.zone/ for more information about Spoke.Zone.

#### 3.2.1 Spoke.Zone API Client

The SDK will provide a robust client for integrating with the Spoke.Zone API. This client will be accessible to applications and implemented in a way that **minimizes required app boilerplate** while still providing full functionality.

The methods for making all API requests should have the same general signature:

- Any request-specific arguments, such as data file ID
- Arguments for a callback function to be executed when the response is returned
  - Necessary because API requests are asynchronous
- Argument to specify the timeout length on the request
- Method immediately returns the success of the initial request

##### 3.2.1.1 Device Token Management

Devices are authenticated with the Spoke.Zone platform via [access tokens](https://docs.spoke.zone/developers/device-integration/device-token-renewal/).

The SDK's Spoke.Zone client will **manage the device's access token** without requiring any interaction from the main application.

- Read the current token from the configuration file stored on the device
- Determine its expiration date via the JWT-encoded payload
- **Refresh the token** as the device gets closer to the expiration date via an API request
  - Requires determining the device's CPU ID, which will need to work with all supported MRS products
- **Store the new token** in the config file

##### 3.2.1.2 Data File Uploads

Devices can **upload data files of various types to Spoke.Zone** using the process documented [here](https://docs.spoke.zone/developers/device-integration/data-file-uploads/).

This process is somewhat complicated, simply because of the asynchronous back-and-forth that goes on between the device and Spoke.Zone. Because of this, the SDK's Spoke.Zone client will aim to abstract as much of the process as possible to make things simpler for applications.

The client will include code that handles all of the sequential API requests and processing of responses required for the data file upload process. Its API will only require applications to **specify the path of the file to be uploaded** and then do the rest of the work with no more input from the app.

Applications will be able to dynamically configure the following:

- Delay time between upload attempts
- Number of attempts to make for each file before failing and moving to another file

The client will provide status updates to applications; specifically, it will provide **detailed error information** if an error is encountered.

##### 3.2.1.3 OTA Release Downloads

Devices can **fetch and download OTA releases from Spoke.Zone** using the process documented [here](https://docs.spoke.zone/developers/device-integration/ota-file-downloads/).

The client will take care of most of the process. Its API will provide simple methods to fetch the list of available OTA files; programmatically review the response to choose the desired release; and download the binary file associated with the release from Spoke.Zone.

Applications will be able to **filter the available releases** list using the options documented [here](https://api.spoke.zone/api-docs/#/ota-files/getOtaFiles).

Downloading an OTA release binary from Spoke.Zone will likely take longer than an average API request; to mitigate the effects of this, binaries will be downloaded in a separate worker thread.

#### 3.2.2 MQTT Connectivity

The SDK will also implement an **MQTT client using the [`mosquitto`](https://mosquitto.org/api/files/mosquitto-h.html) library**.

Necessary features:

- Simple API for applications to **connect, disconnect, and reconnect** the client
- Simple but comprehensive **configuration** of the client: host, port, keepalive, username/password, etc
- Simple API for **publishing MQTT messages**
  - Only require QOS of `0` for now, but higher levels may be supported in the future
- Ability for apps to monitor the current status of the client
  - Apps will be able to dynamically receive status updates via Qt signal-slot connections
- Simple API for **listening to a specific MQTT command** or set of commands

The MQTT implementation must support both statically and dynamically linked `mosquitto` libraries according to the environment defined in the [build system](#31-build-system).

#### 3.2.3 Alerts

The client will provide full **support for the [Spoke.Zone alerts](https://docs.spoke.zone/reference/alert/) feature**.

- Parse and save a device's alerts configuration based on MQTT message from Spoke.Zone
- Cache all MQTT messages during runtime
- Use message cache to monitor the status of each alert, and **trigger an alert when all of its conditions are met**
  - Will support all condition configurations
- **Send alerts to S.Z via MQTT**
- **Notify apps** that an alert was triggered

The monitoring of alerts is a somewhat intensive process, since each alert must be checked every time a new MQTT message is sent. The algorithm's implementation should be as streamlined as possible. If necessary, the alerts algorithm should be moved to its own worker thread to avoid blocking the main application.

### 3.3 CAN Bus

The CAN protocol is a core focus of MRS products, and thus it will be a core feature of the SDK.

Qt provides a [basic API for CAN interfaces](https://doc.qt.io/qt-6/qtcanbus-backends.html) that will be used as the backbone of the SDK's CAN API.

The SDK will implement a **proxy interface for CAN buses using `socketcan`**. This will be the only supported CAN backend because it's what is used on MRS devices. Applications will be able to create new CAN proxies via a factory API in the SDK.

The necessary features for the proxy will be somewhat similar to the MQTT client, with a few added things:

- **Connect and disconnect** the proxy from the bus
- Methods to quickly disable sending/receiving without disconnecting
- **Send messages** on the bus
- **Receive messages** from the bus via Qt signal-slot connections
- Simple API for consumers to **listen to specific CAN IDs** from a particular bus
  - Wrapper over receiver to do the filtering work automatically
- Ability to set the `tx` queue length for a bus
- **Activity monitor** to notify applications if no messages have come over the bus in a specific period of time
  - The timeout length will be configurable by the app
- Notify apps when connection status changes

Any errors of any kind will be gracefully handled and reported to the app.

Additionally, the SDK must provide a convenient **interface for connecting a CAN proxy to a [CAN module flasher](#34-can-module-flasher)** object.

### 3.4 CAN Module Flasher

The SDK will include a closed-source implementation of MRS's proprietary protocol for **flashing connected CAN modules**.

Using the flasher will require integration with a CAN bus proxy interface via Qt signal-slot connections.

The flasher API will be simple:

- The `scan` method will **look for MRS modules** on the connected CAN bus
  - Results will be returned as a list of objects containing all the relevant data about the modules
- The `select` method will tell one of the selected modules to **prepare for flashing**
- The `flash` method will **read and flash the given S19 package file** to the module
  - Flash progress will be incrementally reported back to the app

The flasher will be responsible for notifying the app of the results of each operation and providing **robust error handling** and output for any issues that occur.

#### 3.4.1 Closed-Source Proprietary Flashing Protocol

MRS's protocol for flashing connected CAN modules is proprietary, and thus the implementation of the protocol cannot be entirely open-source.

We recognize that this somewhat undermines the open-source goals of the SDK; however, we decided it would be better to provide a closed-source implementation for use in the SDK than no implementation at all.

So, the CAN flasher library will be precompiled and the binary stored in the SDK repository. Then, during compilation, the library will be statically linked to the rest of the SDK. This is similar to the pattern we use for the `mosquitto` MQTT library in the Spoke.Zone client implementation.

The process for updating the binaries, including who is allowed to do so, must be well-documented.

In the future, we should come up with a better system for integrating the closed-source flasher. Options:

- Move the binaries to a private repo and import as a Git submodule to keep this repo clean
  - Allows for easier verification in the other repo
- Store the binaries with Git LFS
  - Add CI job that verifies a checksum on each build
- Implement system that publishes the binaries as release artifacts and then fetches them before compilation/linking
  - Separate Linux package containing the shared libraries?

However, for now, we will just include the binaries directly to get a basic working implementation going.

### 3.5 Digital GPIOs

MRS products all include a variety of GPIO pins. The SDK must provide an easy **interface for setting up, reading from, and writing to GPIO pins**.

Reading and writing to and from pins must be fully synchronous and as error-free as possible.

#### 3.5.1 Device-Specific Pin Configurations

The SDK will be designed with support for multiple [MRS products](#21-supported-environments), each of which has its own GPIO configuration. To fully support all devices, the SDK must **leverage the [build system](#31-build-system) to know which GPIO pins to make available** to applications in different environments.

#### 3.5.2 Digital GPIO Listeners

The SDK will provide a convenient API for applications to "listen" to a certain GPIO pin. For these pins, the SDK will take care of polling the pin values and notifying the application when a value changes.

When the application registers a listener for a specific pin, the pin will be added to a list of polled pins, and the SDK will read the values at a specified time interval. Applications will be able to configure the length of this polling interval.

### 3.6 General Utilities

The following small features and code utilities will be provided in addition to the features previously listed.

#### 3.6.1 Display Brightness Control

The SDK will provide a simple API for applications to **manage the brightness of the device's display**, if it has one.

Applications will be able to:

- Set the brightness to an arbitrary value (range from `0-100`)
- Configure "awake" and "asleep" brightness values
- Call `sleep` and `wake` functions to send the brightness to those configured values

The SDK will leverage the [build system](#31-build-system) to make this API available only on devices that have an display.

#### 3.6.2 Threading

The SDK will provide a class used for running functions in worker threads. This will be the class used in other parts of the SDK for running heavy operations in separate threads.

#### 3.6.3 Singletons

The SDK will provide a template for using the singleton/service pattern with a class. This template will be used internally for various classes.

### 3.7 Tooling

In addition to the source code itself, the Qt SDK will provide some useful tools to assist developers with various processes, such as generating boilerplate code (eventually) and creating new releases.

#### 3.7.1 Package Generation

The standard way of deploying compiled Qt applications to devices is to bundle them into packages that can be installed by the package manager programs on the display. The process for doing so has quite a few steps and can be tedious to do over and over, so the SDK will include specialized tools for generating these packages.

Buildroot and Yocto operating systems require different package structures because they have different package manager programs: Buildroot includes `opkg` and Yocto includes `dpkg`. The SDK needs to support both.

There will be two scripts, one for IPKs (`opkg`) and another for Debian packages (`dpkg`). Each will include the following:

- User inputs/arguments:
  - Package version number
  - Any desired overrides to static config
- Static configuration file:
  - Location of app executable
  - Location of maintainer scripts (optional)
  - Location of any other files that need included in the package besides the app executable
    - Example: default config files, utility scripts
  - Control file info: package name, organization name, targeted architectures, etc
- Automated steps to generate packages from all of the files specified by the user
- Move the package to wherever the user wants it in their filesystem
- Clean up all leftover files from the packaging process
  - Remove generated control files

### 3.8 Future Features

See our plans for post-MVP features on [this page](/reference/roadmap)!
