import 'package:equatable/equatable.dart';

/// Query params for `GET /v1/campaigns/following`.
class FollowingCampaignsQueryFilter extends Equatable {
  static const int defaultPage = 1;
  static const int defaultLimit = 20;
  static const int maxLimit = 100;
  static const String defaultSortOrder = 'desc';

  final int page;
  final int limit;
  final String sortOrder;
  final String? sortField;
  final String? search;
  final String? status;
  final String? churchId;

  const FollowingCampaignsQueryFilter({
    this.page = defaultPage,
    this.limit = defaultLimit,
    this.sortOrder = defaultSortOrder,
    this.sortField,
    this.search,
    this.status,
    this.churchId,
  });

  factory FollowingCampaignsQueryFilter.defaults() =>
      const FollowingCampaignsQueryFilter();

  FollowingCampaignsQueryFilter copyWith({
    int? page,
    int? limit,
    String? sortOrder,
    String? sortField,
    String? search,
    String? status,
    String? churchId,
    bool clearSortField = false,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearChurchId = false,
  }) {
    return FollowingCampaignsQueryFilter(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortOrder: sortOrder ?? this.sortOrder,
      sortField: clearSortField ? null : (sortField ?? this.sortField),
      search: clearSearch ? null : (search ?? this.search),
      status: clearStatus ? null : (status ?? this.status),
      churchId: clearChurchId ? null : (churchId ?? this.churchId),
    );
  }

  int get clampedLimit => limit.clamp(1, maxLimit);

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page < 1 ? 1 : page,
      'limit': clampedLimit,
      'sortOrder':
          sortOrder.trim().isEmpty ? defaultSortOrder : sortOrder.trim(),
    };

    final field = sortField?.trim();
    if (field != null && field.isNotEmpty) {
      params['sortField'] = field;
    }

    final query = search?.trim();
    if (query != null && query.isNotEmpty) {
      params['search'] = query;
    }

    final statusValue = status?.trim();
    if (statusValue != null && statusValue.isNotEmpty) {
      params['status'] = statusValue;
    }

    final cId = churchId?.trim();
    if (cId != null && cId.isNotEmpty) {
      params['churchId'] = cId;
    }

    return params;
  }

  @override
  List<Object?> get props =>
      [page, limit, sortOrder, sortField, search, status, churchId];
}
