# Atomator Mobile

Remote Xubuntu fleet management from your Android phone via direct SSH.

## Download

Get the latest APK from [Releases](https://github.com/axelsarassamit/atomator-android-app/releases).

## Features

- Direct SSH from your phone (no server needed)
- 44+ remote commands as tap actions
- Parallel execution with live results
- Fleet dashboard (online count, RAM, disk warnings, uptime)
- Host groups with custom names
- Per-host custom SSH credentials
- Wake-on-LAN (all hosts or single host)
- MAC address collection
- Send popup messages to all desktops
- Lock all screens instantly
- Encrypted credential storage on device
- Splash screen with Atomator logo
- Custom app icon
- Dark theme UI

## Created by

**Axel Sarassamit** - axel.sarassamit@gmail.com

- CLI: [github.com/axelsarassamit/atomator](https://github.com/axelsarassamit/atomator)
- App: [github.com/axelsarassamit/atomator-android-app](https://github.com/axelsarassamit/atomator-android-app)

## Build from Source

```bash
git clone https://github.com/axelsarassamit/atomator-android-app.git
cd atomator-android-app
flutter create --project-name atomator_app .
git checkout -- lib/ assets/ pubspec.yaml
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
```

## Based on

[Atomator CLI](https://github.com/axelsarassamit/atomator) v.02.09.00
