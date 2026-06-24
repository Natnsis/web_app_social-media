/// User row from `GET /v1/users/search`.
class UserSearchApiDto {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? phoneNumber;

  const UserSearchApiDto({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.phoneNumber,
  });

  factory UserSearchApiDto.fromJson(Map<String, dynamic> json) {
    return UserSearchApiDto(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] as String? ??
          json['name'] as String? ??
          '',
      avatarUrl: json['avatarUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
}
