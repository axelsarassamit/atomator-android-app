import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/host_provider.dart';
import '../providers/job_provider.dart';
import '../services/ssh_service.dart';
import '../services/command_service.dart';
import '../models/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HostProvider>(
      builder: (context, hp, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Image.asset('assets/images/atomator_banner.png', height: 80, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  _stat(context, 'Total', hp.hosts.length.toString(), Icons.computer, Colors.cyan),
                  _stat(context, 'Online', hp.onlineCount.toString(), Icons.wifi, Colors.green),
                  _stat(context, 'Offline', hp.offlineCount.toString(), Icons.wifi_off, Colors.red),
                  _stat(context, 'Groups', hp.groups.length.toString(), Icons.folder, Colors.orange),
                ].map((w) => Expanded(child: w)).toList()),
                const SizedBox(height: 16),
                Card(child: ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.cyan),
                  title: const Text('Check All Hosts'),
                  subtitle: Text('Ping ' + hp.hosts.length.toString() + ' hosts'),
                  onTap: () => hp.checkHostStatus(),
                )),
                const SizedBox(height: 8),
                Card(child: ListTile(
                  leading: const Icon(Icons.analytics, color: Colors.green),
                  title: const Text('Fleet Summary'),
                  subtitle: const Text('RAM, disk, uptime overview'),
                  onTap: () => _fleetSummary(context, hp),
                )),
                const SizedBox(height: 16),
                Consumer<JobProvider>(builder: (context, jp, _) {
                  if (jp.history.isEmpty) return const SizedBox();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RECENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyan)),
                      const SizedBox(height: 8),
                      ...jp.history.take(5).map((j) => Card(child: ListTile(
                        dense: true,
                        leading: Icon(j.failCount > 0 ? Icons.warning : Icons.check_circle, color: j.failCount > 0 ? Colors.orange : Colors.green, size: 20),
                        title: Text(j.name, style: const TextStyle(fontSize: 13)),
                        subtitle: Text('OK: ' + j.okCount.toString() + ' | Failed: ' + j.failCount.toString(), style: const TextStyle(fontSize: 11, color: Colors.white38)),
                      ))),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stat(BuildContext ctx, String label, String value, IconData icon, Color color) {
    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Icon(icon, color: color, size: 24), const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
    ])));
  }

  void _fleetSummary(BuildContext context, HostProvider hp) async {
    final creds = hp.credentials;
    if (creds == null) return;
    final online = hp.hosts.where((h) => h.isOnline).toList();
    if (online.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No online hosts.'))); return; }
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22), title: const Text('Fleet Summary'),
      content: FutureBuilder<Map<String, dynamic>>(
        future: _collect(online, creds),
        builder: (ctx, snap) {
          if (!snap.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
          final d = snap.data!;
          return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Online: ' + d["online"].toString() + '/' + hp.hosts.length.toString(), style: const TextStyle(color: Colors.green)),
            Text('Total RAM: ' + d["ramGB"].toString() + ' GB'),
            Text('Avg: ' + d["avgGB"].toString() + ' GB/host'),
            if (d["crit"] > 0) Text('Disk Critical: ' + d["crit"].toString(), style: const TextStyle(color: Colors.red)),
            if (d["warn"] > 0) Text('Disk Warning: ' + d["warn"].toString(), style: const TextStyle(color: Colors.orange)),
            if (d["crit"] == 0 && d["warn"] == 0) const Text('Disk: All healthy', style: TextStyle(color: Colors.green)),
            Text('Longest uptime: ' + d["maxD"].toString() + ' days'),
            Text('Shortest: ' + d["minD"].toString() + ' days'),
          ]);
        },
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }

  Future<Map<String, dynamic>> _collect(List<Host> hosts, Credentials creds) async {
    int ram = 0, warn = 0, crit = 0, maxU = 0, minU = 999999999, n = 0;
    final results = await Future.wait(hosts.map((h) => SSHService.runCommand(h.ip, creds, Commands.fleetSummary(), sudo: true, timeoutSec: 10)));
    for (final r in results) {
      if (!r.success) continue; n++;
      final p = r.output.split('|');
      if (p.length >= 3) {
        final rm = int.tryParse(p[0]) ?? 0; final dk = int.tryParse(p[1]) ?? 0; final up = int.tryParse(p[2]) ?? 0;
        ram += rm; if (dk >= 90) crit++; else if (dk >= 80) warn++;
        if (up > maxU) maxU = up; if (up < minU) minU = up;
      }
    }
    return {'online': n, 'ramGB': ram ~/ 1024, 'avgGB': n > 0 ? ram ~/ n ~/ 1024 : 0, 'warn': warn, 'crit': crit, 'maxD': maxU ~/ 86400, 'minD': minU ~/ 86400};
  }
}
