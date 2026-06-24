import 'package:faithconnect/core/utils/media_url_resolver.dart';

/// Church owner nested in `GET /v1/churches/:id`.
class ChurchOwnerApiDto {
  final String id;
  final String userId;
  final String name;
  final String? avatarUrl;

  const ChurchOwnerApiDto({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
  });

  factory ChurchOwnerApiDto.fromJson(Map<String, dynamic> json) {
    final resolvedId = json['id']?.toString() ?? '';
    return ChurchOwnerApiDto(
      id: resolvedId,
      userId: resolvedId,
      name: json['fullName'] as String? ??
          json['name'] as String? ??
          'Owner',
      avatarUrl: MediaUrlResolver.normalize(
        json['avatarUrl'] as String?,
        imageOnly: true,
      ),
    );
  }
}
