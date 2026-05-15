import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import '../models/models.dart';

class SSHService {
  static Future<SSHResult> runCommand(String host, Credentials creds, String command, {bool sudo = false, int timeoutSec = 30}) async {
    final sw = Stopwatch()..start();
    try {
      final socket = await SSHSocket.connect(host, 22, timeout: Duration(seconds: timeoutSec));
      final client = SSHClient(socket, username: creds.username, onPasswordRequest: () => creds.password);
      String cmd = sudo ? 'echo "${creds.password}" | sudo -S bash -c "$command"' : command;
      final result = await client.run(cmd);
      final output = String.fromCharCodes(result).trim();
      client.close();
      sw.stop();
      return SSHResult(host: host, success: true, output: output, duration: sw.elapsed);
    } on SocketException { sw.stop(); return SSHResult(host: host, success: false, output: 'Connection failed', duration: sw.elapsed);
    } on TimeoutException { sw.stop(); return SSHResult(host: host, success: false, output: 'Timeout', duration: sw.elapsed);
    } catch (e) { sw.stop(); return SSHResult(host: host, success: false, output: e.toString(), duration: sw.elapsed); }
  }

  static Future<bool> ping(String host, {int timeoutSec = 5}) async {
    // Try SSH port first (most reliable for our use case)
    try {
      final s = await Socket.connect(host, 22, timeout: Duration(seconds: timeoutSec));
      s.destroy();
      return true;
    } catch (_) {}

    // Fall back to ICMP ping
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', timeoutSec.toString(), host]);
      if (result.exitCode == 0) return true;
    } catch (_) {}

    return false;
  }

  static Stream<SSHResult> runOnAll(List<Host> hosts, Credentials creds, String command, {bool sudo = false, int maxParallel = 5, int timeoutSec = 60}) async* {
    final sem = _Sem(maxParallel);
    final futures = <Future<SSHResult>>[];
    for (final host in hosts) { await sem.acquire(); futures.add(runCommand(host.ip, creds, command, sudo: sudo, timeoutSec: timeoutSec).whenComplete(() => sem.release())); }
    for (final f in futures) { yield await f; }
  }
}

class _Sem {
  int _c; final _w = <Completer<void>>[]; _Sem(this._c);
  Future<void> acquire() async { if (_c > 0) { _c--; return; } final c = Completer<void>(); _w.add(c); await c.future; }
  void release() { if (_w.isNotEmpty) { _w.removeAt(0).complete(); } else { _c++; } }
}
