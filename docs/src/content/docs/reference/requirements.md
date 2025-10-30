---
title: MVP Requirements
description: This page documents all of the features required for the MVP of the Qt SDK.
---

This document outlines the benefits, goals, and general technical requirements for the Minimum Viable Product (MVP) of the MRS Qt SDK.

<details><summary>Revision History</summary>

| Version | Date | Author | Comments |
| --- | --- | --- | --- |
| 1.0 | 10/30/2025 | Bennett Moore | Initial version |

</details>

## Benefits

This SDK will greatly simplify the development process for software/firmware applications that target MRS Electronics hardware platforms.

New and existing customers for any and all of our products will be able to quickly get started developing their own custom applications with well-built Qt-based utilities that provide drop-in functionality for such tasks as GPIO and CAN interfaces, Spoke.Zone/MQTT integration, and management of connected CAN modules.

## Goals

This section defines the major goals for the SDK.

- Supports the following MRS products:
  - NeuralPlex
  - MConn
  - FUSION
- Supports the following OS architectures:
  - Yocto
  - Buildroot

## Features

### General

### Spoke.Zone Client

#### MQTT Connectivity

#### Spoke.Zone API Client

##### Data File Uploads

##### OTA Release Downloads

##### Device Token Management

#### Alerts

### CAN Bus

### Digital I/O

### CAN Module Flasher

### Utilities

Threading helpers, general Qt helpers...

### Tooling

maybe?

### Future Features

for after MVP (?): modem, GPS, IMU, trace files, network management, co-processor interface, PWM, QTimer alternative
