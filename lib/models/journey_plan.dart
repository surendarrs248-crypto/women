import 'package:latlong2/latlong.dart';

class JourneyPlan {
  final LatLng from;
  final LatLng to;
  final String label;
  final int etaMin;
  final int startedAt;
  final double corridor;
  int? stillSince;

  JourneyPlan({
    required this.from,
    required this.to,
    required this.label,
    required this.etaMin,
    required this.startedAt,
    this.corridor = 250,
    this.stillSince,
  });
}