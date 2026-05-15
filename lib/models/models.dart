import 'dart:convert';

class Host {
  final String ip;
  String? hostname;
  String group;
  bool isOnline;
  DateTime? lastSeen;

  Host({required this.ip, this.hostname, this.group = 'default', this.isOnline = false, this.lastSeen});

  Map<String, dynamic> toJson() => {'ip': ip, 'hostname': hostname, 'group': group, 'isOnline': isOnline, 'lastSeen': lastSeen?.toIso8601String()};
  factory Host.fromJson(Map<String, dynamic> json) => Host(ip: json['ip'], hostname: json['hostname'], group: json['group'] ?? 'default', isOnline: json['isOnline'] ?? false, lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null);
}

class Credentials {
  final String username;
  final String password;
  const Credentials({required this.username, required this.password});
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
  factory Credentials.fromJson(Map<String, dynamic> json) => Credentials(username: json['username'], password: json['password']);
}

class SSHResult {
  final String host;
  final bool success;
  final String output;
  final Duration duration;
  const SSHResult({required this.host, required this.success, required this.output, required this.duration});
}

class JobResult {
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final List<SSHResult> results;
  bool isRunning;
  JobResult({required this.name, DateTime? startTime, this.endTime, List<SSHResult>? results, this.isRunning = true}) : startTime = startTime ?? DateTime.now(), results = results ?? [];
  int get okCount => results.where((r) => r.success).length;
  int get failCount => results.where((r) => !r.success).length;
  int get total => results.length;
}
