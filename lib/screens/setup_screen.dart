import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/host_provider.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  final StorageService storage;
  const SetupScreen({super.key, required this.storage});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _rangeCtrl = TextEditingController(text: '192.168.1.50-199');
  int _step = 0;

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 40),
    Image.asset('assets/images/atomator_banner.png', height: 60),
    const SizedBox(height: 24),
    Text(_step == 0 ? 'Step 1: SSH Credentials' : 'Step 2: Add Hosts', style: Theme.of(context).textTheme.titleMedium),
    const SizedBox(height: 8),
    Text(_step == 0 ? 'Default credentials for all hosts' : 'Enter IP range or single IP', style: Theme.of(context).textTheme.bodySmall),
    const SizedBox(height: 24),
    if (_step == 0) ...[
      TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'SSH Username', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'SSH Password', border: OutlineInputBorder())),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
        if (_userCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
        context.read<HostProvider>().saveCredentials(Credentials(username: _userCtrl.text, password: _passCtrl.text));
        setState(() => _step = 1);
      }, child: const Text('Next'))),
    ],
    if (_step == 1) ...[
      TextField(controller: _rangeCtrl, decoration: const InputDecoration(labelText: 'IP Range (e.g. 192.168.1.50-199) or single IP', border: OutlineInputBorder())),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
        final input = _rangeCtrl.text;
        final hp = context.read<HostProvider>();
        if (input.contains('-')) {
          final parts = input.split('-');
          final baseParts = parts[0].split('.');
          if (baseParts.length == 4 && parts.length == 2) {
            hp.addHostRange(baseParts.sublist(0, 3).join('.'), int.tryParse(baseParts[3]) ?? 0, int.tryParse(parts[1]) ?? 0);
          }
        } else if (input.isNotEmpty) {
          hp.addHost(input);
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }, child: const Text('Add Hosts & Start'))),
      const SizedBox(height: 12),
      TextButton(onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen())),
        child: const Text('Skip - add hosts later')),
    ],
  ]))));
}
