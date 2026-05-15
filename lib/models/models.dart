import 'dart:convert';

class Host {
  final String ip;
  String? hostname;
  String? mac;
  String group;
  bool isOnline;
  bool sshOpen;
  DateTime? lastSeen;
  String? customUser;
  String? customPass;

  Host({required this.ip, this.hostname, this.mac, this.group = 'default', this.isOnline = false, this.sshOpen = false, this.lastSeen, this.customUser, this.customPass});

  bool get hasCustomCreds => customUser != null && customUser!.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'ip': ip, 'hostname': hostname, 'mac': mac, 'group': group,
    'isOnline': isOnline, 'sshOpen': sshOpen, 'lastSeen': lastSeen?.toIso8601String(),
    'customUser': customUser, 'customPass': customPass,
  };

  factory Host.fromJson(Map<String, dynamic> json) => Host(
    ip: json['ip'], hostname: json['hostname'], mac: json['mac'],
    group: json['group'] ?? 'default', isOnline: json['isOnline'] ?? false, sshOpen: json['sshOpen'] ?? false,
    lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
    customUser: json['customUser'], customPass: json['customPass'],
  );
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
  final List<SSHResult> results;
  bool isRunning;
  JobResult({required this.name, DateTime? startTime, List<SSHResult>? results, this.isRunning = true})
      : startTime = startTime ?? DateTime.now(), results = results ?? [];
  int get okCount => results.where((r) => r.success).length;
  int get failCount => results.where((r) => !r.success).length;
  int get total => results.length;
}
