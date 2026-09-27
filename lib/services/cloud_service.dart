import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../models/models.dart';

class RemoteAlert {
  final String id;
  final String victim;
  final String phone;
  final String status;
  final int startedAt;
  final LatLng? last;
  final int points;
  final int? batteryLevel;

  const RemoteAlert({
    required this.id,
    required this.victim,
    required this.phone,
    required this.status,
    required this.startedAt,
    this.last,
    this.points = 0,
    this.batteryLevel,
  });

  bool get active => status == 'active';

  factory RemoteAlert.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final lat = (data['lastLat'] as num?)?.toDouble();
    final lng = (data['lastLng'] as num?)?.toDouble();
    return RemoteAlert(
      id: doc.id,
      victim: data['victim'] as String? ?? '—',
      phone: data['phone'] as String? ?? '',
      status: data['status'] as String? ?? 'resolved',
      startedAt: (data['startedAt'] as num?)?.toInt() ?? 0,
      last: lat != null && lng != null ? LatLng(lat, lng) : null,
      points: (data['points'] as num?)?.toInt() ?? 0,
      batteryLevel: (data['batteryLevel'] as num?)?.toInt(),
    );
  }
}

class Watcher {
  final String id;
  final String name;
  final int lastSeen;

  const Watcher({required this.id, required this.name, required this.lastSeen});

  factory Watcher.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Watcher(
      id: doc.id,
      name: data['name'] as String? ?? 'Guardian',
      lastSeen: (data['lastSeen'] as num?)?.toInt() ?? 0,
    );
  }
}

enum ResponseStatus { onWay, called, cannotHelp, confirmedSafe }

class GuardianResponse {
  final String id;
  final String name;
  final ResponseStatus status;
  final int updatedAt;

  const GuardianResponse({
    required this.id,
    required this.name,
    required this.status,
    required this.updatedAt,
  });

  factory GuardianResponse.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return GuardianResponse(
      id: doc.id,
      name: data['name'] as String? ?? 'Guardian',
      status: ResponseStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => ResponseStatus.onWay,
      ),
      updatedAt: (data['updatedAt'] as num?)?.toInt() ?? 0,
    );
  }
}

class CloudService {
  final FirebaseFirestore db;

  CloudService(this.db);

  CollectionReference<Map<String, dynamic>> get _alerts =>
      db.collection('alerts');

  Future<void> pushSession(SosSession session) async {
    try {
      await _alerts.doc(session.id).set({
        'victim': session.victim,
        'phone': session.phone,
        'status': session.status,
        'startedAt': session.startedAt,
        'points': session.path.length,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> pushPoint(String id, TrackPoint point,
      {bool updateParent = false}) async {
    try {
      await _alerts.doc(id).collection('locations').add(point.toJson());
      if (updateParent) {
        await _alerts.doc(id).set({
          'lastLat': point.lat,
          'lastLng': point.lng,
          'points': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  Future<void> pushEvent(String id, SosEvent event) async {
    try {
      await _alerts.doc(id).collection('events').add({
        ...event.toJson(),
        'at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  Future<void> pushBattery(String id, int level) async {
    try {
      await _alerts.doc(id).set(
        {'batteryLevel': level},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  Future<void> resolve(String id) async {
    try {
      await _alerts.doc(id).set({
        'status': 'resolved',
        'resolvedAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> addReport(UnsafeReport report) async {
    try {
      await db.collection('reports').add(report.toJson());
    } catch (_) {}
  }

  Stream<RemoteAlert?> alertDoc(String id) => _alerts
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? RemoteAlert.fromDoc(doc) : null);

  Stream<List<TrackPoint>> alertLocations(String id) => _alerts
      .doc(id)
      .collection('locations')
      .orderBy('t')
      .limitToLast(600)
      .snapshots()
      .map((query) => query.docs
          .map((doc) => TrackPoint.fromJson(doc.data()))
          .toList());

  Stream<List<SosEvent>> alertEvents(String id) => _alerts
      .doc(id)
      .collection('events')
      .orderBy('at')
      .limitToLast(60)
      .snapshots()
      .map((query) => query.docs
          .map((doc) => SosEvent.fromJson(doc.data()))
          .toList());

  Stream<List<RemoteAlert>> alertsStream() => _alerts
      .orderBy('startedAt', descending: true)
      .limit(25)
      .snapshots()
      .map((query) => query.docs.map(RemoteAlert.fromDoc).toList());

  Future<List<TrackPoint>> fetchPath(String id) async {
    try {
      final query = await _alerts
          .doc(id)
          .collection('locations')
          .orderBy('t')
          .limitToLast(600)
          .get();
      return query.docs.map((doc) => TrackPoint.fromJson(doc.data())).toList();
    } catch (_) {
      return [];
    }
  }

  CollectionReference<Map<String, dynamic>> _watchers(String alertId) =>
      _alerts.doc(alertId).collection('watchers');

  Future<void> joinWatch(String alertId, String watcherId, String name) async {
    try {
      await _watchers(alertId).doc(watcherId).set({
        'name': name,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  Future<void> heartbeatWatch(String alertId, String watcherId) async {
    try {
      await _watchers(alertId).doc(watcherId).update({
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  Future<void> leaveWatch(String alertId, String watcherId) async {
    try {
      await _watchers(alertId).doc(watcherId).delete();
    } catch (_) {}
  }

  Stream<List<Watcher>> watchersStream(String alertId) => _watchers(alertId)
      .snapshots()
      .map((query) => query.docs.map(Watcher.fromDoc).toList());

  CollectionReference<Map<String, dynamic>> _responses(String alertId) =>
      _alerts.doc(alertId).collection('responses');

  Future<void> setResponse(
    String alertId,
    String guardianId,
    String name,
    ResponseStatus status,
  ) async {
    try {
      await _responses(alertId).doc(guardianId).set({
        'name': name,
        'status': status.name,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  Stream<List<GuardianResponse>> responsesStream(String alertId) =>
      _responses(alertId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((query) => query.docs.map(GuardianResponse.fromDoc).toList());

  Future<void> registerGuardianToken(String token) async {
    try {
      await db.collection('guardian_tokens').doc(token).set({
        'token': token,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  Future<void> unregisterGuardianToken(String token) async {
    try {
      await db.collection('guardian_tokens').doc(token).delete();
    } catch (_) {}
  }
}