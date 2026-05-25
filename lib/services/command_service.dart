class Commands {
  static String updateAll() => 'dpkg --configure -a 2>/dev/null; DEBIAN_FRONTEND=noninteractive apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=--force-confold && apt-get autoremove -y && apt-get autoclean -y && echo UPDATE COMPLETE';
  static String updatePurgeKernels() => 'dpkg --configure -a 2>/dev/null; DEBIAN_FRONTEND=noninteractive apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=--force-confold && apt-get autoremove -y --purge && apt-get autoclean -y && echo UPDATE COMPLETE';
  static String disableAutoUpdates() => 'systemctl stop unattended-upgrades 2>/dev/null; systemctl disable unattended-upgrades 2>/dev/null; systemctl stop apt-daily.timer 2>/dev/null; systemctl disable apt-daily.timer 2>/dev/null; echo DONE';
  static String cleanup() => 'dpkg --configure -a 2>/dev/null; apt-get clean -y; apt-get autoclean -y; apt-get autoremove -y; journalctl --vacuum-time=7d 2>/dev/null; find /tmp -type f -atime +7 -delete 2>/dev/null; echo CLEANUP DONE';
  static String reboot() => 'reboot';
  static String shutdown() => 'shutdown -h now';
  static String hostname() => 'hostname';
  static String checkInternet() => 'ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1 && echo INTERNET OK || echo NO INTERNET; ping -c 1 -W 3 google.com >/dev/null 2>&1 && echo DNS OK || echo DNS FAIL';
  static String diskUsage() => 'df -h /';
  static String ramInfo() => 'free -h';
  static String uptime() => 'uptime';
  static String services() => 'for s in ssh sshd NetworkManager networking cron crond rsyslog; do status=inactive; systemctl is-active \$s >/dev/null 2>&1 && status=active; if [ \$status = active ]; then echo \$s: ACTIVE; fi; done; echo done';
  static String hardwareInfo() => 'echo --- Hardware ---; dmidecode -s system-manufacturer 2>/dev/null; dmidecode -s system-product-name 2>/dev/null; echo --- CPU ---; grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2; echo Cores:; nproc 2>/dev/null; echo --- Memory ---; free -h | head -2; echo --- Disk ---; df -h / | tail -1; echo --- OS ---; lsb_release -ds 2>/dev/null || head -1 /etc/os-release 2>/dev/null';
  static String changeDns(String servers) => 'CON=\$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep ethernet | head -1 | cut -d: -f1); if [ -n "\$CON" ]; then nmcli con mod "\$CON" ipv4.dns "$servers" && nmcli con mod "\$CON" ipv4.ignore-auto-dns yes && nmcli con up "\$CON" 2>/dev/null && echo DNS CHANGED || echo FAILED; else echo NO ETHERNET; fi';
  static String disableWifi() => 'nmcli radio wifi off 2>/dev/null && echo WIFI DISABLED || echo FAILED';
  static String lockScreen() => 'export DISPLAY=:0; xflock4 2>/dev/null || loginctl lock-sessions 2>/dev/null || xdg-screensaver lock 2>/dev/null; echo LOCKED';
  static String sendMessage(String title, String body) => 'DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/\$(id -u)/bus notify-send "$title" "$body" --urgency=critical 2>/dev/null; DISPLAY=:0 zenity --info --title="$title" --text="$body" --timeout=30 2>/dev/null; echo MESSAGE SENT';
  static String installPackage(String p) => 'dpkg --configure -a 2>/dev/null; DEBIAN_FRONTEND=noninteractive apt-get update -qq && apt-get install -y $p && echo INSTALLED || echo FAILED';
  static String installFirefox() => 'dpkg --configure -a 2>/dev/null; apt-get update -qq; apt-get install -y firefox 2>/dev/null || apt-get install -y firefox-esr 2>/dev/null || snap install firefox 2>/dev/null && echo INSTALLED || echo FAILED';
  static String installChrome() => 'dpkg --configure -a 2>/dev/null; wget -q -O /tmp/chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" && dpkg -i /tmp/chrome.deb 2>/dev/null || apt-get install -f -y && rm -f /tmp/chrome.deb && echo INSTALLED || echo FAILED';
  static String removeFirefox() => 'dpkg --configure -a 2>/dev/null; apt-get remove -y firefox firefox-esr 2>/dev/null; snap remove firefox 2>/dev/null; apt-get autoremove -y; echo REMOVED';
  static String removeChrome() => 'dpkg --configure -a 2>/dev/null; apt-get remove -y google-chrome-stable 2>/dev/null; apt-get autoremove -y; echo REMOVED';
  static String fixSlowSudo() => 'HNAME=\$(hostname); grep -q "\$HNAME" /etc/hosts || echo "127.0.1.1 \$HNAME" >> /etc/hosts; echo FIXED';
  static String deleteSSHKeys() => 'rm -f ~/.ssh/known_hosts; echo DONE';
  static String changePassword(String user, String pass) => 'printf "%s:%s" "$user" "$pass" | chpasswd && echo PASSWORD CHANGED || echo FAILED';
  static String speedTest() => 'if ! which speedtest-cli >/dev/null 2>&1; then echo MISSING: speedtest-cli not installed; else speedtest-cli --simple; fi';
  static String fixDpkg() => 'dpkg --configure -a && apt-get install -f -y && echo DPKG FIXED';
  static String fleetSummary() => 'RAM=\$(free -m | grep Mem | tr -s " " | cut -d" " -f2); DISK=\$(df / | tail -1 | tr -s " " | cut -d" " -f5 | tr -d "%"); UPT=\$(cat /proc/uptime | cut -d. -f1); echo "\$RAM|\$DISK|\$UPT"';

  // ── Generic removal ────────────────────────────────────────────────────────
  static String removePackage(String p) => 'dpkg --configure -a 2>/dev/null; apt-get remove -y $p 2>/dev/null; apt-get autoremove -y; echo REMOVED';

  // ── App-specific installs ──────────────────────────────────────────────────
  static String installVSCode() => 'dpkg --configure -a 2>/dev/null; wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/ms-archive-keyring.gpg 2>/dev/null && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ms-archive-keyring.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && DEBIAN_FRONTEND=noninteractive apt-get update -qq && apt-get install -y code && echo INSTALLED || echo FAILED';
  static String installDiscord() => 'dpkg --configure -a 2>/dev/null; wget -q -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb" && dpkg -i /tmp/discord.deb 2>/dev/null; apt-get install -f -y 2>/dev/null; rm -f /tmp/discord.deb; dpkg -l discord 2>/dev/null | grep -q "^ii" && echo INSTALLED || echo FAILED';
  static String installZoom() => 'dpkg --configure -a 2>/dev/null; wget -q -O /tmp/zoom.deb "https://zoom.us/client/latest/zoom_amd64.deb" && dpkg -i /tmp/zoom.deb 2>/dev/null; apt-get install -f -y 2>/dev/null; rm -f /tmp/zoom.deb; dpkg -l zoom 2>/dev/null | grep -q "^ii" && echo INSTALLED || echo FAILED';
  static String installSteam() => 'dpkg --configure -a 2>/dev/null; dpkg --add-architecture i386 2>/dev/null; DEBIAN_FRONTEND=noninteractive apt-get update -qq && apt-get install -y steam-launcher 2>/dev/null || apt-get install -y steam 2>/dev/null && echo INSTALLED || echo FAILED';

  // ── Performance ────────────────────────────────────────────────────────────
  static String clearRamCache() => 'sync && echo 3 > /proc/sys/vm/drop_caches && free -h && echo CACHE CLEARED';
  static String setCpuPerformance() => 'for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > \$gov 2>/dev/null; done; echo Governor: \$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo N/A)';
  static String setCpuPowersave() => 'for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo powersave > \$gov 2>/dev/null; done; echo Governor: \$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo N/A)';
  static String setSwappiness(int value) => 'sysctl -w vm.swappiness=$value && echo "vm.swappiness=$value" > /etc/sysctl.d/99-atomator-swappiness.conf && echo SWAPPINESS SET TO $value';
  static String checkTemperatures() => 'echo === CPU ===; for zone in /sys/class/thermal/thermal_zone*; do tp=\$(cat \$zone/type 2>/dev/null); t=\$(cat \$zone/temp 2>/dev/null); [ -n "\$t" ] && echo "\$tp: \$((\$t/1000))C"; done; echo === lm-sensors ===; sensors 2>/dev/null || echo "Not installed — run: apt install lm-sensors && sensors-detect"; echo === Disk ===; hddtemp /dev/sda 2>/dev/null || smartctl -A /dev/sda 2>/dev/null | grep -iE "194|190" || echo N/A';
  static String disableCompositing() => 'DISPLAY=:0 xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null && echo COMPOSITING DISABLED || echo Not Xfce or display unavailable';
  static String enableCompositing() => 'DISPLAY=:0 xfconf-query -c xfwm4 -p /general/use_compositing -s true 2>/dev/null && echo COMPOSITING ENABLED || echo Not Xfce or display unavailable';
  static String disableBluetooth() => 'systemctl stop bluetooth 2>/dev/null; systemctl disable bluetooth 2>/dev/null; rfkill block bluetooth 2>/dev/null; echo BLUETOOTH DISABLED';
  static String enableBluetooth() => 'rfkill unblock bluetooth 2>/dev/null; systemctl enable bluetooth 2>/dev/null; systemctl start bluetooth 2>/dev/null; echo BLUETOOTH ENABLED';
  static String setCpuSchedulutil() => 'for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo schedutil > \$gov 2>/dev/null; done; echo Governor: \$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo N/A)';
  static String disableCups() => 'systemctl stop cups 2>/dev/null; systemctl disable cups 2>/dev/null; echo CUPS DISABLED';
  static String enableCups() => 'systemctl enable cups 2>/dev/null; systemctl start cups 2>/dev/null; echo CUPS ENABLED';
  static String disableAvahi() => 'systemctl stop avahi-daemon 2>/dev/null; systemctl disable avahi-daemon 2>/dev/null; echo AVAHI DISABLED';
  static String enableAvahi() => 'systemctl enable avahi-daemon 2>/dev/null; systemctl start avahi-daemon 2>/dev/null; echo AVAHI ENABLED';
  static String disableThp() => 'echo never > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null; echo THP: \$(cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || echo N/A)';
  static String setThpMadvise() => 'echo madvise > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null; echo THP: \$(cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || echo N/A)';
  static String disablePlymouth() => 'sed -i \'s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/\' /etc/default/grub 2>/dev/null && update-grub 2>/dev/null && echo PLYMOUTH DISABLED || echo GRUB NOT FOUND';
  static String enablePlymouth() => 'sed -i \'s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/\' /etc/default/grub 2>/dev/null && update-grub 2>/dev/null && echo PLYMOUTH ENABLED || echo GRUB NOT FOUND';
  static String trimSsd() => 'fstrim -av 2>/dev/null && echo TRIM DONE || echo fstrim FAILED';
  static String setIoSchedulerBfq() => 'for q in /sys/block/*/queue/scheduler; do echo bfq > \$q 2>/dev/null; done; for dev in /sys/block/*/queue/scheduler; do echo "\$(basename \$(dirname \$(dirname \$dev))): \$(cat \$dev 2>/dev/null)"; done';
  static String setIoSchedulerDeadline() => 'for q in /sys/block/*/queue/scheduler; do echo mq-deadline > \$q 2>/dev/null; done; for dev in /sys/block/*/queue/scheduler; do echo "\$(basename \$(dirname \$(dirname \$dev))): \$(cat \$dev 2>/dev/null)"; done';
}
