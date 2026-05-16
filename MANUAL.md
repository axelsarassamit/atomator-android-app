# Atomator Mobile - User Manual

## Getting Started

### First Launch
1. Open the app - you'll see the splash screen with the Atomator logo
2. Go to **Config** tab (bottom right)
3. Tap **SSH Username** and **SSH Password** to set your default credentials
4. Go to **Hosts** tab and tap **+** to add hosts

### Adding Hosts
- **Single host**: Type an IP like `192.168.0.50`
- **IP range**: Type `192.168.0.50-199` to add 150 hosts at once
- **Group**: Give hosts a group name (e.g. "office-a", "servers")
- **Custom credentials**: Check the box to set different SSH user/pass for specific hosts

---

## Tabs

### Home
The main dashboard showing:
- **Total** - number of configured hosts
- **Online** - hosts responding to ping
- **SSH** - hosts with SSH port 22 open
- **Offline** - hosts not responding
- **Groups** - number of host groups
- **Check All Hosts** - ping every host and check SSH
- **Fleet Summary** - RAM, disk, uptime overview
- **Recent** - last 5 actions run

### Hosts
List of all hosts organized by group.
- **Green circle with checkmark** = host online (responds to ping)
- **Red circle with X** = host offline
- **Green terminal icon** = SSH port open
- **Dim terminal icon** = SSH port closed
- **Tap a host** = edit group, custom credentials
- **Swipe left** = delete host
- **Red trash icon on group** = remove entire group
- **Refresh icon** = re-check all hosts

### Actions
All remote commands organized by category:

**System Updates**
- Update All - apt update + upgrade on all hosts
- Update + Purge Kernels - also removes old kernels
- Disable Auto Updates - stops unattended-upgrades

**Maintenance**
- System Cleanup - cache, logs, trash
- Reboot All - restart all hosts (confirmation required)
- Shutdown All - power off all hosts (confirmation required)

**Network**
- Check Internet - verify WAN access per host
- Speed Test - run speedtest-cli
- Change DNS - Cloudflare/Google/Quad9
- Disable WiFi

**Information**
- Disk Usage - check disk percentage
- RAM Info - memory usage
- Uptime - how long running
- Services - SSH, NetworkManager, cron status
- Hardware Info - CPU, model, serial

**Software**
- Install Package - any apt package by name
- Install/Remove Firefox, Chrome

### SSH Terminal
Built-in SSH terminal for interactive commands.
1. Tap the **computer icon** to select a host
2. App connects via SSH
3. Type commands in the input field
4. Output appears in real-time
5. Commands run with sudo

### Tools
**Remote**
- Run Command - execute any command on all hosts
- Change Password - update SSH password fleet-wide
- Send Message - popup notification on all desktops
- Lock Screens - instant lock all desktops

**Wake-on-LAN**
- Collect MAC Addresses - gather from online hosts
- Wake All Hosts - send WOL magic packets
- Wake Single Host - select one host to wake

**Fix**
- Delete SSH Keys - clean known_hosts
- Fix Slow Sudo - add hostname to /etc/hosts

**History**
- Shows last 20 actions with OK/Failed counts

### Config
- **SSH Credentials** - default username and password
- **Fleet info** - host and group counts
- **Collect MAC Addresses** - for Wake-on-LAN
- **Check for Updates** - download new app versions
- **Debug / Network Test** - test connectivity
- **About Atomator** - creator, GitHub links, version
- **Clear All Data** - reset everything

---

## Updating the App

### Check for Updates
1. Go to Config tab
2. Tap "Check for Updates"
3. **Latest tab** shows if a new version is available
4. **All Versions tab** lists every release - tap to download any version
5. After download, tap "Install" or open Downloads folder

### Version Rollback
In the All Versions tab, you can install any previous version to roll back changes.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Host shows offline | Check host is on same network, SSH is running |
| SSH icon dim (red) | SSH port 22 is closed on that host |
| Can't ping hosts | Go to Config > Debug to test connectivity |
| Update won't install | Uninstall app once, then updates work |
| Terminal won't connect | Check credentials in Config, host must have SSH open |
| No hosts found | Make sure you're on the same WiFi network |

## Compatibility

Works with any Debian/Ubuntu-based Linux:
- Ubuntu (all versions)
- Debian 10, 11, 12+
- Xubuntu, Kubuntu, Lubuntu
- Linux Mint
- Any distro with SSH + apt

## Created by

**Axel Sarassamit** - axel.sarassamit@gmail.com
- CLI: github.com/axelsarassamit/atomator
- App: github.com/axelsarassamit/atomator-android-app
