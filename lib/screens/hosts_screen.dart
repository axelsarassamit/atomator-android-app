import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/host_provider.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

class HostsScreen extends StatefulWidget {
  const HostsScreen({super.key});

  @override
  State<HostsScreen> createState() => _HostsScreenState();
}

class _HostsScreenState extends State<HostsScreen> {
  String _query = '';
  String _filter = 'All';

  bool _matches(Host host) {
    final text =
        '${host.ip} ${host.hostname ?? ''} ${host.group} ${host.mac ?? ''}'
            .toLowerCase();
    return text.contains(_query.toLowerCase().trim()) &&
        switch (_filter) {
          'Online' => host.isOnline,
          'Offline' => !host.isOnline,
          'SSH ready' => host.sshOpen,
          _ => true,
        };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HostProvider>(
      builder: (context, hp, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Hosts (${hp.hosts.length})'),
            actions: [
              hp.isChecking
                  ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Check status',
                    onPressed: () => hp.checkHostStatus(),
                  ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add host',
                onPressed: () => _addDialog(context, hp),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search name, IP, group or MAC',
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children:
                      ['All', 'Online', 'Offline', 'SSH ready']
                          .map(
                            (label) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(label),
                                selected: _filter == label,
                                onSelected:
                                    (_) => setState(() => _filter = label),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    hp.hosts.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.computer,
                                size: 64,
                                color: Colors.white12,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No hosts added yet',
                                style: TextStyle(color: Colors.white38),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap + to add hosts or a range',
                                style: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                        : !hp.hosts.any(_matches)
                        ? const Center(
                          child: Text('No hosts match your search or filter.'),
                        )
                        : ListView(
                          children:
                              hp.groups.where((g) => hp.hostsInGroup(g).any(_matches)).map((
                                g,
                              ) {
                                final gh =
                                    hp.hostsInGroup(g).where(_matches).toList();
                                final on = gh.where((h) => h.isOnline).length;
                                return ExpansionTile(
                                  title: Text('[$g]  $on/${gh.length} online'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Remove group',
                                        onPressed:
                                            () => showDialog(
                                              context: context,
                                              builder:
                                                  (_) => AlertDialog(
                                                    backgroundColor:
                                                        const Color(0xFF161B22),
                                                    title: Text(
                                                      'Remove group [$g]?',
                                                    ),
                                                    content: Text(
                                                      'This removes all ${hp.hostsInGroup(g).length} hosts in this group, including hosts hidden by filters.',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                        onPressed: () {
                                                          hp.removeGroup(g);
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: const Text(
                                                          'Remove',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            ),
                                      ),
                                      const Icon(Icons.expand_more),
                                    ],
                                  ),
                                  initiallyExpanded: true,
                                  children:
                                      gh
                                          .map(
                                            (h) => Dismissible(
                                              key: Key(h.ip),
                                              direction:
                                                  DismissDirection.endToStart,
                                              background: Container(
                                                color: Colors.red,
                                                alignment:
                                                    Alignment.centerRight,
                                                padding: const EdgeInsets.only(
                                                  right: 16,
                                                ),
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onDismissed:
                                                  (_) => hp.removeHost(h.ip),
                                              child: ListTile(
                                                leading: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    StatusBadge(
                                                      isOnline: h.isOnline,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      Icons.terminal,
                                                      size: 18,
                                                      color:
                                                          h.sshOpen
                                                              ? Colors.green
                                                              : Colors.red
                                                                  .withAlpha(
                                                                    100,
                                                                  ),
                                                    ),
                                                  ],
                                                ),
                                                title: Text(
                                                  h.hostname != null &&
                                                          h.hostname != h.ip &&
                                                          h.hostname !=
                                                              'Unknown device'
                                                      ? h.hostname!
                                                      : h.ip,
                                                  style: const TextStyle(
                                                    fontFamily: 'RobotoMono',
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  [
                                                    if (h.hostname != null &&
                                                        h.hostname != h.ip)
                                                      h.hostname!,
                                                    h.ip,
                                                    if (h.sshOpen)
                                                      '[SSH]'
                                                    else if (h.isOnline)
                                                      '[No SSH]',
                                                    if (h.hasCustomCreds)
                                                      '[creds]',
                                                    if (h.mac != null) h.mac!,
                                                    if (!h.isOnline &&
                                                        h.lastSeen != null)
                                                      'seen ${_timeAgo(h.lastSeen!)}',
                                                  ].join('  |  '),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white38,
                                                  ),
                                                ),
                                                trailing: const Icon(
                                                  Icons.edit,
                                                  size: 16,
                                                  color: Colors.white24,
                                                ),
                                                onTap:
                                                    () => _editHost(
                                                      context,
                                                      hp,
                                                      h,
                                                    ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                );
                              }).toList(),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _addDialog(BuildContext context, HostProvider hp) {
    final ipCtrl = TextEditingController();
    final groupCtrl = TextEditingController(text: 'default');
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool showCreds = false;
    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (ctx, setState) => AlertDialog(
                  backgroundColor: const Color(0xFF161B22),
                  title: const Text('Add Host'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: ipCtrl,
                          decoration: const InputDecoration(
                            labelText: 'IP or range (192.168.1.50-199)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: groupCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Group',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          title: const Text(
                            'Custom credentials',
                            style: TextStyle(fontSize: 14),
                          ),
                          value: showCreds,
                          onChanged: (v) => setState(() => showCreds = v!),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (showCreds) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: userCtrl,
                            decoration: const InputDecoration(
                              labelText: 'SSH Username',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: passCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'SSH Password',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final input = ipCtrl.text.trim();
                        final group =
                            groupCtrl.text.isEmpty ? 'default' : groupCtrl.text;
                        final user =
                            showCreds && userCtrl.text.isNotEmpty
                                ? userCtrl.text
                                : null;
                        final pass =
                            showCreds && passCtrl.text.isNotEmpty
                                ? passCtrl.text
                                : null;
                        if (input.isEmpty) return;
                        if (input.contains('-')) {
                          final p = input.split('-');
                          final bp = p[0].split('.');
                          if (bp.length == 4)
                            hp.addHostRange(
                              bp.sublist(0, 3).join('.'),
                              int.tryParse(bp[3]) ?? 0,
                              int.tryParse(p[1]) ?? 0,
                              group: group,
                            );
                        } else {
                          hp.addHost(
                            input,
                            group: group,
                            user: user,
                            pass: pass,
                          );
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _editHost(BuildContext context, HostProvider hp, Host host) {
    final userCtrl = TextEditingController(text: host.customUser ?? '');
    final passCtrl = TextEditingController(text: host.customPass ?? '');
    final groupCtrl = TextEditingController(text: host.group);
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF161B22),
            title: Text('Edit ${host.ip}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: groupCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Group',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: userCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Custom SSH User (empty = default)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Custom SSH Pass (empty = default)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (host.hostname != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Hostname: ${host.hostname}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (host.mac != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'MAC: ${host.mac}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (host.lastSeen != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Last seen: ${_timeAgo(host.lastSeen!)}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  host.group =
                      groupCtrl.text.isEmpty ? 'default' : groupCtrl.text;
                  host.customUser =
                      userCtrl.text.isEmpty ? null : userCtrl.text;
                  host.customPass =
                      passCtrl.text.isEmpty ? null : passCtrl.text;
                  hp.updateHost(host);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
