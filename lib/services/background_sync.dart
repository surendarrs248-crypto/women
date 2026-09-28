import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../firebase_options.dart';
import 'offline_alert_queue.dart';
import 'sms_fallback_service.dart';

const String syncTaskName = 'sakhi_sos_sync_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (task != syncTaskName) return true;

    try {
      await _initializeQueue();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await _syncQueuedAlerts();
      return true;
    } catch (_) {
      return false;
    }
  });
}

Future<void> _initializeQueue() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(QueuedAlertAdapter());
  }
  await Hive.openBox<QueuedAlert>(OfflineAlertQueue.boxName);
}

Future<void> _syncQueuedAlerts() async {
  final queue = OfflineAlertQueue();
  final unsynced = await queue.getUnsynced();
  final firestore = FirebaseFirestore.instance;
  final sms = SmsFallbackService();

  for (final alert in unsynced) {
    if (!alert.synced) {
      try {
        await firestore.collection('alerts').doc(alert.id).set({
          'victim': alert.userName,
          'phone': alert.phone,
          'status': 'active',
          'startedAt': alert.startedAt,
          'points': 0,
          'lastLat': alert.latitude,
          'lastLng': alert.longitude,
          'guardianNumbers': alert.guardianNumbers,
          'source': 'offline_queue_sync',
        }, SetOptions(merge: true));
        await queue.markSynced(alert);
      } catch (_) {
        continue;
      }
    }

    if (sms.supportsDirectSms && alert.pendingSmsNumbers.isNotEmpty) {
      try {
        alert.pendingSmsNumbers = await sms.sendEmergencySms(
          guardianNumbers: alert.pendingSmsNumbers,
          message: alert.smsMessage,
        );
        await alert.save();
      } catch (_) {
        continue;
      }
    }

    if (alert.synced && alert.pendingSmsNumbers.isEmpty) {
      await alert.delete();
    }
  }
}

Future<void> initBackgroundSync() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    syncTaskName,
    syncTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );
}