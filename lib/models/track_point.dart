class TrackPoint {
  final double lat;
  final double lng;
  final int t;
  final double spd;

  const TrackPoint(this.lat, this.lng, this.t, this.spd);

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        't': t,
        'spd': spd,
      };

  factory TrackPoint.fromJson(Map<String, dynamic> json) => TrackPoint(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
        (json['t'] as num?)?.toInt() ?? 0,
        (json['spd'] as num?)?.toDouble() ?? 0,
      );
}