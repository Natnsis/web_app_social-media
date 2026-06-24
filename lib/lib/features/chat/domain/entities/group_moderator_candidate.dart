import 'package:equatable/equatable.dart';

class GroupModeratorCandidate extends Equatable {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;

  const GroupModeratorCandidate({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, role, avatarUrl];
}
