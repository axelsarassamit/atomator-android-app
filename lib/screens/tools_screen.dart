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
    final creds = hp.credentials; if (creds == null) return;
    final hosts = hp.hosts.where((h) => h.isOnline).toList();
    if (hosts.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No online hosts.'))); return; }
    final job = jp.startJob(name);
    Navigator.push(context, MaterialPageRoute(builder: (_) => JobScreen(job: job)));
    () async { await for (final r in SSHService.runOnAll(hosts, creds, cmd, sudo: sudo)) { jp.addResult(job, r); } jp.finishJob(job); }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Tools')), body: ListView(children: [
      const SectionHeader(title: 'REMOTE'),
      ActionCard(icon: Icons.terminal, title: 'Run Command', subtitle: 'Execute on all hosts', onTap: () => _cmdDialog(context)),
      ActionCard(icon: Icons.lock_reset, title: 'Change Password', subtitle: 'All hosts', onTap: () => _passDialog(context)),
      ActionCard(icon: Icons.message, title: 'Send Message', subtitle: 'Popup notification', onTap: () => _msgDialog(context)),
      ActionCard(icon: Icons.lock, title: 'Lock Screens', subtitle: 'Instant lock', onTap: () => _run(context, 'Lock Screens', Commands.lockScreen())),
      const SectionHeader(title: 'FIX'),
      ActionCard(icon: Icons.vpn_key, title: 'Delete SSH Keys', subtitle: 'Clean known_hosts', onTap: () => _run(context, 'Delete SSH Keys', Commands.deleteSSHKeys(), sudo: false)),
      ActionCard(icon: Icons.speed, title: 'Fix Slow Sudo', subtitle: 'hostname in /etc/hosts', onTap: () => _run(context, 'Fix Slow Sudo', Commands.fixSlowSudo())),
      const SectionHeader(title: 'HISTORY'),
      Consumer<JobProvider>(builder: (context, jp, _) {
        if (jp.history.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('No actions yet', style: TextStyle(color: Colors.white38)));
        return Column(children: jp.history.take(20).map((j) => Card(child: ListTile(dense: true,
          leading: Icon(j.failCount > 0 ? Icons.warning : Icons.check_circle, color: j.failCount > 0 ? Colors.orange : Colors.green, size: 18),
          title: Text(j.name, style: const TextStyle(fontSize: 13)),
          subtitle: Text('OK: ${j.okCount} | Failed: ${j.failCount}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobScreen(job: j)))))).toList());
      }),
      const SizedBox(height: 80),
    ]));
  }

  void _cmdDialog(BuildContext ctx) {
    final c = TextEditingController();
    showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text('Run Command'),
      content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Command (root)', border: OutlineInputBorder())),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), ElevatedButton(onPressed: () { Navigator.pop(ctx); _run(ctx, 'CMD: ${c.text}', c.text); }, child: const Text('Run'))]));
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
