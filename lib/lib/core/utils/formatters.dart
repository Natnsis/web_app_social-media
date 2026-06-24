import 'package:intl/intl.dart';

String formatCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
  if (count >= 1000) {
    final value = count / 1000;
    return value >= 10
        ? '${value.toStringAsFixed(0)}k'
        : '${value.toStringAsFixed(1)}k';
  }
  return count.toString();
}

/// Compact relative time for comments (e.g. `1h`, `45m`).
String formatShortTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays >= 1) return '${diff.inDays}d';
  if (diff.inHours >= 1) return '${diff.inHours}h';
  if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
  return '${diff.inSeconds}s';
}

String formatTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays >= 7) {
    return DateFormat('MMM d').format(dateTime);
  }
  if (diff.inDays >= 1) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
  if (diff.inHours >= 1) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }
  if (diff.inMinutes >= 1) {
    return '${diff.inMinutes} min ago';
  }
  return 'Just now';
}

String formatCurrencyEtb(
  double amount, {
  bool showPlusSign = false,
}) {
  final sign = amount < 0
      ? '-'
      : (showPlusSign && amount > 0)
          ? '+'
          : '';
  final formatted = NumberFormat('#,##0.00').format(amount.abs());
  return '$sign$formatted ETB';
}

String formatChatMessageTime(DateTime dateTime) {
  return DateFormat('h:mm a').format(dateTime);
}

String formatChatDateSeparator(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay =
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDay == today) return 'TODAY';
  if (messageDay == today.subtract(const Duration(days: 1))) {
    return 'YESTERDAY';
  }
  return DateFormat('MMM d, yyyy').format(dateTime).toUpperCase();
}
