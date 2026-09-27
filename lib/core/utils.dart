import 'dart:math';

import 'package:latlong2/latlong.dart';

/// Haversine distance in metres.
double hav(LatLng a, LatLng b) {
  const rEarth = 6371e3;
  double radians(double degrees) => degrees * pi / 180;

  final dLa = radians(b.latitude - a.latitude);
  final dLo = radians(b.longitude - a.longitude);
  final h = pow(sin(dLa / 2), 2) +
      cos(radians(a.latitude)) *
          cos(radians(b.latitude)) *
          pow(sin(dLo / 2), 2);
  return 2 * rEarth * asin(sqrt(h.toDouble()));
}

/// Metres from point [p] to segment a→b using a city-scale approximation.
double segDist(LatLng p, LatLng a, LatLng b) {
  final kx = 111320 * cos(p.latitude * pi / 180);
  const ky = 110540.0;
  final px = (p.longitude - a.longitude) * kx;
  final py = (p.latitude - a.latitude) * ky;
  final bx = (b.longitude - a.longitude) * kx;
  final by = (b.latitude - a.latitude) * ky;
  final l2 = bx * bx + by * by;
  var t = l2 == 0 ? 0.0 : (px * bx + py * by) / l2;
  t = t.clamp(0.0, 1.0).toDouble();
  return sqrt(pow(px - t * bx, 2) + pow(py - t * by, 2));
}

String fmtDist(double m) =>
    m < 1000 ? '${m.round()} m' : '${(m / 1000).toStringAsFixed(2)} km';

String two(int n) => n.toString().padLeft(2, '0');

String fmtEla(Duration d) {
  final seconds = d.inSeconds;
  return '${two(seconds ~/ 60)}:${two(seconds % 60)}';
}

/// Current time formatted as HH:mm:ss.
String clockNow() {
  final date = DateTime.now();
  return '${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
}

String hhmm(DateTime d) => '${two(d.hour)}:${two(d.minute)}';

String initials(String? name) {
  final trimmed = (name ?? '?').trim();
  if (trimmed.isEmpty) return '?';
  return trimmed
      .split(RegExp(r'\s+'))
      .map((word) => word[0])
      .take(2)
      .join()
      .toUpperCase();
}

String digitsOnly(String phone) => phone.replaceAll(RegExp(r'[^\d]'), '');

String telSafe(String phone) => phone.replaceAll(RegExp(r'[^\d+]'), '');