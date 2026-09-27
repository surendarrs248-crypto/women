class UnsafeReport {
  final double lat;
  final double lng;
  final double w;
  final int t;

  const UnsafeReport(this.lat, this.lng, this.w, this.t);

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'w': w,
        't': t,
      };

  factory UnsafeReport.fromJson(Map<String, dynamic> json) => UnsafeReport(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
        (json['w'] as num?)?.toDouble() ?? .7,
        (json['t'] as num?)?.toInt() ?? 0,
      );
}