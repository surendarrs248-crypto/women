// ============================================================
// PLACEHOLDER — replace by running:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// That command generates the real DefaultFirebaseOptions for your
// Firebase project and overwrites this file.
//
// Until then this throws, main.dart catches it, and SAKHI runs in
// full LOCAL mode (SharedPreferences only) — exactly like the HTML
// prototype with CLOUD.enabled = false.
// ============================================================
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase not configured yet — run `flutterfire configure`. '
      'SAKHI will continue in local-only mode.',
    );
  }
}
