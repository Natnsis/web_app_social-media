import 'package:equatable/equatable.dart';

class NewMember extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime joinedAt;

  const NewMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, joinedAt];
}
