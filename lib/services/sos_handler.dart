import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'offline_alert_queue.dart';
import 'sms_fallback_service.dart';

class SosHandler {
  SosHandler({this.firestore});

  final FirebaseFirestore? firestore;
  final SmsFallbackService _sms = SmsFallbackService();
  final OfflineAlertQueue _queue = OfflineAlertQueue();

  Future<void> triggerSos({
    required String alertId,
    required String userName,
    required String phone,
    required List<String> guardianNumbers,
    Position? cachedPosition,
  }) async {
    final startedAt = DateTime.now().millisecondsSinceEpoch;
    final position = await _sms.currentPosition(cachedPosition: cachedPosition);
    final message = _sms.buildSosMessage(
      userName: userName,
      timestamp: DateTime.fromMillisecondsSinceEpoch(startedAt),
      position: position,
    );
    final smsFuture = _sms.sendEmergencySms(
      guardianNumbers: guardianNumbers,
      message: message,
    );

    final alert = QueuedAlert(
      id: alertId,
      userName: userName,
      phone: phone,
      latitude: position?.latitude,
      longitude: position?.longitude,
      startedAt: startedAt,
      guardianNumbers: List.of(guardianNumbers),
      smsMessage: message,
    );

    var queued = false;
    try {
      await _queue.enqueue(alert);
      queued = true;
    } catch (_) {}

    var synced = false;
    final database = firestore;
    if (database != null) {
      try {
        await database.collection('alerts').doc(alertId).set({
          'victim': userName,
          'phone': phone,
          'status': 'active',
          'startedAt': startedAt,
          'points': 0,
          'lastLat': position?.latitude,
          'lastLng': position?.longitude,
          'guardianNumbers': guardianNumbers,
          'source': 'sos',
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 5));
        synced = true;
      } catch (_) {}
    }

    final failedSmsNumbers = await smsFuture;
    alert
      ..synced = synced
      ..pendingSmsNumbers = _sms.supportsDirectSms ? failedSmsNumbers : [];
    if (synced && alert.pendingSmsNumbers.isEmpty) {
      if (queued) {
        try {
          await _queue.remove(alertId);
        } catch (_) {
          // A stale synced entry is harmless and can be cleared by background sync.
        }
      }
      return;
    }

    try {
      await _queue.enqueue(alert);
    } catch (_) {
      // Local persistence can fail independently; do not undo the SOS session.
    }
  }
}