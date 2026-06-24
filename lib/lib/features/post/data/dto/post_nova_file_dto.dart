/// Media file nested under a post (`files[]` in `GET /v1/posts`).
class PostNovaFileDto {
  final String id;
  final String? novaFileId;
  final String? novaVideoId;
  final String name;
  final String mimeType;
  final int size;
  final String? novaUrl;
  final String status;
  final String mediaType;

  const PostNovaFileDto({
    required this.id,
    this.novaFileId,
    this.novaVideoId,
    required this.name,
    required this.mimeType,
    this.size = 0,
    this.novaUrl,
    this.status = '',
    this.mediaType = '',
  });

  factory PostNovaFileDto.fromJson(Map<String, dynamic> json) {
    return PostNovaFileDto(
      id: json['id']?.toString() ?? '',
      novaFileId: json['novaFileId']?.toString(),
      novaVideoId: json['novaVideoId']?.toString(),
      name: json['name'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      size: _int(json['size']),
      novaUrl: json['novaUrl'] as String?,
      status: json['status'] as String? ?? '',
      mediaType: json['mediaType'] as String? ?? '',
    );
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
