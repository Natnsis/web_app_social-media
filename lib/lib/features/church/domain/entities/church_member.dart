import 'package:equatable/equatable.dart';

class ChurchMember extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? avatarUrl;
  final String? role;

  const ChurchMember({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.role,
  });

  @override
  List<Object?> get props => [id, userId, name, avatarUrl, role];
}
