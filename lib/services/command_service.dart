class Commands {
  static String updateAll() => 'DEBIAN_FRONTEND=noninteractive apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=--force-confold && apt-get autoremove -y && apt-get autoclean -y';
  static String updatePurgeKernels() => 'DEBIAN_FRONTEND=noninteractive apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=--force-confold && apt-get autoremove -y --purge && apt-get autoclean -y';
  static String disableAutoUpdates() => 'systemctl stop unattended-upgrades 2>/dev/null; systemctl disable unattended-upgrades 2>/dev/null; systemctl stop apt-daily.timer 2>/dev/null; systemctl disable apt-daily.timer 2>/dev/null';
  static String cleanup() => 'apt-get clean -y; apt-get autoclean -y; apt-get autoremove -y; journalctl --vacuum-time=7d 2>/dev/null; find /tmp -type f -atime +7 -delete 2>/dev/null';
  static String reboot() => 'reboot';
  static String shutdown() => 'shutdown -h now';
  static String hostname() => 'hostname';
  static String checkInternet() => 'if curl -sI --max-time 5 https://www.google.com >/dev/null 2>&1; then echo INTERNET; elif ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then echo PING_ONLY; else echo NO_INTERNET; fi';
  static String diskUsage() => 'df -h / --output=pcent,size | tail -1';
  static String ramInfo() => 'free -h | grep Mem | tr -s " " | cut -d" " -f2,3,4';
  static String uptime() => 'uptime -p 2>/dev/null || echo N/A';
  static String services() => 'echo SSH:; systemctl is-active ssh 2>/dev/null; echo NM:; systemctl is-active NetworkManager 2>/dev/null; echo Cron:; systemctl is-active cron 2>/dev/null; echo Rsyslog:; systemctl is-active rsyslog 2>/dev/null';
  static String hardwareInfo() => 'echo MFR:; dmidecode -s system-manufacturer 2>/dev/null || echo N/A; echo MDL:; dmidecode -s system-product-name 2>/dev/null || echo N/A; echo CPU:; grep -m1 "model name" /proc/cpuinfo | cut -d: -f2; echo RAM:; free -h | grep Mem | tr -s " " | cut -d" " -f2';
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
  static String speedTest() => 'which speedtest-cli >/dev/null 2>&1 || apt-get install -y speedtest-cli >/dev/null 2>&1; speedtest-cli --simple 2>/dev/null';
  static String fleetSummary() => 'RAM=\$(free -m | grep Mem | tr -s " " | cut -d" " -f2); DISK=\$(df / --output=pcent | tail -1 | tr -d " %"); UPT=\$(cat /proc/uptime | cut -d. -f1); echo "\$RAM|\$DISK|\$UPT"';
}
