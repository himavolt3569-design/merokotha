import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String npr(num amount) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return 'NPR ${formatter.format(amount)}';
  }

  static String nprShort(num amount) {
    if (amount >= 100000) {
      return 'NPR ${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return 'NPR ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'NPR $amount';
  }

  static String date(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // HH:mm — used in chat message timestamps
  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String dateShort(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(date);
  }

  static String distance(double km) {
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)}m';
    return '${km.toStringAsFixed(1)}km';
  }

  static String phone(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    }
    return raw;
  }
}
