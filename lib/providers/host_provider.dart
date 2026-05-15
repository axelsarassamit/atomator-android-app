import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/ssh_service.dart';

class HostProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Host> _hosts = [];
  Credentials? _credentials;
  bool _isConfigured = false;

  HostProvider(this._storage) { _loadData(); }

  List<Host> get hosts => _hosts;
  Credentials? get credentials => _credentials;
  bool get isConfigured => _isConfigured;
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
    _isConfigured = _credentials != null;
    notifyListeners();
  }

  Future<void> saveCredentials(Credentials creds) async {
    await _storage.saveCredentials(creds); _credentials = creds; _isConfigured = true; notifyListeners();
  }

  Future<void> addHost(String ip, {String group = 'default', String? user, String? pass}) async {
    if (_hosts.any((h) => h.ip == ip)) return;
    _hosts.add(Host(ip: ip, group: group, customUser: user, customPass: pass));
    await _storage.saveHosts(_hosts); notifyListeners();
  }

  Future<void> addHostRange(String base, int start, int end, {String group = 'default'}) async {
    for (int i = start; i <= end; i++) {
      final ip = base + '.' + i.toString();
      if (!_hosts.any((h) => h.ip == ip)) _hosts.add(Host(ip: ip, group: group));
    }
    await _storage.saveHosts(_hosts); notifyListeners();
  }

  Future<void> updateHost(Host host) async {
    final idx = _hosts.indexWhere((h) => h.ip == host.ip);
    if (idx >= 0) _hosts[idx] = host;
    await _storage.saveHosts(_hosts); notifyListeners();
  }

  Future<void> removeHost(String ip) async {
    _hosts.removeWhere((h) => h.ip == ip); await _storage.saveHosts(_hosts); notifyListeners();
  }

  Future<void> removeGroup(String group) async {
    _hosts.removeWhere((h) => h.group == group); await _storage.saveHosts(_hosts); notifyListeners();
  }

  Future<void> checkHostStatus() async {
    final futures = _hosts.map((h) async {
      h.isOnline = await SSHService.ping(h.ip);
      if (h.isOnline && _credentials != null) {
        try { final r = await SSHService.runCommand(h.ip, credsForHost(h), 'hostname', timeoutSec: 5); if (r.success) h.hostname = r.output; } catch (_) {}
      }
      h.lastSeen = h.isOnline ? DateTime.now() : h.lastSeen;
    });
    await Future.wait(futures);
    await _storage.saveHosts(_hosts); notifyListeners();
  }

  Future<void> collectMacAddresses() async {
    final cmd = 'IFACE=\$(ip route | grep default | head -1 | tr -s " " | cut -d" " -f5); cat /sys/class/net/\$IFACE/address 2>/dev/null || echo N/A';
    final futures = _hosts.where((h) => h.isOnline).map((h) async {
      try {
        final r = await SSHService.runCommand(h.ip, credsForHost(h), cmd, timeoutSec: 5);
        if (r.success && r.output != 'N/A') h.mac = r.output;
      } catch (_) {}
    });
    await Future.wait(futures);
    await _storage.saveHosts(_hosts); notifyListeners();
  }

  Future<void> clearAll() async { _hosts.clear(); await _storage.saveHosts(_hosts); notifyListeners(); }
}
