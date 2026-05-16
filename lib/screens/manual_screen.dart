import 'package:flutter/material.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Manual')),
      body: ListView(padding: const EdgeInsets.all(16), children: const [
        _Section('Getting Started'),
        _Item('1. Set Credentials', 'Go to Config tab and set your SSH username and password'),
        _Item('2. Add Hosts', 'Go to Hosts tab, tap +, enter IP or range like 192.168.0.50-199'),
        _Item('3. Check Status', 'On Home tab, tap Check All Hosts to scan your network'),
        _Item('4. Run Commands', 'Go to Actions tab to update, manage, or monitor your fleet'),

        _Section('Home Tab'),
        _Item('Status Cards', 'Shows Total, Online, SSH available, Offline, and Groups count'),
        _Item('Check All Hosts', 'Pings every host and checks if SSH port 22 is open'),
        _Item('Fleet Summary', 'Shows total RAM, disk warnings, and uptime across all hosts'),

        _Section('Hosts Tab'),
        _Item('Status Icons', 'Green circle + checkmark = online. Red circle + X = offline. Green terminal = SSH open'),
        _Item('Add Host', 'Tap + button. Enter single IP or range. Optionally set custom credentials'),
        _Item('Edit Host', 'Tap any host to change group or set custom SSH credentials'),
        _Item('Delete Host', 'Swipe left on any host to delete'),
        _Item('Remove Group', 'Tap red trash icon on group header to remove all hosts in that group'),

        _Section('Actions Tab'),
        _Item('System Updates', 'Update all, purge kernels, disable auto-updates'),
        _Item('Maintenance', 'Cleanup, reboot all, shutdown all'),
        _Item('Network', 'Check internet, speed test, change DNS, disable WiFi'),
        _Item('Information', 'Disk usage, RAM, uptime, services, hardware info'),
        _Item('Software', 'Install any package, Firefox, Chrome'),
        _Item('How It Works', 'Each action runs the command via SSH on all online hosts in parallel'),

        _Section('SSH Terminal'),
        _Item('Connect', 'Tap computer icon to select a host with SSH available'),
        _Item('Commands', 'Type any command - runs with sudo automatically'),
        _Item('Output', 'Real-time colored output. Cyan = your command, green = connected, red = error'),

        _Section('Tools Tab'),
        _Item('Run Command', 'Execute any custom command on all hosts'),
        _Item('Change Password', 'Updates SSH password on all hosts and saves locally'),
        _Item('Send Message', 'Sends popup notification to all desktops'),
        _Item('Lock Screens', 'Instantly locks all desktop screens'),
        _Item('Wake-on-LAN', 'Collect MAC addresses first, then wake hosts'),

        _Section('Config Tab'),
        _Item('SSH Credentials', 'Default username/password for all hosts'),
        _Item('Check for Updates', 'Download latest version or browse all versions'),
        _Item('Debug', 'Test network connectivity, DNS, SSH, ping'),
        _Item('About', 'Version info, creator, GitHub links'),

        _Section('Troubleshooting'),
        _Item('Host offline?', 'Check same WiFi network. Verify host is powered on'),
        _Item('SSH icon red?', 'SSH server not running on host. Install with: sudo apt install openssh-server'),
        _Item('Cant connect?', 'Use Debug screen in Config to test. Check firewall'),
        _Item('Update fails?', 'Uninstall app once after keystore change. Then updates work'),

        SizedBox(height: 40),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyan, letterSpacing: 1)),
  );
}

class _Item extends StatelessWidget {
  final String title;
  final String desc;
  const _Item(this.title, this.desc);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('  ', style: TextStyle(fontSize: 12)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white60)),
      ])),
    ]),
  );
}
