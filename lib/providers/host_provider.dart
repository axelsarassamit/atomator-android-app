import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/ssh_service.dart';

class HostProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Host> _hosts = [];
  Credentials? _credentials;
  bool _isConfigured = false;
  bool _isChecking = false;
  int _checkProgress = 0;
  int _checkTotal = 0;

  HostProvider(this._storage) { _loadData(); }

  List<Host> get hosts => _hosts;
  Credentials? get credentials => _credentials;
  bool get isConfigured => _isConfigured;
  bool get isChecking => _isChecking;
  int get checkProgress => _checkProgress;
  int get checkTotal => _checkTotal;
  String get checkStatus => _isChecking ? "Checking " + _checkProgress.toString() + "/" + _checkTotal.toString() : "";
  int get onlineCount => _hosts.where((h) => h.isOnline).length;
  int get offlineCount => _hosts.where((h) => !h.isOnline).length;
  List<String> get groups => _hosts.map((h) => h.group).toSet().toList()..sort();
  List<Host> hostsInGroup(String group) => _hosts.where((h) => h.group == group).toList();

  Credentials credsForHost(Host h) {
    if (h.hasCustomCreds) return Credentials(username: h.customUser!, password: h.customPass!);
    return _credentials!;
  }

  Future<void> _loadData() async {
    _hosts = _storage.getHosts();
    _credentials = await _storage.getCredentials();
    _isConfigured = _hosts.isNotEmpty && _credentials != null;
    notifyListeners();
  }

  Future<void> saveCredentials(Credentials creds) async {
    await _storage.saveCredentials(creds);
    _credentials = creds;
    _isConfigured = _hosts.isNotEmpty;
    notifyListeners();
  }

  Future<void> addHost(String ip, {String group = 'default', String? user, String? pass}) async {
    if (_hosts.any((h) => h.ip == ip)) return;
    _hosts.add(Host(ip: ip, group: group, customUser: user, customPass: pass));
    await _storage.saveHosts(_hosts);
    _isConfigured = _credentials != null;
    notifyListeners();
  }

  Future<void> addHostRange(String base, int start, int end, {String group = 'default'}) async {
    for (int i = start; i <= end; i++) {
      final ip = '$base.$i';
      if (!_hosts.any((h) => h.ip == ip)) _hosts.add(Host(ip: ip, group: group));
    }
    await _storage.saveHosts(_hosts);
    _isConfigured = _credentials != null;
    notifyListeners();
  }

  Future<void> updateHost(Host host) async {
    final idx = _hosts.indexWhere((h) => h.ip == host.ip);
    if (idx >= 0) _hosts[idx] = host;
    await _storage.saveHosts(_hosts);
    notifyListeners();
  }

  Future<void> removeHost(String ip) async {
    _hosts.removeWhere((h) => h.ip == ip);
    await _storage.saveHosts(_hosts);
    notifyListeners();
  }

  Future<void> checkHostStatus() async {
    _isChecking = true;
    _checkProgress = 0;
    _checkTotal = _hosts.length;
    notifyListeners();

    for (final h in _hosts) {
      h.isOnline = await SSHService.ping(h.ip);
      h.sshOpen = false;

      if (h.isOnline) {
        // Try reverse DNS lookup first
        try {
          final addr = InternetAddress(h.ip);
          final resolved = await addr.reverse();
          final rdns = resolved.host;
          if (rdns != h.ip && rdns.isNotEmpty) {
            h.hostname = rdns;
          }
        } catch (_) {}

        // Check SSH port
        try {
          final s = await Socket.connect(h.ip, 22, timeout: const Duration(seconds: 3));
          s.destroy();
          h.sshOpen = true;
        } catch (_) {}

        // If SSH works, get hostname via SSH (overrides DNS)
        if (h.sshOpen && _credentials != null) {
          try {
            final r = await SSHService.runCommand(h.ip, credsForHost(h), 'hostname', timeoutSec: 5);
            if (r.success && r.output.isNotEmpty) h.hostname = r.output;
          } catch (_) {}

          // Get MAC if we dont have one
          if (h.mac == null || h.mac!.isEmpty) {
            try {
              final r = await SSHService.runCommand(h.ip, credsForHost(h), 'ip link show | grep -A1 "state UP" | grep link/ether | head -1 | tr -s " " | cut -d" " -f3', timeoutSec: 5);
              if (r.success && r.output.isNotEmpty && r.output != 'N/A') h.mac = r.output.trim();
            } catch (_) {}
          }
        }

        // If no hostname yet, try MAC vendor lookup
        if ((h.hostname == null || h.hostname!.isEmpty || h.hostname == h.ip) && h.mac != null && h.mac!.length >= 8) {
          h.hostname = _macVendor(h.mac!);
        }
      }

      h.lastSeen = h.isOnline ? DateTime.now() : h.lastSeen;
      _checkProgress++;
      notifyListeners();
    }

    await _storage.saveHosts(_hosts);
    _isChecking = false;
    notifyListeners();
  }

  static String _macVendor(String mac) {
    final prefix = mac.substring(0, 8).toUpperCase();
    const vendors = {
      'DC:A6:32': 'Raspberry Pi',
      'B8:27:EB': 'Raspberry Pi',
      'E4:5F:01': 'Raspberry Pi',
      '28:CD:C1': 'Raspberry Pi',
      '00:50:56': 'VMware',
      '00:0C:29': 'VMware',
      '00:1C:42': 'Parallels',
      '08:00:27': 'VirtualBox',
      '52:54:00': 'QEMU/KVM',
      '00:15:5D': 'Hyper-V',
      'F8:75:A4': 'DELL',
      '00:25:64': 'DELL',
      '18:A9:05': 'HP',
      '3C:D9:2B': 'HP',
      '00:1E:68': 'Quanta/HP',
      '00:25:B5': 'HP',
      'AC:16:2D': 'HP',
      '00:1A:A0': 'DELL',
      '00:0D:3A': 'Microsoft Azure',
      '00:1B:21': 'Intel',
      '00:1E:67': 'Intel',
      '3C:97:0E': 'Intel',
      'A4:BF:01': 'Intel',
      '48:21:0B': 'Intel',
      'F4:4D:30': 'Lenovo',
      '00:06:1B': 'Lenovo',
      '70:5A:0F': 'Lenovo',
      '00:23:AE': 'DELL',
      '84:7B:EB': 'DELL',
      'F0:1F:AF': 'DELL',
      'E0:DB:55': 'DELL',
      'C8:1F:66': 'Huawei',
      '00:E0:FC': 'Huawei',
      '48:46:FB': 'Huawei',
      '00:1B:44': 'SanDisk',
      '00:17:88': 'Philips Hue',
      'B0:BE:76': 'TP-Link',
      '50:C7:BF': 'TP-Link',
      'EC:08:6B': 'TP-Link',
      'C0:25:E9': 'TP-Link',
      '00:1D:7E': 'Cisco',
      '00:26:0B': 'Cisco',
      '00:1E:49': 'Cisco',
      '58:97:BD': 'Cisco',
      '00:24:C4': 'Cisco',
      'F0:9F:C2': 'Ubiquiti',
      '78:8A:20': 'Ubiquiti',
      '80:2A:A8': 'Ubiquiti',
      'FC:EC:DA': 'Ubiquiti',
      '00:27:22': 'Ubiquiti',
      '44:D9:E7': 'Ubiquiti',
      '24:5A:4C': 'Ubiquiti',
      '00:0E:08': 'Shuttle',
      'B4:FB:E4': 'Ubiquiti',
      '18:E8:29': 'Ubiquiti',
      '74:83:C2': 'Ubiquiti',
    };
    return vendors[prefix] ?? 'Unknown device';
  }

  Future<void> collectMacAddresses() async {
    final futures = _hosts.where((h) => h.isOnline).map((h) async {
      try {
        final r = await SSHService.runCommand(h.ip, credsForHost(h), 'ip link show | grep -A1 "state UP" | grep link/ether | head -1 | tr -s " " | cut -d" " -f3', timeoutSec: 5);
        if (r.success && r.output.isNotEmpty && r.output != 'N/A') h.mac = r.output.trim();
      } catch (_) {}
    });
    await Future.wait(futures);
    await _storage.saveHosts(_hosts); notifyListeners();
  }

  Future<void> removeGroup(String group) async {
    _hosts.removeWhere((h) => h.group == group);
    await _storage.saveHosts(_hosts); notifyListeners();
  }

  Future<void> clearAll() async {
    _hosts.clear();
    await _storage.saveHosts(_hosts);
    _isConfigured = false;
    notifyListeners();
  }
}
