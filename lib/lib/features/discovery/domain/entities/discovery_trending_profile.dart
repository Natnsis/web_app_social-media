import 'package:equatable/equatable.dart';

class DiscoveryTrendingProfile extends Equatable {
  final String id;
  final String name;
  final int followerCount;
  final String? avatarUrl;

  const DiscoveryTrendingProfile({
    required this.id,
    required this.name,
    required this.followerCount,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, followerCount, avatarUrl];
}
