class EvidenceItem {
  final String label;
  final String? path;
  final String type;

  const EvidenceItem(this.label, this.path, this.type);

  Map<String, dynamic> toJson() => {
        'label': label,
        'path': path,
        'type': type,
      };

  factory EvidenceItem.fromJson(Map<String, dynamic> json) => EvidenceItem(
        json['label'] as String? ?? '',
        json['path'] as String?,
        json['type'] as String? ?? 'audio',
      );
}