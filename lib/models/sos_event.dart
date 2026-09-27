class SosEvent {
  final String t;
  final String msg;
  final String kind;

  const SosEvent(this.t, this.msg, this.kind);

  Map<String, dynamic> toJson() => {
        't': t,
        'msg': msg,
        'kind': kind,
      };

  factory SosEvent.fromJson(Map<String, dynamic> json) => SosEvent(
        json['t'] as String? ?? '',
        json['msg'] as String? ?? '',
        json['kind'] as String? ?? 'info',
      );
}