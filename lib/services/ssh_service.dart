import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import '../models/models.dart';

class SSHService {
  static Future<SSHResult> runCommand(
    String host,
    Credentials creds,
    String command, {
    bool sudo = false,
    int timeoutSec = 30,
  }) async {
    final sw = Stopwatch()..start();
    SSHClient? client;
    try {
      final socket = await SSHSocket.connect(host, 22,
          timeout: Duration(seconds: timeoutSec));
      client = SSHClient(
        socket,
        username: creds.username,
        onPasswordRequest: () => creds.password,
      );

      SSHSession session;
      if (sudo) {
        // Open a bash session under sudo and feed the password + command via
        // stdin.  sudo -S reads the password from the first line; bash -s then
        // reads and executes the remaining lines.  No shell-quoting needed —
        // the command travels as raw bytes, so dollar signs, quotes, backticks
        // and every other special character work without any escaping.
        session = await client.execute('sudo -S bash -s');
        session.stdin.add(utf8.encode('${creds.password}\n$command\n'));
      } else {
        session = await client.execute(command);
      }
      await session.stdin.close();

      // Drain stdout and stderr concurrently so neither blocks the other.
      final stdoutBuf = <int>[];
      final stderrBuf = <int>[];
      await Future.wait([
        session.stdout.forEach((chunk) => stdoutBuf.addAll(chunk)),
        session.stderr.forEach((chunk) => stderrBuf.addAll(chunk)),
      ]);
      await session.done;

      final out = utf8.decode(stdoutBuf, allowMalformed: true).trim();
      final err = utf8.decode(stderrBuf, allowMalformed: true).trim();
      // Prefer stdout; surface stderr when stdout is empty so auth/permission
      // errors are visible in the job output instead of showing "(no output)".
      final output = out.isNotEmpty ? out : (err.isNotEmpty ? err : '(no output)');

      client.close();
      sw.stop();
      return SSHResult(host: host, success: true, output: output, duration: sw.elapsed);
    } on SocketException {
      sw.stop();
      client?.close();
      return SSHResult(host: host, success: false, output: 'Connection refused', duration: sw.elapsed);
    } on TimeoutException {
      sw.stop();
      client?.close();
      return SSHResult(host: host, success: false, output: 'Connection timed out', duration: sw.elapsed);
    } catch (e) {
      sw.stop();
      client?.close();
      return SSHResult(host: host, success: false, output: e.toString(), duration: sw.elapsed);
    }
  }

  static Future<bool> ping(String host, {int timeoutSec = 5}) async {
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', timeoutSec.toString(), host]);
      if (result.exitCode == 0) { return true; }
    } catch (_) {}
    try {
      final s = await Socket.connect(host, 22, timeout: Duration(seconds: timeoutSec));
      s.destroy();
      return true;
    } catch (_) {}
    return false;
  }

  static Stream<SSHResult> runOnAll(
    List<Host> hosts,
    Credentials creds,
    String command, {
    bool sudo = false,
    int maxParallel = 5,
    int timeoutSec = 60,
  }) async* {
    final sem = _Sem(maxParallel);
    final futures = <Future<SSHResult>>[];
    for (final host in hosts) {
      await sem.acquire();
      futures.add(runCommand(host.ip, creds, command, sudo: sudo, timeoutSec: timeoutSec)
          .whenComplete(() => sem.release()));
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
