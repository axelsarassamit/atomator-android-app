import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import '../models/models.dart';

class SSHService {
  static Future<SSHResult> runCommand(String host, Credentials creds, String command, {bool sudo = false, int timeoutSec = 30}) async {
    final sw = Stopwatch()..start();
    try {
      final socket = await SSHSocket.connect(host, 22, timeout: Duration(seconds: timeoutSec));
      final client = SSHClient(socket, username: creds.username, onPasswordRequest: () => creds.password);

      // Build the command to execute on the remote host.
      //
      // When sudo is required we must avoid double-quote wrapping because the
      // inner command often contains double quotes (echo "...", [ -n "$var" ], etc.)
      // which would break bash -c "..." quoting.
      //
      // Fix: base64-encode the command so it contains only safe alphanumerics,
      // then decode and execute it inside a single-quoted bash -c '...'.
      // The password is passed via printf + single quotes, with inner single
      // quotes escaped via the '...'\'\'... shell idiom.
      final String cmd;
      if (sudo) {
        final b64 = base64Encode(utf8.encode(command));
        final pass = creds.password.replaceAll("'", "'\\''");
        cmd = "printf '%s\\n' '$pass' | sudo -S bash -c 'echo $b64 | base64 -d | bash'";
      } else {
        cmd = command;
      }

      final result = await client.run(cmd);
      final output = utf8.decode(result, allowMalformed: true).trim();
      client.close();
      sw.stop();
      return SSHResult(host: host, success: true, output: output, duration: sw.elapsed);
    } on SocketException {
      sw.stop();
      return SSHResult(host: host, success: false, output: 'Connection refused', duration: sw.elapsed);
    } on TimeoutException {
      sw.stop();
      return SSHResult(host: host, success: false, output: 'Connection timed out', duration: sw.elapsed);
    } catch (e) {
      sw.stop();
      return SSHResult(host: host, success: false, output: e.toString(), duration: sw.elapsed);
    }
  }

  static Future<bool> ping(String host, {int timeoutSec = 5}) async {
    // Try ICMP ping first (works even if SSH is not running)
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', timeoutSec.toString(), host]);
      if (result.exitCode == 0) { return true; }
    } catch (_) {}

    // Fall back to SSH port check
    try {
      final s = await Socket.connect(host, 22, timeout: Duration(seconds: timeoutSec));
      s.destroy();
      return true;
    } catch (_) {}

    return false;
  }

  static Stream<SSHResult> runOnAll(List<Host> hosts, Credentials creds, String command, {bool sudo = false, int maxParallel = 5, int timeoutSec = 60}) async* {
    final sem = _Sem(maxParallel);
    final futures = <Future<SSHResult>>[];
    for (final host in hosts) {
      await sem.acquire();
      futures.add(runCommand(host.ip, creds, command, sudo: sudo, timeoutSec: timeoutSec).whenComplete(() => sem.release()));
    }
    for (final f in futures) { yield await f; }
  }
}

class _Sem {
  int _c;
  final _w = <Completer<void>>[];
  _Sem(this._c);
  Future<void> acquire() async {
    if (_c > 0) { _c--; return; }
    final c = Completer<void>();
    _w.add(c);
    await c.future;
  }
  void release() {
    if (_w.isNotEmpty) { _w.removeAt(0).complete(); } else { _c++; }
  }
}
