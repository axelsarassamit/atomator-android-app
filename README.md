# Atomator Mobile

Remote Linux fleet management from your Android phone via direct SSH.

## Download

Get the latest APK from [Releases](https://github.com/axelsarassamit/atomator-android-app/releases).

## Compatibility

**Managed hosts (targets):**
- Ubuntu (all versions: 20.04, 22.04, 24.04+)
- Xubuntu, Kubuntu, Lubuntu, Ubuntu MATE
- Debian (10, 11, 12+)
- Linux Mint
- Any Debian/Ubuntu-based distribution

**Requirements on managed hosts:**
- SSH server enabled
- A user account with sudo privileges
- NetworkManager (for network-related commands)
- `apt` package manager (used by update/install commands)

**Note:** Some features are desktop-specific:
- Lock screens, send messages, wallpaper — require a desktop environment (Xfce, GNOME, KDE, etc.)
- Hostname display — uses Conky (Xfce optimized but works on others)
- Wake-on-LAN — requires WOL enabled in BIOS

## Features

- Direct SSH from your phone - no server needed
- **In-app updates** - check and install new versions from Settings
- 44+ remote commands as tap actions
- Parallel execution with live results
- Fleet dashboard with health overview
- Host groups with custom names
- Per-host custom SSH credentials
- Wake-on-LAN - all hosts or single host
- MAC address collection
- Send popup messages to all desktops
- Lock all screens instantly
- Edit and remove individual hosts or entire groups
- Encrypted credential storage on device
- Splash screen and custom app icon
- Dark theme UI

## Created by

**Axel Sarassamit** - axel.sarassamit@gmail.com

- CLI: [github.com/axelsarassamit/atomator](https://github.com/axelsarassamit/atomator)
- App: [github.com/axelsarassamit/atomator-android-app](https://github.com/axelsarassamit/atomator-android-app)

## Releases

| Version | Changes |
|---------|---------|
| v1.2.4 | Support all Ubuntu/Debian distros, updated compatibility docs |
| v1.2.3 | Fix app icon generation, verify icon in build logs |
| v1.2.2 | Fix all version references across all files |
| v1.2.5 | Fix app icon - manual copy to mipmap folders as fallback |
| v1.2.0 | In-app updates - check and download new versions from Settings |
| v1.1.7 | Updated logos and icons |
| v1.1.5 | Fix version numbers, About screen, README |
| v1.1.4 | Restore custom creds, remove group, fix MAC collection |
| v1.1.3 | Fix Dart $ escape in MAC command |
| v1.1.0 | Per-host credentials, WOL, About screen, edit host |
| v1.0.0 | Initial release - all 44 scripts, dashboard, host groups |

## Build from Source

```bash
git clone https://github.com/axelsarassamit/atomator-android-app.git
cd atomator-android-app
flutter create --project-name atomator_app .
git checkout -- lib/ assets/ pubspec.yaml scripts/
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
```

## Based on

[Atomator CLI](https://github.com/axelsarassamit/atomator) v.02.09.00
