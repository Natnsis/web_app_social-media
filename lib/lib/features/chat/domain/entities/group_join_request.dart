import 'package:equatable/equatable.dart';

class GroupJoinRequest extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? avatarUrl;
  final DateTime requestedAt;

  const GroupJoinRequest({
    required this.id,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.requestedAt,
  });

  @override
  List<Object?> get props => [id, userId, userName, avatarUrl, requestedAt];
}
