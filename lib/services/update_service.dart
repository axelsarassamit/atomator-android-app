import 'dart:convert';
import 'dart:io';
import '../../lib/version.dart' as ver;

class UpdateService {
  static const String currentVersion = '1.2.7';
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
      final assets = data['assets'] as List;
      String? apkUrl;
      String? apkName;
      for (final asset in assets) {
        final name = asset['name'] as String;
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String;
          apkName = name;
          break;
        }
      }
      return {
        'version': tagName,
        'current': currentVersion,
        'isNewer': _isNewer(tagName, currentVersion),
        'apkUrl': apkUrl,
        'apkName': apkName,
        'body': data['body'] ?? '',
      };
    } catch (e) {
      return {'error': e.toString(), 'current': currentVersion};
    }
  }

  static Future<String?> downloadApk(String url, String filename, Function(double) onProgress) async {
    try {
      final dir = Directory('/storage/emulated/0/Download');
      if (!dir.existsSync()) {
        final altDir = await _getDownloadDir();
        if (altDir == null) return null;
        return await _download(url, altDir + '/' + filename, onProgress);
      }
      return await _download(url, dir.path + '/' + filename, onProgress);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> _getDownloadDir() async {
    try {
      final dir = Directory('/storage/emulated/0/Download');
      if (dir.existsSync()) return dir.path;
      final tmpDir = Directory.systemTemp;
      return tmpDir.path;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _download(String url, String filePath, Function(double) onProgress) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final totalBytes = response.contentLength;
    int receivedBytes = 0;
    final file = File(filePath);
    final sink = file.openWrite();
    await for (final chunk in response) {
      sink.add(chunk);
      receivedBytes += chunk.length;
      if (totalBytes > 0) onProgress(receivedBytes / totalBytes);
    }
    await sink.close();
    return filePath;
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
