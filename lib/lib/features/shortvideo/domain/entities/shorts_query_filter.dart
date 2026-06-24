import 'package:equatable/equatable.dart';

/// Query params for `GET /v1/shorts` (page, limit, sortBy, sortOrder).
class ShortsQueryFilter extends Equatable {
  static const int defaultPage = 1;
  static const int defaultLimit = 20;
  static const int maxLimit = 100;
  static const String defaultSortOrder = 'desc';

  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  const ShortsQueryFilter({
    this.page = defaultPage,
    this.limit = defaultLimit,
    this.sortBy,
    this.sortOrder = defaultSortOrder,
  });

  factory ShortsQueryFilter.defaults() => const ShortsQueryFilter();

  ShortsQueryFilter copyWith({
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
    bool clearSortBy = false,
  }) {
    return ShortsQueryFilter(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  int get clampedLimit => limit.clamp(1, maxLimit);

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page < 1 ? 1 : page,
      'limit': clampedLimit,
    };

    final sortField = sortBy?.trim();
    if (sortField != null && sortField.isNotEmpty) {
      params['sortBy'] = sortField;
    }

    final order = sortOrder?.trim();
    if (order != null && order.isNotEmpty) {
      params['sortOrder'] = order;
    }

    return params;
  }

  @override
  List<Object?> get props => [page, limit, sortBy, sortOrder];
}
