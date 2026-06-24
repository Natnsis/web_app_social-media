/// Normalizes phone numbers for API requests (Ethiopia +251 default).
abstract final class PhoneNormalizer {
  PhoneNormalizer._();

  static String normalize(String raw) {
    final trimmed = raw.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (trimmed.startsWith('+')) return trimmed;
    if (trimmed.startsWith('0')) return '+251${trimmed.substring(1)}';
    if (trimmed.startsWith('251')) return '+$trimmed';
    return '+$trimmed';
  }

  static String normalizeEmailOrPhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.contains('@')) return trimmed.toLowerCase();
    return normalize(trimmed);
  }

  static bool looksLikePhone(String value) => !value.trim().contains('@');
}
