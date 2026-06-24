import 'package:equatable/equatable.dart';

class LatLngModel extends Equatable {
  final double latitude;
  final double longitude;

  const LatLngModel({required this.latitude, required this.longitude});

  factory LatLngModel.fromJson(Map<String, dynamic> json) {
    return LatLngModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [latitude, longitude];
}

class NearbyChurchesMeta extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final LatLngModel? center;
  final double? radiusKm;

  const NearbyChurchesMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.center,
    this.radiusKm,
  });

  factory NearbyChurchesMeta.fromJson(Map<String, dynamic> json) {
    return NearbyChurchesMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      center: json['center'] != null ? LatLngModel.fromJson(json['center']) : null,
      radiusKm: json['radiusKm'] != null ? (json['radiusKm'] as num).toDouble() : null,
    );
  }

  @override
  List<Object?> get props => [
        page,
        limit,
        total,
        totalPages,
        hasNextPage,
        hasPreviousPage,
        center,
        radiusKm,
      ];
}
