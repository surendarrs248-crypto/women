// ============================================================
// SAKHI — Women Safety Alert & Tracking System (PRJ_496)
// Flutter + Firebase.  Entry point.
//
// Firebase is OPTIONAL: if `flutterfire configure` hasn't been
// run (or init fails), the app runs fully in local mode using
// SharedPreferences — exactly like the HTML prototype.
// ============================================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'lib/firebase_options.dart';
import 'lib/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await StorageService.init();

  bool cloudAvailable = false;
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    // Anonymous auth so Firestore rules can require an authed user.
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    cloudAvailable = true;
    debugPrint('SAKHI: Firebase online — cloud sync enabled.');
  } catch (e) {
    cloudAvailable = false;
    debugPrint('SAKHI: running local-only (Firebase not configured). $e');
  }

  runApp(SakhiApp(storage: storage, cloudAvailable: cloudAvailable));
}
