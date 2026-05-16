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

**Desktop-specific features:**
- Lock screens, send messages, wallpaper - require a desktop environment
- Hostname display - uses Conky
- Wake-on-LAN - requires WOL enabled in BIOS

## Features

- Direct SSH from your phone - no server needed
- In-app updates with version rollback
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
| v1.2.13 | Fix permissions: store full AndroidManifest, network security config for local SSH |
| v1.2.12 | Fix install after download, show release notes, auto-install APK |
| v1.2.11 | Fix same-version showing as update |
| v1.2.10 | All permissions: local network, WiFi, WOL multicast, storage |
| v1.2.9 | Add internet and network permissions to AndroidManifest |
| v1.2.8 | Fix bad import path in update service |
| v1.2.7 | Robust update system - better download, error handling |
| v1.2.6 | Version history with rollback - browse and install any previous version |
| v1.2.5 | Fix app icon - manual copy to mipmap folders |
| v1.2.4 | Support all Ubuntu/Debian distros, compatibility docs |
| v1.2.3 | Fix app icon generation with debug output |
| v1.2.2 | Fix all version references across all files |
| v1.2.1 | Fix private member access in update service |
| v1.2.14 | Verify permissions in build logs, confirm INTERNET and cleartext traffic |
| v1.2.15 | Add debug screen: test internet, local network, SSH, ping, file access |
| v1.2.16 | Fix APK install using open_filex, add Open Downloads folder button |
| v1.2.17 | Persistent APK signing with keystore - updates install without uninstalling |
| v1.2.18 | Progress bar on Check All Hosts, spinner on Hosts refresh, sequential checking with live updates |
| v1.2.19 | Auto-detect network gateway, scan for SSH hosts, no more hardcoded 192.168.1.x |
| v1.2.20 | Fix ping: 5s timeout, ICMP ping fallback if SSH port closed |
| v1.2.21 | Ping uses ICMP first (not port 22), improved signing with verification |
| v1.2.22 | SSH indicator icon per host - green terminal icon if SSH works, red if only ping |
| v1.2.23 | Bigger status indicators (16px circles, 18px SSH icon) |
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
git checkout -- lib/ assets/ pubspec.yaml scripts/ android_manifest/
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
```

## Based on

[Atomator CLI](https://github.com/axelsarassamit/atomator) v.02.09.00
