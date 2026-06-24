import 'package:equatable/equatable.dart';

class SearchedUser extends Equatable {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? phoneNumber;

  const SearchedUser({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, fullName, avatarUrl, phoneNumber];
}
