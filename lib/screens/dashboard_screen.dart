import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/host_provider.dart';
import '../providers/job_provider.dart';
import '../services/ssh_service.dart';
import '../services/command_service.dart';
import '../models/models.dart';
import '../models/fleet_summary.dart';
import '../theme.dart';
import 'job_screen.dart';
import 'hosts_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => Consumer<HostProvider>(
    builder: (context, hp, _) {
      final ready = hp.hosts.where((h) => h.sshOpen).length;
      return SafeArea(
        child: RefreshIndicator(
          onRefresh: hp.checkHostStatus,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: atomatorAccent.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.hub_outlined,
                      color: atomatorAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atomator',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Linux fleet management',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Fleet overview',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                hp.hosts.isEmpty
                    ? 'Add your first host to get started.'
                    : '${hp.hosts.length} hosts across ${hp.groups.length} groups. Pull down to refresh.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 600 ? 4 : 2;
                  final width =
                      (constraints.maxWidth - 12 * (columns - 1)) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _stat(
                        context,
                        width,
                        'Total hosts',
                        hp.hosts.length,
                        Icons.dns_outlined,
                        atomatorAccent,
                      ),
                      _stat(
                        context,
                        width,
                        'Online',
                        hp.onlineCount,
                        Icons.wifi,
                        const Color(0xFF78DEAC),
                      ),
                      _stat(
                        context,
                        width,
                        'SSH ready',
                        ready,
                        Icons.terminal,
                        const Color(0xFF9FB9FF),
                      ),
                      _stat(
                        context,
                        width,
                        'Offline',
                        hp.offlineCount,
                        Icons.wifi_off,
                        const Color(0xFFFFB4AB),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              if (hp.hosts.isEmpty)
                FilledButton.icon(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HostsScreen()),
                      ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add hosts'),
                )
              else ...[
                FilledButton.icon(
                  onPressed: hp.isChecking ? null : hp.checkHostStatus,
                  icon:
                      hp.isChecking
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.refresh),
                  label: Text(hp.isChecking ? hp.checkStatus : 'Refresh hosts'),
                ),
                if (hp.isChecking) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value:
                        hp.checkTotal == 0
                            ? null
                            : hp.checkProgress / hp.checkTotal,
                    semanticsLabel: 'Host scan progress',
                  ),
                ],
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    leading: const Icon(
                      Icons.insights_outlined,
                      color: atomatorAccent,
                    ),
                    title: const Text('Fleet health'),
                    subtitle: const Text('Memory, disk space and uptime'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _fleet(context, hp),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Consumer<JobProvider>(
                builder:
                    (context, jp, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent activity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (jp.activeJob case final active?)
                          Card(
                            child: ListTile(
                              leading: const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              title: Text(active.name),
                              subtitle: Text(
                                'Running · ${active.total} results received',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => JobScreen(job: active),
                                    ),
                                  ),
                            ),
                          ),
                        if (jp.history.isEmpty && jp.activeJob == null)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Icon(Icons.history, color: atomatorAccent),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'Your completed actions will appear here.',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ...jp.history
                            .take(5)
                            .map(
                              (job) => Card(
                                child: ListTile(
                                  leading: Icon(
                                    job.failCount > 0
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_circle_outline,
                                    color:
                                        job.failCount > 0
                                            ? Colors.orangeAccent
                                            : const Color(0xFF78DEAC),
                                  ),
                                  title: Text(job.name),
                                  subtitle: Text(
                                    '${job.okCount} succeeded · ${job.failCount} failed · ${_timeAgo(job.startTime)}',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => JobScreen(job: job),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                      ],
                    ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _stat(
    BuildContext context,
    double width,
    String label,
    int value,
    IconData icon,
    Color color,
  ) => SizedBox(
    width: width,
    child: Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text('$value', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ),
  );

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _fleet(BuildContext context, HostProvider hp) {
    final hosts = hp.hosts.where((h) => h.sshOpen).toList();
    if (hp.credentials == null || hosts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set SSH credentials and refresh hosts first.'),
        ),
      );
      return;
    }
    // Create once, outside the dialog builder, so rebuilds never repeat remote work.
    final readings = _collect(hosts, hp);
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Fleet health'),
            content: FutureBuilder<FleetSummary>(
              future: readings,
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Text(
                    'Could not collect fleet readings. Try refreshing hosts.',
                  );
                if (!snapshot.hasData)
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                final summary = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${summary.reported} of ${hosts.length} hosts reported',
                      ),
                      if (summary.unavailable > 0)
                        Text(
                          '${summary.unavailable} unavailable or invalid readings',
                          style: const TextStyle(color: Colors.orangeAccent),
                        ),
                      if (summary.reported > 0) ...[
                        const SizedBox(height: 16),
                        Text('Total memory: ${summary.totalRam} GB'),
                        Text('Average memory: ${summary.averageRam} GB / host'),
                        const SizedBox(height: 12),
                        if (summary.critical > 0)
                          Text(
                            '${summary.critical} hosts at 90% disk usage or above',
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        if (summary.warning > 0)
                          Text(
                            '${summary.warning} hosts at 80% to 89% disk usage',
                            style: const TextStyle(color: Colors.orangeAccent),
                          ),
                        if (summary.critical == 0 && summary.warning == 0)
                          const Text(
                            'Reported disks are below 80% usage.',
                            style: TextStyle(color: Color(0xFF78DEAC)),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          'Uptime: ${summary.minUptime! ~/ 86400} to ${summary.maxUptime! ~/ 86400} days',
                        ),
                      ] else
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'No valid health data. Check SSH access and try again.',
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<FleetSummary> _collect(List<Host> hosts, HostProvider hp) async {
    final results = <SSHResult>[];
    // Bound connection pressure for larger fleets and honor per-host credentials.
    for (var i = 0; i < hosts.length; i += 5) {
      results.addAll(
        await Future.wait(
          hosts
              .skip(i)
              .take(5)
              .map(
                (host) => SSHService.runCommand(
                  host.ip,
                  hp.credsForHost(host),
                  Commands.fleetSummary(),
                  sudo: true,
                  timeoutSec: 10,
                ),
              ),
        ),
      );
    }
    return FleetSummary.fromResults(results);
  }
}
