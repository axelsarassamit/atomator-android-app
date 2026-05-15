import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/host_provider.dart';
import '../widgets/widgets.dart';

class HostsScreen extends StatelessWidget {
  const HostsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<HostProvider>(builder: (context, hp, _) {
      return Scaffold(
        appBar: AppBar(title: Text('Hosts (${hp.hosts.length})'), actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => hp.checkHostStatus()),
          IconButton(icon: const Icon(Icons.add), onPressed: () => _add(context, hp)),
        ]),
        body: ListView(children: hp.groups.map((g) {
          final gh = hp.hostsInGroup(g);
          final on = gh.where((h) => h.isOnline).length;
          return ExpansionTile(title: Text('[$g]  $on/${gh.length} online'), initiallyExpanded: true,
            children: gh.map((h) => Dismissible(key: Key(h.ip), direction: DismissDirection.endToStart,
              background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
              onDismissed: (_) => hp.removeHost(h.ip),
              child: ListTile(dense: true, leading: StatusBadge(isOnline: h.isOnline),
                title: Text(h.ip, style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 14)),
                subtitle: Text(h.hostname ?? 'unknown', style: const TextStyle(fontSize: 11, color: Colors.white38))))).toList());
        }).toList()),
      );
    });
  }
  void _add(BuildContext context, HostProvider hp) {
    final ctrl = TextEditingController(); final gCtrl = TextEditingController(text: 'default');
    showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF161B22), title: const Text('Add Hosts'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'IP or range', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: gCtrl, decoration: const InputDecoration(labelText: 'Group', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          final input = ctrl.text; final group = gCtrl.text.isEmpty ? 'default' : gCtrl.text;
          if (input.contains('-')) { final p = input.split('-'); final bp = p[0].split('.'); if (bp.length == 4) hp.addHostRange(bp.sublist(0,3).join('.'), int.tryParse(bp[3]) ?? 0, int.tryParse(p[1]) ?? 0, group: group); }
          else hp.addHost(input, group: group);
          Navigator.pop(context);
        }, child: const Text('Add')),
      ]));
  }
}
