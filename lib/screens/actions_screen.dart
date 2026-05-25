import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/host_provider.dart';
import '../providers/job_provider.dart';
import '../services/ssh_service.dart';
import '../services/command_service.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import 'job_screen.dart';

class ActionsScreen extends StatelessWidget {
  const ActionsScreen({super.key});

  void _run(BuildContext context, String name, String cmd, {bool sudo = true, int par = 5}) {
    final hp = context.read<HostProvider>();
    final creds = hp.credentials;
    if (creds == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Set SSH credentials in Config first.'))); return; }
    final allSsh = hp.hosts.where((h) => h.sshOpen).toList();
    if (allSsh.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hosts with SSH available. Run Check All Hosts first.'))); return; }
    final groups = hp.groups;
    if (groups.length <= 1) {
      _execute(context, name, cmd, allSsh, sudo: sudo, par: par);
      return;
    }
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: Text('Run: $name', style: const TextStyle(fontSize: 14)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.select_all, color: Colors.cyan),
          title: Text('All hosts (${allSsh.length})', style: const TextStyle(fontSize: 14)),
          onTap: () { Navigator.pop(context); _execute(context, name, cmd, allSsh, sudo: sudo, par: par); },
        ),
        const Divider(color: Colors.white12),
        ...groups.map((g) {
          final groupHosts = hp.hostsInGroup(g).where((h) => h.sshOpen).toList();
          return ListTile(
            leading: const Icon(Icons.folder, color: Colors.orange, size: 20),
            title: Text('[$g] (${groupHosts.length})', style: const TextStyle(fontSize: 14)),
            enabled: groupHosts.isNotEmpty,
            onTap: groupHosts.isEmpty ? null : () { Navigator.pop(context); _execute(context, '$name [$g]', cmd, groupHosts, sudo: sudo, par: par); },
          );
        }),
      ]),
    ));
  }

  void _execute(BuildContext context, String name, String cmd, List<Host> hosts, {bool sudo = true, int par = 5}) {
    final hp = context.read<HostProvider>();
    final jp = context.read<JobProvider>();
    final job = jp.startJob(name);
    Navigator.push(context, MaterialPageRoute(builder: (_) => JobScreen(job: job, totalHosts: hosts.length)));
    () async {
      for (final h in hosts) {
        final creds = hp.credsForHost(h);
        final r = await SSHService.runCommand(h.ip, creds, cmd, sudo: sudo);
        jp.addResult(job, r);
      }
      jp.finishJob(job);
    }();
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _speedTestDialog(BuildContext ctx) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: const Text('Speed Test'),
      content: const Text('This requires speedtest-cli on each host.\nIf not installed, results will show MISSING.\n\nInstall speedtest-cli first?'),
      actions: [
        TextButton(onPressed: () { Navigator.pop(ctx); _run(ctx, 'Speed Test', Commands.speedTest(), par: 3); }, child: const Text('Run Test')),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _run(ctx, 'Install speedtest-cli', Commands.installPackage('speedtest-cli')); }, child: const Text('Install First')),
      ],
    ));
  }

  void _confirm(BuildContext ctx, String name, String cmd) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: Text('Confirm: $name'),
      content: const Text('Are you sure?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () { Navigator.pop(ctx); _run(ctx, name, cmd); }, child: const Text('Yes')),
      ],
    ));
  }

  void _dnsDialog(BuildContext ctx) {
    final c = TextEditingController(text: '1.1.1.1 8.8.8.8');
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: const Text('Change DNS'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: c, decoration: const InputDecoration(labelText: 'DNS servers (space-separated)', border: OutlineInputBorder(), hintText: '1.1.1.1 8.8.8.8')),
        const SizedBox(height: 8),
        const Text('Applies to active ethernet via NetworkManager', style: TextStyle(fontSize: 11, color: Colors.white38)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (c.text.trim().isEmpty) { return; }
          Navigator.pop(ctx);
          _run(ctx, 'Change DNS', Commands.changeDns(c.text.trim()));
        }, child: const Text('Apply')),
      ],
    ));
  }

  void _pkgDialog(BuildContext ctx) {
    final c = TextEditingController();
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: const Text('Install Package'),
      content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'Package name(s)', border: OutlineInputBorder(), hintText: 'htop neofetch')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (c.text.trim().isEmpty) { return; }
          Navigator.pop(ctx);
          _run(ctx, 'Install ${c.text.trim()}', Commands.installPackage(c.text.trim()));
        }, child: const Text('Install')),
      ],
    ));
  }

  void _appDialog(BuildContext ctx) {
    final apps = <_AppDef>[
      _AppDef('Firefox',     'Web browser (ESR)',        Icons.web,                  Colors.orange,     Commands.installFirefox(),                        Commands.removeFirefox()),
      _AppDef('Chrome',      'Google Chrome browser',    Icons.public,               Colors.blue,       Commands.installChrome(),                         Commands.removeChrome()),
      _AppDef('VLC',         'Universal media player',   Icons.play_circle_outline,  Colors.orange,     Commands.installPackage('vlc'),                   Commands.removePackage('vlc')),
      _AppDef('GIMP',        'Photo & image editor',     Icons.brush,                Colors.purple,     Commands.installPackage('gimp'),                  Commands.removePackage('gimp')),
      _AppDef('LibreOffice', 'Office suite',             Icons.description,          Colors.cyan,       Commands.installPackage('libreoffice'),            Commands.removePackage('libreoffice')),
      _AppDef('Thunderbird', 'Email client',             Icons.email,                Colors.blue,       Commands.installPackage('thunderbird'),            Commands.removePackage('thunderbird')),
      _AppDef('VS Code',     'Code editor',              Icons.code,                 Colors.blueAccent, Commands.installVSCode(),                         Commands.removePackage('code')),
      _AppDef('Remmina',     'Remote desktop (RDP/VNC)', Icons.desktop_windows,      Colors.teal,       Commands.installPackage('remmina remmina-plugin-rdp'), Commands.removePackage('remmina')),
      _AppDef('Discord',     'Chat & voice',             Icons.forum,                const Color(0xFF7289DA), Commands.installDiscord(),               Commands.removePackage('discord')),
      _AppDef('Zoom',        'Video meetings',           Icons.video_call,           Colors.blue,       Commands.installZoom(),                           Commands.removePackage('zoom')),
      _AppDef('FileZilla',   'FTP / SFTP client',        Icons.folder_open,          Colors.orange,     Commands.installPackage('filezilla'),             Commands.removePackage('filezilla')),
      _AppDef('Steam',       'Gaming platform',          Icons.sports_esports,       Colors.blueGrey,   Commands.installSteam(),                          Commands.removePackage('steam')),
    ];

    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: const Text('Install Applications'),
      contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      content: SizedBox(
        width: double.maxFinite,
        height: 580,
        child: ListView.builder(
          itemCount: apps.length,
          itemBuilder: (_, i) {
            final app = apps[i];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Row(children: [
                  Icon(app.icon, color: app.color, size: 26),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(app.subtitle, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                  ])),
                  TextButton(
                    onPressed: () { Navigator.pop(ctx); _run(ctx, 'Remove ${app.name}', app.removeCmd); },
                    style: TextButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 6)),
                    child: const Text('Remove', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () { Navigator.pop(ctx); _run(ctx, 'Install ${app.name}', app.installCmd); },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10), minimumSize: const Size(64, 32), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: const Text('Install', style: TextStyle(fontSize: 11)),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
    ));
  }

  void _swappinessDialog(BuildContext ctx) {
    const options = [
      (value: 10,  label: '10 — Desktop optimized (recommended)'),
      (value: 30,  label: '30 — Balanced'),
      (value: 60,  label: '60 — Default (reset to system default)'),
      (value: 80,  label: '80 — Server / high-memory pressure'),
    ];
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: const Text('Set Swappiness'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Lower = less swap usage, better for desktops with plenty of RAM.', style: TextStyle(fontSize: 12, color: Colors.white38)),
        const SizedBox(height: 12),
        ...options.map((o) => ListTile(
          dense: true,
          title: Text(o.label, style: const TextStyle(fontSize: 13)),
          onTap: () { Navigator.pop(ctx); _run(ctx, 'Set Swappiness ${o.value}', Commands.setSwappiness(o.value)); },
        )),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
    ));
  }

  void _perfDialog(BuildContext ctx) {
    showDialog(context: ctx, builder: (dCtx) {
      void go(String name, String cmd, {bool sudo = true}) {
        Navigator.pop(dCtx);
        _run(ctx, name, cmd, sudo: sudo);
      }
      Widget btn(String label, Color col, VoidCallback onTap) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: col,
          side: BorderSide(color: col),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          minimumSize: const Size(0, 26),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 11),
        ),
        child: Text(label),
      );
      Widget row(String title, String sub, IconData icon, List<Widget> btns) => Card(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        child: Padding(padding: const EdgeInsets.fromLTRB(10, 8, 8, 8), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: Colors.white54),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(sub, style: const TextStyle(fontSize: 11, color: Colors.white38)),
              ])),
            ]),
            const SizedBox(height: 6),
            Wrap(spacing: 4, runSpacing: 4, children: btns),
          ],
        )),
      );
      return AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Performance Settings'),
        contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
        content: SizedBox(
          width: double.maxFinite,
          height: 520,
          child: ListView(children: [
            row('CPU Governor', 'Frequency scaling policy', Icons.bolt, [
              btn('Powersave', Colors.orange, () => go('CPU Powersave', Commands.setCpuPowersave())),
              btn('Balanced', Colors.amber, () => go('CPU Balanced', Commands.setCpuSchedulutil())),
              btn('Performance', Colors.green, () => go('CPU Performance', Commands.setCpuPerformance())),
            ]),
            row('Desktop Compositing', 'Xfce desktop effects', Icons.desktop_windows, [
              btn('Disable', Colors.orange, () => go('Disable Compositing', Commands.disableCompositing())),
              btn('Enable', Colors.green, () => go('Enable Compositing', Commands.enableCompositing())),
            ]),
            row('Bluetooth', 'BT service / rfkill', Icons.bluetooth, [
              btn('Disable', Colors.orange, () => go('Disable Bluetooth', Commands.disableBluetooth())),
              btn('Enable', Colors.blue, () => go('Enable Bluetooth', Commands.enableBluetooth())),
            ]),
            row('CUPS Printing', 'Print service', Icons.print, [
              btn('Disable', Colors.orange, () => go('Disable CUPS', Commands.disableCups())),
              btn('Enable', Colors.green, () => go('Enable CUPS', Commands.enableCups())),
            ]),
            row('Avahi / mDNS', 'Local network discovery', Icons.wifi, [
              btn('Disable', Colors.orange, () => go('Disable Avahi', Commands.disableAvahi())),
              btn('Enable', Colors.green, () => go('Enable Avahi', Commands.enableAvahi())),
            ]),
            row('Transparent Huge Pages', 'Kernel memory allocation', Icons.memory, [
              btn('Disable', Colors.orange, () => go('Disable THP', Commands.disableThp())),
              btn('madvise', Colors.cyan, () => go('THP: madvise', Commands.setThpMadvise())),
            ]),
            row('I/O Scheduler', 'Block device I/O policy', Icons.storage, [
              btn('BFQ', Colors.purple, () => go('I/O: BFQ', Commands.setIoSchedulerBfq())),
              btn('mq-deadline', Colors.teal, () => go('I/O: mq-deadline', Commands.setIoSchedulerDeadline())),
            ]),
            row('Plymouth Splash', 'Boot splash screen (GRUB)', Icons.computer, [
              btn('Disable', Colors.orange, () => go('Disable Plymouth', Commands.disablePlymouth())),
              btn('Enable', Colors.green, () => go('Enable Plymouth', Commands.enablePlymouth())),
            ]),
            row('SSD TRIM', 'fstrim all mounted SSDs', Icons.cleaning_services, [
              btn('Run TRIM', Colors.cyan, () => go('SSD TRIM', Commands.trimSsd())),
            ]),
            row('Swappiness', 'Swap usage tendency', Icons.tune, [
              btn('Adjust...', Colors.cyan, () { Navigator.pop(dCtx); _swappinessDialog(ctx); }),
            ]),
            row('RAM Cache', 'Flush page cache & dentries', Icons.memory, [
              btn('Clear', Colors.cyan, () => go('Clear RAM Cache', Commands.clearRamCache())),
            ]),
            row('Temperatures', 'CPU zones + lm-sensors', Icons.thermostat, [
              btn('Check', Colors.cyan, () => go('Temperatures', Commands.checkTemperatures(), sudo: false)),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Close'))],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Actions')), body: ListView(children: [

      // ── SYSTEM UPDATES ─────────────────────────────────────────────────────
      const SectionHeader(title: 'SYSTEM UPDATES'),
      ActionCard(icon: Icons.system_update, title: 'Update All', subtitle: 'apt update + upgrade', onTap: () => _run(context, 'Update All', Commands.updateAll())),
      ActionCard(icon: Icons.cleaning_services, title: 'Update + Purge Kernels', subtitle: 'Frees disk space', onTap: () => _run(context, 'Update + Purge', Commands.updatePurgeKernels())),
      ActionCard(icon: Icons.block, title: 'Disable Auto Updates', subtitle: 'Stop unattended-upgrades', onTap: () => _run(context, 'Disable Updates', Commands.disableAutoUpdates())),

      // ── MAINTENANCE ────────────────────────────────────────────────────────
      const SectionHeader(title: 'MAINTENANCE'),
      ActionCard(icon: Icons.delete_sweep, title: 'System Cleanup', subtitle: 'Cache, logs, trash', onTap: () => _run(context, 'Cleanup', Commands.cleanup())),
      ActionCard(icon: Icons.build_circle, title: 'Fix dpkg', subtitle: 'Fix interrupted installs', onTap: () => _run(context, 'Fix dpkg', Commands.fixDpkg())),
      ActionCard(icon: Icons.restart_alt, title: 'Reboot All', subtitle: 'Restart hosts', iconColor: Colors.orange, onTap: () => _confirm(context, 'Reboot All', Commands.reboot())),
      ActionCard(icon: Icons.power_settings_new, title: 'Shutdown All', subtitle: 'Power off', iconColor: Colors.red, onTap: () => _confirm(context, 'Shutdown All', Commands.shutdown())),

      // ── NETWORK ────────────────────────────────────────────────────────────
      const SectionHeader(title: 'NETWORK'),
      ActionCard(icon: Icons.language, title: 'Check Internet', subtitle: 'Verify WAN', onTap: () => _run(context, 'Check Internet', Commands.checkInternet(), sudo: false)),
      ActionCard(icon: Icons.speed, title: 'Speed Test', subtitle: 'speedtest-cli', onTap: () => _speedTestDialog(context)),
      ActionCard(icon: Icons.dns, title: 'Change DNS', subtitle: 'Set custom DNS servers', onTap: () => _dnsDialog(context)),
      ActionCard(icon: Icons.wifi_off, title: 'Disable WiFi', subtitle: 'All hosts', onTap: () => _run(context, 'Disable WiFi', Commands.disableWifi())),

      // ── INFORMATION ────────────────────────────────────────────────────────
      const SectionHeader(title: 'INFORMATION'),
      ActionCard(icon: Icons.storage, title: 'Disk Usage', subtitle: 'Check disk %', onTap: () => _run(context, 'Disk Usage', Commands.diskUsage(), sudo: false)),
      ActionCard(icon: Icons.memory, title: 'RAM Info', subtitle: 'Memory usage', onTap: () => _run(context, 'RAM Info', Commands.ramInfo(), sudo: false)),
      ActionCard(icon: Icons.schedule, title: 'Uptime', subtitle: 'How long running', onTap: () => _run(context, 'Uptime', Commands.uptime(), sudo: false)),
      ActionCard(icon: Icons.miscellaneous_services, title: 'Services', subtitle: 'SSH, NM, cron', onTap: () => _run(context, 'Services', Commands.services(), sudo: false)),
      ActionCard(icon: Icons.info, title: 'Hardware Info', subtitle: 'CPU, model, serial', onTap: () => _run(context, 'Hardware', Commands.hardwareInfo())),

      // ── SOFTWARE ───────────────────────────────────────────────────────────
      const SectionHeader(title: 'SOFTWARE'),
      ActionCard(icon: Icons.install_desktop, title: 'Install Package', subtitle: 'Any apt package', onTap: () => _pkgDialog(context)),
      ActionCard(icon: Icons.apps, title: 'Install Applications', subtitle: '12 popular apps — install or remove', iconColor: Colors.cyan, onTap: () => _appDialog(context)),

      // ── PERFORMANCE ────────────────────────────────────────────────────────
      const SectionHeader(title: 'PERFORMANCE'),
      ActionCard(icon: Icons.tune, title: 'Performance Settings', subtitle: 'CPU, I/O, compositing, services and more', iconColor: Colors.purple, onTap: () => _perfDialog(context)),

      const SizedBox(height: 80),
    ]));
  }
}

class _AppDef {
  final String name, subtitle, installCmd, removeCmd;
  final IconData icon;
  final Color color;
  const _AppDef(this.name, this.subtitle, this.icon, this.color, this.installCmd, this.removeCmd);
}
