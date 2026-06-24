import 'package:equatable/equatable.dart';

class ChurchProfileGroup extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final int memberCount;
  final bool isPrivate;

  const ChurchProfileGroup({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    this.memberCount = 0,
    this.isPrivate = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        coverImageUrl,
        memberCount,
        isPrivate,
      ];
}
