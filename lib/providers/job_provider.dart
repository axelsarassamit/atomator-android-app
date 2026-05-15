import 'package:flutter/material.dart';
import '../models/models.dart';

class JobProvider extends ChangeNotifier {
  final List<JobResult> _jobs = [];
  List<JobResult> get jobs => _jobs;
  JobResult? get activeJob => _jobs.where((j) => j.isRunning).firstOrNull;
  List<JobResult> get history => _jobs.where((j) => !j.isRunning).toList().reversed.toList();

  JobResult startJob(String name) { final job = JobResult(name: name); _jobs.insert(0, job); notifyListeners(); return job; }
  void addResult(JobResult job, SSHResult result) { job.results.add(result); notifyListeners(); }
  void finishJob(JobResult job) { job.isRunning = false; notifyListeners(); }
}
