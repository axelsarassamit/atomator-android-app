import 'dart:convert';
import 'dart:io';
import 'package:open_filex/open_filex.dart';

class UpdateService {
  static const String currentVersion = '1.3.2';
  static const String _repo = 'axelsarassamit/atomator-android-app';

  static Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse('https://api.github.com/repos/' + _repo + '/releases/latest'));
      request.headers.add('Accept', 'application/vnd.github.v3+json');
      request.headers.add('User-Agent', 'Atomator-App');
      final response = await request.close();
      if (response.statusCode != 200) return null;
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body) as Map<String, dynamic>;
      final tagName = (data['tag_name'] as String).replaceFirst('v', '');
      if (!_isNewer(tagName, currentVersion)) return null;
      final assets = data['assets'] as List;
      String? apkUrl, apkName;
      for (final asset in assets) {
        final name = asset['name'] as String;
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String;
          apkName = name;
          break;
        }
      }
      return {'version': tagName, 'current': currentVersion, 'apkUrl': apkUrl, 'apkName': apkName, 'body': data['body'] ?? ''};
    } catch (e) {
      return {'error': e.toString(), 'current': currentVersion};
    }
  }

  static Future<String?> downloadApk(String url, String filename, Function(double) onProgress) async {
    try {
      final dir = Directory('/storage/emulated/0/Download');
      final path = (dir.existsSync() ? dir.path : Directory.systemTemp.path) + '/' + filename;
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final totalBytes = response.contentLength;
      int received = 0;
      final file = File(path);
      final sink = file.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (totalBytes > 0) onProgress(received / totalBytes);
      }
      await sink.close();
      return path;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> installApk(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath, type: 'application/vnd.android.package-archive');
      return result.type == ResultType.done;
    } catch (e) {
      return false;
    }
  }

  static Future<void> openDownloads() async {
    try {
      await Process.run('am', ['start', '-a', 'android.intent.action.VIEW', '-d', 'content://com.android.externalstorage.documents/document/primary:Download', '-t', 'vnd.android.document/directory']);
    } catch (_) {
      try {
        await Process.run('am', ['start', '-a', 'android.intent.action.VIEW', '-d', 'file:///storage/emulated/0/Download/', '-t', 'resource/folder']);
      } catch (_) {}
    }
  }

  static bool _isNewer(String remote, String local) {
    final r = remote.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final l = local.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    while (r.length < 3) r.add(0);
    while (l.length < 3) l.add(0);
    for (int i = 0; i < 3; i++) {
      if (r[i] > l[i]) return true;
      if (r[i] < l[i]) return false;
    }
    return false;
  }
}
