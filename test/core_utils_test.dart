import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:women/core/utils.dart';

void main() {
  test('calculates haversine distance in metres', () {
    final distance = hav(const LatLng(0, 0), const LatLng(0, 0.001));

    expect(distance, closeTo(111.2, 0.2));
  });

  test('measures distance from a point to a route segment', () {
    final distance = segDist(
      const LatLng(0.001, 0.005),
      const LatLng(0, 0),
      const LatLng(0, 0.01),
    );

    expect(distance, closeTo(110.54, 0.1));
  });

  test('formats distances, elapsed time, initials, and phone numbers', () {
    expect(fmtDist(850), '850 m');
    expect(fmtDist(1250), '1.25 km');
    expect(fmtEla(const Duration(minutes: 2, seconds: 5)), '02:05');
    expect(initials('  Alex Morgan '), 'AM');
    expect(digitsOnly('+1 (555)-0100'), '15550100');
    expect(telSafe('+1 (555)-0100'), '+15550100');
  });
}