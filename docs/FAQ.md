# Frequently Asked Questions

## General

**Q: Does this need internet access?**
A: No. Atomator connects directly to your machines over your local network via SSH. Internet is only needed for in-app updates.

**Q: Is my data sent anywhere?**
A: No. All credentials are stored locally on your phone (encrypted). All SSH connections go directly to your hosts. Nothing goes through any cloud service.

**Q: How many hosts can it manage?**
A: No hard limit. Tested with 150+ hosts. Actions run sequentially (not all at once) so even large fleets work.

**Q: Does it work over VPN?**
A: Yes. As long as your phone can reach the hosts' IP addresses, Atomator works.

## Connectivity

**Q: Hosts show offline but I know they're on**
A: Make sure your phone is on the same WiFi/network. Use Config > Debug to test. The app pings hosts first, then checks SSH port 22.

**Q: SSH icon is red/dim**
A: The host responds to ping but SSH port 22 is closed. Install SSH: `sudo apt install openssh-server`

**Q: "No hosts with SSH available"**
A: Run Check All Hosts on the Home tab first to scan your network.

## Updates

**Q: "Package conflicts with existing package"**
A: Uninstall the old app and install the new one. This happens once when the signing key changes. After that, updates work seamlessly.

**Q: How do I roll back to an old version?**
A: Config > Check for Updates > All Versions tab > tap any version to download and install.

## Commands

**Q: Commands show no output**
A: Some commands need sudo. Make sure your SSH user has sudo privileges without a password prompt, or the password is correct.

**Q: "dpkg was interrupted"**
A: Use Actions > Maintenance > Fix dpkg. This runs automatically before installs/updates too.

**Q: Send message doesn't show on desktop**
A: Requires `notify-send` or `zenity` on the host. The SSH user must be the same user logged into the desktop.
