import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/host_provider.dart';
import '../models/models.dart';
import 'about_screen.dart';
import 'update_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<HostProvider>(builder: (context, hp, _) => Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        _sec('CREDENTIALS'),
        ListTile(leading: const Icon(Icons.person, color: Colors.cyan), title: const Text('SSH Username'), subtitle: Text(hp.credentials?.username ?? 'Not set'), onTap: () => _editCreds(context, hp)),
        ListTile(leading: const Icon(Icons.lock, color: Colors.cyan), title: const Text('SSH Password'), subtitle: const Text('********'), onTap: () => _editCreds(context, hp)),
        _sec('FLEET'),
        ListTile(leading: const Icon(Icons.computer, color: Colors.cyan), title: Text(hp.hosts.length.toString() + ' hosts in ' + hp.groups.length.toString() + ' groups'),
          subtitle: Text(hp.onlineCount.toString() + ' online, ' + hp.offlineCount.toString() + ' offline')),
        ListTile(leading: const Icon(Icons.wifi, color: Colors.cyan), title: const Text('Collect MAC Addresses'), subtitle: const Text('For Wake-on-LAN'), onTap: () { hp.collectMacAddresses(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Collecting MACs...'))); }),
        _sec('APP'),
        ListTile(leading: const Icon(Icons.system_update, color: Colors.green), title: const Text('Check for Updates'), subtitle: const Text('Download latest version'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateScreen()))),
        ListTile(leading: const Icon(Icons.info, color: Colors.cyan), title: const Text('About Atomator'), subtitle: const Text('Creator, links, version'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
        _sec('DANGER'),
        ListTile(leading: const Icon(Icons.delete_forever, color: Colors.red), title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
          onTap: () => showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text('Clear all?'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () { hp.clearAll(); Navigator.pop(context); }, child: const Text('Clear'))]))),
      ]),
    ));
  }
  Widget _sec(String t) => Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyan, letterSpacing: 1.2)));
  void _editCreds(BuildContext context, HostProvider hp) {
    final u = TextEditingController(text: hp.credentials?.username ?? ''); final p = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text('SSH Credentials'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: u, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: p, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()))]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () { hp.saveCredentials(Credentials(username: u.text, password: p.text)); Navigator.pop(context); }, child: const Text('Save'))]));
  }
}
