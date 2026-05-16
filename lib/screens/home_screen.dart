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
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.computer), label: 'Hosts'),
        NavigationDestination(icon: Icon(Icons.play_arrow), label: 'Actions'),
        NavigationDestination(icon: Icon(Icons.terminal), label: 'Terminal'),
        NavigationDestination(icon: Icon(Icons.build), label: 'Tools'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    ),
  );
}
