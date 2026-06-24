/// Scryper item from church scryper endpoints.
class ScryperApiDto {
  final String id;
  final String churchId;
  final String verse;
  final String reference;
  final bool isActive;
  final String? churchName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScryperApiDto({
    required this.id,
    this.churchId = '',
    required this.verse,
    required this.reference,
    this.isActive = true,
    this.churchName,
    this.createdAt,
    this.updatedAt,
  });

  factory ScryperApiDto.fromJson(Map<String, dynamic> json) {
    final church = json['church'];
    final churchMap =
        church is Map ? Map<String, dynamic>.from(church) : null;

    return ScryperApiDto(
      id: json['id']?.toString() ?? '',
      churchId: json['churchId']?.toString() ??
          churchMap?['id']?.toString() ??
          '',
      verse: json['verse'] as String? ??
          json['verseText'] as String? ??
          json['text'] as String? ??
          '',
      reference: json['reference'] as String? ??
          json['bibleReference'] as String? ??
          '',
      isActive: json['isActive'] as bool? ?? true,
      churchName: churchMap?['name'] as String?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  static ScryperApiDto parseResponse(dynamic body) {
    final root = _asMap(body) ?? {};
    final data = _asMap(root['data']) ?? root;
    return ScryperApiDto.fromJson(data);
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
