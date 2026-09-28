import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'firebase_options.dart';
import 'screens/root_shell.dart';
import 'services/background_sync.dart';
import 'services/cloud_service.dart';
import 'services/offline_alert_queue.dart';
import 'services/storage_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(QueuedAlertAdapter());
  await Hive.openBox<QueuedAlert>(OfflineAlertQueue.boxName);
  final storage = await StorageService.init();
  var cloudAvailable = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    cloudAvailable = true;
  } catch (_) {}
  if (cloudAvailable) {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    } catch (_) {}
  }
  try {
    await initBackgroundSync();
  } catch (_) {}
  runApp(SakhiApp(storage: storage, cloudAvailable: cloudAvailable));
}

class SakhiApp extends StatelessWidget {
  final StorageService storage;
  final bool cloudAvailable;

  const SakhiApp({
    super.key,
    required this.storage,
    required this.cloudAvailable,
  });

  @override
  Widget build(BuildContext context) => _SakhiAppView(
    createState: () => AppState(
      storage: storage,
      cloud: cloudAvailable ? CloudService(FirebaseFirestore.instance) : null,
      demo: false,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) =>
      _SakhiAppView(createState: () => AppState());
}

class _SakhiAppView extends StatelessWidget {
  final AppState Function() createState;

  const _SakhiAppView({required this.createState});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => createState(),
    child: MaterialApp(
      title: 'SAKHI',
      debugShowCheckedModeBanner: false,
      theme: sakhiTheme(),
      home: const RootShell(),
    ),
  );
}
