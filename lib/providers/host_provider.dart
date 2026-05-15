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

  Future<void> _loadData() async {
    _hosts = _storage.getHosts();
    _credentials = await _storage.getCredentials();
    _isConfigured = _hosts.isNotEmpty && _credentials != null;
    notifyListeners();
  }

  Future<void> saveCredentials(Credentials creds) async { await _storage.saveCredentials(creds); _credentials = creds; _isConfigured = _hosts.isNotEmpty; notifyListeners(); }

  Future<void> addHost(String ip, {String group = 'default'}) async { if (_hosts.any((h) => h.ip == ip)) return; _hosts.add(Host(ip: ip, group: group)); await _storage.saveHosts(_hosts); _isConfigured = _credentials != null; notifyListeners(); }

  Future<void> addHostRange(String base, int start, int end, {String group = 'default'}) async {
    for (int i = start; i <= end; i++) { final ip = '$base.$i'; if (!_hosts.any((h) => h.ip == ip)) _hosts.add(Host(ip: ip, group: group)); }
    await _storage.saveHosts(_hosts); _isConfigured = _credentials != null; notifyListeners();
  }

  Future<void> removeHost(String ip) async { _hosts.removeWhere((h) => h.ip == ip); await _storage.saveHosts(_hosts); notifyListeners(); }

  Future<void> checkHostStatus() async {
    final futures = _hosts.map((h) async {
      h.isOnline = await SSHService.ping(h.ip);
      if (h.isOnline && _credentials != null) { try { final r = await SSHService.runCommand(h.ip, _credentials!, 'hostname', timeoutSec: 5); if (r.success) h.hostname = r.output; } catch (_) {} }
      h.lastSeen = h.isOnline ? DateTime.now() : h.lastSeen;
    });
    await Future.wait(futures);
    await _storage.saveHosts(_hosts);
    notifyListeners();
  }

  Future<void> clearAll() async { _hosts.clear(); await _storage.saveHosts(_hosts); _isConfigured = false; notifyListeners(); }
}
