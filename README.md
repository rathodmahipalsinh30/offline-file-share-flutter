# Offline File Share Flutter

A Flutter Material 3 offline file-sharing prototype with an Android-first UX and cross-platform-safe Dart UI.

## Features

- Material 3 app shell using `ThemeData(useMaterial3: true)`
- Bottom navigation for **Home**, **Transfers**, and **Settings**
- Send flow with file selection (`file_picker`), peer selection, and transfer progress
- Receive flow with discoverability, pairing token placeholder, nearby sender status, and accept/reject actions
- Transfer history with active/completed/failed states and transfer details bottom sheet
- Local in-memory settings for device name, discoverability, auto-accept, theme mode, and storage location
- Lightweight state management with `ChangeNotifier`

## Architecture

- `lib/models`: share-file, peer, and transfer entities
- `lib/services`: transport and file-selection service boundaries
  - `TransferService` is the abstraction where native Wi-Fi Direct / Nearby Connections transport should be implemented
  - `MockTransportService` provides a complete demo flow in environments without native transport
- `lib/state`: `AppState` for UI and transfer state
- `lib/screens`: Home, Send, Receive, Transfers, and Settings screens
- `lib/widgets`: reusable shared widgets

## Mock transport limitation

This project **does not implement real peer-to-peer transport yet**. Transfers currently use `MockTransportService` to simulate discovery, incoming requests, and progress updates.

To add real offline transfer, replace `MockTransportService` with a platform-backed `TransferService` implementation (e.g. Android Wi-Fi Direct / Nearby Connections via platform channels) while keeping the same interface used by UI/state layers.

## Setup

```bash
flutter pub get
flutter run
```

## Quality checks

```bash
flutter analyze
flutter test
```

## Tests included

- `test/app_navigation_test.dart`: verifies main navigation behavior
- `test/send_flow_test.dart`: verifies key send flow interaction and transfer start
