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
          String? apkUrl;
          String? apkName;
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
            'tag': r['tag_name'],
            'name': r['name'] ?? r['tag_name'],
            'body': r['body'] ?? '',
            'date': (r['published_at'] as String).substring(0, 10),
            'apkUrl': apkUrl,
            'apkName': apkName,
            'size': size,
          };
        }).toList();
      });
    } catch (_) {}
  }

  Future<void> _downloadVersion(String url, String filename) async {
    setState(() { _downloading = true; _progress = 0; _error = null; _downloadedPath = null; });
    final path = await UpdateService.downloadApk(url, filename, (p) => setState(() => _progress = p));
    if (path != null) {
      setState(() { _downloadedPath = path; _downloading = false; });
    } else {
      setState(() { _error = 'Download failed'; _downloading = false; });
    }
  }

  Future<void> _install() async {
    if (_downloadedPath == null) return;
    try {
      await Process.run('am', ['start', '-a', 'android.intent.action.VIEW', '-d', 'file://' + _downloadedPath!, '-t', 'application/vnd.android.package-archive']);
    } catch (e) {
      setState(() => _error = 'Open file manager and install from: ' + (_downloadedPath ?? ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Update'),
        bottom: TabBar(controller: _tabCtrl, tabs: const [
          Tab(text: 'Latest'),
          Tab(text: 'All Versions'),
        ]),
      ),
      body: TabBarView(controller: _tabCtrl, children: [
        _buildLatestTab(),
        _buildAllVersionsTab(),
      ]),
    );
  }

  Widget _buildLatestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _checkUpdate, child: const Text('Check Again'))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () => _tabCtrl.animateTo(1),
            child: const Text('Browse All Versions'),
          )),
        ] else ...[
          const Icon(Icons.system_update, color: Colors.cyan, size: 48),
          const SizedBox(height: 16),
          const Text('Update Available!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyan)),
          const SizedBox(height: 8),
          Text('Current: v' + (_update!['current'] ?? '?'), style: const TextStyle(color: Colors.white38)),
          Text('New: v' + (_update!['version'] ?? '?'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
          if (_update!['body'] != null && (_update!['body'] as String).isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(_update!['body'], style: const TextStyle(fontSize: 12, color: Colors.white60)),
          ],
          const SizedBox(height: 16),
          _buildDownloadSection(_update!['apkUrl'], _update!['apkName'] ?? 'atomator.apk'),
        ],
      ]),
    );
  }

  Widget _buildAllVersionsTab() {
    if (_allReleases.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: _allReleases.length,
      itemBuilder: (context, index) {
        final r = _allReleases[index];
        final isCurrent = r['version'] == UpdateService.currentVersion;
        final hasApk = r['apkUrl'] != null;
        final sizeMB = r['size'] != null ? (r['size'] / 1024 / 1024).toStringAsFixed(1) : '?';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: isCurrent ? const Color(0xFF1A2332) : null,
          child: ExpansionTile(
            leading: Icon(
              isCurrent ? Icons.check_circle : Icons.history,
              color: isCurrent ? Colors.green : Colors.white24,
              size: 20,
            ),
            title: Row(children: [
              Text('v' + r['version'], style: TextStyle(fontWeight: FontWeight.bold, color: isCurrent ? Colors.green : Colors.white)),
              if (isCurrent) const Text('  (installed)', style: TextStyle(fontSize: 11, color: Colors.green)),
            ]),
            subtitle: Text(r['date'] + (hasApk ? ' | ' + sizeMB + ' MB' : ' | no APK'), style: const TextStyle(fontSize: 11, color: Colors.white38)),
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r['body'] != null && (r['body'] as String).isNotEmpty)
                    Text(r['body'], style: const TextStyle(fontSize: 12, color: Colors.white60)),
                  const SizedBox(height: 12),
                  if (hasApk)
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(
                      icon: Icon(isCurrent ? Icons.refresh : Icons.download),
                      label: Text(isCurrent ? 'Reinstall v' + r['version'] : 'Install v' + r['version']),
                      onPressed: () => _downloadVersion(r['apkUrl'], r['apkName'] ?? 'atomator.apk'),
                    ))
                  else
                    const Text('No APK available for this version', style: TextStyle(color: Colors.white24, fontSize: 12)),
                ],
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadSection(String? url, String filename) {
    if (url == null) return const Text('No download available', style: TextStyle(color: Colors.red));
    return Column(children: [
      if (_downloading) ...[
        LinearProgressIndicator(value: _progress, color: Colors.cyan),
        const SizedBox(height: 8),
        Text((_progress * 100).toInt().toString() + '%', style: const TextStyle(color: Colors.white38)),
      ] else if (_downloadedPath != null) ...[
        const Text('Downloaded!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          icon: const Icon(Icons.install_mobile),
          label: const Text('Install Update'),
          onPressed: _install,
        )),
        const SizedBox(height: 8),
        Text(_downloadedPath ?? '', style: const TextStyle(fontSize: 10, color: Colors.white24)),
      ] else ...[
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Download'),
          onPressed: () => _downloadVersion(url, filename),
        )),
      ],
      if (_error != null) ...[
        const SizedBox(height: 12),
        Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
      ],
    ]);
  }
}
