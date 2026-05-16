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
    final hp = context.read<HostProvider>(); final jp = context.read<JobProvider>();
    final creds = hp.credentials; if (creds == null) return;
    final hosts = hp.hosts.where((h) => h.sshOpen).toList();
    if (hosts.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hosts with SSH available. Run Check All Hosts first.'))); return; }
    final job = jp.startJob(name);
    Navigator.push(context, MaterialPageRoute(builder: (_) => JobScreen(job: job, totalHosts: hosts.length)));
    () async { await for (final r in SSHService.runOnAll(hosts, creds, cmd, sudo: sudo, maxParallel: par)) { jp.addResult(job, r); } jp.finishJob(job); }();
  }

  void _confirm(BuildContext ctx, String name, String cmd) {
    showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: Text('Confirm: $name'), content: Text('Are you sure?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () { Navigator.pop(ctx); _run(ctx, name, cmd); }, child: const Text('Yes'))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Actions')), body: ListView(children: [
      const SectionHeader(title: 'SYSTEM UPDATES'),
      ActionCard(icon: Icons.system_update, title: 'Update All', subtitle: 'apt update + upgrade', onTap: () => _run(context, 'Update All', Commands.updateAll())),
      ActionCard(icon: Icons.cleaning_services, title: 'Update + Purge Kernels', subtitle: 'Frees disk space', onTap: () => _run(context, 'Update + Purge', Commands.updatePurgeKernels())),
      ActionCard(icon: Icons.block, title: 'Disable Auto Updates', subtitle: 'Stop unattended-upgrades', onTap: () => _run(context, 'Disable Updates', Commands.disableAutoUpdates())),
      const SectionHeader(title: 'MAINTENANCE'),
      ActionCard(icon: Icons.delete_sweep, title: 'System Cleanup', subtitle: 'Cache, logs, trash', onTap: () => _run(context, 'Cleanup', Commands.cleanup())),
      ActionCard(icon: Icons.restart_alt, title: 'Reboot All', subtitle: 'Restart hosts', iconColor: Colors.orange, onTap: () => _confirm(context, 'Reboot All', Commands.reboot())),
      ActionCard(icon: Icons.power_settings_new, title: 'Shutdown All', subtitle: 'Power off', iconColor: Colors.red, onTap: () => _confirm(context, 'Shutdown All', Commands.shutdown())),
      const SectionHeader(title: 'NETWORK'),
      ActionCard(icon: Icons.language, title: 'Check Internet', subtitle: 'Verify WAN', onTap: () => _run(context, 'Check Internet', Commands.checkInternet())),
      ActionCard(icon: Icons.speed, title: 'Speed Test', subtitle: 'speedtest-cli', onTap: () => _run(context, 'Speed Test', Commands.speedTest(), par: 3)),
      ActionCard(icon: Icons.wifi_off, title: 'Disable WiFi', subtitle: 'All hosts', onTap: () => _run(context, 'Disable WiFi', Commands.disableWifi())),
      const SectionHeader(title: 'INFORMATION'),
      ActionCard(icon: Icons.storage, title: 'Disk Usage', subtitle: 'Check disk %', onTap: () => _run(context, 'Disk Usage', Commands.diskUsage())),
      ActionCard(icon: Icons.memory, title: 'RAM Info', subtitle: 'Memory usage', onTap: () => _run(context, 'RAM Info', Commands.ramInfo())),
      ActionCard(icon: Icons.schedule, title: 'Uptime', subtitle: 'How long running', onTap: () => _run(context, 'Uptime', Commands.uptime(), sudo: false)),
      ActionCard(icon: Icons.miscellaneous_services, title: 'Services', subtitle: 'SSH, NM, cron', onTap: () => _run(context, 'Services', Commands.services(), sudo: false)),
      ActionCard(icon: Icons.info, title: 'Hardware Info', subtitle: 'CPU, model, serial', onTap: () => _run(context, 'Hardware', Commands.hardwareInfo())),
      const SectionHeader(title: 'SOFTWARE'),
      ActionCard(icon: Icons.install_desktop, title: 'Install Package', subtitle: 'Any apt package', onTap: () => _pkgDialog(context)),
      ActionCard(icon: Icons.web, title: 'Install Firefox', subtitle: 'ESR browser', onTap: () => _run(context, 'Install Firefox', Commands.installFirefox())),
      ActionCard(icon: Icons.web, title: 'Install Chrome', subtitle: 'Google Chrome', onTap: () => _run(context, 'Install Chrome', Commands.installChrome())),
      ActionCard(icon: Icons.delete, title: 'Remove Firefox', subtitle: 'Uninstall', iconColor: Colors.red, onTap: () => _run(context, 'Remove Firefox', Commands.removeFirefox())),
      ActionCard(icon: Icons.delete, title: 'Remove Chrome', subtitle: 'Uninstall', iconColor: Colors.red, onTap: () => _run(context, 'Remove Chrome', Commands.removeChrome())),
      const SizedBox(height: 80),
    ]));
  }

  void _pkgDialog(BuildContext ctx) {
    final c = TextEditingController();
    showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text('Install Package'),
      content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Package name(s)', border: OutlineInputBorder(), hintText: 'htop neofetch')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); _run(ctx, 'Install ${c.text}', Commands.installPackage(c.text)); }, child: const Text('Install'))]));
  }
}
