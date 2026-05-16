import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Atomator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset('assets/images/atomator_banner.png', height: 100),
            const SizedBox(height: 24),
            const Text('Atomator Mobile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.cyan)),
            const SizedBox(height: 4),
            const Text('v1.4.5', style: TextStyle(fontSize: 14, color: Colors.white38)),
            const SizedBox(height: 24),
            const Text('Remote Linux fleet management from your phone.\nDirect SSH - no server needed.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 32),
            _tile(context, Icons.person, 'Created by', 'Axel Sarassamit'),
            _tile(context, Icons.email, 'Email', 'axel.sarassamit@gmail.com'),
            _link(context, Icons.code, 'CLI Source', 'github.com/axelsarassamit/atomator', 'https://github.com/axelsarassamit/atomator'),
            _link(context, Icons.phone_android, 'App Source', 'github.com/axelsarassamit/atomator-android-app', 'https://github.com/axelsarassamit/atomator-android-app'),
            _link(context, Icons.download, 'Releases', 'Download latest APK', 'https://github.com/axelsarassamit/atomator-android-app/releases'),
            const SizedBox(height: 24),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            const Text('Based on Atomator CLI v.02.09.00', style: TextStyle(fontSize: 12, color: Colors.white24)),
            const Text('Built with Flutter + dartssh2', style: TextStyle(fontSize: 12, color: Colors.white24)),
          ],
        ),
      ),
    );
  }

  static Widget _tile(BuildContext ctx, IconData icon, String label, String value) {
    return ListTile(leading: Icon(icon, color: Colors.cyan), title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white38)), subtitle: Text(value, style: const TextStyle(fontSize: 15)));
  }

  static Widget _link(BuildContext ctx, IconData icon, String label, String text, String url) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyan),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white38)),
      subtitle: Text(text, style: const TextStyle(fontSize: 14, color: Colors.cyan)),
      trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.white24),
      onTap: () => Clipboard.setData(ClipboardData(text: url)).then((_) => ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Copied: ' + url)))),
    );
  }
}
