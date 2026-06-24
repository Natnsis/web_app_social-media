import 'package:equatable/equatable.dart';

/// Query params for `GET /v1/posts` (page, limit, sortBy, sortOrder, search).
class PostsQueryFilter extends Equatable {
  static const int defaultPage = 1;
  static const int defaultLimit = 20;
  static const int maxLimit = 100;
  static const String defaultSortOrder = 'desc';

  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;
  final String? search;
  final String? churchId;

  const PostsQueryFilter({
    this.page = defaultPage,
    this.limit = defaultLimit,
    this.sortBy,
    this.sortOrder = defaultSortOrder,
    this.search,
    this.churchId,
  });

  factory PostsQueryFilter.defaults() => const PostsQueryFilter();

  PostsQueryFilter copyWith({
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
    String? search,
    String? churchId,
    bool clearSortBy = false,
    bool clearSearch = false,
    bool clearChurchId = false,
  }) {
    return PostsQueryFilter(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      sortOrder: sortOrder ?? this.sortOrder,
      search: clearSearch ? null : (search ?? this.search),
      churchId: clearChurchId ? null : (churchId ?? this.churchId),
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

    final query = search?.trim();
    if (query != null && query.isNotEmpty) {
      params['search'] = query;
    }

    final cId = churchId?.trim();
    if (cId != null && cId.isNotEmpty) {
      params['churchId'] = cId;
    }

    return params;
  }

  @override
  List<Object?> get props => [page, limit, sortBy, sortOrder, search, churchId];
}
