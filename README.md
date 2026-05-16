# Atomator Mobile

Remote Linux fleet management from your Android phone via direct SSH.

## Download

Get the latest APK from [Releases](https://github.com/axelsarassamit/atomator-android-app/releases).

## Compatibility

**Managed hosts:** Ubuntu, Xubuntu, Kubuntu, Lubuntu, Debian, Linux Mint, or any SSH device (switches, routers, NAS, Raspberry Pi)

**Requirements:** SSH server + sudo user + apt (for update/install commands)

## Features

- Direct SSH from phone — no server needed
- Built-in SSH terminal for interactive commands
- Group selector — run actions on all hosts or a specific group
- In-app updates with version rollback
- 44+ remote commands as tap actions
- Progress bars on all operations
- Smart host resolution (hostname, DNS, MAC vendor)
- Per-host custom SSH credentials
- Wake-on-LAN (all or single host)
- Send popup messages to desktops
- Lock all screens instantly
- Auto-fix dpkg before apt commands
- Cross-distro compatible (Ubuntu, Debian, Mint)
- Debug / network test screen
- User manual and bug report built in
- Accessible status indicators
- Encrypted credential storage
- Dark theme UI

## Created by

**Axel Sarassamit** — axel.sarassamit@gmail.com

- CLI: [github.com/axelsarassamit/atomator](https://github.com/axelsarassamit/atomator)
- App: [github.com/axelsarassamit/atomator-android-app](https://github.com/axelsarassamit/atomator-android-app)

## Releases

| Version | Changes |
|---------|---------|
| v1.4.6 | Fix send message shell syntax |
| v1.4.5 | Fix send message — runs as SSH user, not root |
| v1.4.4 | Fix send message — simple wall + zenity + notify-send |
| v1.4.3 | Fix send message — temp script approach |
| v1.4.2 | Fix Firefox install (tries 3 package names), dpkg fix on remove |
| v1.4.1 | Fix send message — notify-send + xmessage + wall |
| v1.4.0 | Group selector — choose ALL or specific group before any action |
| v1.3.13 | Auto-fix dpkg before all apt commands |
| v1.3.12 | Fix all commands — clean output, cross-distro, no-sudo for reads |
| v1.3.11 | Fix speedtest output, cross-distro commands |
| v1.3.10 | Fix WOL build crash |
| v1.3.9 | Actions only run on SSH-ready hosts |
| v1.3.8 | Progress bars on all actions and tools |
| v1.3.7 | Smart host resolution — hostname, DNS, MAC vendor |
| v1.3.6 | Report a Problem screen |
| v1.3.5 | In-app user manual |
| v1.3.4 | Force release signing |
| v1.3.0 | Built-in SSH terminal |
| v1.2.24 | Accessible status badges |
| v1.2.15 | Debug / network test screen |
| v1.2.0 | In-app updates |
| v1.1.0 | Per-host credentials, WOL, About screen |
| v1.0.0 | Initial release |

## Documentation

- [User Manual](MANUAL.md)
- [CLI Documentation](https://github.com/axelsarassamit/atomator)

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
