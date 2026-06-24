import 'package:faithconnect/core/network/api_list_response.dart';

/// Geo center returned in nearby list `meta.center`.
class NearbyGeoCenter {
  final double latitude;
  final double longitude;

  const NearbyGeoCenter({
    required this.latitude,
    required this.longitude,
  });

  factory NearbyGeoCenter.fromJson(Map<String, dynamic> json) {
    return NearbyGeoCenter(
      latitude: _toDouble(json['latitude']) ?? 0,
      longitude: _toDouble(json['longitude']) ?? 0,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return null;
  }
}

/// Pagination + search context from `GET /v1/churches/nearby`.
class NearbyChurchesMeta {
  final ApiListMeta pagination;
  final NearbyGeoCenter? center;
  final double? radiusKm;

  const NearbyChurchesMeta({
    required this.pagination,
    this.center,
    this.radiusKm,
  });

  factory NearbyChurchesMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return NearbyChurchesMeta(
        pagination: ApiListMeta.fromJson(null),
      );
    }

    return NearbyChurchesMeta(
      pagination: ApiListMeta.fromJson(json),
      center: json['center'] is Map
          ? NearbyGeoCenter.fromJson(
              Map<String, dynamic>.from(json['center'] as Map),
            )
          : null,
      radiusKm: _toDouble(json['radiusKm']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return null;
  }
}
