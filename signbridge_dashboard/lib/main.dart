import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:signbridge_dashboard/core/constants/app_constants.dart';
import 'package:signbridge_dashboard/core/models/activity_log_entry.dart';
import 'package:signbridge_dashboard/core/models/activity_log_entry_adapters.dart';
import 'package:signbridge_dashboard/core/theme/app_theme.dart';
import 'package:signbridge_dashboard/features/dashboard/presentation/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    // Initialize Hive on disk for persistent session logs
    await Hive.initFlutter();
    Hive.registerAdapter(ActivityLogEntryAdapter());
    Hive.registerAdapter(EventTypeAdapter());
    await Hive.openBox<ActivityLogEntry>(kActivityLogBox);
  }

  runApp(
    const ProviderScope(
      child: SignBridgeDashboardApp(),
    ),
  );
}

/// Root application widget for the Windows desktop dashboard.
class SignBridgeDashboardApp extends StatelessWidget {
  const SignBridgeDashboardApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SignBridge Dashboard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const DashboardScreen(),
      );
}
