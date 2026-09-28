import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';
import '../models/track_point.dart';

class AlertPath {
  final List<TrackPoint> points;
  final bool active;

  const AlertPath(this.points, this.active);
}

class SakhiMap extends StatefulWidget {
  final double height;
  final double zoom;
  final LatLng? victim;
  final List<LatLng> trail;
  final List<AlertPath> alertPaths;
  final List<List<double>> heat;
  final bool showHelp;
  final bool follow;
  final LatLng? routeFrom;
  final LatLng? routeTo;
  final LatLng? dest;
  final int fitStamp;
  final ValueChanged<HelpSpot>? onHelpTap;

  const SakhiMap({
    super.key,
    required this.height,
    this.zoom = 13,
    this.victim,
    this.trail = const [],
    this.alertPaths = const [],
    this.heat = const [],
    this.showHelp = false,
    this.follow = false,
    this.routeFrom,
    this.routeTo,
    this.dest,
    this.fitStamp = 0,
    this.onHelpTap,
  });

  @override
  State<SakhiMap> createState() => _SakhiMapState();
}

class _SakhiMapState extends State<SakhiMap> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  @override
  void didUpdateWidget(covariant SakhiMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.follow &&
        widget.victim != null &&
        (!oldWidget.follow || oldWidget.victim != widget.victim)) {
      _followVictim();
    }
  }

  void _followVictim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final position = widget.victim;
      if (!mounted || !_mapReady || !widget.follow || position == null) return;
      _mapController.move(position, _mapController.camera.zoom);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.victim ?? widget.routeFrom ?? blr;
    final polylines = <Polyline>[
      if (widget.trail.length > 1)
        Polyline(points: widget.trail, color: C.rose, strokeWidth: 4),
      if (widget.routeFrom != null && widget.routeTo != null)
        Polyline(
          points: [widget.routeFrom!, widget.routeTo!],
          color: C.guard.withValues(alpha: .8),
          strokeWidth: 3,
          pattern: const StrokePattern.dotted(),
        ),
      for (final alert in widget.alertPaths)
        if (alert.points.length > 1)
          Polyline(
            points: [
              for (final point in alert.points) LatLng(point.lat, point.lng),
            ],
            color: alert.active ? C.rose : C.guard,
            strokeWidth: alert.active ? 4 : 2,
          ),
    ];
    final circles = <CircleMarker>[
      for (final point in widget.heat)
        if (point.length >= 3)
          CircleMarker(
            point: LatLng(point[0], point[1]),
            radius: 18 + point[2] * 28,
            useRadiusInMeter: false,
            color: C.rose.withValues(alpha: .08 + point[2] * .12),
            borderColor: C.rose.withValues(alpha: .25),
            borderStrokeWidth: 1,
          ),
    ];
    final markers = <Marker>[
      if (widget.victim != null)
        Marker(
          point: widget.victim!,
          width: 42,
          height: 42,
          child: const _MapPin(color: C.rose, icon: Icons.person_pin_circle),
        ),
      if (widget.dest != null)
        Marker(
          point: widget.dest!,
          width: 38,
          height: 38,
          child: const _MapPin(color: C.guard, icon: Icons.flag_rounded),
        ),
      if (widget.showHelp)
        for (final spot in helpSpots)
          Marker(
            point: spot.point,
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: widget.onHelpTap == null
                  ? null
                  : () => widget.onHelpTap!(spot),
              child: _MapPin(
                color: C.amber,
                icon: spot.type == 'Police'
                    ? Icons.local_police_rounded
                    : Icons.local_hospital_rounded,
              ),
            ),
          ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(C.r),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: widget.zoom,
                minZoom: 3,
                maxZoom: 19,
                onMapReady: () {
                  _mapReady = true;
                  if (widget.follow) _followVictim();
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              mapController: _mapController,
              children: [
                TileLayer(
                  urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  retinaMode: RetinaMode.isHighDensity(context),
                  userAgentPackageName: 'com.sakhi.women',
                ),
                if (circles.isNotEmpty) CircleLayer(circles: circles),
                if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                if (markers.isNotEmpty) MarkerLayer(markers: markers),
                const SimpleAttributionWidget(
                  source: Text('© OpenStreetMap contributors © CARTO'),
                ),
              ],
            ),
            Positioned(
              right: 10,
              top: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: C.night2.withValues(alpha: .9),
                  border: Border.all(color: C.line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Text('LIVE MAP', style: TextStyle(fontSize: 9)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _MapPin({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Center(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: C.night2,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: .3), blurRadius: 12),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 20, color: color),
      ),
    ),
  );
}
