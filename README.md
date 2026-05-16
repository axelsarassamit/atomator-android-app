# Atomator Mobile

Remote Linux fleet management from your Android phone via direct SSH.

## Download

Get the latest APK from [Releases](https://github.com/axelsarassamit/atomator-android-app/releases).

## Compatibility

**Managed hosts:**
- Ubuntu, Xubuntu, Kubuntu, Lubuntu, Debian, Linux Mint
- Any device with SSH: switches, routers, firewalls, NAS, Raspberry Pi

**Requirements:** SSH server + sudo user + apt (for update/install commands)

## Features

- Direct SSH from phone - no server needed
- Built-in SSH terminal for interactive commands
- In-app updates with version rollback
- 44+ remote commands as tap actions
- Progress bars on all operations
- Smart host resolution (hostname, DNS, MAC vendor)
- Per-host custom SSH credentials
- Host groups with custom names
- Wake-on-LAN (all or single host)
- Send popup messages to all desktops
- Lock all screens instantly
- Fleet dashboard with health overview
- Debug / network test screen
- User manual built into the app
- Bug report / feature request screen
- Accessible status indicators (icons, not just colors)
- Encrypted credential storage
- Dark theme UI

## Created by

**Axel Sarassamit** - axel.sarassamit@gmail.com

- CLI: [github.com/axelsarassamit/atomator](https://github.com/axelsarassamit/atomator)
- App: [github.com/axelsarassamit/atomator-android-app](https://github.com/axelsarassamit/atomator-android-app)

## Releases

| Version | Changes |
|---------|---------|
| v1.3.10 | Fix build crash in WOL function |
| v1.3.9 | Actions/tools only run on SSH-ready hosts |
| v1.3.8 | Progress bars on all actions and tools |
| v1.3.7 | Smart host resolution: hostname, DNS, MAC vendor |
| v1.3.6 | Report a Problem screen |
| v1.3.5 | In-app user manual |
| v1.3.4 | Force release signing for seamless updates |
| v1.3.3 | Fix stat cards auto-scaling |
| v1.3.2 | Shorter navigation labels |
| v1.3.1 | Fix All Versions download |
| v1.3.0 | Built-in SSH terminal |
| v1.2.25 | SSH counter on dashboard |
| v1.2.24 | Accessible status badges with icons |
| v1.2.22 | SSH indicator per host |
| v1.2.20 | Ping uses ICMP first |
| v1.2.19 | Network auto-detection |
| v1.2.17 | Persistent APK signing |
| v1.2.15 | Debug / network test screen |
| v1.2.13 | AndroidManifest overhaul |
| v1.2.10 | Full network permissions |
| v1.2.6 | Version rollback |
| v1.3.11 | Fix speedtest output, cross-distro commands, install prompt before speedtest |
| v1.3.12 | Fix all commands: clean output, sendMessage for all users, no-sudo for read commands |
| v1.3.13 | Auto-fix dpkg before all apt commands + new Fix dpkg action |
| v1.4.0 | Group selector: choose ALL hosts or a specific group before running any action/tool |
| v1.4.1 | Fix send message: tries notify-send, xmessage, and wall for maximum compatibility |
| v1.2.0 | In-app updates |
| v1.1.0 | Per-host credentials, WOL, About screen |
| v1.0.0 | Initial release |

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

## Documentation

- [User Manual](MANUAL.md)
- [CLI Documentation](https://github.com/axelsarassamit/atomator)
