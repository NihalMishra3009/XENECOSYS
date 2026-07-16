# XENECOSYS

XENECOSYS is a two-app Flutter workspace:

- `XenComm` is the main decentralized emergency communication app.
- `XenHub` is the companion hub/admin app that serves local APIs and manages shared data.

## What The Project Does

### XenComm

`XenComm` is a delay-tolerant emergency communication platform built for community coordination when normal infrastructure is weak or unavailable. It includes:

- secure messaging and contact management
- emergency alerts and broadcasts
- DTN simulation screens and supporting services
- local persistence, auth, and notification handling
- desktop, web, iOS, and Android targets

### XenHub

`XenHub` is the companion hub app that provides:

- local API server bootstrap
- dashboard, users, DTN, and message queue features
- SQLite-backed data stores
- Flutter desktop and Android targets

## Repository Structure

```text
XENECOSYS/
|-- README.md
|-- LICENSE
|-- .github/
|   `-- workflows/
|       `-- xencomm-release.yml
|-- XenComm/
|   |-- README.md
|   |-- LICENSE
|   `-- Xencomm/
|       |-- lib/
|       |-- assets/
|       |-- android/
|       |-- ios/
|       |-- web/
|       |-- linux/
|       |-- macos/
|       |-- windows/
|       `-- test/
`-- XenHub/
    |-- README.md
    |-- pubspec.yaml
    |-- lib/
    |-- android/
    |-- windows/
    `-- test/
```

## Key Paths

- `XenComm/Xencomm/lib/` - XenComm application code
- `XenComm/Xencomm/assets/` - fonts and static assets
- `XenComm/Xencomm/android/` - Android build files for the APK
- `XenHub/lib/` - XenHub source code
- `XenHub/android/` - Android build files for the hub app
- `.github/workflows/` - release automation

## Build

### XenComm APK

```bash
cd XenComm/Xencomm
flutter pub get
flutter build apk --release
```

### XenHub

```bash
cd XenHub
flutter pub get
flutter run
```

## Releases

The latest XenComm APK is attached to the GitHub Release created from the `xencomm-release` workflow.

To publish one:

1. Push your code.
2. Tag a release, for example `xencomm-v1.0.0`.
3. Let GitHub Actions build the APK and upload it to Releases.

## Notes

- Do not commit generated build output.
- Keep source, assets, and docs in Git.
- `XenComm/Xencomm/` is the main mobile app in this repo.
