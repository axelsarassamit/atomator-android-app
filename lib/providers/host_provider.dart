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
      if (h.isOnline && _credentials != null) {
        try {
          final r = await SSHService.runCommand(h.ip, credsForHost(h), 'hostname', timeoutSec: 5);
          if (r.success) h.hostname = r.output;
        } catch (_) {}
      }
      h.lastSeen = h.isOnline ? DateTime.now() : h.lastSeen;
      _checkProgress++;
      notifyListeners();
    }

    await _storage.saveHosts(_hosts);
    _isChecking = false;
    notifyListeners();
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
