import 'package:flutter/material.dart';
import 'dart:io';
import '../services/update_service.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});
  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  Map<String, dynamic>? _update;
  bool _checking = true;
  bool _downloading = false;
  double _progress = 0;
  String? _downloadedPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    setState(() { _checking = true; _error = null; });
    final update = await UpdateService.checkForUpdate();
    setState(() { _update = update; _checking = false; });
  }

  Future<void> _download() async {
    if (_update == null || _update!['apkUrl'] == null) return;
    setState(() { _downloading = true; _progress = 0; _error = null; });
    final path = await UpdateService.downloadApk(
      _update!['apkUrl'], _update!['apkName'] ?? 'atomator.apk',
      (p) => setState(() => _progress = p),
    );
    if (path != null) {
      setState(() { _downloadedPath = path; _downloading = false; });
    } else {
      setState(() { _error = 'Download failed'; _downloading = false; });
    }
  }

  Future<void> _install() async {
    if (_downloadedPath == null) return;
    try {
      final result = await Process.run('am', ['start', '-a', 'android.intent.action.VIEW', '-d', 'file://' + _downloadedPath!, '-t', 'application/vnd.android.package-archive']);
    } catch (e) {
      setState(() => _error = 'Could not open installer. Install manually from: ' + (_downloadedPath ?? ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Update')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/atomator_banner.png', height: 60, fit: BoxFit.contain),
            const SizedBox(height: 24),
            if (_checking) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              const Center(child: Text('Checking for updates...', style: TextStyle(color: Colors.white38))),
            ] else if (_update == null) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text('You are on the latest version!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Current: v' + UpdateService.currentVersion, style: const TextStyle(color: Colors.white38)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _checkUpdate, child: const Text('Check Again')),
            ] else ...[
              const Icon(Icons.system_update, color: Colors.cyan, size: 48),
              const SizedBox(height: 16),
              Text('Update Available!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyan)),
              const SizedBox(height: 8),
              Text('Current: v' + (_update!['current'] ?? '?'), style: const TextStyle(color: Colors.white38)),
              Text('New: v' + (_update!['version'] ?? '?'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_update!['body'] != null && (_update!['body'] as String).isNotEmpty) ...[
                const Text('Release Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_update!['body'], style: const TextStyle(fontSize: 12, color: Colors.white60)),
                const SizedBox(height: 16),
              ],
              if (_downloading) ...[
                LinearProgressIndicator(value: _progress, color: Colors.cyan),
                const SizedBox(height: 8),
                Text((_progress * 100).toInt().toString() + '%', style: const TextStyle(color: Colors.white38)),
              ] else if (_downloadedPath != null) ...[
                const Text('Downloaded!', style: TextStyle(color: Colors.green)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.install_mobile),
                  label: const Text('Install Update'),
                  onPressed: _install,
                ),
                const SizedBox(height: 8),
                Text('File: ' + (_downloadedPath ?? ''), style: const TextStyle(fontSize: 10, color: Colors.white24)),
              ] else ...[
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: Text('Download v' + (_update!['version'] ?? '')),
                  onPressed: _download,
                )),
              ],
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
