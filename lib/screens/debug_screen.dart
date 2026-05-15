import 'package:flutter/material.dart';
import 'dart:io';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});
  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final List<String> _log = [];
  final _ipCtrl = TextEditingController();
  bool _running = false;
  String _detectedNetwork = '';

  @override
  void initState() {
    super.initState();
    _detectNetwork();
  }

  Future<void> _detectNetwork() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (ip.startsWith('192.168.') || ip.startsWith('10.') || ip.startsWith('172.')) {
            final parts = ip.split('.');
            final gateway = parts[0] + '.' + parts[1] + '.' + parts[2] + '.1';
            setState(() {
              _detectedNetwork = 'Your IP: ' + ip + ' | Gateway: ' + gateway;
              if (_ipCtrl.text.isEmpty || _ipCtrl.text == '192.168.1.1') {
                _ipCtrl.text = gateway;
              }
            });
            return;
          }
        }
      }
      setState(() => _detectedNetwork = 'No local network detected');
    } catch (e) {
      setState(() => _detectedNetwork = 'Detection error: ' + e.toString());
    }
  }

  void _addLog(String msg) {
    setState(() => _log.add('[' + DateTime.now().toString().substring(11, 19) + '] ' + msg));
  }

  Future<void> _runAllTests() async {
    setState(() { _log.clear(); _running = true; });

    _addLog('=== ATOMATOR DEBUG ===');
    _addLog('App version: 1.2.19');
    _addLog('Platform: ' + Platform.operatingSystem + ' ' + Platform.operatingSystemVersion);
    _addLog('');

    // Detect network
    _addLog('--- Network Detection ---');
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          _addLog('Interface: ' + iface.name + ' = ' + addr.address);
        }
      }
    } catch (e) {
      _addLog('FAIL: ' + e.toString());
    }

    // Test 1: Internet
    _addLog('--- Test 1: Internet access ---');
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty) _addLog('OK: DNS google.com = ' + result[0].address);
      else _addLog('FAIL: DNS empty');
    } catch (e) {
      _addLog('FAIL: ' + e.toString());
    }

    // Test 2: HTTP
    _addLog('--- Test 2: HTTP connection ---');
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse('https://api.github.com'));
      final response = await request.close();
      _addLog('OK: GitHub API status ' + response.statusCode.toString());
    } catch (e) {
      _addLog('FAIL: ' + e.toString());
    }

    // Test 3: Local SSH
    final ip = _ipCtrl.text;
    _addLog('--- Test 3: SSH to ' + ip + ':22 ---');
    try {
      final socket = await Socket.connect(ip, 22, timeout: const Duration(seconds: 5));
      _addLog('OK: Connected to ' + ip + ':22');
      socket.listen((data) => _addLog('SSH Banner: ' + String.fromCharCodes(data).trim()));
      await Future.delayed(const Duration(seconds: 2));
      socket.destroy();
    } catch (e) {
      _addLog('FAIL: ' + e.toString());
    }

    // Test 4: Ping
    _addLog('--- Test 4: ICMP ping ' + ip + ' ---');
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', '2', ip]);
      _addLog(result.exitCode == 0 ? 'OK: ping success' : 'FAIL: ping returned ' + result.exitCode.toString());
    } catch (e) {
      _addLog('FAIL: ' + e.toString());
    }

    // Test 5: Scan nearby ports
    _addLog('--- Test 5: Scan ' + ip.substring(0, ip.lastIndexOf('.')) + '.X for SSH ---');
    final base = ip.substring(0, ip.lastIndexOf('.'));
    int found = 0;
    for (int i = 1; i <= 10; i++) {
      final scanIp = base + '.' + i.toString();
      try {
        final socket = await Socket.connect(scanIp, 22, timeout: const Duration(seconds: 1));
        _addLog('FOUND: ' + scanIp + ':22 open');
        socket.destroy();
        found++;
      } catch (_) {}
    }
    _addLog(found > 0 ? 'Found ' + found.toString() + ' SSH hosts' : 'No SSH hosts found in ' + base + '.1-10');

    // Test 6: File system
    _addLog('--- Test 6: File system ---');
    try {
      final dlDir = Directory('/storage/emulated/0/Download');
      _addLog('Download dir exists: ' + dlDir.existsSync().toString());
      final testFile = File(Directory.systemTemp.path + '/atomator_test.txt');
      testFile.writeAsStringSync('test');
      _addLog('OK: Can write files');
      testFile.deleteSync();
    } catch (e) {
      _addLog('FAIL: ' + e.toString());
    }

    _addLog('');
    _addLog('=== TESTS COMPLETE ===');
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: Column(children: [
        if (_detectedNetwork.isNotEmpty) Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Text(_detectedNetwork, style: const TextStyle(fontSize: 11, color: Colors.cyan)),
        ),
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: TextField(controller: _ipCtrl, decoration: const InputDecoration(labelText: 'Test IP', border: OutlineInputBorder(), isDense: true))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _running ? null : _runAllTests, child: Text(_running ? 'Running...' : 'Run Tests')),
        ])),
        Expanded(child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: _log.length,
            itemBuilder: (context, i) {
              final line = _log[i];
              Color color = Colors.white70;
              if (line.contains('OK:')) color = Colors.green;
              if (line.contains('FAIL:')) color = Colors.red;
              if (line.contains('FOUND:')) color = Colors.green;
              if (line.contains('===')) color = Colors.cyan;
              if (line.contains('---')) color = Colors.yellow;
              if (line.contains('Interface:')) color = Colors.cyan;
              return Text(line, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: color));
            },
          ),
        )),
      ]),
    );
  }
}
