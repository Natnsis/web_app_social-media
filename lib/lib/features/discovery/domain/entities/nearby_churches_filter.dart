import 'package:equatable/equatable.dart';

/// Query filters for `GET /v1/churches/nearby`.
class NearbyChurchesFilter extends Equatable {
  static const int defaultRadiusKm = 50;
  static const int defaultPage = 1;
  static const int defaultPageSize = 20;
  static const int minRadiusKm = 1;
  static const int maxRadiusKm = 500;
  static const int maxPageSize = 50;

  /// Preset radius options shown in the filter sheet (km).
  static const List<int> radiusPresets = [10, 25, 50, 100, 250];

  final int radiusKm;
  final int page;
  final int pageSize;

  const NearbyChurchesFilter({
    this.radiusKm = defaultRadiusKm,
    this.page = defaultPage,
    this.pageSize = defaultPageSize,
  });

  factory NearbyChurchesFilter.defaults() => const NearbyChurchesFilter();

  /// Full list on [NearbyChurchesPage] — `GET /v1/churches/nearby` with max page size.
  factory NearbyChurchesFilter.forListPage({
    int radiusKm = defaultRadiusKm,
    int page = defaultPage,
  }) =>
      NearbyChurchesFilter(
        radiusKm: radiusKm,
        page: page,
        pageSize: maxPageSize,
      );

  NearbyChurchesFilter copyWith({
    int? radiusKm,
    int? page,
    int? pageSize,
  }) {
    return NearbyChurchesFilter(
      radiusKm: radiusKm ?? this.radiusKm,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  int get clampedRadiusKm => radiusKm.clamp(minRadiusKm, maxRadiusKm);

  int get clampedPageSize => pageSize.clamp(1, maxPageSize);

  String get radiusLabel => '$clampedRadiusKm km';

  Map<String, dynamic> toQueryParameters() => {
        'radiusKm': clampedRadiusKm,
        'page': page < 1 ? 1 : page,
        'pageSize': clampedPageSize,
      };

  @override
  List<Object?> get props => [radiusKm, page, pageSize];
}
