# MRS SDK - Qt

Welcome to the official repository for the MRS Electronic Software Development Kit for Qt! This SDK provides developers with the tools, libraries, and documentation needed to create applications for MRS Electronics products using the Qt framework.

## Table of Contents

- [Overview](#overview)
- [Roadmap](#roadmap)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [License](#license)
- [Contact](#contact)
- [Contributing](#contributing)

## Overview

The MRS Electronic SDK for Qt is designed to streamline the development process for applications targeting MRS Electronic hardware platforms. It includes a variety of pre-built Qt-based utilities that provide drop-in functionality for such tasks as interfacing with GPIO and CAN, communicating with the co-processor and modem, and integrating with the Spoke.Zone feature set.

> [!WARNING]
> ⚠️⚠️⚠️
>
> This project is a work-in-progress. Many of the features listed below are in the planning stages, and have not been implemented yet.
> Check back regularly for updates!

## Roadmap

- [x] Add documentation site
- [ ] Add design documents
- [ ] Set up the Qt project
- [ ] Integrate with the [Spoke.Zone OTA API](https://docs.spoke.zone/developers/device-integration/ota-file-downloads/)
- [ ] Add auto-generated API docs
- [ ] CAN bus utilities
- [ ] Add demo application for [NeuralPlex](https://neuralplex.dev)
- [ ] Add demo application for [MConn](https://mconn.dev)
- [ ] Add tool for generating IPK from user application
- [ ] MQTT utilities
- [ ] Integrate with the [Spoke.Zone Data Files API](https://docs.spoke.zone/developers/device-integration/data-file-uploads/)
- [ ] Integrate with Spoke.Zone Alerts
- [ ] Other hardware abstractions (GPIO, co-processor, modem, etc.)
- [ ] Integrate with Spoke.Zone Geo-fencing

## Features

- Cross-platform development support
- Hardware abstraction layer for MRS Electronic products
- Easy integration with the [Spoke.Zone](https://spoke.zone) cloud platform
- Comprehensive documentation and API reference
- Demo applications

<!-- TODO(#7): add demo applications in demos directory -->

## Prerequisites

Coming soon!

<!-- TODO(#5): add prequisites -->

## Installation

### From Source

1. Clone the repository:

   ```bash
   git clone https://github.com/mrs-electronics-inc/mrs-sdk-qt.git
   cd mrs-sdk-qt
   ```

2. Initialize submodules:

   ```bash
   git submodule update --init --recursive
   ```

3. Build the SDK:
   TBD

<!-- TODO(#5): Add build instructions once we have them -->

## Getting Started

Coming soon!

<!-- TODO(#4): add getting started info, with basic example code blocks -->

## Documentation

Comprehensive documentation can be found at https://qt.mrs-electronics.dev.

## License

This project is MIT licensed. See the [LICENSE](./LICENSE) file for more details.

## Contact

Feel free to reach out by emailing us at info@mrs-electronics.com, or by creating a new post in the [discussion boards](https://github.com/mrs-electronics-inc/mrs-sdk-qt/discussions).

## Contributing

**Contributors are welcome!!** Refer to our [contributing guide](./CONTRIBUTING.md) to get started.
