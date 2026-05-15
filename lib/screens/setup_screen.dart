import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/host_provider.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

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
    Text('Atomator', style: Theme.of(context).textTheme.headlineLarge),
    const SizedBox(height: 8),
    Text('Initial Setup', style: Theme.of(context).textTheme.bodyMedium),
    const SizedBox(height: 40),
    if (_step == 0) ...[
      Text('SSH Credentials', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 16),
      TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'SSH Username', border: OutlineInputBorder())), const SizedBox(height: 12),
      TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'SSH Password', border: OutlineInputBorder())), const SizedBox(height: 24),
      ElevatedButton(onPressed: () { if (_userCtrl.text.isEmpty || _passCtrl.text.isEmpty) return; context.read<HostProvider>().saveCredentials(Credentials(username: _userCtrl.text, password: _passCtrl.text)); setState(() => _step = 1); }, child: const Text('Next')),
    ],
    if (_step == 1) ...[
      Text('Add Hosts', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 16),
      TextField(controller: _rangeCtrl, decoration: const InputDecoration(labelText: 'IP Range (192.168.1.50-199)', border: OutlineInputBorder())), const SizedBox(height: 24),
      ElevatedButton(onPressed: () { final r = _rangeCtrl.text; final p = r.split('-'); if (p.length != 2) return; final bp = p[0].split('.'); if (bp.length != 4) return; context.read<HostProvider>().addHostRange(bp.sublist(0,3).join('.'), int.tryParse(bp[3]) ?? 0, int.tryParse(p[1]) ?? 0); }, child: const Text('Add Hosts & Start')),
    ],
  ]))));
}
