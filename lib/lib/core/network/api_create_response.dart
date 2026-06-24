/// Parses create endpoints: `{ "success": true, "data": { "id": "..." } }`.
abstract final class ApiCreateResponse {
  ApiCreateResponse._();

  static String parseId(dynamic body) {
    final root = _asMap(body);
    if (root == null) {
      throw const FormatException('Invalid create post response.');
    }

    final data = _asMap(root['data']);
    if (data != null) {
      final id = data['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }

    final directId = root['id']?.toString();
    if (directId != null && directId.isNotEmpty) return directId;

    throw const FormatException('Create post response did not include an id.');
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
