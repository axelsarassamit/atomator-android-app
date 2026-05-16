import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../services/update_service.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});
  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  Map<String, dynamic>? _update;
  List<Map<String, dynamic>> _allReleases = [];
  bool _checking = true;
  bool _downloading = false;
  double _progress = 0;
  String? _downloadedPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _checkUpdate();
    _loadAllReleases();
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _checkUpdate() async {
    setState(() { _checking = true; _error = null; });
    final update = await UpdateService.checkForUpdate();
    setState(() { _update = update; _checking = false; });
  }

  Future<void> _loadAllReleases() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://api.github.com/repos/axelsarassamit/atomator-android-app/releases?per_page=50'));
      request.headers.add('Accept', 'application/vnd.github.v3+json');
      request.headers.add('User-Agent', 'Atomator-App');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body) as List;
      setState(() {
        _allReleases = data.map((r) {
          final assets = r['assets'] as List;
          String? apkUrl, apkName;
          int? size;
          for (final a in assets) {
            if ((a['name'] as String).endsWith('.apk')) {
              apkUrl = a['browser_download_url'] as String;
              apkName = a['name'] as String;
              size = a['size'] as int;
              break;
            }
          }
          return {
            'version': (r['tag_name'] as String).replaceFirst('v', ''),
            'name': r['name'] ?? r['tag_name'],
            'body': r['body'] ?? '',
            'date': (r['published_at'] as String).substring(0, 10),
            'apkUrl': apkUrl, 'apkName': apkName, 'size': size,
          };
        }).toList();
      });
    } catch (_) {}
  }

  Future<void> _downloadAndInstall(String url, String filename) async {
    setState(() { _downloading = true; _progress = 0; _error = null; _downloadedPath = null; });
    final path = await UpdateService.downloadApk(url, filename, (p) => setState(() => _progress = p));
    if (path != null) {
      setState(() { _downloadedPath = path; _downloading = false; });
      final ok = await UpdateService.installApk(path);
      if (!ok) setState(() => _error = 'Auto-install failed. File saved to: ' + path + '\nOpen your file manager and tap the APK to install.');
    } else {
      setState(() { _error = 'Download failed. Check internet connection.'; _downloading = false; });
    }
  }


  void _showDownloadDialog(BuildContext context, String url, String filename, String version) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No APK available for this version')));
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DownloadDialog(url: url, filename: filename, version: version),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Update'), bottom: TabBar(controller: _tabCtrl, tabs: const [Tab(text: 'Latest'), Tab(text: 'All Versions')])),
      body: TabBarView(controller: _tabCtrl, children: [_latestTab(), _allTab()]),
    );
  }

  Widget _latestTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Image.asset('assets/images/atomator_banner.png', height: 60)),
      const SizedBox(height: 24),
      if (_checking) ...[
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 16),
        const Center(child: Text('Checking for updates...', style: TextStyle(color: Colors.white38))),
      ] else if (_update != null && _update!.containsKey('error')) ...[
        const Icon(Icons.error, color: Colors.orange, size: 48),
        const SizedBox(height: 16),
        const Text('Could not check for updates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_update!['error'].toString(), style: const TextStyle(fontSize: 12, color: Colors.white38)),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _checkUpdate, child: const Text('Retry'))),
      ] else if (_update == null) ...[
        const Icon(Icons.check_circle, color: Colors.green, size: 48),
        const SizedBox(height: 16),
        const Text('You are on the latest version!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Current: v' + UpdateService.currentVersion, style: const TextStyle(color: Colors.white38)),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _checkUpdate, child: const Text('Check Again'))),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _tabCtrl.animateTo(1), child: const Text('Browse All Versions / Reinstall'))),
      ] else ...[
        const Icon(Icons.system_update, color: Colors.cyan, size: 48),
        const SizedBox(height: 16),
        const Text('Update Available!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyan)),
        const SizedBox(height: 8),
        Text('Current: v' + UpdateService.currentVersion, style: const TextStyle(color: Colors.white38)),
        Text('New: v' + (_update!['version'] ?? '?'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
        if (_update!['body'] != null && (_update!['body'] as String).isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Release Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(_update!['body'], style: const TextStyle(fontSize: 12, color: Colors.white60)),
        ],
        const SizedBox(height: 20),
        _downloadWidget(_update!['apkUrl'], _update!['apkName'] ?? 'atomator.apk'),
      ],
    ]));
  }

  Widget _allTab() {
    if (_allReleases.isEmpty) return const Center(child: CircularProgressIndicator());
    return ListView.builder(itemCount: _allReleases.length, itemBuilder: (context, index) {
      final r = _allReleases[index];
      final isCurrent = r['version'] == UpdateService.currentVersion;
      final hasApk = r['apkUrl'] != null;
      final sizeMB = r['size'] != null ? ((r['size'] as int) / 1024 / 1024).toStringAsFixed(1) : '?';
      return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), color: isCurrent ? const Color(0xFF1A2332) : null,
        child: ExpansionTile(
          leading: Icon(isCurrent ? Icons.check_circle : Icons.history, color: isCurrent ? Colors.green : Colors.white24, size: 20),
          title: Row(children: [
            Text('v' + r['version'], style: TextStyle(fontWeight: FontWeight.bold, color: isCurrent ? Colors.green : Colors.white)),
            if (isCurrent) const Text('  (installed)', style: TextStyle(fontSize: 11, color: Colors.green)),
          ]),
          subtitle: Text(r['date'] + (hasApk ? ' | ' + sizeMB + ' MB' : ''), style: const TextStyle(fontSize: 11, color: Colors.white38)),
          children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (r['body'] != null && (r['body'] as String).isNotEmpty) ...[
              Text(r['body'], style: const TextStyle(fontSize: 12, color: Colors.white60)),
              const SizedBox(height: 12),
            ],
            if (hasApk)
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                icon: Icon(isCurrent ? Icons.refresh : Icons.download),
                label: Text(isCurrent ? 'Reinstall v' + r['version'] : 'Download & Install v' + r['version']),
                onPressed: () => _showDownloadDialog(context, r['apkUrl'] ?? '', r['apkName'] ?? 'atomator.apk', r['version']),
              ))
            else const Text('No APK for this version', style: TextStyle(color: Colors.white24, fontSize: 12)),
          ]))],
        ),
      );
    });
  }

  Widget _downloadWidget(String? url, String filename) {
    if (url == null) return const Text('No download available', style: TextStyle(color: Colors.red));
    return Column(children: [
      if (_downloading) ...[
        LinearProgressIndicator(value: _progress, color: Colors.cyan),
        const SizedBox(height: 8),
        Text((_progress * 100).toInt().toString() + '% downloading...', style: const TextStyle(color: Colors.white38)),
      ] else if (_downloadedPath != null) ...[
        const Icon(Icons.check_circle, color: Colors.green, size: 32),
        const SizedBox(height: 8),
        const Text('Downloaded!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(icon: const Icon(Icons.install_mobile), label: const Text('Install Now'),
          onPressed: () async { final ok = await UpdateService.installApk(_downloadedPath!); if (!ok) setState(() => _error = 'Tap Open Downloads below and install the APK manually'); })),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(icon: const Icon(Icons.folder_open), label: const Text('Open Downloads Folder'),
          onPressed: () => UpdateService.openDownloads())),
        const SizedBox(height: 8),
        Text('Saved to: ' + (_downloadedPath ?? ''), style: const TextStyle(fontSize: 10, color: Colors.white24)),
      ] else ...[
        SizedBox(width: double.infinity, child: ElevatedButton.icon(icon: const Icon(Icons.download), label: const Text('Download & Install'), onPressed: () => _downloadAndInstall(url, filename))),
      ],
      if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: Colors.orange, fontSize: 12))],
    ]);
  }
}


