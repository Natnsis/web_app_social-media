/// Pagination block from list endpoints (`meta` in API responses).
class ApiListMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const ApiListMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory ApiListMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ApiListMeta(
        page: 1,
        limit: 20,
        total: 0,
        totalPages: 0,
        hasNextPage: false,
        hasPreviousPage: false,
      );
    }
    return ApiListMeta(
      page: _int(json['page'], 1),
      limit: _int(json['limit'], 20),
      total: _int(json['total'], 0),
      totalPages: _int(json['totalPages'], 0),
      hasNextPage: json['hasNextPage'] == true || json['hasNext'] == true,
      hasPreviousPage:
          json['hasPreviousPage'] == true || json['hasPrev'] == true,
    );
  }

  static int _int(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }
}

/// Standard list envelope: `{ "success": true, "data": [...], "meta": {...} }`.
class ApiListResponse<T> {
  final bool success;
  final List<T> data;
  final ApiListMeta meta;

  const ApiListResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  static ApiListResponse<T> parse<T>(
    dynamic body,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) {
    final items = _parseItems(body, itemFromJson);

    if (body is List) {
      return ApiListResponse<T>(
        success: true,
        data: items,
        meta: ApiListMeta(
          page: 1,
          limit: items.isEmpty ? 20 : items.length,
          total: items.length,
          totalPages: items.isEmpty ? 0 : 1,
          hasNextPage: false,
          hasPreviousPage: false,
        ),
      );
    }

    final root = _asMap(body) ?? {};
    final meta = _resolveMeta(root);
    final total = meta.total > 0 ? meta.total : items.length;

    return ApiListResponse<T>(
      success: root['success'] == true || items.isNotEmpty,
      data: items,
      meta: ApiListMeta(
        page: meta.page,
        limit: meta.limit,
        total: total,
        totalPages: meta.totalPages,
        hasNextPage: meta.hasNextPage,
        hasPreviousPage: meta.hasPreviousPage,
      ),
    );
  }

  static List<T> _parseItems<T>(
    dynamic body,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) {
    final rawList = extractRawList(body);
    final items = <T>[];

    for (final entry in rawList) {
      final map = _asMap(entry);
      if (map != null) items.add(itemFromJson(map));
    }

    return items;
  }

  /// Raw list items from standard list envelopes (`data`, `data.data`, `items`).
  static List<dynamic> extractRawList(dynamic body) {
    if (body is List) return body;

    final root = _asMap(body);
    if (root == null) return const [];

    final data = root['data'];
    if (data is List) return data;

    final nested = _asMap(data);
    if (nested != null) {
      final inner = nested['data'];
      if (inner is List) return inner;
      final items = nested['items'];
      if (items is List) return items;
    }

    final items = root['items'];
    if (items is List) return items;

    return const [];
  }

  static ApiListMeta _resolveMeta(Map<String, dynamic> root) {
    final topMeta = ApiListMeta.fromJson(_asMap(root['meta']));
    if (topMeta.total > 0) return topMeta;

    final nested = _asMap(root['data']);
    if (nested == null) return topMeta;

    final total = _int(nested['total'], 0);
    if (total <= 0) return topMeta;

    final take = _int(nested['take'], topMeta.limit);
    final skip = _int(nested['skip'], 0);
    final page = take > 0 ? (skip ~/ take) + 1 : 1;

    return ApiListMeta(
      page: page,
      limit: take,
      total: total,
      totalPages: take > 0 ? ((total + take - 1) ~/ take) : 0,
      hasNextPage: skip + take < total,
      hasPreviousPage: skip > 0,
    );
  }

  static int _int(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
