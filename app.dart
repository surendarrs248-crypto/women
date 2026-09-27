// ============================================================
// SAKHI · app root — wires AppState (with optional cloud) into
// the widget tree and applies the night theme.
// ============================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/core/theme.dart';
import 'lib/screens/root_shell.dart';
import 'lib/services/cloud_service.dart';
import 'lib/services/storage_service.dart';
import 'lib/state/app_state.dart';

class SakhiApp extends StatelessWidget {
  final StorageService storage;
  final bool cloudAvailable;
  const SakhiApp(
      {super.key, required this.storage, required this.cloudAvailable});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(
        storage: storage,
        cloud:
            cloudAvailable ? CloudService(FirebaseFirestore.instance) : null,
      ),
      child: MaterialApp(
        title: 'SAKHI',
        debugShowCheckedModeBanner: false,
        theme: sakhiTheme(),
        home: const RootShell(),
      ),
    );
  }
}
