import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'hosts_screen.dart';
import 'actions_screen.dart';
import 'tools_screen.dart';
import 'settings_screen.dart';
import 'terminal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _screens = const [DashboardScreen(), HostsScreen(), ActionsScreen(), TerminalScreen(), ToolsScreen(), SettingsScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: _screens[_index],
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index, onDestinationSelected: (i) => setState(() => _index = i),
      backgroundColor: const Color(0xFF161B22), indicatorColor: const Color(0xFF00BCD4).withAlpha(50),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard, size: 22), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.computer, size: 22), label: 'Hosts'),
        NavigationDestination(icon: Icon(Icons.play_arrow, size: 22), label: 'Actions'),
        NavigationDestination(icon: Icon(Icons.terminal, size: 22), label: 'SSH'),
        NavigationDestination(icon: Icon(Icons.build, size: 22), label: 'Tools'),
        NavigationDestination(icon: Icon(Icons.settings, size: 22), label: 'Config'),
      ],
    ),
  );
}
