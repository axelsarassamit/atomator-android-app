import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  late SharedPreferences _prefs;
  final _secure = const FlutterSecureStorage();
  Future<void> init() async { _prefs = await SharedPreferences.getInstance(); }
  Future<void> saveCredentials(Credentials creds) async { await _secure.write(key: 'ssh_user', value: creds.username); await _secure.write(key: 'ssh_pass', value: creds.password); }
  Future<Credentials?> getCredentials() async { final user = await _secure.read(key: 'ssh_user'); final pass = await _secure.read(key: 'ssh_pass'); if (user == null || pass == null) return null; return Credentials(username: user, password: pass); }
  Future<void> saveHosts(List<Host> hosts) async { await _prefs.setString('hosts', jsonEncode(hosts.map((h) => h.toJson()).toList())); }
  List<Host> getHosts() { final data = _prefs.getString('hosts'); if (data == null) return []; return (jsonDecode(data) as List).map((j) => Host.fromJson(j)).toList(); }
  bool get isConfigured => _prefs.containsKey('hosts');
}
