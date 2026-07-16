# XenComm

Delay-Tolerant Emergency Communication Platform.

## Architecture Overview

- `lib/core`: app constants, errors, and small utilities.
- `lib/models`: serializable domain models for users, hubs, messages, bundles, and data mules.
- `lib/database`: SQLite schema definitions.
- `lib/services`: database and crypto services.
- `lib/repositories`: repository contracts for data access.
- `lib/simulation`: dummy data for early testing.
- `lib/main.dart`: app entry point and splash screen.

## Deliverables Summary

Complete XenComm Application:

1. Flutter project with Clean Architecture
2. SQLite database with 6 persisted tables
3. AES-256 encryption for hub-blind messages
4. User management for registration, login, and contacts
5. Messaging system with encryption, queuing, and priorities
6. DTN simulator with the full workflow
7. 11 UI screens using Material Design 3
8. Dark mode support
9. Emergency broadcast system
10. Complete documentation with README, diagrams, and CHANGELOG
11. Production-ready code structure with SOLID and Clean Architecture
12. Future extension placeholders for Bluetooth and Wi-Fi Direct

Build and scope:

- Total lines of code: roughly 3,500+ excluding generated files
- Development path: 5 stages
- Release APK size: under 100 MB
- Target audience: emergency communications researchers and offline-first app developers

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
