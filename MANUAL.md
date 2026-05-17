# Atomator Mobile — User Manual

Complete guide to every feature in the app.

---

## Getting Started

### Step 1: Set Credentials
Go to **Config** tab (bottom right) and tap **SSH Username** and **SSH Password** to enter your default login credentials. These are used for all hosts unless a host has custom credentials.

### Step 2: Add Hosts
Go to **Hosts** tab and tap the **+** button.
- **Single host**: Enter an IP like `192.168.0.50`
- **IP range**: Enter `192.168.0.50-199` to add 150 hosts at once
- **Group name**: Organize hosts into groups like "office-a" or "servers"
- **Custom credentials**: Check the box to set different SSH user/password for a specific host

### Step 3: Check Status
Go to **Home** tab and tap **Check All Hosts**. This pings every host and checks if SSH port 22 is open. A progress bar shows the scan progress.

### Step 4: Start Managing
Go to **Actions** tab to run commands, or **SSH** tab for an interactive terminal.

---

## Tabs

### Home
The main dashboard showing your fleet health at a glance.

**Status Cards:**
- **Total** — number of configured hosts
- **Online** — hosts responding to ping
- **SSH** — hosts with SSH port 22 open (ready for commands)
- **Offline** — hosts not responding
- **Groups** — number of host groups

**Actions:**
- **Check All Hosts** — ping every host and check SSH (with progress bar)
- **Fleet Summary** — popup showing total RAM, disk warnings, uptime range

**Recent** — last 5 actions you ran with OK/FAIL counts.

### Hosts
List of all hosts organized by group.

**Status Icons:**
- Green circle with checkmark = host online (responds to ping)
- Red circle with X = host offline
- Green terminal icon = SSH port 22 open
- Dim terminal icon = SSH port closed

**Actions:**
- Tap **+** to add hosts (single IP, range, or with custom credentials)
- Tap any host to **edit** group or custom credentials
- **Swipe left** on a host to delete it
- Tap **red trash icon** on a group header to remove the entire group
- Tap **refresh** icon to re-check all hosts

### Actions
All remote commands organized by category. When you tap an action:
1. If you have multiple groups: a dialog asks **All hosts** or a **specific group**
2. If only one group: runs immediately
3. Only targets hosts with SSH available

**System Updates:**
- Update All — apt update + upgrade on all hosts
- Update + Purge Kernels — also removes old kernels to free disk
- Disable Auto Updates — stops unattended-upgrades

**Maintenance:**
- System Cleanup — cleans APT cache, old logs, temp files, trash
- Fix dpkg — repairs interrupted package installs
- Reboot All — restarts all hosts (requires confirmation)
- Shutdown All — powers off all hosts (requires confirmation)

**Network:**
- Check Internet — verifies WAN access (ping + DNS)
- Speed Test — runs speedtest-cli (prompts to install if missing)
- Change DNS — choose Cloudflare, Google, or Quad9
- Disable WiFi — permanent WiFi disable

**Information:**
- Disk Usage — shows disk percentage (runs without sudo)
- RAM Info — memory usage table (runs without sudo)
- Uptime — how long each host has been running
- Services — checks SSH, NetworkManager, cron, rsyslog
- Hardware Info — manufacturer, model, CPU, cores, RAM, disk, OS

**Software:**
- Install Package — enter any apt package name
- Install/Remove Firefox — tries firefox, firefox-esr, and snap
- Install/Remove Chrome

### SSH (Terminal)
Built-in interactive SSH terminal.

1. Tap the **computer icon** in the top right to select a host
2. Only hosts with SSH available are shown
3. Type commands in the input field at the bottom
4. Press enter or tap send to execute
5. Output appears in real-time with color coding:
   - Cyan = your command
   - Green = connected
   - Red = error
   - White = command output
6. Commands run with sudo automatically

### Tools
Remote management tools.

**Remote:**
- **Run Command** — execute any command on all hosts (or selected group)
- **Change Password** — update SSH password fleet-wide and locally
- **Send Message** — sends popup notification to all desktops (notify-send + zenity)
- **Lock Screens** — instantly locks all desktop screens

**Wake-on-LAN:**
- **Collect MAC Addresses** — gathers MACs from online hosts
- **Wake All Hosts** — sends WOL magic packets to all
- **Wake Single Host** — pick one host to wake

**Fix:**
- **Delete SSH Keys** — cleans known_hosts
- **Fix Slow Sudo** — adds hostname to /etc/hosts

**History** — shows last 20 actions with OK/FAIL counts. Tap to see details.

### Config
App settings and tools.

- **SSH Credentials** — default username and password for all hosts
- **Fleet info** — host and group counts
- **Collect MAC Addresses** — for Wake-on-LAN
- **Check for Updates** — download new versions or roll back to previous
  - **Latest tab** — checks for new version, shows release notes
  - **All Versions tab** — browse and install any previous version
- **Debug / Network Test** — test internet, local network, SSH, ping, file access
- **User Manual** — this guide
- **Report a Problem** — bug reports and feature requests
- **About Atomator** — version, creator, GitHub links
- **Clear All Data** — reset everything (requires confirmation)

---

## Host Groups

Organize hosts by adding them with group names:
- "office-a", "office-b", "servers", "kiosks", etc.
- When running actions, choose ALL or a specific group
- Groups with no SSH hosts are greyed out
- Remove entire groups from the Hosts tab

---

## Smart Host Resolution

When checking hosts, the app identifies each device:
1. **SSH hostname** — runs `hostname` command (most accurate)
2. **Reverse DNS** — looks up the IP in DNS
3. **MAC vendor** — identifies manufacturer (50+ built-in: Dell, HP, Lenovo, Cisco, Ubiquiti, Raspberry Pi, etc.)
4. **IP address** — always shown

---

## Updating the App

### Check for Updates
Config tab > Check for Updates

**Latest tab:** Shows if a new version is available with release notes. Tap to download and install.

**All Versions tab:** Browse every release. Download any version to upgrade or roll back.

### Auto-fix dpkg
All install, update, and remove commands automatically run `dpkg --configure -a` first to fix interrupted package installs.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Host shows offline | Verify host is on same network, powered on |
| SSH icon red/dim | SSH not running. Install: `sudo apt install openssh-server` |
| Can't ping hosts | Use Config > Debug to test connectivity |
| Actions show "No SSH hosts" | Run Check All Hosts first on Home tab |
| "Set credentials first" | Go to Config and enter SSH username/password |
| Speed test empty | speedtest-cli not installed. Use the install prompt |
| dpkg interrupted error | Use Actions > Maintenance > Fix dpkg |
| Update won't install | Uninstall app once, then updates work (signing key change) |
| Message not showing | Requires notify-send or zenity on the host |
| Terminal won't connect | Check credentials, host must have SSH open |

---

## Created by

**Axel Sarassamit** — axel.sarassamit@gmail.com

- CLI: github.com/axelsarassamit/atomator
- App: github.com/axelsarassamit/atomator-android-app

Free and open source.
