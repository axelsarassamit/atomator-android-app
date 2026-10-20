import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:atomator_app/models/models.dart';
import 'package:atomator_app/models/fleet_summary.dart';
import 'package:atomator_app/providers/job_provider.dart';
import 'package:atomator_app/providers/host_provider.dart';
import 'package:atomator_app/services/storage_service.dart';
import 'package:atomator_app/screens/dashboard_screen.dart';
import 'package:atomator_app/screens/hosts_screen.dart';
import 'package:atomator_app/theme.dart';

SSHResult reading(String output, {bool success = true}) => SSHResult(
  host: 'test',
  success: success,
  output: output,
  duration: Duration.zero,
);

class PreviewStorage extends StorageService {
  @override
  List<Host> getHosts() => [
    Host(
      ip: '192.168.1.10',
      hostname: 'studio-server',
      group: 'Studio',
      isOnline: true,
      sshOpen: true,
    ),
    Host(
      ip: '192.168.1.11',
      hostname: 'workstation',
      group: 'Studio',
      isOnline: true,
    ),
    Host(ip: '192.168.1.12', hostname: 'backup-node', group: 'Storage'),
  ];
  @override
  Future<Credentials?> getCredentials() async =>
      const Credentials(username: 'preview', password: '');
}

void main() {
  setUpAll(() async {
    if (Platform.environment['ATOMATOR_CAPTURE'] == '1' && Platform.isWindows) {
      final textFont = FontLoader('Roboto')..addFont(
        Future.value(
          ByteData.sublistView(
            File(r'C:\Windows\Fonts\segoeui.ttf').readAsBytesSync(),
          ),
        ),
      );
      final icons = FontLoader('MaterialIcons')..addFont(
        Future.value(
          ByteData.sublistView(
            File(
              r'C:\Applications\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf',
            ).readAsBytesSync(),
          ),
        ),
      );
      await textFont.load();
      await icons.load();
    }
  });
  test('health summary excludes failed and malformed responses', () {
    final summary = FleetSummary.fromResults([
      reading('8192|79|86400'),
      reading('4096|80|172800'),
      reading('1024|90|3600'),
      reading(''),
      reading('0|0|0', success: false),
      reading('bad|20|30'),
      reading('1|101|30'),
      reading('-1|10|30'),
    ]);
    expect(summary.reported, 3);
    expect(summary.unavailable, 5);
    expect(summary.warning, 1);
    expect(summary.critical, 1);
    expect(summary.minUptime, 3600);
    expect(summary.maxUptime, 172800);
    expect(summary.totalRam, '13.0');
  });

  test('no valid readings never invent an uptime', () {
    final summary = FleetSummary.fromResults([reading('unavailable')]);
    expect(summary.reported, 0);
    expect(summary.minUptime, isNull);
    expect(summary.maxUptime, isNull);
  });

  test('job history is newest first and clearing retains running jobs', () {
    final provider = JobProvider();
    final first = provider.startJob('First');
    provider.finishJob(first);
    final second = provider.startJob('Second');
    provider.finishJob(second);
    final running = provider.startJob('Running');
    expect(provider.history, [second, first]);
    provider.clearHistory();
    expect(provider.jobs, [running]);
  });

  Widget app(Widget screen, HostProvider hosts, {Key? captureKey}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: hosts),
          ChangeNotifierProvider(create: (_) => JobProvider()),
        ],
        child: MaterialApp(
          theme: atomatorTheme,
          home: RepaintBoundary(key: captureKey, child: Scaffold(body: screen)),
        ),
      );

  testWidgets('dashboard is readable on narrow phones and enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final hosts = HostProvider(PreviewStorage());
    await tester.pumpWidget(app(const DashboardScreen(), hosts));
    await tester.pumpAndSettle();
    expect(find.text('Fleet overview'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final key = GlobalKey();
    await tester.pumpWidget(
      app(const DashboardScreen(), hosts, captureKey: key),
    );
    await tester.pumpAndSettle();
    if (Platform.environment['ATOMATOR_CAPTURE'] == '1') {
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/images/app_icon.png'),
          tester.element(find.byType(DashboardScreen)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory('build/review').createSync(recursive: true);
        File(
          'build/review/dashboard.png',
        ).writeAsBytesSync(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(app(const DashboardScreen(), hosts));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('host search combines with connection filters', (tester) async {
    final hosts = HostProvider(PreviewStorage());
    await tester.pumpWidget(app(const HostsScreen(), hosts));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'studio-server');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'studio-server'), findsOneWidget);
    expect(find.text('backup-node'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Offline'));
    await tester.pumpAndSettle();
    expect(find.text('No hosts match your search or filter.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
