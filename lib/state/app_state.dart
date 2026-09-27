import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../services/cloud_service.dart';
import '../services/geo_engine.dart';
import '../services/shake_detector.dart';
import '../services/storage_service.dart';

enum AppRole { user, guardian, admin }

class AlertCardData {
  final String id;
  final String victim;
  final int startedAt;
  final int points;
  final bool active;
  final bool remote;

  const AlertCardData({
    required this.id,
    required this.victim,
    required this.startedAt,
    required this.points,
    required this.active,
    this.remote = false,
  });
}

class GuardianTarget {
  final String id;
  final String victim;
  final String phone;
  final int startedAt;
  final bool active;
  final bool remote;
  final List<TrackPoint> path;
  final List<SosEvent> events;

  const GuardianTarget({
    required this.id,
    required this.victim,
    required this.phone,
    required this.startedAt,
    required this.active,
    required this.path,
    required this.events,
    this.remote = false,
  });
}

class DemoGeoState {
  bool demo = true;
}

class AppState extends ChangeNotifier {
  final StorageService? storage;
  final CloudService? cloud;
  AppRole role = AppRole.user;
  int tabIndex = 0;
  int destIndex = 0;
  int etaMinutes = 25;
  int journeyFitStamp = 0;
  bool showReportSheet = false;
  bool sirenOn = false;
  bool strobeOn = false;
  bool motionArmed = false;
  bool toastVisible = false;
  String toastMsg = '';
  String jStateText = 'On route';
  String jClockText = '00:00';
  String accText = 'DEMO';
  String? remoteWatchId;
  final DemoGeoState geo = DemoGeoState();
  final UserProfile profile = UserProfile(name: 'Ananya', phone: '+919900112233');
  final List<GuardianContact> contacts = [];
  final List<SosSession> _sessions = [];
  final List<UnsafeReport> _reports = [];
  final List<RemoteAlert> _remoteAlerts = [];
  RemoteAlert? _remoteAlert;
  List<TrackPoint> _remotePath = [];
  List<SosEvent> _remoteEvents = [];
  late final GeoEngine _geoEngine;
  final ShakeDetector _shakeDetector = ShakeDetector();
  StreamSubscription<List<RemoteAlert>>? _remoteAlertsSub;
  StreamSubscription<RemoteAlert?>? _remoteAlertSub;
  StreamSubscription<List<TrackPoint>>? _remotePathSub;
  StreamSubscription<List<SosEvent>>? _remoteEventsSub;
  LatLng? lastPos = blr;
  JourneyPlan? journey;
  Timer? _journeyTimer;
  Timer? _toastTimer;
  Timer? _persistTimer;
  int _alertCounter = 1234;
  double spd = 0;

  AppState({this.storage, this.cloud}) {
    _restoreSavedState();
    _geoEngine = GeoEngine(
      onPosition: (lat, lng, accuracy) {
        lastPos = LatLng(lat, lng);
        accText = '${accuracy.round()} m';
        spd = geo.demo ? 3.2 : spd;
        if (journey?.stillSince == null) _appendPoint();
        _checkJourney();
        notifyListeners();
      },
      onError: (message) {
        geo.demo = true;
        accText = 'DEMO';
        toast(message);
      },
    );
    _geoEngine.demo = geo.demo;
    _geoEngine.start();
    if (cloud != null) {
      _remoteAlertsSub = cloud!.alertsStream().listen(
        (alerts) {
          _remoteAlerts
            ..clear()
            ..addAll(alerts);
          notifyListeners();
        },
        onError: (_) => toast('Could not load cloud alerts'),
      );
    }
  }

