/// Request body for `POST /v1/churches/{id}/members`.
class AssignChurchModeratorDto {
  final String userId;

  const AssignChurchModeratorDto({required this.userId});

  Map<String, dynamic> toJson() => {'userId': userId.trim()};
}
