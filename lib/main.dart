import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'providers/host_provider.dart';
import 'providers/job_provider.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();
  runApp(AtomatorApp(storage: storage));
}

class AtomatorApp extends StatelessWidget {
  final StorageService storage;
  const AtomatorApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HostProvider(storage)),
        ChangeNotifierProvider(create: (_) => JobProvider()),
      ],
      child: MaterialApp(
        title: 'Atomator',
        theme: atomatorTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<HostProvider>(
          builder: (context, hostProvider, _) {
            final nextScreen = hostProvider.isConfigured
                ? const HomeScreen()
                : SetupScreen(storage: storage);
            return SplashScreen(nextScreen: nextScreen);
          },
        ),
      ),
    );
  }
}
