import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/host_provider.dart';
import '../providers/job_provider.dart';
import '../services/ssh_service.dart';
import '../services/command_service.dart';
import '../models/models.dart';
import 'job_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HostProvider>(builder: (context, hp, _) {
      return SafeArea(child: SingleChildScrollView(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: double.infinity, child: Image.asset('assets/images/atomator_banner.png', fit: BoxFit.fitWidth)),
          Padding(padding: const EdgeInsets.all(16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _stat('Total', hp.hosts.length.toString(), Icons.computer, Colors.cyan),
                _stat('Online', hp.onlineCount.toString(), Icons.wifi, Colors.green),
                _stat('SSH', hp.hosts.where((h) => h.sshOpen).length.toString(), Icons.terminal, const Color(0xFF4CAF50)),
                _stat('Offline', hp.offlineCount.toString(), Icons.wifi_off, Colors.red),
                _stat('Groups', hp.groups.length.toString(), Icons.folder, Colors.orange),
              ].map((w) => Expanded(child: w)).toList()),
              const SizedBox(height: 16),
              Card(child: Column(children: [
                ListTile(
                  leading: hp.isChecking
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyan))
                      : const Icon(Icons.refresh, color: Colors.cyan),
                  title: Text(hp.isChecking ? 'Checking hosts…' : 'Check All Hosts'),
                  subtitle: Text('Ping ${hp.hosts.length} hosts'),
                  onTap: hp.isChecking ? null : () => hp.checkHostStatus(),
                ),
                if (hp.isChecking) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Column(children: [
                  LinearProgressIndicator(value: hp.checkTotal > 0 ? hp.checkProgress / hp.checkTotal : 0, color: Colors.cyan, backgroundColor: Colors.white12),
                  const SizedBox(height: 4),
                  Text(hp.checkStatus, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                ])),
              ])),
              const SizedBox(height: 8),
              Card(child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.green),
                title: const Text('Fleet Summary'),
                subtitle: const Text('RAM, disk, uptime overview'),
                onTap: () => _fleet(context, hp),
              )),
              const SizedBox(height: 16),
              Consumer<JobProvider>(builder: (context, jp, _) {
                final active = jp.activeJob;
                if (active == null) return const SizedBox();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('RUNNING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Card(
                    color: const Color(0xFF1A2332),
                    child: ListTile(
                      leading: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)),
                      title: Text(active.name, style: const TextStyle(fontSize: 13)),
                      subtitle: Text('${active.results.length} results so far', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobScreen(job: active))),
                    ),
                  ),
                  const SizedBox(height: 16),
                ]);
              }),
              Consumer<JobProvider>(builder: (context, jp, _) {
                if (jp.history.isEmpty) return const SizedBox();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('RECENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyan, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  ...jp.history.take(5).map((j) => Card(child: ListTile(
                    dense: true,
                    leading: Icon(j.failCount > 0 ? Icons.warning : Icons.check_circle, color: j.failCount > 0 ? Colors.orange : Colors.green, size: 20),
                    title: Text(j.name, style: const TextStyle(fontSize: 13)),
                    subtitle: Text('OK: ${j.okCount} | Failed: ${j.failCount}  •  ${_timeAgo(j.startTime)}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                    trailing: j.totalDuration != null ? Text('${j.totalDuration!.inSeconds}s', style: const TextStyle(fontSize: 11, color: Colors.white24)) : null,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobScreen(job: j))),
                  ))),
                ]);
              }),
            ],
          )),
        ],
      )));
    });
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 2),
        FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
        FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38))),
      ],
    )));
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _fleet(BuildContext context, HostProvider hp) async {
    final creds = hp.credentials;
    if (creds == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Set credentials in Settings first.'))); return; }
    final online = hp.hosts.where((h) => h.isOnline).toList();
    if (online.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No online hosts.'))); return; }
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22), title: const Text('Fleet Summary'),
      content: FutureBuilder<Map<String, dynamic>>(future: _collect(online, creds), builder: (ctx, snap) {
        if (!snap.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        final d = snap.data!;
        return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Online: ${d['online']}/${hp.hosts.length}', style: const TextStyle(color: Colors.green)),
          const SizedBox(height: 4),
          Text('Total RAM: ${d['ramGB']} GB'),
          Text('Avg RAM: ${d['avgGB']} GB/host'),
          const SizedBox(height: 4),
          if (d['crit'] > 0) Text('Disk Critical: ${d['crit']} host(s)', style: const TextStyle(color: Colors.red)),
          if (d['warn'] > 0) Text('Disk Warning: ${d['warn']} host(s)', style: const TextStyle(color: Colors.orange)),
          if (d['crit'] == 0 && d['warn'] == 0) const Text('Disk: All healthy', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 4),
          Text('Uptime: ${d['minD']}d – ${d['maxD']}d'),
        ]);
      }),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }

  Future<Map<String, dynamic>> _collect(List<Host> hosts, Credentials creds) async {
    int ram = 0, warn = 0, crit = 0, maxU = 0, minU = 999999999, n = 0;
    final results = await Future.wait(hosts.map((h) => SSHService.runCommand(h.ip, creds, Commands.fleetSummary(), sudo: true, timeoutSec: 10)));
    for (final r in results) {
      if (!r.success) continue;
      n++;
      final p = r.output.split('|');
      if (p.length >= 3) {
        final rm = int.tryParse(p[0]) ?? 0;
        final dk = int.tryParse(p[1]) ?? 0;
        final up = int.tryParse(p[2]) ?? 0;
        ram += rm;
        if (dk >= 90) { crit++; } else if (dk >= 80) { warn++; }
        if (up > maxU) { maxU = up; }
        if (up < minU) { minU = up; }
      }
    }
    return {'online': n, 'ramGB': ram ~/ 1024, 'avgGB': n > 0 ? ram ~/ n ~/ 1024 : 0, 'warn': warn, 'crit': crit, 'maxD': maxU ~/ 86400, 'minD': minU ~/ 86400};
  }
}
