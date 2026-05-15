import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class UpdateService {
  static const String _repo = 'axelsarassamit/atomator-android-app';
  static const String currentVersion = '1.2.3';

  static Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://api.github.com/repos/' + _repo + '/releases/latest'));
      request.headers.add('Accept', 'application/vnd.github.v3+json');
      request.headers.add('User-Agent', 'Atomator-App');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body) as Map<String, dynamic>;
      final tagName = (data['tag_name'] as String).replaceFirst('v', '');
      if (_isNewer(tagName, currentVersion)) {
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
          'apkUrl': apkUrl,
          'apkName': apkName,
          'body': data['body'] ?? '',
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> downloadApk(String url, String filename, Function(double) onProgress) async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return null;
      final filePath = dir.path + '/' + filename;
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
    } catch (e) {
      return null;
    }
  }

  static bool _isNewer(String remote, String local) {
    final r = remote.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final l = local.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    for (int i = 0; i < 3; i++) {
      final rv = i < r.length ? r[i] : 0;
      final lv = i < l.length ? l[i] : 0;
      if (rv > lv) return true;
      if (rv < lv) return false;
    }
    return false;
  }
}
