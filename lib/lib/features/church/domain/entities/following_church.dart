import 'package:equatable/equatable.dart';

/// Church returned by `GET /v1/churches/me/following`.
class FollowingChurch extends Equatable {
  final String id;
  final String name;
  final String? slug;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? city;
  final bool isVerified;
  final int followerCount;

  const FollowingChurch({
    required this.id,
    required this.name,
    this.slug,
    this.logoUrl,
    this.coverImageUrl,
    this.city,
    this.isVerified = false,
    this.followerCount = 0,
  });

  String get locationLabel => city?.trim().isNotEmpty == true ? city!.trim() : '';

  String? get displayImageUrl => coverImageUrl ?? logoUrl;

  String? get displayAvatarUrl => logoUrl;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        logoUrl,
        coverImageUrl,
        city,
        isVerified,
        followerCount,
      ];
}
