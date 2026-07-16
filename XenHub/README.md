# XenHub

XenHub is the desktop/admin hub for the XENECOSYS ecosystem. It manages local users, message queues, DTN simulation, bundle handling, and hub-side coordination without depending on central cloud infrastructure.

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
