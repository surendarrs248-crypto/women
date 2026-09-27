import 'evidence_item.dart';
import 'sos_event.dart';
import 'track_point.dart';

class SosSession {
  final String id;
  String victim;
  String phone;
  String status;
  final int startedAt;
  int? resolvedAt;
  final List<TrackPoint> path;
  final List<SosEvent> events;
  final List<EvidenceItem> evidence;
  final bool remote;

  SosSession({
    required this.id,
    required this.victim,
    required this.phone,
    required this.status,
    required this.startedAt,
    this.resolvedAt,
    List<TrackPoint>? path,
    List<SosEvent>? events,
    List<EvidenceItem>? evidence,
    this.remote = false,
  })  : path = path ?? [],
        events = events ?? [],
        evidence = evidence ?? [];

  bool get active => status == 'active';

  Map<String, dynamic> toJson() => {
        'id': id,
        'victim': victim,
        'phone': phone,
        'status': status,
        'startedAt': startedAt,
        'resolvedAt': resolvedAt,
        'path': path.map((point) => point.toJson()).toList(),
        'events': events.map((event) => event.toJson()).toList(),
        'evidence': evidence.map((item) => item.toJson()).toList(),
      };

  factory SosSession.fromJson(Map<String, dynamic> json) => SosSession(
        id: json['id'] as String? ?? '—',
        victim: json['victim'] as String? ?? '—',
        phone: json['phone'] as String? ?? '',
        status: json['status'] as String? ?? 'resolved',
        startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
        resolvedAt: (json['resolvedAt'] as num?)?.toInt(),
        path: _path(json['path']),
        events: (json['events'] as List? ?? [])
            .map((event) =>
                SosEvent.fromJson(Map<String, dynamic>.from(event as Map)))
            .toList(),
        evidence: (json['evidence'] as List? ?? [])
            .map((item) => EvidenceItem.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList(),
      );

  static List<TrackPoint> _path(dynamic raw) {
    final points = <TrackPoint>[];
    for (final entry in (raw as List? ?? [])) {
      if (entry is List && entry.length >= 2) {
        points.add(TrackPoint(
          (entry[0] as num).toDouble(),
          (entry[1] as num).toDouble(),
          0,
          0,
        ));
      } else if (entry is Map) {
        points.add(TrackPoint.fromJson(Map<String, dynamic>.from(entry)));
      }
    }
    return points;
  }
}