# XenHub

XenHub is the desktop and admin hub for the XENECOSYS ecosystem. It provides local control over users, message queues, encrypted bundles, DTN simulation, and hub-side coordination without depending on central cloud infrastructure.

[<img src="../XenHub/software.ui/Dashboard.png" alt="XenHub Dashboard UI" width="360">](https://youtu.be/j_z4tbJNfmw)

## Project Description

XenHub acts as the operational control center for offline and low-connectivity communication. It is designed to manage local hub activity, track connected users, bundle and protect messages, and visualize data transfer across delay-tolerant paths.

The app focuses on:

- local-first hub management
- encrypted message queue handling
- user tracking and coordination
- DTN and relay visibility
- offline communication support
- desktop-oriented admin workflows

## What It Does

- Tracks users connected to the hub
- Manages message queues and encrypted bundles
- Supports DTN simulation and relay visibility
- Exposes API and SQLite-backed local data handling
- Provides a desktop-style Flutter interface for admin workflows

## File Structure

```text
XenHub/
|-- README.md
|-- XENHUB
|-- software.ui/
|   |-- Dashboard.png
|   |-- DTN.png
|   |-- Emergency broadcast.png
|   |-- Emergency broadcast message Acknowledgment.png
|   |-- Queue.png
|   |-- Relay.png
|   `-- User.png
|-- lib/
|   |-- main.dart
|   `-- src/
|       |-- app.dart
|       |-- core/
|       |   |-- api/
|       |   |-- database/
|       |   |-- navigation/
|       |   `-- theme/
|       |-- features/
|       |   |-- dashboard/
|       |   |-- dtn/
|       |   |-- message_queue/
|       |   |-- relay/
|       |   `-- users/
|       `-- ...
|-- android/
|-- windows/
|-- test/
|-- pubspec.yaml
`-- analysis_options.yaml
```

## Notes

- `software.ui/` contains UI screenshots for the hub interface.
- `lib/src/` holds the app source code organized by feature.
- Generated folders such as `build/` and `.dart_tool/` should not be committed.

## APK Release

No XenHub release has been published yet.

When a build is published, the XenHub APK or desktop build can be shared as a GitHub Actions artifact or packaged into a GitHub Release.

To download it:

1. Open the repository on GitHub.
2. Go to **Actions** or **Releases**.
3. Download the latest XenHub build asset if one is available.
