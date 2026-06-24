import 'package:share_plus/share_plus.dart';

abstract final class ContentShare {
  ContentShare._();

  static Future<void> shareText({
    required String text,
    String? subject,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await SharePlus.instance.share(
      ShareParams(text: trimmed, subject: subject),
    );
  }

  static Future<void> sharePost({
    required String authorName,
    required String content,
  }) {
    return shareText(
      text: _joinNonEmpty([authorName, content]),
      subject: 'FaithConnect',
    );
  }

  static Future<void> shareShort({
    required String authorName,
    required String caption,
  }) {
    return shareText(
      text: _joinNonEmpty([authorName, caption]),
      subject: 'FaithConnect Short',
    );
  }

  static Future<void> shareCampaign({
    required String title,
    required String organizationName,
    required String description,
  }) {
    return shareText(
      text: _joinNonEmpty([title, organizationName, description]),
      subject: title,
    );
  }

  static String _joinNonEmpty(List<String> parts) {
    return parts
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join('\n\n');
  }
}
