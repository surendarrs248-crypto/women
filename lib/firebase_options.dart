import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'Firebase is configured for web only. Run `flutterfire configure` to add native platform settings.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBmH2u5dHOuU5C1SGKJoRne44o_8MRVXB0',
    appId: '1:830916708294:web:b22aaf4bb4bab6a87c94c7',
    messagingSenderId: '830916708294',
    projectId: 'women-10335',
    authDomain: 'women-10335.firebaseapp.com',
    storageBucket: 'women-10335.firebasestorage.app',
    measurementId: 'G-3LS4QYCLXX',
  );
}
