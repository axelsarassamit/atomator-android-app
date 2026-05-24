<div align="center">

# ⚡ Atomator Mobile

**Manage your entire Linux fleet from your Android phone.**

Direct SSH • 55+ Commands • Built-in Terminal • Wake-on-LAN • Fleet Dashboard

[![Latest Release](https://img.shields.io/github/v/release/axelsarassamit/atomator-android-app?color=cyan&label=Latest)](https://github.com/axelsarassamit/atomator-android-app/releases)
[![Downloads](https://img.shields.io/github/downloads/axelsarassamit/atomator-android-app/total?color=green&label=Downloads)](https://github.com/axelsarassamit/atomator-android-app/releases)
[![License](https://img.shields.io/badge/License-Free-brightgreen)](LICENSE)

[**Download APK**](https://github.com/axelsarassamit/atomator-android-app/releases) • [**User Manual**](MANUAL.md) • [**CLI Version**](https://github.com/axelsarassamit/atomator)

</div>

---

## What is Atomator?

Atomator is a free Android app that connects directly to your Linux machines over SSH. No cloud services, no monthly fees, no server in between — just your phone and your fleet on the same network.

Whether you manage 5 machines or 500, Atomator lets you update, monitor, and control them all from your pocket.

---

## Key Features

| Feature | Description |
|---------|-------------|
| 📊 **Fleet Dashboard** | Active-job banner, online/offline/SSH status, RAM, disk warnings at a glance |
| 📟 **SSH Terminal** | Full interactive shell — pick a host, type commands |
| 🎯 **Group Targeting** | Run actions on ALL hosts or just a specific group |
| 🔄 **45+ Commands** | Updates, cleanup, DNS change, software, network, info — one tap |
| 📈 **Live Progress** | Progress bar with OK/FAIL count and duration on every action |
| 🔍 **Smart Detection** | Auto-resolves hostname via SSH, DNS, or MAC vendor |
| 📡 **Wake-on-LAN** | Power on machines remotely |
| 💬 **Send Messages** | Push popups to all desktops |
| 🔒 **Lock Screens** | One tap, every screen locked |
| 👤 **Per-Host Credentials** | Different user/password for each device |
| 🌐 **DNS Management** | Change DNS servers on all hosts in one tap |
| 📦 **App Installer** | 10-app catalog (VLC, GIMP, VS Code, Discord, Zoom…) — install or remove |
| ⚡ **Performance Tools** | CPU governor, RAM cache flush, swappiness, temperatures, compositing |
| 📋 **Job History** | Full history with duration, OK/fail counts, copy output |
| 🔄 **In-App Updates** | Download new versions or roll back — from within the app |
| 🛡️ **Encrypted Storage** | Credentials stored securely on device |

---

## Compatibility

**Works with any SSH device:**

| Device Type | Examples |
|-------------|----------|
| 🐧 Linux desktops | Ubuntu, Debian, Xubuntu, Kubuntu, Linux Mint |
| 🖥️ Servers | Ubuntu Server, Debian, any headless Linux |
| 🍓 Single-board | Raspberry Pi, Orange Pi, ODROID |
| 🔌 Network gear | Cisco, Ubiquiti, TP-Link (SSH-enabled switches/routers) |
| 💾 Storage | Synology, QNAP, TrueNAS (SSH access) |
| ☁️ Virtual | VMware, VirtualBox, Proxmox, Docker hosts |

**Requirements:** SSH server + a user with sudo privileges

---

## Screenshots

> *Dashboard • Hosts • Actions • SSH Terminal • Tools • Config*

---

## Quick Start

1. **Download** the [latest APK](https://github.com/axelsarassamit/atomator-android-app/releases)
2. **Install** on your Android phone
3. **Config tab** → set SSH username and password
4. **Hosts tab** → tap + → enter IP or range (e.g. `192.168.0.50-199`)
5. **Home tab** → Check All Hosts
6. **Actions tab** → tap any command to run

---

## Documentation

| Document | Description |
|----------|-------------|
| [**User Manual**](MANUAL.md) | Complete guide to every feature |
| [**CLI Version**](https://github.com/axelsarassamit/atomator) | Bash script version for terminal servers |
| [**Releases**](https://github.com/axelsarassamit/atomator-android-app/releases) | All versions with APKs and release notes |

---

## Release History

<details>
<summary>Click to expand (37 releases)</summary>

| Version | Changes |
|---------|---------|
| v1.6.1 | **SSH hotfix**: robust sudo wrapper using base64 encoding — fixes SSH commands broken by special characters (quotes, `$`, backticks) in passwords or commands |
| v1.6.0 | **App installer** (10-app catalog with install/remove), **Performance section** (CPU governor, RAM cache, swappiness, temperatures, compositing, Bluetooth) |
| v1.5.0 | **Job tracking** (duration, active banner), **DNS change** dialog, password confirm, sudo toggle, copy output, empty-state screens, last-seen times, lint clean |
| v1.4.6 | Fix send message shell syntax |
| v1.4.5 | Fix send message: runs as SSH user |
| v1.4.4 | Fix send message: wall + zenity + notify-send |
| v1.4.2 | Fix Firefox install, dpkg fix on remove |
| v1.4.0 | **Group selector**: choose ALL or specific group |
| v1.3.13 | Auto-fix dpkg before all apt commands |
| v1.3.12 | Cross-distro commands, clean output |
| v1.3.11 | Fix speedtest, cross-distro compatible |
| v1.3.10 | Fix WOL build crash |
| v1.3.9 | Only run on SSH-ready hosts |
| v1.3.8 | **Progress bars** on all actions |
| v1.3.7 | **Smart host resolution** (hostname, DNS, MAC vendor) |
| v1.3.6 | Report a Problem screen |
| v1.3.5 | In-app user manual |
| v1.3.4 | Persistent signing (seamless updates) |
| v1.3.0 | **SSH Terminal** |
| v1.2.24 | Accessible status badges |
| v1.2.22 | SSH indicator per host |
| v1.2.15 | Debug / network test screen |
| v1.2.6 | Version rollback |
| v1.2.0 | **In-app updates** |
| v1.1.0 | Per-host credentials, WOL |
| v1.0.0 | Initial release |

</details>

---

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

**Requirements:** Flutter 3.29+, Java 17, Android SDK

---

## Contributing

Found a bug? Have a feature idea?
- Open an [Issue](https://github.com/axelsarassamit/atomator-android-app/issues)
- Or use the in-app "Report a Problem" in Config tab

---

## Created by

**Axel Sarassamit** — axel.sarassamit@gmail.com

- 📱 App: [atomator-android-app](https://github.com/axelsarassamit/atomator-android-app)
- 🐧 CLI: [atomator](https://github.com/axelsarassamit/atomator)

---

<div align="center">

**Free and open source. Use it, modify it, share it.**

⚡ *The future of fleet management is in your pocket.*

</div>
