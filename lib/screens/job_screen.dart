import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class JobScreen extends StatelessWidget {
  final JobResult job;
  const JobScreen({super.key, required this.job});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(job.name, style: const TextStyle(fontSize: 16))),
    body: Consumer<JobProvider>(builder: (context, jp, _) => ResultsList(job: job)),
  );
}
