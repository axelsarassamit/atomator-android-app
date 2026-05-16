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
  const ResultsList({super.key, required this.job});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      if (job.isRunning) ...[const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 8), Text('Running... ${job.results.length}')]
      else ...[const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8), Text('OK: ${job.okCount}  Failed: ${job.failCount}  Total: ${job.total}')],
    ])),
    Expanded(child: ListView.builder(itemCount: job.results.length, itemBuilder: (context, i) {
      final r = job.results[i];
      return ListTile(dense: true, leading: Icon(r.success ? Icons.check_circle : Icons.error, color: r.success ? Colors.green : Colors.red, size: 18),
        title: Text(r.host, style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 13)),
        subtitle: Text(r.output.length > 80 ? r.output.substring(0, 80) : r.output, style: const TextStyle(fontSize: 11, color: Colors.white38)),
        trailing: Text('${r.duration.inMilliseconds}ms', style: const TextStyle(fontSize: 11, color: Colors.white24)));
    })),
  ]);
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, letterSpacing: 1.2)));
}
