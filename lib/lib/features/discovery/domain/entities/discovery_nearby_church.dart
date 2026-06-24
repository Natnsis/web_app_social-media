import 'package:equatable/equatable.dart';

class DiscoveryNearbyChurch extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? location; // Keep for backward compatibility or map from address/city
  final String? address;
  final String? city;
  final String? country;
  final String? imageUrl;
  final String? avatarUrl;
  final String? logoUrl;
  final String? coverImageUrl;
  final bool isFollowing;
  final double? distanceKm;
  final double? latitude;
  final double? longitude;
  final String? verificationStatus;
  final bool isActive;
  final int followerCount;

  const DiscoveryNearbyChurch({
    required this.id,
    required this.name,
    this.slug = '',
    this.description,
    this.location,
    this.address,
    this.city,
    this.country,
    this.imageUrl,
    this.avatarUrl,
    this.logoUrl,
    this.coverImageUrl,
    this.isFollowing = false,
    this.distanceKm,
    this.latitude,
    this.longitude,
    this.verificationStatus,
    this.isActive = true,
    this.followerCount = 0,
  });

  String? get distanceLabel {
    final km = distanceKm;
    if (km == null) return null;
    if (km < 1) return '${(km * 1000).round()} m away';
    return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km away';
  }

  DiscoveryNearbyChurch copyWith({
    bool? isFollowing,
    double? distanceKm,
  }) {
    return DiscoveryNearbyChurch(
      id: id,
      name: name,
      slug: slug,
      description: description,
      location: location,
      address: address,
      city: city,
      country: country,
      imageUrl: imageUrl,
      avatarUrl: avatarUrl,
      logoUrl: logoUrl,
      coverImageUrl: coverImageUrl,
      isFollowing: isFollowing ?? this.isFollowing,
      distanceKm: distanceKm ?? this.distanceKm,
      latitude: latitude,
      longitude: longitude,
      verificationStatus: verificationStatus,
      isActive: isActive,
      followerCount: followerCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        location,
        address,
        city,
        country,
        imageUrl,
        avatarUrl,
        logoUrl,
        coverImageUrl,
        isFollowing,
        distanceKm,
        latitude,
        longitude,
        verificationStatus,
        isActive,
        followerCount,
      ];
}
