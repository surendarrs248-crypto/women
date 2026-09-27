import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  StreamSubscription<AccelerometerEvent>? _subscription;
  int _hits = 0;
  int _lastHit = 0;

  bool get armed => _subscription != null;

  void start(void Function() onTrigger) {
    if (_subscription != null) return;
    _subscription = accelerometerEventStream().listen((event) {
      final magnitude = event.x.abs() + event.y.abs() + event.z.abs();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      if (magnitude > 42 && timestamp - _lastHit > 250) {
        _lastHit = timestamp;
        _hits++;
        if (_hits >= 3) {
          _hits = 0;
          onTrigger();
        }
        Timer(const Duration(milliseconds: 1600), () {
          if (_hits > 0) _hits--;
        });
      }
    }, onError: (_) {});
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _hits = 0;
  }
}