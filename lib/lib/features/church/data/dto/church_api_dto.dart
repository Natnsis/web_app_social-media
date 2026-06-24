import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/campaign/data/dto/campaign_api_dto.dart';
import 'package:faithconnect/features/chat/data/dto/group_api_dto.dart';
import 'package:faithconnect/features/church/data/dto/church_member_api_dto.dart';
import 'package:faithconnect/features/church/data/dto/church_owner_api_dto.dart';
import 'package:faithconnect/features/church/data/models/church_profile_model.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_nearby_church.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_suggested_church.dart';
import 'package:faithconnect/features/post/data/dto/post_api_dto.dart';

/// Church object from `GET /v1/churches` and `GET /v1/churches/:id`.
class ChurchApiDto {
  final String id;
  final String? userId;
  final String name;
  final String? slug;
  final String? description;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? websiteUrl;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? verificationStatus;
  final bool isActive;
  final int followerCount;
  final int campaignCount;
  final int postCount;
  final int shortsCount;
  final int groupsCount;
  final double? distanceKm;
  final bool isFollowingByMe;
  final List<PostApiDto> recentPosts;
  final List<CampaignApiDto> recentCampaigns;
  final List<GroupApiDto> recentGroups;
  final List<ChurchMemberApiDto> moderators;
  final ChurchOwnerApiDto? owner;

  const ChurchApiDto({
    required this.id,
    this.userId,
    required this.name,
    this.slug,
    this.description,
    this.logoUrl,
    this.coverImageUrl,
    this.websiteUrl,
    this.phoneNumber,
    this.email,
    this.address,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.verificationStatus,
    this.isActive = true,
    this.followerCount = 0,
    this.campaignCount = 0,
    this.postCount = 0,
    this.shortsCount = 0,
    this.groupsCount = 0,
    this.distanceKm,
    this.isFollowingByMe = false,
    this.recentPosts = const [],
    this.recentCampaigns = const [],
    this.recentGroups = const [],
    this.moderators = const [],
    this.owner,
  });

  factory ChurchApiDto.fromJson(Map<String, dynamic> json) {
    final count = json['_count'];
    final countMap = count is Map
        ? Map<String, dynamic>.from(count)
        : null;

    return ChurchApiDto(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String? ?? json['logo_url'] as String?,
      coverImageUrl:
          json['coverImageUrl'] as String? ?? json['cover_image_url'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      verificationStatus: json['verificationStatus'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      followerCount: _int(countMap?['followers'] ?? json['followerCount']),
      campaignCount: _int(countMap?['campaigns']),
      postCount: _int(countMap?['posts']),
      shortsCount: _int(countMap?['shorts']),
      groupsCount: _int(countMap?['groups']),
      distanceKm: _toDouble(json['distanceKm'] ?? json['distance_km']),
      isFollowingByMe: _parseFollowingFlag(json),
      recentPosts: _parseList(json['recentPosts'], PostApiDto.fromJson),
      recentCampaigns:
          _parseList(json['recentCampaigns'], CampaignApiDto.fromJson),
      recentGroups: _parseList(json['recentGroups'], GroupApiDto.fromJson),
      moderators: _parseList(json['moderators'], ChurchMemberApiDto.fromJson),
      owner: _parseOwner(json['owner']),
    );
  }

  static ChurchOwnerApiDto? _parseOwner(dynamic value) {
    final map = _asMap(value);
    if (map == null) return null;
    return ChurchOwnerApiDto.fromJson(map);
  }

  static List<T> _parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (value is! List) return const [];
    return value
        .map((entry) => _asMap(entry))
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
  }

  /// `GET /v1/churches/nearby` and church detail may return any of these keys.
  static bool _parseFollowingFlag(Map<String, dynamic> json) {
    for (final key in [
      'isFollowing',
      'is_following',
      'isFollowingByMe',
      'is_following_by_me',
      'isFollowedByMe',
      'is_followed_by_me',
    ]) {
      if (_parseBool(json[key])) return true;
    }
    return false;
  }

  static bool _parseBool(dynamic value) {
    if (value == true) return true;
    if (value == false || value == null) return false;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return null;
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  String get locationLabel {
    final parts = <String>[
      if (address != null && address!.trim().isNotEmpty) address!.trim(),
      if (city != null && city!.trim().isNotEmpty) city!.trim(),
      if (country != null && country!.trim().isNotEmpty) country!.trim(),
    ];
    return parts.isEmpty ? '' : parts.join(', ');
  }

  bool get isVerified =>
      verificationStatus?.toUpperCase() == 'APPROVED';

  String? get displayImageUrl =>
      MediaUrlResolver.normalize(coverImageUrl, imageOnly: true) ??
      MediaUrlResolver.normalize(logoUrl, imageOnly: true);

  String? get displayAvatarUrl =>
      MediaUrlResolver.normalize(logoUrl, imageOnly: true);

  ChurchProfileModel toProfileModel({bool? isFollowing}) {
    return ChurchProfileModel(
      id: id,
      name: name,
      bio: (description ?? '').trim(),
      bannerUrl: MediaUrlResolver.normalize(coverImageUrl, imageOnly: true),
      avatarUrl: displayAvatarUrl,
      isVerified: isVerified,
      locationLabel: locationLabel.isEmpty ? null : locationLabel,
      isFollowing: isFollowing ?? isFollowingByMe,
    );
  }

  DiscoveryNearbyChurch toNearbyChurch({bool? isFollowing}) {
    return DiscoveryNearbyChurch(
      id: id,
      name: name,
      slug: slug ?? '',
      description: description,
      location: locationLabel.isEmpty ? (city ?? '') : locationLabel,
      address: address,
      city: city,
      country: country,
      imageUrl: displayImageUrl,
      avatarUrl: displayAvatarUrl,
      logoUrl: logoUrl,
      coverImageUrl: coverImageUrl,
      isFollowing: isFollowing ?? isFollowingByMe,
      distanceKm: distanceKm,
      latitude: latitude,
      longitude: longitude,
      verificationStatus: verificationStatus,
      isActive: isActive,
      followerCount: followerCount,
    );
  }

  DiscoverySuggestedChurch toSuggestedChurch() {
    return DiscoverySuggestedChurch(
      id: id,
      name: name,
      location: locationLabel.isEmpty ? (city ?? '') : locationLabel,
      imageUrl: displayImageUrl ?? '',
    );
  }

  /// Parses a single church from list or detail response bodies.
  static ChurchApiDto? parseSingle(dynamic body) {
    final root = _asMap(body);
    if (root == null) return null;

    final data = _asMap(root['data']) ?? root;
    if (data.containsKey('id') || data.containsKey('name')) {
      return ChurchApiDto.fromJson(data);
    }

    final nested = _asMap(data['church']);
    if (nested != null) return ChurchApiDto.fromJson(nested);

    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
