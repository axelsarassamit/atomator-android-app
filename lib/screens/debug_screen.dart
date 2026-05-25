import 'package:flutter/material.dart';
import 'dart:io';
import '../version.dart';

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
      String? wifiIp;       // from wlan/eth — first choice
      String? anyPrivateIp; // any private IP — fallback

      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          final isPrivate = ip.startsWith('192.168.') || ip.startsWith('172.') || ip.startsWith('10.');
          if (!isPrivate) continue;
          // Prefer real WiFi/LAN interfaces over cellular (ccmni, rmnet, ppp, etc.)
          final isWifi = iface.name.startsWith('wlan') || iface.name.startsWith('eth') || iface.name.startsWith('en');
          if (isWifi && wifiIp == null) wifiIp = ip;
          anyPrivateIp ??= ip;
        }
      }

      final bestIp = wifiIp ?? anyPrivateIp;
      if (bestIp != null) {
        final parts = bestIp.split('.');
        final gateway = '${parts[0]}.${parts[1]}.${parts[2]}.1';
        setState(() {
          _detectedNetwork = 'Your IP: $bestIp | Gateway: $gateway';
          if (_ipCtrl.text.isEmpty || _ipCtrl.text == '192.168.1.1') {
            _ipCtrl.text = gateway;
          }
        });
      } else {
        setState(() => _detectedNetwork = 'No local network detected');
      }
    } catch (e) {
      setState(() => _detectedNetwork = 'Detection error: $e');
    }
  }

  void _addLog(String msg) {
    setState(() => _log.add('[${DateTime.now().toString().substring(11, 19)}] $msg'));
  }

  Future<void> _runAllTests() async {
    setState(() { _log.clear(); _running = true; });

    _addLog('=== ATOMATOR DEBUG ===');
    _addLog('App version: $appVersion (build $appBuild)');
    _addLog('Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    _addLog('');

    // Detect network — show all interfaces
    _addLog('--- Network Detection ---');
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          _addLog('Interface: ${iface.name} = ${addr.address}');
        }
      }
    } catch (e) {
      _addLog('FAIL: $e');
    }

    // Test 1: Internet
    _addLog('--- Test 1: Internet access ---');
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty) { _addLog('OK: DNS google.com = ${result[0].address}'); } else { _addLog('FAIL: DNS empty'); }
    } catch (e) {
      _addLog('FAIL: $e');
    }

    // Test 2: HTTP
    _addLog('--- Test 2: HTTP connection ---');
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse('https://api.github.com'));
      final response = await request.close();
      _addLog('OK: GitHub API status ${response.statusCode}');
    } catch (e) {
      _addLog('FAIL: $e');
    }

    // Test 3: SSH to the chosen IP
    final ip = _ipCtrl.text.trim();
    _addLog('--- Test 3: SSH to $ip:22 ---');
    try {
      final socket = await Socket.connect(ip, 22, timeout: const Duration(seconds: 5));
      _addLog('OK: Connected to $ip:22');
      socket.listen((data) => _addLog('SSH Banner: ${String.fromCharCodes(data).trim()}'));
      await Future.delayed(const Duration(seconds: 2));
      socket.destroy();
    } catch (e) {
      _addLog('FAIL: $e');
    }

    // Test 4: Ping
    _addLog('--- Test 4: ICMP ping $ip ---');
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', '2', ip]);
      _addLog(result.exitCode == 0 ? 'OK: ping success' : 'FAIL: ping returned ${result.exitCode}');
    } catch (e) {
      _addLog('FAIL: $e');
    }

    // Test 5: Parallel SSH scan of full subnet
    final base = ip.contains('.') ? ip.substring(0, ip.lastIndexOf('.')) : '192.168.0';
    _addLog('--- Test 5: Scan $base.1-100 for SSH (parallel) ---');
    int found = 0;
    final scanFutures = <Future<void>>[];
    for (int i = 1; i <= 100; i++) {
      final scanIp = '$base.$i';
      scanFutures.add(() async {
        try {
          final s = await Socket.connect(scanIp, 22, timeout: const Duration(milliseconds: 500));
          if (mounted) { setState(() => _log.add('[${DateTime.now().toString().substring(11, 19)}] FOUND: $scanIp:22 open')); }
          s.destroy();
          found++;
        } catch (_) {}
      }());
    }
    await Future.wait(scanFutures);
    _addLog(found > 0 ? 'Found $found SSH host(s) in $base.1-100' : 'No SSH hosts found in $base.1-100');

    // Test 6: File system
    _addLog('--- Test 6: File system ---');
    try {
      final dlDir = Directory('/storage/emulated/0/Download');
      _addLog('Download dir exists: ${dlDir.existsSync()}');
      final testFile = File('${Directory.systemTemp.path}/atomator_test.txt');
      testFile.writeAsStringSync('test');
      _addLog('OK: Can write files');
      testFile.deleteSync();
    } catch (e) {
      _addLog('FAIL: $e');
    }

    _addLog('');
    _addLog('=== TESTS COMPLETE ===');
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: SafeArea(top: false, child: Column(children: [
        if (_detectedNetwork.isNotEmpty) Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Text(_detectedNetwork, style: const TextStyle(fontSize: 11, color: Colors.cyan)),
        ),
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: TextField(controller: _ipCtrl, decoration: const InputDecoration(labelText: 'Test IP (enter your SSH host)', border: OutlineInputBorder(), isDense: true))),
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
              if (line.contains('OK:')) { color = Colors.green; }
              if (line.contains('FAIL:')) { color = Colors.red; }
              if (line.contains('FOUND:')) { color = Colors.green; }
              if (line.contains('===')) { color = Colors.cyan; }
              if (line.contains('---')) { color = Colors.yellow; }
              if (line.contains('Interface:')) { color = Colors.cyan; }
              return Text(line, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: color));
            },
          ),
        )),
      ])),   // closes Column + SafeArea
    );
  }
}
