# XENECOSYS: Communication Beyond Infrastructure

[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-live-2ea44f?style=flat-square)](https://nihalmishra3009.github.io/XENECOSYS/)
[![Build APK](https://img.shields.io/badge/GitHub%20Actions-APK%20build-blue?style=flat-square)](https://github.com/NihalMishra3009/XENECOSYS/actions)

Decentralised, infrastructure-independent communication ecosystem for a post-digital world. It enables human connectivity when traditional networks fail.

---

## Overview

**Four Core Pillars:**

| Component | Role |
|-----------|------|
| **XenComm** | Mobile app for users to register, message, sync with local nodes |
| **XenHub** | Offline community hub managing message queues and bundling |
| **XenRelay** | Vehicle software transporting encrypted bundles between hubs |
| **XenRoute** | Adaptive routing engine selecting optimal path |

---

## Architecture

### Information Flow
```text
User A -> XenHub A -> Encrypted Bundle -> XenRelay (Data Mule) -> XenHub B -> User B
```

### XenHub (Desktop/Admin Hub)
- **Hub-Blindness:** Stores encrypted blobs only
- **Bundling:** Groups messages into encrypted bundles for physical transport
- **Dashboard:** Track connected users, pending bundles, emergency alerts
- **Local Management:** No cloud dependency

[![XenHub Dashboard UI](XenHub/software.ui/Dashboard.png)](https://youtu.be/j_z4tbJNfmw)

### XenComm (Mobile App)
- **Unique Identity:** HX-XXXXXXXX format
- **Encryption:** AES-256 + RSA-2048
- **Message Priority:** Emergency, Medical, Government, Normal
- **Sync:** Automatic upload/download when near XenHub
- **Offline-First:** Designed for no internet dependency

[<img src="XenComm/app.ui/home.jpg" alt="XenComm Home UI" width="320">](https://youtu.be/j_z4tbJNfmw)

### XenRelay (Data Mule)
Vehicles physically transport encrypted message bundles between hubs.

### XenRoute (Intelligence)
Adaptive routing selects the best delivery path based on cached network metadata.

---

## Debug

- XenHub includes a built-in debug report button in the top bar.
- It shows the current tab, API port, debug mode, platform, and timestamp.
- Test status:
  - XenComm widget tests pass
  - XenHub widget and API tests pass
- Checklist:
  - Debug report opens from the XenHub top bar
  - APK build workflow runs from tagged pushes
  - GitHub Pages site is configured
  - README links for PPT, report, drive, and demo are in place

---

## Project Health

- **Status:** Active and working
- **Tests:** XenComm and XenHub widget suites pass after the latest fixes
- **UI:** Screenshots, clickable previews, and YouTube links are in place
- **Delivery:** APK build workflow is configured for GitHub Actions artifacts
- **Docs:** README files, PPT, report, and drive links are organized

---

## UI Assets

### XenHub UI (`XenHub/software.ui/`)
Screenshots for the XenHub admin interface:
- `Dashboard.png` - System overview and status
- `DTN.png` - Data Transfer Node visualization
- `Emergency broadcast.png` - Alert transmission interface
- `Emergency broadcast message Acknowledgment.png` - Delivery confirmation
- `Queue.png` - Pending message and bundle queue
- `Relay.png` - Data mule and vehicle status tracking
- `User.png` - Connected users and activity management

### XenComm UI (`XenComm/app.ui/`)
Screenshots for the XenComm mobile app:
- `home.jpg` - Main home dashboard
- `Broadcast.jpg.jpg` - Emergency and government broadcast display
- `Contact.jpg.jpg` - User contact list and management
- `Others.jpg.jpg` - Additional utility screens
- `Schedule.jpg.jpg` - Message scheduling and queue management

## Document

- [Team Zephyr PPT](./ppt/Team%20Zephyr.pdf)
- [Report](report/XenEcosys.pdf)
- [Drive Folder](https://drive.google.com/drive/folders/13lk1G2cB8fbUps9Z_fOxAkLu1LRCEh_G)

---

## Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter (Material 3 Design) |
| **State Management** | Riverpod |
| **Persistence** | SQLite (sqflite) |
| **Encryption** | AES-256 + RSA-2048 |
| **Routing** | XenRoute (Opportunistic Networking) |

---

## Repository Structure

```text
XENECOSYS/
|-- .github/
|   `-- workflows/
|       `-- xencomm-release.yml
|-- docs/
|   `-- architecture-diagrams/
|-- ppt/
|-- report/
|-- XenComm/
|   |-- app.ui/
|   |   |-- Broadcast.jpg.jpg
|   |   |-- Contact.jpg.jpg
|   |   |-- home.jpg
|   |   |-- Others.jpg.jpg
|   |   `-- Schedule.jpg.jpg
|   |-- pubspec.yaml
|   |-- analysis_options.yaml
|   |-- README.md
|   |-- LICENSE
|   |-- lib/
|   |-- assets/
|   |-- android/
|   |-- ios/
|   |-- web/
|   |-- linux/
|   |-- macos/
|   |-- windows/
|   `-- test/
|-- XenHub/
|   |-- software.ui/
|   |   |-- Dashboard.png
|   |   |-- DTN.png
|   |   |-- Emergency broadcast.png
|   |   |-- Emergency broadcast message Acknowledgment.png
|   |   |-- Queue.png
|   |   |-- Relay.png
|   |   `-- User.png
|   |-- pubspec.yaml
|   |-- analysis_options.yaml
|   |-- README.md
|   |-- LICENSE
|   |-- lib/
|   |-- assets/
|   |-- android/
|   |-- windows/
|   `-- test/
|-- LICENSE
`-- README.md
```

**Core Folders:**
- `lib/core/` - Constants, config, utilities
- `lib/models/` - Data models
- `lib/services/` - SQLite, crypto, notifications, API
- `lib/ui/screens/` - App screens
- `lib/ui/widgets/` - Reusable UI components
- `lib/ui/themes/` - Material 3 theming
- `lib/simulation/` - DTN visualization
- `assets/` - Images, fonts, data files
- `test/` - Unit and widget tests

---

## Build & Development

### Prerequisites
- Flutter 3.x

### XenComm (Mobile APK)
```bash
cd XenComm
flutter pub get
flutter pub run build_runner build
flutter build apk --release
```

### XenHub (Desktop/Admin)
```bash
cd XenHub
flutter pub get
flutter run
```

---

## Key Features

- **DTN Simulator:** Visualize data mule movement between hubs
- **Emergency Broadcasts:** Highest-priority alerts sync before normal traffic
- **Offline Notifications:** Local-only triggers; no Firebase or push services
- **Infrastructure-Independent:** Every device becomes part of infrastructure
- **Privacy-First:** No central server stores unencrypted data or history
- **Hybrid Modes:** Direct P2P, mesh, DTN-relay

---

## Release Process

**Automated via xencomm-release workflow:**

1. Tag commit, for example `xencomm-v1.0.0`
2. Push the tag to trigger an APK build in GitHub Actions
3. Download the APK from the workflow artifacts

### APK Release
- The Android APK is uploaded as a GitHub Actions artifact.
- Open the workflow run, go to **Artifacts**, and download `xencomm-apk`.
- If you want a published GitHub Release later, create it manually from the tagged build.

---

## Design Philosophy

- **Infrastructure-Independent:** Resilient without centralized networks
- **Privacy:** End-to-end encryption; no unencrypted cloud storage
- **Scalability:** Supports hybrid P2P, mesh, and DTN modes
- **Community-First:** Local hubs empower grassroots connectivity

---

## Authors

| Author | GitHub |
|--------|--------|
| **Disha Mohite** | [@dishamohitedev](https://github.com/dishamohitedev) |
| **Hemant Thakur** | [@stackht](https://github.com/stackht) |
| **Vedh Pokharkar** | [@Vedh28](https://github.com/Vedh28) |
| **Nihal Mishra** | [@NihalMishra3009](https://github.com/NihalMishra3009) |
