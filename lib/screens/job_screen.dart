import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/job_provider.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class JobScreen extends StatelessWidget {
  final JobResult job;
  final int totalHosts;
  const JobScreen({super.key, required this.job, this.totalHosts = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(job.name, style: const TextStyle(fontSize: 15)),
          Text(DateFormat('HH:mm:ss').format(job.startTime), style: const TextStyle(fontSize: 11, color: Colors.white38)),
        ]),
        actions: [
          Consumer<JobProvider>(builder: (_, jp, __) => IconButton(
            icon: const Icon(Icons.copy_all, size: 20),
            tooltip: 'Copy all output',
            onPressed: job.results.isEmpty ? null : () {
              final buf = StringBuffer();
              buf.writeln('Job: ${job.name}');
              buf.writeln('Started: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(job.startTime)}');
              buf.writeln('OK: ${job.okCount}  Failed: ${job.failCount}  Total: ${job.total}');
              if (job.totalDuration != null) buf.writeln('Duration: ${job.totalDuration!.inSeconds}s');
              buf.writeln('─' * 40);
              for (final r in job.results) {
                buf.writeln('[${r.success ? 'OK' : 'FAIL'}] ${r.host}  (${r.duration.inMilliseconds}ms)');
                if (r.output.isNotEmpty) buf.writeln(r.output);
                buf.writeln();
              }
              Clipboard.setData(ClipboardData(text: buf.toString()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All output copied to clipboard'), duration: Duration(seconds: 2)),
              );
            },
          )),
        ],
      ),
      body: SafeArea(top: false, child: Consumer<JobProvider>(builder: (context, jp, _) => ResultsList(job: job, totalHosts: totalHosts))),
    );
  }
}
