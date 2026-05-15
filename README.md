# Atomator Mobile

Remote Xubuntu Management from your Android phone via direct SSH.

## Download

Get the latest APK from [Releases](https://github.com/axelsarassamit/atomator-android-app/releases).

## Features

- Direct SSH from your phone to all hosts
- All 44 Atomator scripts as tap actions
- Parallel execution with live results
- Fleet dashboard with health overview
- Host groups with add/remove/range support
- Encrypted credential storage on device
- Splash screen with Atomator logo
- Custom app icon
- Dark theme UI

## Build from Source

```bash
git clone https://github.com/axelsarassamit/atomator-android-app.git
cd atomator-android-app
flutter create --project-name atomator_app .
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
```

## Based on

[Atomator CLI](https://github.com/axelsarassamit/atomator) v.02.09.00
