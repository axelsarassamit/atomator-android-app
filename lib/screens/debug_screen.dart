import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});
  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final List<String> _log = [];
  final _ipCtrl = TextEditingController(text: '192.168.1.1');
  bool _running = false;

  void _addLog(String msg) {
    setState(() => _log.add('[' + DateTime.now().toString().substring(11, 19) + '] ' + msg));
  }

  Future<void> _runAllTests() async {
    setState(() { _log.clear(); _running = true; });

    _addLog('=== ATOMATOR DEBUG ===');
    _addLog('App version: 1.2.15');
    _addLog('Platform: ' + Platform.operatingSystem + ' ' + Platform.operatingSystemVersion);
    _addLog('');

    // Test 1: Internet access
    _addLog('--- Test 1: Internet access ---');
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _addLog('OK: DNS lookup google.com = ' + result[0].address);
      } else {
        _addLog('FAIL: DNS returned empty');
      }
    } catch (e) {
      _addLog('FAIL: ' + e.toString());
    }

    // Test 2: HTTP connection
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

    // Test 3: Local network ping (TCP port 22)
    _addLog('--- Test 3: Local SSH ping ---');
    final ip = _ipCtrl.text;
    try {
      final socket = await Socket.connect(ip, 22, timeout: const Duration(seconds: 5));
      _addLog('OK: Connected to ' + ip + ':22');
      socket.destroy();
    } catch (e) {
      _addLog('FAIL: Cannot reach ' + ip + ':22 - ' + e.toString());
    }

    // Test 4: Raw TCP to local IP
    _addLog('--- Test 4: Raw TCP to ' + ip + ' ---');
    try {
      final socket = await Socket.connect(ip, 80, timeout: const Duration(seconds: 3));
      _addLog('OK: TCP port 80 open on ' + ip);
      socket.destroy();
    } catch (e) {
      _addLog('INFO: Port 80 closed (normal) - ' + e.runtimeType.toString());
    }

    // Test 5: ICMP-like check via Process
    _addLog('--- Test 5: ping command ---');
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', '2', ip]);
      if (result.exitCode == 0) {
        _addLog('OK: ping ' + ip + ' success');
      } else {
        _addLog('FAIL: ping returned ' + result.exitCode.toString());
        _addLog('stderr: ' + result.stderr.toString().trim());
      }
    } catch (e) {
      _addLog('FAIL: ping command error - ' + e.toString());
    }

    // Test 6: File system access
    _addLog('--- Test 6: File system ---');
    try {
      final dlDir = Directory('/storage/emulated/0/Download');
      _addLog('Download dir exists: ' + dlDir.existsSync().toString());
      final tmpDir = Directory.systemTemp;
      _addLog('Temp dir: ' + tmpDir.path);
      final testFile = File(tmpDir.path + '/atomator_test.txt');
      testFile.writeAsStringSync('test');
      _addLog('OK: Can write to temp dir');
      testFile.deleteSync();
    } catch (e) {
      _addLog('FAIL: ' + e.toString());
    }

    // Test 7: SSH connection with dartssh2
    _addLog('--- Test 7: SSH library test ---');
    try {
      final socket = await Socket.connect(ip, 22, timeout: const Duration(seconds: 5));
      _addLog('OK: Socket connected to ' + ip + ':22');
      // Read SSH banner
      socket.listen((data) {
        final banner = String.fromCharCodes(data).trim();
        _addLog('SSH Banner: ' + banner);
      });
      await Future.delayed(const Duration(seconds: 2));
      socket.destroy();
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
              if (line.contains('===')) color = Colors.cyan;
              if (line.contains('---')) color = Colors.yellow;
              if (line.contains('INFO:')) color = Colors.orange;
              return Text(line, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: color));
            },
          ),
        )),
      ]),
    );
  }
}
