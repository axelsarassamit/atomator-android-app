import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../services/update_service.dart';

class BugReportScreen extends StatefulWidget {
  const BugReportScreen({super.key});
  @override
  State<BugReportScreen> createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'Bug';
  bool _sent = false;

  String _buildReport() {
    final info = StringBuffer();
    info.writeln('## ' + _category + ': ' + _titleCtrl.text);
    info.writeln('');
    info.writeln('### Description');
    info.writeln(_descCtrl.text);
    info.writeln('');
    info.writeln('### Device Info');
    info.writeln('- App version: ' + UpdateService.currentVersion);
    info.writeln('- Platform: ' + Platform.operatingSystem + ' ' + Platform.operatingSystemVersion);
    info.writeln('- Dart: ' + Platform.version);
    return info.toString();
  }

  void _copyAndOpen() {
    final report = _buildReport();
    Clipboard.setData(ClipboardData(text: report));
    setState(() => _sent = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report copied to clipboard!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a Problem')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!_sent) ...[
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: ['Bug', 'Feature Request', 'Question', 'Other'].map((c) =>
              ChoiceChip(
                label: Text(c),
                selected: _category == c,
                onSelected: (s) => setState(() => _category = c),
                selectedColor: Colors.cyan.withAlpha(80),
              ),
            ).toList()),
            const SizedBox(height: 16),
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'Short description of the issue', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(controller: _descCtrl, maxLines: 6, decoration: const InputDecoration(hintText: 'What happened? What did you expect? Steps to reproduce...', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            Text('Device info will be attached automatically', style: TextStyle(fontSize: 11, color: Colors.white38)),
            const SizedBox(height: 24),
            const Text('How to submit:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _option(context, Icons.content_copy, 'Copy report to clipboard', 'Then paste in email or GitHub issue', _copyAndOpen),
            const SizedBox(height: 8),
            _option(context, Icons.email, 'Email: axel.sarassamit@gmail.com', 'Tap to copy email address', () {
              Clipboard.setData(const ClipboardData(text: 'axel.sarassamit@gmail.com'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email copied!')));
            }),
            const SizedBox(height: 8),
            _option(context, Icons.bug_report, 'GitHub Issues', 'Tap to copy URL', () {
              Clipboard.setData(const ClipboardData(text: 'https://github.com/axelsarassamit/atomator-android-app/issues'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GitHub Issues URL copied!')));
            }),
          ] else ...[
            const SizedBox(height: 40),
            const Center(child: Icon(Icons.check_circle, color: Colors.green, size: 64)),
            const SizedBox(height: 16),
            const Center(child: Text('Report Copied!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            const Center(child: Text('Paste it in an email or GitHub issue.', style: TextStyle(color: Colors.white60))),
            const SizedBox(height: 32),
            const Text('Submit to:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _option(context, Icons.email, 'axel.sarassamit@gmail.com', 'Tap to copy', () {
              Clipboard.setData(const ClipboardData(text: 'axel.sarassamit@gmail.com'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email copied!')));
            }),
            const SizedBox(height: 8),
            _option(context, Icons.bug_report, 'GitHub Issues', 'Tap to copy URL', () {
              Clipboard.setData(const ClipboardData(text: 'https://github.com/axelsarassamit/atomator-android-app/issues'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL copied!')));
            }),
            const SizedBox(height: 32),
            Center(child: OutlinedButton(onPressed: () => setState(() { _sent = false; _titleCtrl.clear(); _descCtrl.clear(); }), child: const Text('Report Another Issue'))),
          ],
        ]),
      ),
    );
  }

  Widget _option(BuildContext ctx, IconData icon, String title, String sub, VoidCallback onTap) {
    return Card(child: ListTile(leading: Icon(icon, color: Colors.cyan), title: Text(title, style: const TextStyle(fontSize: 14)), subtitle: Text(sub, style: const TextStyle(fontSize: 11, color: Colors.white38)), onTap: onTap));
  }
}