class _DownloadDialog extends StatefulWidget {
  final String url;
  final String filename;
  final String version;
  const _DownloadDialog({required this.url, required this.filename, required this.version});
  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog> {
  double _progress = 0;
  bool _downloading = true;
  String? _path;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    final path = await UpdateService.downloadApk(widget.url, widget.filename, (p) => setState(() => _progress = p));
    if (path != null) {
      setState(() { _path = path; _downloading = false; });
      final ok = await UpdateService.installApk(path);
      if (!ok) setState(() => _error = 'Auto-install failed. File saved to Downloads folder.');
    } else {
      setState(() { _error = 'Download failed'; _downloading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: Text('v' + widget.version, style: const TextStyle(fontSize: 16)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_downloading) ...[
          LinearProgressIndicator(value: _progress, color: Colors.cyan),
          const SizedBox(height: 12),
          Text((_progress * 100).toInt().toString() + '% downloading...', style: const TextStyle(color: Colors.white38)),
        ] else if (_path != null) ...[
          const Icon(Icons.check_circle, color: Colors.green, size: 40),
          const SizedBox(height: 12),
          const Text('Downloaded!', style: TextStyle(color: Colors.green)),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.orange, fontSize: 12)),
          ],
        ] else if (_error != null) ...[
          const Icon(Icons.error, color: Colors.red, size: 40),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      ]),
      actions: [
        if (!_downloading) ...[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          if (_path != null) ...[
            ElevatedButton.icon(icon: const Icon(Icons.install_mobile), label: const Text('Install'),
              onPressed: () => UpdateService.installApk(_path!)),
            OutlinedButton.icon(icon: const Icon(Icons.folder_open), label: const Text('Downloads'),
              onPressed: () => UpdateService.openDownloads()),
          ],
        ],
      ],
    );
  }
}

