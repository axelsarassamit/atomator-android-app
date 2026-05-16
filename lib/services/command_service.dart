class Commands {
  static String updateAll() => 'DEBIAN_FRONTEND=noninteractive apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=--force-confold && apt-get autoremove -y && apt-get autoclean -y';
  static String updatePurgeKernels() => 'DEBIAN_FRONTEND=noninteractive apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=--force-confold && apt-get autoremove -y --purge && apt-get autoclean -y';
  static String disableAutoUpdates() => 'systemctl stop unattended-upgrades 2>/dev/null; systemctl disable unattended-upgrades 2>/dev/null; systemctl stop apt-daily.timer 2>/dev/null; systemctl disable apt-daily.timer 2>/dev/null';
  static String cleanup() => 'apt-get clean -y; apt-get autoclean -y; apt-get autoremove -y; journalctl --vacuum-time=7d 2>/dev/null; find /tmp -type f -atime +7 -delete 2>/dev/null';
  static String reboot() => 'reboot';
  static String shutdown() => 'shutdown -h now';
  static String hostname() => 'hostname';
  static String checkInternet() => 'if which curl >/dev/null 2>&1; then if curl -sI --max-time 5 https://www.google.com >/dev/null 2>&1; then echo FULL INTERNET ACCESS; else echo NO HTTP - curl failed; fi; elif which wget >/dev/null 2>&1; then if wget -q --spider --timeout=5 https://www.google.com 2>/dev/null; then echo FULL INTERNET ACCESS; else echo NO HTTP - wget failed; fi; else echo curl/wget not installed; fi; if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then echo PING OK - can reach 8.8.8.8; else echo PING FAILED - no route to internet; fi; echo DNS: ; nslookup google.com 2>/dev/null | tail -2 || echo nslookup not available';
  static String diskUsage() => 'echo Disk:; df -h / | tail -1; echo; echo Inodes:; df -i / | tail -1';
  static String ramInfo() => 'free -h | head -2';
  static String uptime() => 'uptime -p 2>/dev/null || echo N/A';
  static String services() => 'echo SSH: ; systemctl is-active ssh 2>/dev/null || systemctl is-active sshd 2>/dev/null || echo inactive; echo NetworkManager: ; systemctl is-active NetworkManager 2>/dev/null || systemctl is-active networking 2>/dev/null || echo inactive; echo Cron: ; systemctl is-active cron 2>/dev/null || systemctl is-active crond 2>/dev/null || echo inactive; echo Rsyslog: ; systemctl is-active rsyslog 2>/dev/null || echo inactive';
  static String hardwareInfo() => 'echo Manufacturer: ; dmidecode -s system-manufacturer 2>/dev/null || echo N/A; echo Model: ; dmidecode -s system-product-name 2>/dev/null || echo N/A; echo CPU: ; grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 || echo N/A; echo Cores: ; nproc 2>/dev/null || echo N/A; echo RAM: ; free -h | head -2; echo Disk: ; df -h / | tail -1; echo OS: ; lsb_release -ds 2>/dev/null || cat /etc/os-release 2>/dev/null | head -1 || echo Unknown';
  static String changeDns(String servers) => 'CON=\$(nmcli -t -f NAME,TYPE connection show --active | grep ethernet | head -1 | cut -d: -f1); [ -n "\$CON" ] && nmcli con mod "\$CON" ipv4.dns "' + servers + '" && nmcli con mod "\$CON" ipv4.ignore-auto-dns yes && nmcli con up "\$CON" 2>/dev/null && echo OK || echo FAIL';
  static String disableWifi() => 'nmcli radio wifi off && echo OK';
  static String lockScreen() => 'export DISPLAY=:0; xflock4 2>/dev/null || loginctl lock-sessions 2>/dev/null || xdg-screensaver lock 2>/dev/null';
  static String sendMessage(String title, String body) => 'export DISPLAY=:0; notify-send "' + title + '" "' + body + '" --urgency=critical 2>/dev/null || true';
  static String installPackage(String p) => 'DEBIAN_FRONTEND=noninteractive apt-get update -qq && apt-get install -y ' + p;
  static String installFirefox() => installPackage('firefox-esr');
  static String installChrome() => 'wget -q -O /tmp/chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" && dpkg -i /tmp/chrome.deb 2>/dev/null || apt-get install -f -y && rm -f /tmp/chrome.deb';
  static String removeFirefox() => 'apt-get remove -y firefox-esr 2>/dev/null; apt-get autoremove -y';
  static String removeChrome() => 'apt-get remove -y google-chrome-stable 2>/dev/null; apt-get autoremove -y';
  static String fixSlowSudo() => 'HNAME=\$(hostname); grep -q "\$HNAME" /etc/hosts || echo "127.0.1.1 \$HNAME" >> /etc/hosts';
  static String deleteSSHKeys() => 'rm -f ~/.ssh/known_hosts';
  static String changePassword(String user, String pass) => 'printf "%s:%s" "' + user + '" "' + pass + '" | chpasswd';
  static String speedTest() => 'if ! which speedtest-cli >/dev/null 2>&1; then echo MISSING:speedtest-cli not installed. Run Install Package to add it.; else speedtest-cli --simple; fi';
  static String fleetSummary() => 'RAM=\$(free -m | grep Mem | tr -s " " | cut -d" " -f2); DISK=\$(df / --output=pcent | tail -1 | tr -d " %"); UPT=\$(cat /proc/uptime | cut -d. -f1); echo "\$RAM|\$DISK|\$UPT"';
}
