# Getting Started with Atomator Mobile

## Prerequisites

- Android phone (5.0+)
- Linux machines with SSH enabled on your network
- SSH username and password with sudo privileges

## Installation

1. Go to [Releases](https://github.com/axelsarassamit/atomator-android-app/releases)
2. Download the latest `atomator.X.Y.Z.apk`
3. Open the APK on your phone and install
4. If prompted by Play Protect, tap "Install anyway" (app is not from Play Store)

## First Setup

### Set Credentials
1. Open the app
2. Go to **Config** tab (bottom right)
3. Tap **SSH Username** — enter your Linux username
4. Tap **SSH Password** — enter your password

### Add Hosts
1. Go to **Hosts** tab
2. Tap the **+** button
3. Enter an IP or range:
   - Single: `192.0.2.50`
   - Range: `192.0.2.50-199` (adds 150 hosts)
4. Optionally set a group name (e.g. "office")
5. Tap **Add**

### Verify Connection
1. Go to **Home** tab
2. Tap **Check All Hosts**
3. Watch the progress bar
4. Green checkmark = online, green terminal icon = SSH ready

## You're Ready!

Go to **Actions** tab and run your first command. Try "Uptime" to verify SSH works.