  bool get cloudEnabled => cloud != null;
  SosSession? get session => _sessions.isEmpty ? null : _sessions.last;
  bool get sosActive => session?.active ?? false;
  int get statActive => _sessions.where((item) => item.active).length +
      _remoteAlerts
          .where((alert) =>
              alert.active && !_sessions.any((item) => item.id == alert.id))
          .length;
  int get statResolved => _sessions.where((item) => !item.active).length +
      _remoteAlerts
          .where((alert) =>
              !alert.active && !_sessions.any((item) => item.id == alert.id))
          .length;
  int get statGuardians => contacts.length;
  double get pathDistance {
    final points = session?.path ?? const <TrackPoint>[];
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += hav(
        LatLng(points[i - 1].lat, points[i - 1].lng),
        LatLng(points[i].lat, points[i].lng),
      );
    }
    return total;
  }

  List<List<double>> get heatPoints => [
        ...seedHeat,
        for (final report in _reports) [report.lat, report.lng, report.w],
      ];

  List<AlertCardData> get alertCards => [
        for (final item in _sessions.reversed)
          AlertCardData(
            id: item.id,
            victim: item.victim,
            startedAt: item.startedAt,
            points: item.path.length,
            active: item.active,
          ),
        for (final alert in _remoteAlerts)
          if (!_sessions.any((item) => item.id == alert.id))
            AlertCardData(
              id: alert.id,
              victim: alert.victim,
              startedAt: alert.startedAt,
              points: alert.points,
              active: alert.active,
              remote: true,
            ),
      ];

  GuardianTarget? get guardianTarget {
    if (remoteWatchId != null) {
      final alert = _remoteAlert;
      if (alert == null) return null;
      return GuardianTarget(
        id: alert.id,
        victim: alert.victim,
        phone: alert.phone,
        startedAt: alert.startedAt,
        active: alert.active,
        path: _remotePath,
        events: _remoteEvents,
        remote: true,
      );
    }
    final item = session;
    if (item == null) return null;
    return GuardianTarget(
      id: item.id,
      victim: item.victim,
      phone: item.phone,
      startedAt: item.startedAt,
      active: item.active,
      path: item.path,
      events: item.events,
      remote: item.remote,
    );
  }

  void setRole(AppRole value) {
    role = value;
    notifyListeners();
  }

  void setTab(int value) {
    tabIndex = value;
    notifyListeners();
  }

  void toggleDemo() {
    geo.demo = !geo.demo;
    _geoEngine.setDemo(geo.demo);
    accText = geo.demo ? 'DEMO' : 'GPS';
    toast(geo.demo ? 'Demo location enabled' : 'Requesting real GPS');
    notifyListeners();
  }

  void armSos() {
    if (sosActive) {
      resolveSos();
      return;
    }
    _alertCounter++;
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = 'BLR-$_alertCounter';
    final next = SosSession(
      id: id,
      victim: profile.name,
      phone: profile.phone,
      status: 'active',
      startedAt: now,
      path: [],
      events: [SosEvent(hhmm(DateTime.now()), 'SOS alert started', 'alert')],
    );
    _sessions.add(next);
    _persistSoon();
    if (cloud != null) unawaited(cloud!.pushSession(next));
    _appendPoint();
    toast('SOS active · $id');
    notifyListeners();
  }

  void silentHoldTrigger() => armSos();

  void resolveSos() {
    final active = session;
    if (active == null || !active.active) {
      final remote = _remoteAlerts.where((alert) => alert.active).firstOrNull;
      if (remote != null && cloud != null) {
        unawaited(cloud!.resolve(remote.id));
      }
      return;
    }
    active.status = 'resolved';
    active.resolvedAt = DateTime.now().millisecondsSinceEpoch;
    active.events.add(SosEvent(hhmm(DateTime.now()), 'Alert marked safe', 'safe'));
    _persistSoon();
    if (cloud != null) unawaited(cloud!.resolve(active.id));
    toast('Alert marked resolved');
    notifyListeners();
  }

  void guardianResolve() {
    final target = guardianTarget;
    if (target?.remote == true && cloud != null) {
      unawaited(cloud!.resolve(target!.id));
    } else {
      resolveSos();
    }
  }

  void focusAlert(AlertCardData alert) {
    if (alert.remote) {
      setRole(AppRole.guardian);
      watchRemote(alert.id);
    } else if (alert.active) {
      setRole(AppRole.guardian);
    }
  }

  void resolveAlert(AlertCardData alert) {
    if (alert.remote && cloud != null) {
      unawaited(cloud!.resolve(alert.id));
      return;
    }
    for (final item in _sessions) {
      if (item.id == alert.id && item.active) {
        item.status = 'resolved';
        item.resolvedAt = DateTime.now().millisecondsSinceEpoch;
        item.events.add(
          SosEvent(hhmm(DateTime.now()), 'Alert marked safe', 'safe'),
        );
        _persistSoon();
        notifyListeners();
        return;
      }
    }
  }

  List<TrackPoint> pathFor(AlertCardData alert) {
    for (final item in _sessions) {
      if (item.id == alert.id) return item.path;
    }
    return remoteWatchId == alert.id ? _remotePath : const [];
  }

  void addContact(String name, String phone) {
    final cleanName = name.trim();
    final cleanPhone = phone.trim();
    if (cleanName.isEmpty || cleanPhone.isEmpty) {
      toast('Enter a name and phone number');
      return;
    }
    contacts.add(GuardianContact(n: cleanName, p: cleanPhone));
    _persistSoon();
    toast('Guardian added');
    notifyListeners();
  }

  void starContact(int index) {
    final makePrimary = !contacts[index].star;
    for (final contact in contacts) {
      contact.star = false;
    }
    contacts[index].star = makePrimary;
    _persistSoon();
    notifyListeners();
  }

  void delContact(int index) {
    contacts.removeAt(index);
    _persistSoon();
    notifyListeners();
  }

  void setProfileName(String value) {
    profile.name = value;
    _persistSoon();
    notifyListeners();
  }

  void setProfilePhone(String value) {
    profile.phone = value;
    _persistSoon();
    notifyListeners();
  }

  void watchRemote(String id) {
    final normalized = id.trim().toUpperCase();
    if (normalized.isEmpty) {
      toast('Enter an alert ID');
      return;
    }
    final service = cloud;
    if (service == null) {
      toast('Cloud sync is not configured');
      return;
    }
    _cancelRemoteWatch();
    remoteWatchId = normalized;
    _remoteAlert = null;
    _remotePath = [];
    _remoteEvents = [];
    _remoteAlertSub = service.alertDoc(normalized).listen(
      (alert) {
        _remoteAlert = alert;
        if (alert == null) toast('Alert $normalized was not found');
        notifyListeners();
      },
      onError: (_) => toast('Could not watch alert $normalized'),
    );
    _remotePathSub = service.alertLocations(normalized).listen(
      (points) {
        _remotePath = points;
        notifyListeners();
      },
      onError: (_) => toast('Could not load the alert trail'),
    );
    _remoteEventsSub = service.alertEvents(normalized).listen(
      (events) {
        _remoteEvents = events;
        notifyListeners();
      },
      onError: (_) => toast('Could not load alert events'),
    );
    notifyListeners();
  }

  void stopRemoteWatch() {
    _cancelRemoteWatch();
    remoteWatchId = null;
    _remoteAlert = null;
    _remotePath = [];
    _remoteEvents = [];
    notifyListeners();
  }

  void _cancelRemoteWatch() {
    _remoteAlertSub?.cancel();
    _remotePathSub?.cancel();
    _remoteEventsSub?.cancel();
    _remoteAlertSub = null;
    _remotePathSub = null;
    _remoteEventsSub = null;
  }

  void setDest(int index) {
    destIndex = index;
    notifyListeners();
  }

  void setEta(int value) {
    etaMinutes = value.clamp(1, 240);
    notifyListeners();
  }

  void toggleJourney() {
    if (journey != null) {
      journey = null;
      _geoEngine.resetSims();
      _journeyTimer?.cancel();
      jStateText = 'On route';
      jClockText = '00:00';
      toast('Journey ended');
    } else {
      final option = destOptions[destIndex];
      journey = JourneyPlan(
        from: lastPos ?? blr,
        to: option.point,
        label: option.label,
        etaMin: etaMinutes,
        startedAt: DateTime.now().millisecondsSinceEpoch,
      );
      journeyFitStamp++;
      jStateText = 'On route to ${option.label}';
      _journeyTimer?.cancel();
      _journeyTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final started = journey?.startedAt;
        if (started != null) {
          jClockText = fmtEla(Duration(
            milliseconds: DateTime.now().millisecondsSinceEpoch - started,
          ));
          notifyListeners();
        }
      });
      toast('Journey started');
    }
    notifyListeners();
  }

  void simulateDeviation() {
    jStateText = 'Route deviation detected';
    toast('Deviation detected');
    armSos();
    notifyListeners();
  }

  void simulateStop() {
    final current = journey;
    if (current == null) return;
    current.stillSince = DateTime.now().millisecondsSinceEpoch;
    _geoEngine.frozen = true;
    jStateText = 'Movement stopped';
    toast('Stop detected');
    notifyListeners();
  }

  void toggleSiren() {
    sirenOn = !sirenOn;
    notifyListeners();
  }

  void toggleStrobe() {
    strobeOn = !strobeOn;
    notifyListeners();
  }

  void startFakeCall() => toast('Fake call is not configured on this build');

  void capturePhoto() => toast('Camera access is not configured on this build');

  void enableMotion() {
    motionArmed = true;
    _shakeDetector.start(silentHoldTrigger);
    toast('Motion trigger enabled for this session');
    notifyListeners();
  }

  void openReportSheet() {
    showReportSheet = true;
    notifyListeners();
  }

  void closeReportSheet() {
    showReportSheet = false;
    notifyListeners();
  }

  void addReport(double weight) {
    final point = lastPos ?? blr;
    _reports.add(UnsafeReport(
      point.latitude,
      point.longitude,
      weight,
      DateTime.now().millisecondsSinceEpoch,
    ));
    _persistSoon();
    if (cloud != null) unawaited(cloud!.addReport(_reports.last));
    toast('Safety report added');
    closeReportSheet();
  }

  void toast(String message) {
    toastMsg = message;
    toastVisible = true;
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 3), () {
      toastVisible = false;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> launch(Uri uri) async {
    try {
      if (!await launchUrl(uri)) toast('Could not open ${uri.scheme} link');
    } catch (_) {
      toast('Could not open ${uri.scheme} link');
    }
  }

  Future<void> copyTrackInfo() async {
    final link = 'SAKHI alert ${session?.id ?? '—'}';
    await Clipboard.setData(ClipboardData(text: link));
    toast('Track details copied');
  }

  Future<void> shareLocation() async {
    final point = lastPos;
    if (point == null) return;
    final location = '${point.latitude}, ${point.longitude}';
    await Clipboard.setData(ClipboardData(text: location));
    toast('Location copied');
  }

  Future<void> exportAlerts() async {
    final json = jsonEncode(_sessions.map((item) => item.toJson()).toList());
    await Clipboard.setData(ClipboardData(text: json));
    toast('Alert JSON copied to clipboard');
  }

  void runDemoTour() {
    if (!sosActive) armSos();
    setRole(AppRole.admin);
    toast('Demo alert started');
  }

  void _appendPoint() {
    final position = lastPos;
    final current = session;
    if (position == null || current == null || !current.active) return;
    final trackPoint = TrackPoint(
      position.latitude,
      position.longitude,
      DateTime.now().millisecondsSinceEpoch,
      spd,
    );
    current.path.add(trackPoint);
    if (current.path.length > 600) current.path.removeAt(0);
    _persistSoon();
    if (cloud != null) {
      unawaited(cloud!.pushPoint(current.id, trackPoint, updateParent: true));
    }
  }

  void _restoreSavedState() {
    final saved = storage?.load();
    if (saved == null) return;
    final profileData = saved['profile'];
    if (profileData is Map) {
      final restored = UserProfile.fromJson(
        Map<String, dynamic>.from(profileData),
      );
      profile
        ..name = restored.name
        ..phone = restored.phone;
    }
    final savedContacts = saved['contacts'];
    if (savedContacts is List) {
      contacts
        ..clear()
        ..addAll(savedContacts.whereType<Map>().map(
          (item) => GuardianContact.fromJson(Map<String, dynamic>.from(item)),
        ));
    }
    final savedSessions = saved['sessions'];
    if (savedSessions is List) {
      _sessions
        ..clear()
        ..addAll(savedSessions.whereType<Map>().map(
          (item) => SosSession.fromJson(Map<String, dynamic>.from(item)),
        ));
    }
    final savedReports = saved['reports'];
    if (savedReports is List) {
      _reports
        ..clear()
        ..addAll(savedReports.whereType<Map>().map(
          (item) => UnsafeReport.fromJson(Map<String, dynamic>.from(item)),
        ));
    }
  }

  Map<String, dynamic> _storageSnapshot() => {
        'profile': profile.toJson(),
        'contacts': contacts.map((contact) => contact.toJson()).toList(),
        'sessions': _sessions.map((item) => item.toJson()).toList(),
        'reports': _reports.map((item) => item.toJson()).toList(),
      };

  void _persistSoon() {
    if (storage == null) return;
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 400), () {
      unawaited(storage!.save(_storageSnapshot()));
    });
  }

  void _checkJourney() {
    final current = journey;
    if (current == null) return;
    final startedAt = current.stillSince;
    if (startedAt != null &&
        DateTime.now().millisecondsSinceEpoch - startedAt > 30000 &&
        !sosActive) {
      jStateText = 'Stillness alert';
      armSos();
    }
  }

  @override
  void dispose() {
    _geoEngine.stop();
    _shakeDetector.stop();
    _remoteAlertsSub?.cancel();
    _cancelRemoteWatch();
    _journeyTimer?.cancel();
    _toastTimer?.cancel();
    _persistTimer?.cancel();
    if (storage != null) unawaited(storage!.save(_storageSnapshot()));
    super.dispose();
  }
}