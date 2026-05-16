import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/host_provider.dart';
import '../providers/job_provider.dart';
import '../services/ssh_service.dart';
import '../services/command_service.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';
import 'job_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  void _run(BuildContext context, String name, String cmd, {bool sudo = true}) {
    final hp = context.read<HostProvider>(); final jp = context.read<JobProvider>();
    if (hp.credentials == null) return;
    final hosts = hp.hosts.where((h) => h.sshOpen).toList();
    if (hosts.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hosts with SSH available. Run Check All Hosts first.'))); return; }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Tools')), body: ListView(children: [
      const SectionHeader(title: 'REMOTE'),
      ActionCard(icon: Icons.terminal, title: 'Run Command', subtitle: 'Execute on all hosts', onTap: () => _cmdDialog(context)),
      ActionCard(icon: Icons.lock_reset, title: 'Change Password', subtitle: 'All hosts', onTap: () => _passDialog(context)),
      ActionCard(icon: Icons.message, title: 'Send Message', subtitle: 'Popup notification', onTap: () => _msgDialog(context)),
      ActionCard(icon: Icons.lock, title: 'Lock Screens', subtitle: 'Instant lock', onTap: () => _run(context, 'Lock Screens', Commands.lockScreen())),
      const SectionHeader(title: 'WAKE-ON-LAN'),
      ActionCard(icon: Icons.wifi, title: 'Collect MAC Addresses', subtitle: 'From online hosts', onTap: () { context.read<HostProvider>().collectMacAddresses(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Collecting MACs...'))); }),
      ActionCard(icon: Icons.power, title: 'Wake All Hosts', subtitle: 'Send WOL magic packets', iconColor: Colors.green, onTap: () => _wol(context)),
      ActionCard(icon: Icons.power_settings_new, title: 'Wake Single Host', subtitle: 'Select host to wake', iconColor: Colors.green, onTap: () => _wolSingle(context)),
      const SectionHeader(title: 'FIX'),
      ActionCard(icon: Icons.vpn_key, title: 'Delete SSH Keys', subtitle: 'Clean known_hosts', onTap: () => _run(context, 'Delete SSH Keys', Commands.deleteSSHKeys(), sudo: false)),
      ActionCard(icon: Icons.speed, title: 'Fix Slow Sudo', subtitle: 'hostname in /etc/hosts', onTap: () => _run(context, 'Fix Slow Sudo', Commands.fixSlowSudo())),
      const SectionHeader(title: 'HISTORY'),
      Consumer<JobProvider>(builder: (context, jp, _) {
        if (jp.history.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('No actions yet', style: TextStyle(color: Colors.white38)));
        return Column(children: jp.history.take(20).map((j) => Card(child: ListTile(dense: true,
          leading: Icon(j.failCount > 0 ? Icons.warning : Icons.check_circle, color: j.failCount > 0 ? Colors.orange : Colors.green, size: 18),
          title: Text(j.name, style: const TextStyle(fontSize: 13)),
          subtitle: Text('OK: ' + j.okCount.toString() + ' | Failed: ' + j.failCount.toString(), style: const TextStyle(fontSize: 11, color: Colors.white38)),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobScreen(job: j)))))).toList());
      }),
      const SizedBox(height: 80),
    ]));
  }

  void _wol(BuildContext context) {
    final hp = context.read<HostProvider>();
    final hostsWithMac = hp.hosts.where((h) => h.mac != null && h.mac!.isNotEmpty).toList();
    if (hostsWithMac.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No MAC addresses. Collect them first.'))); return; }
    final onlineHost = hp.hosts.firstWhere((h) => h.isOnline, orElse: () => hp.hosts.first);
    final creds = hp.credsForHost(onlineHost);
    final jp = context.read<JobProvider>();
    final job = jp.startJob('Wake-on-LAN (all)');
    Navigator.push(context, MaterialPageRoute(builder: (_) => JobScreen(job: job, totalHosts: hosts.length)));
    () async {
      for (final h in hostsWithMac) {
        final r = await SSHService.runCommand(onlineHost.ip, creds, 'wakeonlan ' + h.mac! + ' 2>/dev/null || etherwake ' + h.mac! + ' 2>/dev/null; echo "WOL sent to ' + h.mac! + '"');
        jp.addResult(job, SSHResult(host: h.ip, success: true, output: 'WOL sent to ' + (h.mac ?? ''), duration: r.duration));
      }
      jp.finishJob(job);
    }();
  }

  void _wolSingle(BuildContext context) {
    final hp = context.read<HostProvider>();
    final hostsWithMac = hp.hosts.where((h) => h.mac != null).toList();
    if (hostsWithMac.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No MAC addresses.'))); return; }
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22), title: const Text('Wake Host'),
      content: SizedBox(width: double.maxFinite, height: 300, child: ListView.builder(
        itemCount: hostsWithMac.length,
        itemBuilder: (ctx, i) {
          final h = hostsWithMac[i];
          return ListTile(
            title: Text(h.ip + ' (' + (h.hostname ?? '?') + ')', style: const TextStyle(fontSize: 14)),
            subtitle: Text(h.mac ?? '', style: const TextStyle(fontSize: 11, color: Colors.white38)),
            onTap: () { Navigator.pop(context); _sendWol(context, h); },
          );
        },
      )),
    ));
  }

  void _sendWol(BuildContext context, Host target) {
    final hp = context.read<HostProvider>();
    final onlineHost = hp.hosts.firstWhere((h) => h.isOnline, orElse: () => hp.hosts.first);
    final creds = hp.credsForHost(onlineHost);
    SSHService.runCommand(onlineHost.ip, creds, 'wakeonlan ' + target.mac! + ' 2>/dev/null || etherwake ' + target.mac! + ' 2>/dev/null').then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('WOL sent to ' + target.ip)));
    });
  }

  void _cmdDialog(BuildContext ctx) {
    final c = TextEditingController();
    showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text('Run Command'),
      content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Command (root)', border: OutlineInputBorder())),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () { Navigator.pop(ctx); _run(ctx, 'CMD: ' + c.text, c.text); }, child: const Text('Run'))]));
  }

  void _passDialog(BuildContext ctx) {
    final c = TextEditingController();
    showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text('Change Password'),
      content: TextField(controller: c, obscureText: true, decoration: const InputDecoration(labelText: 'New password', border: OutlineInputBorder())),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () {
        Navigator.pop(ctx); final hp = ctx.read<HostProvider>(); final user = hp.credentials?.username ?? 'user';
        _run(ctx, 'Change Password', Commands.changePassword(user, c.text));
        hp.saveCredentials(Credentials(username: user, password: c.text));
      }, child: const Text('Change'))]));
  }

  void _msgDialog(BuildContext ctx) {
    final t = TextEditingController(text: 'Atomator'); final b = TextEditingController();
    showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text('Send Message'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: t, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())), const SizedBox(height: 12),
        TextField(controller: b, decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()), maxLines: 3)]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () { Navigator.pop(ctx); _run(ctx, 'Send Message', Commands.sendMessage(t.text, b.text)); }, child: const Text('Send'))]));
  }
}
