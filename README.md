# NoteCapture Flutter

A Flutter mobile and web app for NoteCapture MCP - Voice pendant note capture and AI processing.

## Features

- **Dashboard**: Real-time stats, quick sync actions, integration status
- **Notes**: Browse, search, and filter captured notes
- **Integrations**: View status of all connected services
- **Settings**: Configure server URL and preferences
- **Sync**: Pull notes from Omi and Limitless pendants
- **Capture**: Manually capture notes with AI processing

## Supported Integrations

### Capture Sources
- Omi Voice Pendant
- Limitless AI Pendant

### CRM & Business
- Monica CRM
- SomniProperty

### Task Management
- Vikunja
- Donetick
- Apple Reminders

### Scheduling
- Cal.com

### Storage
- Obsidian

## Development

### Prerequisites

- Flutter SDK >= 3.2.0
- Dart SDK >= 3.2.0

### Setup

```bash
# Get dependencies
flutter pub get

# Generate Hive adapters (if needed)
flutter pub run build_runner build

# Run on web
flutter run -d chrome

# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android
```

### Build

```bash
# Build web release
flutter build web --release

# Build Android APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Deployment

### Docker

```bash
# Build Docker image
docker build -t notecapture-flutter .

# Run locally
docker run -p 8080:80 notecapture-flutter
```

### Kubernetes (SomniCluster)

The app is deployed via ArgoCD using the manifests in `/manifests`:

```bash
# Manual apply
kubectl apply -f manifests/notecapture-flutter.yaml
```

ArgoCD will automatically sync changes from this repository.

## Architecture

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── note.dart
│   └── integration.dart
├── providers/             # State management
│   ├── app_state_provider.dart
│   ├── notes_provider.dart
│   └── integrations_provider.dart
├── screens/               # UI screens
│   ├── home_screen.dart
│   ├── notes_screen.dart
│   ├── capture_screen.dart
│   ├── integrations_screen.dart
│   └── settings_screen.dart
├── services/              # API services
│   └── api_service.dart
├── utils/                 # Utilities
│   └── theme.dart
└── widgets/               # Reusable widgets
    ├── glass_card.dart
    ├── stat_card.dart
    ├── integration_chip.dart
    └── activity_item.dart
```

## Configuration

Set the backend URL in Settings or via environment:

```
API_URL=https://notecapture-api.home.lan
```

## License

Proprietary - SomniLabs
