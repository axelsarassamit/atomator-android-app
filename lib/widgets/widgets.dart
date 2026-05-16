import 'package:flutter/material.dart';
import '../models/models.dart';

class StatusBadge extends StatelessWidget {
  final bool isOnline;
  const StatusBadge({super.key, required this.isOnline});
  @override
  Widget build(BuildContext context) => Container(
    width: 20, height: 20,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isOnline ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
      border: Border.all(color: isOnline ? const Color(0xFF81C784) : const Color(0xFFEF9A9A), width: 2),
    ),
    child: Center(child: Icon(isOnline ? Icons.check : Icons.close, size: 12, color: Colors.white)),
  );
}

class ActionCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap; final Color? iconColor;
  const ActionCard({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap, this.iconColor});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary, size: 28), title: Text(title, style: Theme.of(context).textTheme.titleMedium), subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall), trailing: const Icon(Icons.chevron_right, color: Colors.white24), onTap: onTap));
}

class ResultsList extends StatelessWidget {
  final JobResult job;
  final int totalHosts;
  const ResultsList({super.key, required this.job, this.totalHosts = 0});
  @override
  Widget build(BuildContext context) {
    final total = totalHosts > 0 ? totalHosts : (job.isRunning ? job.results.length + 1 : job.total);
    final progress = total > 0 ? job.results.length / total : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (job.isRunning) ...[
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Row(children: [
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyan)),
          const SizedBox(width: 12),
          Text('Running ' + job.results.length.toString() + (totalHosts > 0 ? '/' + totalHosts.toString() : '') + '...', style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(job.okCount.toString() + ' OK', style: const TextStyle(fontSize: 12, color: Colors.green)),
          if (job.failCount > 0) ...[const SizedBox(width: 8), Text(job.failCount.toString() + ' FAIL', style: const TextStyle(fontSize: 12, color: Colors.red))],
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, minHeight: 6, color: Colors.cyan, backgroundColor: Colors.white12))),
      ] else ...[
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Icon(job.failCount > 0 ? Icons.warning : Icons.check_circle, color: job.failCount > 0 ? Colors.orange : Colors.green, size: 24),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(job.failCount > 0 ? 'Completed with errors' : 'Completed successfully', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: job.failCount > 0 ? Colors.orange : Colors.green)),
            Text('OK: ' + job.okCount.toString() + '  |  Failed: ' + job.failCount.toString() + '  |  Total: ' + job.total.toString(), style: const TextStyle(fontSize: 12, color: Colors.white38)),
          ]),
        ])),
      ],
      const Divider(height: 1, color: Colors.white12),
      Expanded(child: ListView.builder(itemCount: job.results.length, itemBuilder: (context, i) {
        final r = job.results[i];
        return ListTile(dense: true,
          leading: Icon(r.success ? Icons.check_circle : Icons.error, color: r.success ? Colors.green : Colors.red, size: 18),
          title: Text(r.host, style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 13)),
          subtitle: Text(r.output.length > 100 ? r.output.substring(0, 100) + '...' : r.output, style: const TextStyle(fontSize: 11, color: Colors.white38)),
          trailing: Text(r.duration.inMilliseconds.toString() + 'ms', style: const TextStyle(fontSize: 11, color: Colors.white24)),
          onTap: r.output.length > 100 ? () => _showFull(context, r) : null,
        );
      })),
    ]);
  }

  static void _showFull(BuildContext context, SSHResult r) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: Text(r.host, style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 14)),
      content: SingleChildScrollView(child: SelectableText(r.output, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white70))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, letterSpacing: 1.2)));
}
