import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dartssh2/dartssh2.dart';
import 'dart:convert';
import 'dart:io';
import '../providers/host_provider.dart';
import '../models/models.dart';

class TerminalScreen extends StatefulWidget {
  final Host? initialHost;
  const TerminalScreen({super.key, this.initialHost});
  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final List<String> _output = [];
  final _cmdCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Host? _selectedHost;
  bool _connected = false;
  bool _connecting = false;
  SSHClient? _client;

  @override
  void initState() {
    super.initState();
    _selectedHost = widget.initialHost;
    if (_selectedHost != null) _connect();
  }

  @override
  void dispose() {
    _client?.close();
    _cmdCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _addOutput(String text, {Color color = Colors.white70}) {
    setState(() => _output.add(text));
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
    });
  }

  Future<void> _connect() async {
    if (_selectedHost == null) return;
    final hp = context.read<HostProvider>();
    final creds = hp.credsForHost(_selectedHost!);

    setState(() { _connecting = true; _output.clear(); });
    _addOutput('Connecting to ' + _selectedHost!.ip + ':22...');

    try {
      final socket = await SSHSocket.connect(_selectedHost!.ip, 22, timeout: const Duration(seconds: 10));
      _client = SSHClient(socket, username: creds.username, onPasswordRequest: () => creds.password);
      _addOutput('Connected as ' + creds.username + '@' + _selectedHost!.ip);
      _addOutput('Type commands below. Each command runs independently.');
      _addOutput('');
      setState(() { _connected = true; _connecting = false; });
    } catch (e) {
      _addOutput('FAILED: ' + e.toString());
      setState(() { _connected = false; _connecting = false; });
    }
  }

  Future<void> _disconnect() async {
    _client?.close();
    _client = null;
    _addOutput('');
    _addOutput('Disconnected.');
    setState(() => _connected = false);
  }

  Future<void> _runCommand() async {
    final cmd = _cmdCtrl.text.trim();
    if (cmd.isEmpty || _client == null) return;
    _cmdCtrl.clear();

    _addOutput('');
    _addOutput('\$ ' + cmd);

    try {
      final hp = context.read<HostProvider>();
      final creds = hp.credsForHost(_selectedHost!);
      final fullCmd = 'echo "' + creds.password + '" | sudo -S bash -c "' + cmd + '" 2>&1';
      final result = await _client!.run(fullCmd);
      final output = utf8.decode(result).trim();
      if (output.isNotEmpty) {
        for (final line in output.split('\n')) {
          _addOutput(line);
        }
      }
    } catch (e) {
      _addOutput('Error: ' + e.toString());
      _addOutput('Connection lost. Reconnecting...');
      setState(() => _connected = false);
      _connect();
    }
  }

  void _selectHost(BuildContext context) {
    final hp = context.read<HostProvider>();
    final sshHosts = hp.hosts.where((h) => h.sshOpen).toList();
    if (sshHosts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hosts with SSH available. Run Check All Hosts first.')));
      return;
    }
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      title: const Text('Select Host'),
      content: SizedBox(width: double.maxFinite, height: 300, child: ListView.builder(
        itemCount: sshHosts.length,
        itemBuilder: (ctx, i) {
          final h = sshHosts[i];
          return ListTile(
            leading: const Icon(Icons.terminal, color: Colors.green, size: 20),
            title: Text(h.ip, style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
            subtitle: Text(h.hostname ?? 'unknown', style: const TextStyle(fontSize: 11, color: Colors.white38)),
            onTap: () {
              Navigator.pop(context);
              _client?.close();
              setState(() { _selectedHost = h; _connected = false; _output.clear(); });
              _connect();
            },
          );
        },
      )),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedHost != null ? 'SSH: ' + _selectedHost!.ip : 'SSH Terminal', style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
        actions: [
          if (_connected) IconButton(icon: const Icon(Icons.link_off, color: Colors.red), tooltip: 'Disconnect', onPressed: _disconnect),
          IconButton(icon: const Icon(Icons.computer), tooltip: 'Select host', onPressed: () => _selectHost(context)),
        ],
      ),
      body: Column(children: [
        if (_connecting) const LinearProgressIndicator(color: Colors.cyan),
        Expanded(
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              controller: _scrollCtrl,
              itemCount: _output.length,
              itemBuilder: (context, i) {
                final line = _output[i];
                Color color = Colors.white70;
                if (line.startsWith('\$ ')) color = Colors.cyan;
                if (line.startsWith('Connected')) color = Colors.green;
                if (line.startsWith('FAILED') || line.startsWith('Error')) color = Colors.red;
                if (line.startsWith('Disconnected')) color = Colors.orange;
                return Text(line, style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: color));
              },
            ),
          ),
        ),
        Container(
          color: const Color(0xFF161B22),
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Text(_connected ? '\$ ' : '  ', style: const TextStyle(fontFamily: 'monospace', color: Colors.cyan, fontSize: 14)),
            Expanded(child: TextField(
              controller: _cmdCtrl,
              enabled: _connected,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: InputDecoration(
                hintText: _connected ? 'Type command...' : _selectedHost == null ? 'Select a host first' : 'Connecting...',
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (_) => _runCommand(),
            )),
            IconButton(icon: const Icon(Icons.send, size: 20), color: _connected ? Colors.cyan : Colors.white12, onPressed: _connected ? _runCommand : null),
          ]),
        ),
      ]),
    );
  }
}
