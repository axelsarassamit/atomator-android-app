# Atomator Mobile

Manage your entire Linux fleet from your Android phone via direct SSH. No cloud, no server, no subscriptions.

## Download

**[Download latest APK](https://github.com/axelsarassamit/atomator-android-app/releases)**

## What It Does

Atomator connects directly from your phone to your Linux machines over SSH. Run commands on one host or hundreds simultaneously. Monitor health, install software, send messages, lock screens, wake machines — all from your pocket.

## Compatibility

**Managed hosts:**
- Ubuntu (all versions: 20.04, 22.04, 24.04+)
- Debian (10, 11, 12+)
- Xubuntu, Kubuntu, Lubuntu, Ubuntu MATE
- Linux Mint
- Any Debian/Ubuntu-based distribution
- Any SSH device: switches, routers, firewalls, NAS, Raspberry Pi

**Requirements on managed hosts:**
- SSH server enabled
- A user account with sudo privileges
- NetworkManager (for network commands)
- `apt` package manager (for install/update commands)

## Features

### Fleet Management
- Fleet dashboard with online/offline/SSH status counts
- Check all hosts with progress bar
- Fleet summary: total RAM, disk warnings, uptime stats
- Group selector: run actions on ALL hosts or a specific group

### Remote Commands (44+)
- **System Updates**: update all, purge old kernels, disable auto-updates
- **Maintenance**: cleanup, reboot all, shutdown all, fix dpkg
- **Network**: check internet, speed test, change DNS, disable WiFi
- **Information**: disk usage, RAM, uptime, services, hardware info
- **Software**: install/remove Firefox, Chrome, or any apt package

### SSH Terminal
- Built-in interactive SSH terminal
- Select any host with SSH available
- Type commands with real-time output
- Auto-reconnects on disconnect

### Tools
- Run any custom command on all hosts
- Change SSH password fleet-wide
- Send popup messages to all desktops
- Lock all screens instantly
- Wake-on-LAN (all or single host)
- MAC address collection

### Host Management
- Add single hosts or IP ranges
- Organize into named groups
- Per-host custom SSH credentials
- Smart name resolution: hostname, DNS, MAC vendor (50+ manufacturers)
- Swipe to delete, tap to edit

### App Features
- In-app updates with version rollback
- Debug / network test screen
- Built-in user manual
- Bug report / feature request screen
- Accessible status indicators (icons inside circles, not just colors)
- Encrypted credential storage
- Dark theme UI
- Persistent APK signing (updates without uninstalling)

## Created by

**Axel Sarassamit** — axel.sarassamit@gmail.com

- CLI: [github.com/axelsarassamit/atomator](https://github.com/axelsarassamit/atomator)
- App: [github.com/axelsarassamit/atomator-android-app](https://github.com/axelsarassamit/atomator-android-app)

## Release History

| Version | Changes |
|---------|---------|
| v1.4.6 | Fix send message shell syntax |
| v1.4.5 | Fix send message: runs as SSH user, uses user DBUS session |
| v1.4.4 | Fix send message: simple wall + zenity + notify-send |
| v1.4.3 | Fix send message: temp script approach |
| v1.4.2 | Fix Firefox install (3 package names), dpkg fix on remove |
| v1.4.1 | Fix send message: notify-send + xmessage + wall |
| v1.4.0 | Group selector: choose ALL or specific group before any action |
| v1.3.13 | Auto-fix dpkg before all apt commands |
| v1.3.12 | Fix all commands: clean output, cross-distro, no-sudo for reads |
| v1.3.11 | Fix speedtest output, cross-distro compatible commands |
| v1.3.10 | Fix WOL build crash |
| v1.3.9 | Actions only run on SSH-ready hosts |
| v1.3.8 | Progress bars on all actions and tools |
| v1.3.7 | Smart host resolution: hostname, DNS, MAC vendor (50+) |
| v1.3.6 | Report a Problem screen |
| v1.3.5 | In-app user manual |
| v1.3.4 | Force release signing for seamless updates |
| v1.3.3 | Fix stat cards auto-scaling |
| v1.3.2 | Shorter navigation labels (fit on screen) |
| v1.3.1 | Fix All Versions download |
| v1.3.0 | Built-in SSH terminal |
| v1.2.25 | SSH counter on dashboard |
| v1.2.24 | Accessible status badges with check/X icons |
| v1.2.22 | SSH indicator per host |
| v1.2.20 | Ping uses ICMP first (not just port 22) |
| v1.2.19 | Auto-detect network gateway |
| v1.2.17 | Persistent APK signing with keystore |
| v1.2.15 | Debug / network test screen |
| v1.2.13 | AndroidManifest overhaul with all permissions |
| v1.2.10 | Full network permissions for local SSH |
| v1.2.6 | Version history with rollback |
| v1.2.0 | In-app updates |
| v1.1.0 | Per-host credentials, WOL, About screen |
| v1.0.0 | Initial release: 44 scripts, dashboard, host groups |

## Documentation

- **[User Manual](MANUAL.md)** — complete guide to every feature
- **[CLI Documentation](https://github.com/axelsarassamit/atomator)** — bash script version

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

## License

Free and open source. Use it, modify it, share it.
