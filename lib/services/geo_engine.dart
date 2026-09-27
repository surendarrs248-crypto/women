import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';

typedef PositionCb = void Function(double lat, double lng, double accuracy);

class GeoEngine {
  final PositionCb onPosition;
  final void Function(String message) onError;

  GeoEngine({required this.onPosition, required this.onError});

  bool demo = true;
  bool frozen = false;
  List<double> offset = [0, 0];
  int _index = 0;
  Timer? _timer;
  StreamSubscription<Position>? _subscription;
  final Random _random = Random();
  double? _lastLat;
  double? _lastLng;
  late final List<LatLng> _demoPath = _interpolate();

  static List<LatLng> _interpolate() {
    final points = <LatLng>[];
    for (var i = 0; i < routeAnchors.length - 1; i++) {
      final start = routeAnchors[i];
      final end = routeAnchors[i + 1];
      for (var step = 0; step < 8; step++) {
        points.add(LatLng(
          start.latitude + (end.latitude - start.latitude) * step / 8,
          start.longitude + (end.longitude - start.longitude) * step / 8,
        ));
      }
    }
    points.add(routeAnchors.last);
    return points;
  }

  void start() {
    stop();
    if (demo) {
      _timer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
        if (frozen && _lastLat != null && _lastLng != null) {
          onPosition(_lastLat!, _lastLng!, 5);
          return;
        }
        final point = _demoPath[_index % _demoPath.length];
        _index++;
        double jitter() => (_random.nextDouble() - .5) * .00016;
        _lastLat = point.latitude + offset[0] + jitter();
        _lastLng = point.longitude + offset[1] + jitter();
        onPosition(_lastLat!, _lastLng!, 5);
      });
    } else {
      _startReal();
    }
  }

  Future<void> _startReal() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('location permission denied');
      }
      _subscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).listen(
        (position) {
          _lastLat = position.latitude;
          _lastLng = position.longitude;
          onPosition(position.latitude, position.longitude, position.accuracy);
        },
        onError: (Object error) => _fail('$error'),
      );
    } catch (error) {
      _fail('$error');
    }
  }

  void _fail(String error) {
    onError('GPS unavailable ($error); switching to demo');
    demo = true;
    start();
  }

  void setDemo(bool value) {
    demo = value;
    _index = 0;
    offset = [0, 0];
    frozen = false;
    start();
  }

  void resetSims() {
    offset = [0, 0];
    frozen = false;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _subscription?.cancel();
    _subscription = null;
  }
}